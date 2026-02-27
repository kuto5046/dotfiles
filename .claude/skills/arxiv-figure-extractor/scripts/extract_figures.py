#!/usr/bin/env python3
"""arXiv論文からFigure/TableのキャプションとimageファイルをTeX Sourceから抽出するスクリプト。

優先順位:
1. TeXソース (https://arxiv.org/e-print/<id>) からの抽出
   - キャプション・ラベル・画像ファイルを直接取得できる
2. PDF (https://arxiv.org/pdf/<id>) からの抽出（フォールバック）
   - テキストのみ（画像なし）

Usage:
    uv run ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py <arxiv-url-or-id> <output-dir>

    # PDFのみを使う場合:
    uv run --with pymupdf ~/.claude/skills/arxiv-figure-extractor/scripts/extract_figures.py <arxiv-url-or-id> <output-dir> --pdf-only
"""

import argparse
import gzip
import json
import re
import shutil
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path


# ============================================================
# arXiv ID パース
# ============================================================

def parse_arxiv_input(input_str: str) -> str:
    """arXiv URLまたはIDから論文IDを抽出する。"""
    input_str = input_str.strip().rstrip("/")
    arxiv_id_pattern = r"(\d{4}\.\d{4,5}(?:v\d+)?|[a-z-]+/\d{7}(?:v\d+)?)"

    for pattern in [
        rf"arxiv\.org/(?:abs|pdf|html|e-print)/({arxiv_id_pattern})",
        rf"alphaxiv\.org/abs/({arxiv_id_pattern})",
    ]:
        m = re.search(pattern, input_str, re.IGNORECASE)
        if m:
            return m.group(1)

    m = re.fullmatch(arxiv_id_pattern, input_str)
    if m:
        return m.group(0)

    raise ValueError(f"arXiv URLまたはIDを認識できません: {input_str}")


# ============================================================
# ダウンロード
# ============================================================

def _http_get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "arxiv-figure-extractor/2.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()


def download_tex_source(arxiv_id: str, dest: Path) -> bool:
    """arXiv TeXソース (e-print) をダウンロードする。成功時 True を返す。"""
    url = f"https://arxiv.org/e-print/{arxiv_id}"
    print(f"Downloading TeX source from {url} ...")
    try:
        data = _http_get(url)
        # HTMLが返ってきた場合は失敗扱い
        if data[:8].lstrip(b"\xef\xbb\xbf").lower().startswith((b"<!doctype", b"<html")):
            print("Warning: Got HTML response instead of archive", file=sys.stderr)
            return False
        dest.write_bytes(data)
        print(f"Downloaded {len(data):,} bytes -> {dest}")
        return True
    except Exception as e:
        print(f"Warning: TeX source download failed: {e}", file=sys.stderr)
        return False


def download_pdf(arxiv_id: str, dest: Path) -> bool:
    """arXiv PDFをダウンロードする。成功時 True を返す。"""
    url = f"https://arxiv.org/pdf/{arxiv_id}"
    print(f"Downloading PDF from {url} ...")
    try:
        data = _http_get(url)
        dest.write_bytes(data)
        print(f"Downloaded {len(data):,} bytes -> {dest}")
        return True
    except Exception as e:
        print(f"Error: PDF download failed: {e}", file=sys.stderr)
        return False


# ============================================================
# アーカイブ展開
# ============================================================

def extract_archive(archive_path: Path, extract_dir: Path) -> bool:
    """tar.gz / gzip 単体ファイルを展開する。成功時 True を返す。"""
    extract_dir.mkdir(parents=True, exist_ok=True)

    # tar (圧縮形式を自動検出) として試みる
    try:
        with tarfile.open(str(archive_path)) as tf:
            # パストラバーサル防止
            safe = [
                m for m in tf.getmembers()
                if ".." not in Path(m.name).parts and not m.name.startswith("/")
            ]
            tf.extractall(str(extract_dir), members=safe)
        print(f"Extracted archive to {extract_dir} ({len(safe)} files)")
        return True
    except (tarfile.TarError, EOFError, Exception):
        pass

    # 単一 gzip ファイルとして試みる
    try:
        with gzip.open(str(archive_path), "rb") as f:
            content = f.read()
        (extract_dir / "main.tex").write_bytes(content)
        print(f"Extracted single file to {extract_dir / 'main.tex'}")
        return True
    except Exception as e:
        print(f"Warning: Failed to extract archive: {e}", file=sys.stderr)
        return False


# ============================================================
# LaTeX パーシングユーティリティ
# ============================================================

def remove_comments(tex: str) -> str:
    """LaTeXコメント（%以降）を削除する（\\%は除く）。"""
    return re.sub(r"(?<!\\)%[^\n]*", "", tex)


def extract_brace_content(text: str, start: int) -> str:
    """start位置の'{' に対応するネストを考慮した内容を返す。"""
    if start >= len(text) or text[start] != "{":
        return ""
    depth = 1
    i = start + 1
    while i < len(text) and depth > 0:
        c = text[i]
        if c == "\\":
            i += 2  # エスケープ文字をスキップ
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        i += 1
    return text[start + 1 : i - 1] if depth == 0 else text[start + 1 :]


def find_environments(tex: str, env_base: str) -> list[str]:
    """\\begin{env} と \\begin{env*} 両方の環境内容を抽出する。"""
    results = []
    pos = 0
    begin_re = re.compile(rf"\\begin\{{{re.escape(env_base)}(\*?)\}}")

    while True:
        m = begin_re.search(tex, pos)
        if not m:
            break

        star = m.group(1)
        env_full = env_base + star
        content_start = m.end()
        depth = 1
        p = content_start

        inner_begin = re.compile(rf"\\begin\{{{re.escape(env_full)}\}}")
        inner_end = re.compile(rf"\\end\{{{re.escape(env_full)}\}}")

        while depth > 0 and p < len(tex):
            nb = inner_begin.search(tex, p)
            ne = inner_end.search(tex, p)
            if ne is None:
                break
            if nb and nb.start() < ne.start():
                depth += 1
                p = nb.end()
            else:
                depth -= 1
                if depth == 0:
                    results.append(tex[content_start : ne.start()])
                    pos = ne.end()
                    break
                p = ne.end()
        else:
            break

    return results


def extract_caption(env: str) -> str:
    """\\caption[...]{...} からキャプションテキストを抽出する。"""
    m = re.search(r"\\caption(?:\[[^\]]*\])?\{", env)
    if not m:
        return ""
    raw = extract_brace_content(env, m.end() - 1)
    # シンプルなLaTeXコマンドを除去して平文化
    text = re.sub(r"\\(?:textbf|textit|emph|text[a-z]*|mathrm|mathbf|mathit)\{([^}]*)\}", r"\1", raw)
    text = re.sub(r"\\(?:cite|ref|label|footnote|footnotemark)\{[^}]*\}", "", text)
    text = re.sub(r"\\[a-zA-Z]+\s*", " ", text)
    text = re.sub(r"[{}]", "", text)
    return re.sub(r"\s+", " ", text).strip()


def extract_label(env: str) -> str:
    """\\label{...} を抽出する。"""
    m = re.search(r"\\label\{([^}]+)\}", env)
    return m.group(1) if m else ""


def extract_includegraphics(env: str) -> list[str]:
    """\\includegraphics のパスを全て抽出する。"""
    paths = []
    for m in re.finditer(r"\\includegraphics(?:\[[^\]]*\])?\{", env):
        path = extract_brace_content(env, m.end() - 1).strip()
        if path:
            paths.append(path)
    return paths


# ============================================================
# ファイル解決
# ============================================================

IMAGE_EXTS = ["", ".pdf", ".eps", ".png", ".jpg", ".jpeg", ".PNG", ".JPG", ".JPEG", ".EPS"]


def resolve_image(img_path: str, tex_dir: Path) -> Path | None:
    """LaTeX内の画像パスを実ファイルパスに解決する。"""
    # 拡張子を付けて直接検索
    for ext in IMAGE_EXTS:
        candidate = tex_dir / (img_path + ext)
        if candidate.exists():
            return candidate.resolve()

    # ファイル名のみで再帰検索（ディレクトリ構造が異なる場合）
    name = Path(img_path).name
    for ext in IMAGE_EXTS:
        for found in tex_dir.rglob(name + ext):
            return found.resolve()

    return None


def find_main_tex(tex_dir: Path) -> Path | None:
    """\\documentclass を含むメインのTeXファイルを探す。"""
    tex_files = list(tex_dir.rglob("*.tex"))
    if not tex_files:
        return None
    # 階層が浅い順に検索
    for f in sorted(tex_files, key=lambda p: len(p.parts)):
        try:
            if r"\documentclass" in f.read_text(encoding="utf-8", errors="ignore"):
                return f
        except Exception:
            pass
    return tex_files[0]


def load_tex_recursive(path: Path, base: Path, visited: set | None = None) -> str:
    """TeXファイルを読み込み、\\input / \\include を再帰的に展開する。"""
    if visited is None:
        visited = set()
    key = path.resolve()
    if key in visited:
        return ""
    visited.add(key)

    try:
        content = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""

    def _expand(m: re.Match) -> str:
        name = m.group(1).strip()
        suffixes = [".tex", ""] if not name.endswith(".tex") else [""]
        for suf in suffixes:
            for d in [path.parent, base]:
                p = d / (name + suf)
                if p.exists():
                    return load_tex_recursive(p, base, visited)
        return m.group(0)

    content = re.sub(r"\\input\{([^}]+)\}", _expand, content)
    content = re.sub(r"\\include\{([^}]+)\}", _expand, content)
    return content


def collect_tex_content(tex_dir: Path) -> str:
    """TeXディレクトリから全ソース内容を収集する。"""
    main = find_main_tex(tex_dir)
    if main:
        print(f"Main TeX file: {main.relative_to(tex_dir)}")
        return load_tex_recursive(main, tex_dir)
    # フォールバック: 全 .tex を結合
    print("No main TeX file found, combining all .tex files")
    parts = []
    for f in sorted(tex_dir.rglob("*.tex")):
        try:
            parts.append(f.read_text(encoding="utf-8", errors="ignore"))
        except Exception:
            pass
    return "\n".join(parts)


# ============================================================
# TeXソースからの抽出
# ============================================================

def extract_from_tex(tex_dir: Path, output_dir: Path) -> dict:
    """TeXソースからfigure/tableのキャプション・画像を抽出する。"""
    images_dir = output_dir / "images"
    images_dir.mkdir(parents=True, exist_ok=True)

    tex = remove_comments(collect_tex_content(tex_dir))

    results = []
    fig_n = 0
    tbl_n = 0

    # figure 環境を処理（figure* も含む）
    for env in find_environments(tex, "figure"):
        fig_n += 1
        caption = extract_caption(env)
        label = extract_label(env)
        raw_paths = extract_includegraphics(env)

        saved = []
        for rp in raw_paths:
            src = resolve_image(rp, tex_dir)
            if src:
                dest = images_dir / f"figure_{fig_n:02d}_{Path(rp).stem}{src.suffix}"
                shutil.copy2(src, dest)
                saved.append(str(dest.relative_to(output_dir)))

        results.append({
            "kind": "figure",
            "number": fig_n,
            "label": label,
            "caption": caption,
            "image_files": saved,
        })
        print(f"  Figure {fig_n}: {caption[:70]}")
        for s in saved:
            print(f"    -> {s}")

    # table 環境を処理（table* も含む）
    for env in find_environments(tex, "table"):
        tbl_n += 1
        caption = extract_caption(env)
        label = extract_label(env)
        results.append({
            "kind": "table",
            "number": tbl_n,
            "label": label,
            "caption": caption,
            "image_files": [],
        })
        print(f"  Table {tbl_n}: {caption[:70]}")

    summary = {
        "source": "tex",
        "total_figures": fig_n,
        "total_tables": tbl_n,
        "items": results,
    }
    sp = output_dir / "figures_summary.json"
    sp.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nDone! {fig_n} figures, {tbl_n} tables.")
    print(f"Summary: {sp}")
    return summary


# ============================================================
# PDFからの抽出（フォールバック）
# ============================================================

def extract_from_pdf(pdf_path: Path, output_dir: Path) -> dict:
    """PDFからfigure/tableキャプションを抽出する（画像なし）。"""
    try:
        import pymupdf as _pmu  # type: ignore
    except ImportError:
        try:
            import fitz as _pmu  # type: ignore
        except ImportError:
            print(
                "Error: pymupdf not installed.\n"
                "Run with: uv run --with pymupdf ... --pdf-only",
                file=sys.stderr,
            )
            return {"source": "pdf", "total_figures": 0, "total_tables": 0, "items": []}

    output_dir.mkdir(parents=True, exist_ok=True)
    doc = _pmu.open(str(pdf_path))
    caption_re = re.compile(r"(Figure|Fig\.|Table)\s+(\d+)[.:]\s*(.*)", re.IGNORECASE)

    results = []
    seen: set[tuple[str, int]] = set()

    for page_num in range(doc.page_count):
        page = doc[page_num]
        for block in page.get_text("dict")["blocks"]:
            if block["type"] != 0:
                continue
            text = " ".join(
                span["text"]
                for line in block.get("lines", [])
                for span in line.get("spans", [])
            ).strip()
            m = caption_re.search(text)
            if not m:
                continue
            kind = "table" if m.group(1).lower() == "table" else "figure"
            number = int(m.group(2))
            key = (kind, number)
            if key in seen:
                continue
            seen.add(key)
            results.append({
                "kind": kind,
                "number": number,
                "label": "",
                "caption": m.group(3).strip(),
                "image_files": [],
            })
            print(f"  {kind.capitalize()} {number}: {m.group(3)[:60]}")

    doc.close()

    fig_n = sum(1 for r in results if r["kind"] == "figure")
    tbl_n = sum(1 for r in results if r["kind"] == "table")
    summary = {"source": "pdf", "total_figures": fig_n, "total_tables": tbl_n, "items": results}
    sp = output_dir / "figures_summary.json"
    sp.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nDone! {fig_n} figures, {tbl_n} tables.")
    print(f"Summary: {sp}")
    return summary


# ============================================================
# エントリポイント
# ============================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="arXiv論文からFigure/TableのキャプションとimageファイルをTeX Sourceから抽出する",
    )
    parser.add_argument("arxiv_input", help="arXiv URL or ID (e.g., https://arxiv.org/abs/2301.12345 or 2301.12345)")
    parser.add_argument("output_dir", help="出力ディレクトリ")
    parser.add_argument("--pdf-only", action="store_true", help="TeXソースを使わずPDFのみを使用する")
    args = parser.parse_args()

    try:
        arxiv_id = parse_arxiv_input(args.arxiv_input)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"arXiv ID: {arxiv_id}")
    output_dir = Path(args.output_dir)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)

        if not args.pdf_only:
            archive = tmp / "eprint.bin"
            if download_tex_source(arxiv_id, archive):
                tex_dir = tmp / "tex"
                if extract_archive(archive, tex_dir):
                    summary = extract_from_tex(tex_dir, output_dir)
                    print(json.dumps(summary, indent=2, ensure_ascii=False))
                    return

        # PDFフォールバック
        print("Falling back to PDF extraction...")
        pdf = tmp / f"{arxiv_id.replace('/', '_')}.pdf"
        if not download_pdf(arxiv_id, pdf):
            sys.exit(1)
        summary = extract_from_pdf(pdf, output_dir)
        print(json.dumps(summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
