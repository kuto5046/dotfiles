#!/usr/bin/env python3
"""arXiv論文からFigure/Tableのキャプション情報を抽出するスクリプト。

Usage:
    uv run --with pymupdf scripts/extract_figures.py <arxiv-url-or-id> <output-dir>
"""

import argparse
import json
import os
import re
import sys
import tempfile
import urllib.request
from pathlib import Path


def parse_arxiv_input(input_str: str) -> str:
    """arXiv URL または ID から論文IDを抽出する。"""
    input_str = input_str.strip().rstrip("/")

    # arXiv ID パターン: 2301.12345 or 2301.12345v2 or hep-th/9901001
    arxiv_id_pattern = r"(\d{4}\.\d{4,5}(?:v\d+)?|[a-z-]+/\d{7}(?:v\d+)?)"

    # URL形式: abs/, pdf/, html/
    url_patterns = [
        rf"arxiv\.org/abs/({arxiv_id_pattern})",
        rf"arxiv\.org/pdf/({arxiv_id_pattern})",
        rf"arxiv\.org/html/({arxiv_id_pattern})",
    ]

    for pattern in url_patterns:
        m = re.search(pattern, input_str)
        if m:
            return m.group(1)

    # IDのみ
    m = re.fullmatch(arxiv_id_pattern, input_str)
    if m:
        return m.group(0)

    raise ValueError(f"arXiv URLまたはIDを認識できません: {input_str}")


def download_pdf(arxiv_id: str, output_path: str) -> str:
    """arXiv PDFをダウンロードする。"""
    url = f"https://arxiv.org/pdf/{arxiv_id}"
    print(f"Downloading PDF from {url} ...")

    req = urllib.request.Request(
        url,
        headers={"User-Agent": "arxiv-figure-extractor/1.0"},
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = resp.read()

    with open(output_path, "wb") as f:
        f.write(data)

    print(f"Downloaded {len(data)} bytes -> {output_path}")
    return output_path


def find_captions(page) -> list[dict]:
    """ページ内のテキストブロックからFigure/Tableキャプションを検出する。"""
    captions = []
    caption_pattern = re.compile(
        r"(Figure|Fig\.|Table)\s+(\d+)[.:]\s*(.*)",
        re.IGNORECASE,
    )

    blocks = page.get_text("dict")["blocks"]
    for block in blocks:
        if block["type"] != 0:  # テキストブロックのみ
            continue

        # ブロック内の全テキストを結合
        block_text = ""
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                block_text += span["text"] + " "
        block_text = block_text.strip()

        m = caption_pattern.search(block_text)
        if m:
            kind_raw = m.group(1).lower()
            kind = "table" if kind_raw == "table" else "figure"
            number = int(m.group(2))
            caption_text = m.group(3).strip()
            bbox = block["bbox"]  # (x0, y0, x1, y1)
            captions.append({
                "kind": kind,
                "number": number,
                "caption": caption_text,
                "bbox": bbox,
                "page": page.number,
            })

    return captions


def extract_figures(
    pdf_path: str,
    output_dir: str,
) -> dict:
    """PDFから図表のキャプション情報を抽出するメイン関数。"""
    import pymupdf

    doc = pymupdf.open(pdf_path)
    os.makedirs(output_dir, exist_ok=True)

    results = []
    seen_keys = set()  # (kind, number) で重複管理

    print(f"Processing {doc.page_count} pages ...")

    for page_num in range(doc.page_count):
        page = doc[page_num]
        captions = find_captions(page)

        for cap in captions:
            kind = cap["kind"]
            number = cap["number"]
            key = (kind, number)

            if key in seen_keys:
                continue
            seen_keys.add(key)

            result = {
                "kind": kind,
                "number": number,
                "caption": cap["caption"],
                "page": page_num + 1,
            }
            results.append(result)
            print(f"  Found {kind} {number} (page {page_num + 1}): {cap['caption'][:60]}")

    doc.close()

    figure_count = sum(1 for r in results if r["kind"] == "figure")
    table_count = sum(1 for r in results if r["kind"] == "table")

    # サマリーJSON を保存
    summary = {
        "source": pdf_path,
        "total_figures": figure_count,
        "total_tables": table_count,
        "items": results,
    }
    summary_path = os.path.join(output_dir, "figures_summary.json")
    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    print(f"\nDone! Found {figure_count} figures, {table_count} tables.")
    print(f"Summary: {summary_path}")

    return summary


def main():
    parser = argparse.ArgumentParser(
        description="arXiv論文からFigure/Tableのキャプション情報を抽出する",
    )
    parser.add_argument(
        "arxiv_input",
        help="arXiv URL or ID (e.g., https://arxiv.org/abs/2301.12345 or 2301.12345)",
    )
    parser.add_argument(
        "output_dir",
        help="出力ディレクトリ",
    )
    args = parser.parse_args()

    # arXiv IDを解析
    try:
        arxiv_id = parse_arxiv_input(args.arxiv_input)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"arXiv ID: {arxiv_id}")

    # PDFダウンロード
    with tempfile.TemporaryDirectory() as tmpdir:
        pdf_path = os.path.join(tmpdir, f"{arxiv_id.replace('/', '_')}.pdf")
        try:
            download_pdf(arxiv_id, pdf_path)
        except Exception as e:
            print(f"Error downloading PDF: {e}", file=sys.stderr)
            sys.exit(1)

        # キャプション情報抽出
        summary = extract_figures(
            pdf_path,
            args.output_dir,
        )

    # 結果をJSON出力
    print(json.dumps(summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
