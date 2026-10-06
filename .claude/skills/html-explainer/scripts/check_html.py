#!/usr/bin/env python3
"""html-explainer で作ったページの機械的な確認。

使い方: python3 check_html.py page.html
構文エラー、ページ内リンク切れ、id の重複、プレースホルダ（【…】）の残り、
<title> の有無を調べる。問題があれば終了コード 1。
"""
import re
import sys
from html.parser import HTMLParser


class Collector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.hrefs = []
        self.has_title = False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            self.ids.append(a["id"])
        if tag == "a" and a.get("href", "").startswith("#"):
            self.hrefs.append(a["href"][1:])
        if tag == "title":
            self.has_title = True


def main(path):
    src = open(path, encoding="utf-8").read()
    c = Collector()
    c.feed(src)
    problems = []

    dup = sorted({i for i in c.ids if c.ids.count(i) > 1})
    if dup:
        problems.append(f"id が重複: {', '.join(dup)}")
    missing = sorted({h for h in c.hrefs if h and h not in c.ids})
    if missing:
        problems.append(f"リンク先の id が無い: {', '.join(missing)}")
    left = re.findall(r"【[^】]*】", src)
    if left:
        problems.append(f"プレースホルダが残っている: {len(left)} 件（例: {left[0]}）")
    if not c.has_title:
        problems.append("<title> が無い")

    for p in problems:
        print("NG", p)
    if not problems:
        print(f"OK ids={len(c.ids)} anchors={len(c.hrefs)} bytes={len(src.encode())}")
    return 1 if problems else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: check_html.py page.html")
    sys.exit(main(sys.argv[1]))
