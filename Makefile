# 『Markdownライティング入門』（初版：技術書典4）を生成するMakefile

# make pr: 添削用PDFを生成
# make all: 入稿用PDFを生成
# make img: カラー画像をグレースケールに変換
# make preview: PDFプレビュー


# 変数 (ファイル名系)

## 共通
### LaTeXのヘッダファイル（プリアンブル部分）
header       := header.tex
### 画像
img_dest_dir := img
img_dest     := $(wildcard $(img_dest_dir)/*)

## 入稿用原稿（Markdown）
### 入稿しない原稿はコメントアウト
### chap90_appendix.md: \appendix を入れるだけ
### chap99_bibliography.md: 参考文献の見出し（本体はPandocの--tocオプションで出す）
# md           := chap00_intro.md
md           += chap01_whats-markdown.md
# md           += chap02_minimum-markdown.md
# md           += chap03_try-markdown.md
# md           += chap04_basic-markdown.md
# md           += chap05_md-practice.md
# md           += chap06_extended-markdown.md
# md           += chap07_md-and-not-md.md
# md           += chap09_conclusion.md

# md_appendix   += chap91_discussions.md
# md_appendix   += chap92_list-markdown.md
# md_appendix   += chap93_md-and-html.md
# md_appendix   += chap94_how-to-install.md
# md_appendix   += chap98_special-thanks.md

md_appendix_div := chap90_appendix.md
md_bib          := chap99_bibliography.md

### 校正用ディレクトリ
pr_dir          := ../proofread

### PandocのYAMLメタデータブロックをファイルで与える
meta         := metadata.yaml
### 出力PDF
pdf          := book.pdf
### latexmkが出力したPDFの場所（tmpディレクトリに出力するので）
tmp_dir      := tmp
tmppdf       := $(tmp_dir)/book.pdf
### 拡張子を変える（Makeの置換機能）
tex          := book.tex

## 参考文献
bib_src      := MarkdownBook.bib
bib_dest     := MarkdownBook-fixed.bib
csl          := AgcontNum.csl

# 変数 (Pandocオプション系)

## 入力フォーマット
## markdown: Pandoc's Markdown
## +smart: 約物を組版的に正しくする
## +raw_tex: TeX記法をMarkdownに埋め込める
## +east_asian_line_breaks: Markdown上の改行を勝手にスペース扱いしない
## -auto_identifiers: 「自動的にヘッダへidentifierを付ける」のをやめる（マイナスでオプションをオフにする）
pandoc_input_format := markdown+smart+raw_tex+east_asian_line_breaks-auto_identifiers

## Pandocオプション
pandoc_options := -s                              # ヘッダ・フッタを付けた完全な出力にする
pandoc_options := --toc                           # 目次を入れる
pandoc_options += -f $(pandoc_input_format)       # 入力フォーマット（上記）
pandoc_options += -t latex                        # 出力フォーマット（LaTeXファイル）
pandoc_options += --listings                      # LaTeXのlistingsパッケージを使う
pandoc_options += --number-sections               # 章に番号を付ける（デフォルトは付けない）
pandoc_options += --top-level-division=chapter    # 見出しの「#」をLaTeXの\chapterに対応させる
pandoc_options += -H $(header)                    # LaTeXのヘッダファイル(.tex)（プリアンブル部分）
pandoc_options += --bibliography=$(bib_dest)      # 参考文献ファイル(.bib)
# pandoc_options += --csl=$(csl)                    # CSLファイル(.csl) 参考文献の形式を指定するXML
pandoc_options += --biblatex                      # bibLaTeXを使用
pandoc_options += --filter pandoc-latex-unlisted  # Pandocフィルタ: .unlistedの付いた見出しを目次から除外
pandoc_options += --filter pandoc-crossref        # Pandocフィルタ: 図・表・コードの引用
pandoc_options += --filter pandoc-citeproc        # Pandocフィルタ: 引用・参考文献ページを作る

# ルール

## Makefileそのものの設定

### Makeのサフィックスを追加 (1行目はデフォルト設定を削除)
.SUFFIXES:
.SUFFIXES: .pdf .tex .md

### 中間ファイルとして削除されないようにする
.PRECIOUS : %.tex %.pdf

## 入稿用PDFのルール

### make all: 入稿用PDFを生成
.PHONY: all
all: $(pdf)

### LuaLaTeX(latexmk): TeXファイルからPDFを生成
$(pdf): $(tex)
	latexmk -pdflua -outdir=tmp $(tex)
	cp $(tmppdf) ./

### Pandoc: Pandoc's Markdownから中間TeXファイルを生成
$(tex): $(header) $(bib_dest) $(csl) $(meta) $(md) $(md_bib)
	pandoc $(pandoc_options) $(pandoc_options_all) $(meta) $(md) $(md_bib) -o $@

### make preview: PDFプレビュー
.PHONY: preview
preview: $(tex)
	latexmk -pvc -pdflua -outdir=tmp $(tex)

## Mendeleyからbibファイルをコピー (藤原ローカルPCのみ)
### Mendeleyで出力した参考文献 (BibTeX) の修正
regex_urlamp := 's/^url = \{(.+)\{\\([&_\#])\}(.*)\},/url = \{$$1$$2$$3\},/g'  # 1. URLで&が入るのを修正
regex_online := 's/\@misc/\@online/'  # 2. Web Pageが@miscで出力されてしまうので、@onlineに置換
bib_mendeley := ~/MEGA/Mendeley/BibTeX/MarkdownBook.bib

.PHONY: bib
bib: $(bib_dest)

$(bib_dest): $(bib_mendeley)
	cp $(bib_mendeley) $(bib_src)
	cat $(bib_src) | \
	perl -pe $(regex_urlamp) | perl -pe $(regex_online) > $(bib_dest)

.PHONY: bibc
bibc:
	rm -f $(bib_dest) *.synctex.gz

### make clean: 生成したファイルを削除
.PHONY: clean
clean:
	latexmk -f -c -outdir=$(tmp_dir) $(tex)
	rm -f $(tex) *.synctex.gz

### make pr: proofreadに必要ファイルをコピーする
### PDFの分割は手動でやる
.PHONY: pr
pr: $(md)
	cp -n $(md) $(pr_dir)
	cp -r $(img_dest_dir) $(pr_dir)

### make imcheck: 最大ピクセル数が320万以下かどうかをチェックする
.PHONY: imcheck
imcheck:
	cd img; ruby size_check.rb
