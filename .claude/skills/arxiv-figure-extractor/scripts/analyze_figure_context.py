#!/usr/bin/env python3
"""
arXiv論文のTeXソースを解析し、各Figureがどのセクションで言及されているかを抽出する。

Usage:
    uv run ~/.claude/skills/arxiv-figure-extractor/scripts/analyze_figure_context.py \
        <arxiv_id_or_url> <output.json> [--figures-summary <figures_summary.json>]

Output JSON example:
{
  "arxiv_id": "2501.12345",
  "figures": [
    {
      "label": "fig:overview",
      "number": 1,
      "caption": "Overview of our proposed method.",
      "image_files": ["images/figure_01_overview.pdf"],
      "section_mentions": [
        {
          "section_path": ["3. Proposed Method", "3.1 Architecture"],
          "context": "As illustrated in Figure 1, our model consists of an encoder...",
          "ref_count": 2
        }
      ]
    }
  ]
}
"""

import argparse
import gzip
import json
import re
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
# ダウンロード & アーカイブ展開
# ============================================================

def _http_get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "arxiv-figure-context-analyzer/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read()


def download_tex_source(arxiv_id: str, dest: Path) -> bool:
    """arXiv TeXソース (e-print) をダウンロードする。成功時 True を返す。"""
    url = f"https://arxiv.org/e-print/{arxiv_id}"
    print(f"Downloading TeX source from {url} ...", file=sys.stderr)
    try:
        data = _http_get(url)
        if data[:8].lstrip(b"\xef\xbb\xbf").lower().startswith((b"<!doctype", b"<html")):
            print("Warning: Got HTML response instead of archive", file=sys.stderr)
            return False
        dest.write_bytes(data)
        print(f"Downloaded {len(data):,} bytes", file=sys.stderr)
        return True
    except Exception as e:
        print(f"Warning: TeX source download failed: {e}", file=sys.stderr)
        return False


def extract_archive(archive_path: Path, extract_dir: Path) -> bool:
    """tar.gz / gzip 単体ファイルを展開する。成功時 True を返す。"""
    extract_dir.mkdir(parents=True, exist_ok=True)
    try:
        with tarfile.open(str(archive_path)) as tf:
            safe = [
                m for m in tf.getmembers()
                if ".." not in Path(m.name).parts and not m.name.startswith("/")
            ]
            tf.extractall(str(extract_dir), members=safe)
        print(f"Extracted archive ({len(safe)} files)", file=sys.stderr)
        return True
    except Exception:
        pass
    try:
        with gzip.open(str(archive_path), "rb") as f:
            content = f.read()
        (extract_dir / "main.tex").write_bytes(content)
        return True
    except Exception as e:
        print(f"Warning: Failed to extract archive: {e}", file=sys.stderr)
        return False


# ============================================================
# LaTeX ロード
# ============================================================

def find_main_tex(tex_dir: Path) -> Path | None:
    """\\documentclass を含むメインのTeXファイルを探す。"""
    tex_files = list(tex_dir.rglob("*.tex"))
    if not tex_files:
        return None
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
        print(f"Main TeX file: {main.relative_to(tex_dir)}", file=sys.stderr)
        return load_tex_recursive(main, tex_dir)
    parts = []
    for f in sorted(tex_dir.rglob("*.tex")):
        try:
            parts.append(f.read_text(encoding="utf-8", errors="ignore"))
        except Exception:
            pass
    return "\n".join(parts)


def remove_comments(tex: str) -> str:
    """LaTeXコメント（%以降）を削除する（\\%は除く）。"""
    return re.sub(r"(?<!\\)%[^\n]*", "", tex)


# ============================================================
# コンテキスト解析
# ============================================================

def build_section_map(tex: str) -> list[dict]:
    """セクション位置のリストを返す。各要素は {pos, level, title}"""
    section_re = re.compile(
        r'\\((?:sub)*section)\*?\s*(?:\[[^\]]*\])?\{([^}]+)\}',
    )
    sections = []
    for m in section_re.finditer(tex):
        level_str = m.group(1)  # "section", "subsection", "subsubsection"
        level = level_str.count("sub") + 1
        raw_title = m.group(2)
        # LaTeXコマンドを除去してテキスト化
        title = re.sub(r'\\(?:textbf|textit|emph|text[a-z]*)\{([^}]*)\}', r'\1', raw_title)
        title = re.sub(r'\\[a-zA-Z]+\*?\s*', ' ', title)
        title = re.sub(r'[{}]', '', title)
        title = re.sub(r'\s+', ' ', title).strip()
        if title:
            sections.append({'pos': m.start(), 'level': level, 'title': title})
    return sections


def get_section_path_at(pos: int, sections: list[dict]) -> list[str]:
    """posより前の最新セクション階層パスを返す。例: ["3. Method", "3.1 Architecture"]"""
    active: dict[int, str] = {}  # level -> title
    for sec in sections:
        if sec['pos'] > pos:
            break
        active[sec['level']] = sec['title']
        # 下位レベルをクリア
        for lower_lvl in [k for k in active if k > sec['level']]:
            del active[lower_lvl]

    if not active:
        return ["(Before sections)"]
    return [active[lvl] for lvl in sorted(active.keys())]


def clean_snippet(tex: str) -> str:
    """TeX スニペットを人間が読みやすいテキストに変換する。"""
    # インラインmath をそのまま保持
    text = re.sub(r'\\(?:textbf|textit|emph|text[a-z]*)\{([^}]*)\}', r'\1', tex)
    text = re.sub(r'\\(?:cite|citep|citet|citealp|citealt)\{[^}]*\}', '[CITE]', text)
    # \ref{xxx} は ref:xxx の形に残す（どこを参照しているかわかるように）
    text = re.sub(r'\\(?:ref|autoref|Autoref|cref|Cref|vref)\{([^}]*)\}', r'(ref:\1)', text)
    text = re.sub(r'\\(?:label|footnote|footnotemark)\{[^}]*\}', '', text)
    text = re.sub(r'\\(?:begin|end)\{[^}]*\}', '', text)
    text = re.sub(r'\\[a-zA-Z]+\*?\s*', ' ', text)
    text = re.sub(r'[{}]', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def extract_context_around(tex: str, pos: int, window: int = 400) -> str:
    """pos周辺のテキストを抽出し、文境界で整形する。"""
    start = max(0, pos - window)
    end = min(len(tex), pos + window)
    snippet = tex[start:end]

    # 文境界を探す（前方）
    # 行頭か ". " で始まる位置を探す
    front_match = re.search(r'(?:^|\.\s+|\n\n)', snippet[:window])
    if front_match:
        snippet = snippet[front_match.end():]

    return clean_snippet(snippet)


def analyze_contexts(tex: str, labels: list[str]) -> dict[str, list[dict]]:
    """各ラベルについて参照コンテキストを解析する。"""
    sections = build_section_map(tex)
    print(f"Detected {len(sections)} sections", file=sys.stderr)

    # \ref 系コマンドすべてを検索
    ref_re = re.compile(
        r'\\(?:ref|autoref|Autoref|cref|Cref|vref|figref|Fig)\{([^}]+)\}'
    )

    label_to_mentions: dict[str, list[dict]] = {lbl: [] for lbl in labels}

    for m in ref_re.finditer(tex):
        ref_label = m.group(1).strip()
        if ref_label not in label_to_mentions:
            continue

        sec_path = get_section_path_at(m.start(), sections)
        context = extract_context_around(tex, m.start())

        # 同じセクションパスへの重複をまとめる
        existing = next(
            (x for x in label_to_mentions[ref_label] if x['section_path'] == sec_path),
            None
        )
        if existing:
            existing['ref_count'] += 1
            if len(context) > len(existing['context']):
                existing['context'] = context
        else:
            label_to_mentions[ref_label].append({
                'section_path': sec_path,
                'context': context,
                'ref_count': 1
            })

    return label_to_mentions


# ============================================================
# エントリポイント
# ============================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="arXiv論文のTeXソースを解析し、各Figureがどのセクションで言及されているかを抽出する"
    )
    parser.add_argument("arxiv_input", help="arXiv URL or ID (e.g. 2501.12345)")
    parser.add_argument("output", help="出力JSONファイルパス")
    parser.add_argument(
        "--figures-summary",
        metavar="PATH",
        help="extract_figures.py が生成した figures_summary.json のパス（ラベル・キャプション情報に使用）",
        default=None,
    )
    args = parser.parse_args()

    try:
        arxiv_id = parse_arxiv_input(args.arxiv_input)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"arXiv ID: {arxiv_id}", file=sys.stderr)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        archive = tmp / "eprint.bin"

        if not download_tex_source(arxiv_id, archive):
            print("Error: TeXソースのダウンロードに失敗しました", file=sys.stderr)
            sys.exit(1)

        tex_dir = tmp / "tex"
        if not extract_archive(archive, tex_dir):
            print("Error: アーカイブの展開に失敗しました", file=sys.stderr)
            sys.exit(1)

        tex = remove_comments(collect_tex_content(tex_dir))

    print(f"TeX source size: {len(tex):,} chars", file=sys.stderr)

    # figures_summary.json からラベルと図情報を取得
    figures_data: list[dict] = []
    if args.figures_summary:
        try:
            summary = json.loads(Path(args.figures_summary).read_text(encoding="utf-8"))
            figures_data = [item for item in summary.get("items", []) if item.get("kind") == "figure"]
            print(f"Loaded {len(figures_data)} figures from summary", file=sys.stderr)
        except Exception as e:
            print(f"Warning: figures_summary.json の読み込みに失敗: {e}", file=sys.stderr)

    # ラベルのリストを作成（summary がない場合はTeX から自動検出）
    if figures_data:
        labels = [fig["label"] for fig in figures_data if fig.get("label")]
    else:
        label_re = re.compile(r'\\label\{([^}]+)\}')
        # figure環境内の \label を抽出
        fig_env_re = re.compile(r'\\begin\{figure\*?\}(.*?)\\end\{figure\*?\}', re.DOTALL)
        labels = []
        for env_m in fig_env_re.finditer(tex):
            for label_m in label_re.finditer(env_m.group(1)):
                lbl = label_m.group(1)
                if lbl not in labels:
                    labels.append(lbl)
        if not labels:
            # フォールバック: fig を含む全ラベル
            labels = list({m.group(1) for m in label_re.finditer(tex)
                           if re.search(r'fig', m.group(1), re.IGNORECASE)})
        print(f"Auto-detected figure labels: {labels}", file=sys.stderr)

    print(f"Analyzing {len(labels)} figure labels...", file=sys.stderr)

    # コンテキスト解析
    label_contexts = analyze_contexts(tex, labels)

    # 結果を figures_data と組み合わせ
    output_figures: list[dict] = []
    if figures_data:
        for fig in figures_data:
            label = fig.get("label", "")
            result = dict(fig)
            result["section_mentions"] = label_contexts.get(label, [])
            output_figures.append(result)
            mention_count = len(result["section_mentions"])
            print(f"  Figure {fig.get('number', '?')} ({label}): {mention_count} section mention(s)", file=sys.stderr)
    else:
        for label in labels:
            mentions = label_contexts.get(label, [])
            output_figures.append({
                "label": label,
                "section_mentions": mentions,
            })

    output = {
        "arxiv_id": arxiv_id,
        "total_figures": len(output_figures),
        "figures": output_figures,
    }

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(output, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nOutput saved: {out_path}", file=sys.stderr)
    print(json.dumps(output, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
