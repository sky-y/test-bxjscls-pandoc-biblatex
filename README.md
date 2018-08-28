# Pandoc + LuaLaTeX: BXjsclsのPandocモードとBibLaTeXの組み合わせを検証

zr_tex8rさんの[BXjscls](https://texwiki.texjp.org/?BXjscls)（Pandocモード）で、
従来タイプセットができなかったBibLaTeXの参考文献リストを生成するテストです。

## 何をやりたいか

- Pandocを使って、Markdown (.md) → (LuaLaTeX経由) → PDF の出力をしたい
- 同時に参考文献リストを出力したい
    - BibLaTeXを使って、参考文献リストをそれなりに美しく出力したい
    - `pandoc-citeproc` は使わない
- LuaLaTeX側では、BXjsclsを使って「[pLaTeX2e 新ドキュメントクラス（jsclasses）](https://texwiki.texjp.org/?jsclasses)」相当の組版をしたい

## 補足説明

### BXjsclsとは

> BXjscls パッケージは pdflatex, lualatex, xelatex, platex-ng, uplatex, platex で使用可能な日本語文書組版のための LaTeX 文書クラスのコレクションです． TeX Live, W32TeX に含まれています．
> 
> 奥村先生の「pLaTeX2e 新ドキュメントクラス（jsclasses）」は (u)pLaTeX での使用を前提としているため，他のエンジンでは使用することができません． BXjscls は jsclasses から (u)pLaTeX 依存の部分を分離したもので，これと各エンジン用の日本語処理パッケージを組み合わせることで，(u)pLaTeX 以外でも新ドキュメントクラスを用いた場合と同等の文書作成が可能となります．
> 
> [BXjscls - TeX Wiki](https://texwiki.texjp.org/?BXjscls)

さらにBXjsclsでは、Pandocモードを使うことで、より適切な出力が得られます。

> Pandoc （文書形式変換ツール）のデフォルトの LaTeX 用テンプレートを利用して他形式（Markdown 等）の日本語文書を LaTeX 形式（および PDF 形式）に変換する場合，
> BXJS クラスの「Pandoc モード」を利用すると適切な出力が得られます．この場合，文書クラスのオプションに pandoc を指定し，エンジンと和文ドライバの指定（ja=...）を省略します．

### BibLaTeXとは

> biblatex というのは bibtex の後継で、より柔軟な運用が可能な文献管理・処理パッケージです。
> 目で見て判りやすいところでは、例えばデフォルトで英字の書名は斜体、ユニコード文字の書名は太字で出力されるようになったりします。
> MacTeX や TeXLive であれば、これらは最初から何もしなくとも勝手に入っています。 
> もちろん見た目だけではなくって、例えば文献一覧のソート順を柔軟に指定出来たり、様々な実用的なフィールドが追加されていたりします。
> 
> [latexmk で楽々 TeX タイプセットの薦め（＆ biblatex+biberで先進的な参考文献処理） - konn-san.com](https://konn-san.com/prog/why-not-latexmk.html)

Pandocを使ってLaTeX経由で日本語PDFを出力する場合、正攻法はXeLaTeXまたはLuaLaTeXを使うことです（注1）。
日本語LaTeX環境で使われてきたpLaTeXは（正攻法としては）使えないため、その環境で参考文献リストを出力するpBibTeXも使用できません。

BibLaTeXはXeLaTex/LuaLaTeXにも対応しています。（主観ですが）将来性も高いと思われます。
「Pandoc + LuaLaTeX + BibLaTeX」の組み合わせは、PandocでLaTeX経由の日本語PDF出力をする上で、有力な選択肢になるでしょう（注2）。

（注1） 一方、BXjsclsのPandocモードを使うと、正常な（コンパイルが正しく通る）(u)pLaTeX 文書に変換することも可能らしいです。
こちらは私が検証していないので、今回は割愛します。

参考: [BXjscls がまた新しくなった（v1.1a） - マクロツイーター](http://d.hatena.ne.jp/zrbabbler/20160228/1456622107)

（注2）Pandocで参考文献リストを出力したい場合、[pandoc-citeproc](https://github.com/jgm/pandoc-citeproc)というPandocフィルタを使うのがより標準的な方法です。
LaTeX以外の出力形式でも使えるので汎用性が高い一方で、適切な参考文献リストを作るには適切なCSLファイルを用意する必要があります。

日本語文献向けのCSLファイルは、[Mendeley初心者の会](https://mendeley-beginners.blogspot.com/2017/02/blog-post.html)が配布しているものが使用できます。

## 検証したいこと

TeXLive 2017のBXjscls（Pandocモード）では、Pandocで出力したtexファイルをLuaLaTeX + BibLaTeXで処理（タイプセット）すると、
多言語化のためのパッケージ「[polyglossia](https://ctan.org/pkg/polyglossia)」（babelの後継）に起因する、以下のようなエラーが起きます。

```
Class bxjsbook Warning: Loading of polyglossia is blocked on input line 154.
（略）
! Package biblatex Error: No default 'polyglossia' language defined.
```

そもそも、BXjscls側で（何らかの不具合があるらしいので）babelとpolyglossiaをオフにしているようです。
この処理がうまくいっていなかったようです。

> ちなみに、BXjsなクラスのPandocモードでBabelやPolyglossiaの読込をブロックしている理由は何かというと、
> 「-V lang=ja を付けてlatexに変換した場合に嫌なことが起こる」（変換元が <html lang="ja"> なHTMLだった場合も含む）のを避けるため、だったりする。 #TeX 
> <https://twitter.com/zr_tex8r/status/1032955806952476672>

TeXLive 2018のBXjscls（最新版）では、上記の問題点が改善されたようです。今回はこれを検証します。

> 「Pandoc＋pandoc-citeproc＋LuaLaTeX＋BXjscls（Pandocモード）」の環境でBibLaTeXの参考文献を出そうとすると、まさにPolyglossia関係でエラーになったので。 
> （結局BibLaTeXを諦めて、Pandoc側のCSL指定で参考文献を出してます）
> <https://twitter.com/sky_y/status/1032958189212299264>

> 修正版をリリースした（CTAN／TeX Liveで利用可能）ので、もしよければ、BibLaTeXが通るかを確認して頂けると非常にありがたいです。
> <https://twitter.com/zr_tex8r/status/1034088254700707840>

## 検証に使用したソフトウェア・環境

- macOS High Sierra 10.13.6
- **TeXLive 2018**（最新版）
    - LuaLaTeX ([LuaTeX-ja](https://ja.osdn.net/projects/luatex-ja/wiki/LuaTeX-ja%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9))
    - [BXjscls](https://texwiki.texjp.org/?BXjscls) (bxjsbook)
    - **BibLaTeX**
    - 上記は `scheme-full` ディストリビューションですべてインストールできます（**強く推奨**）
- [Pandoc](http://pandoc.org/) 2.2.1
- Pandocフィルタ
    - [pandoc-citeproc](https://github.com/jgm/pandoc-citeproc) 0.14.3.1
        - Pandocで参考文献リストの生成をするためのフィルタ


## TeXLiveのアップデート

**必ずTeXLive 2018を使用してください。**
古い場合は`tlmgr`（TeXLiveのパッケージマネージャー）でアップデートします（40分ぐらいかかるので注意）。

```
$ sudo tlmgr update --self --all
```

参考: [tlmgr - TeX Wiki](https://texwiki.texjp.org/?tlmgr)

アップデートできたら、BXjsclsの`cat-version`が`1.9b`以降になっていることを確認してください。

```
$ tlmgr info bxjscls
（中略）
cat-version: 1.9b
```

## サンプルを動かす

上記の環境が整っていれば、このリポジトリを`git clone`して、サンプルを動かすことができるはずです。

```
$ git clone test-bxjscls-pandoc-biblatex
$ cd test-bxjscls-pandoc-biblatex
$ make all
```

実際に実行されるコマンドは次の2行です（ターミナルに直打ちしても同じ動作です）。

```
$ pandoc -s -N --biblatex --bibliography=reference.bib book.md -o book.tex
$ latexmk -pdflua book.tex
```

`make clean`で、生成したファイルを一括削除します。

## 注意点

### 1. `lang` 指定をしてはいけない

Pandoc側のテンプレート変数（`-V`）やメタデータ（`-M`、Markdownファイル冒頭のYAMLメタデータブロック）で、`lang`を**指定してはいけません**。
`lang:ja`も`lang:en`もダメです。

`lang`指定が入るとPolyglossiaを読み込もうとするので、タイプセットが中止してしまいます。

### 2. 全部Pandocでやらない（texファイルに出力して、latexmkでタイプセットする）

一般に、LaTeXは参考文献リストを正しく出力するために、タイプセットを何度か行う必要があります。
手動で実行すると非常に煩雑ですが、`latexmk`というツールを使うと、コマンド一発で必要なコマンドを適当に実行してくれます。

一方、`pandoc`コマンドは本来、LaTeX経由のPDF出力を一発で行うコマンドがあります。
具体的には上記ディレクトリで、次のように実行します（動作が分かりやすいように`--verbose`オプションも入れています）。

```
$ pandoc --verbose -s -N --biblatex --bibliography=reference.bib --pdf-engine=lualatex book.md -o book2.pdf
```

しかし、`pandoc` コマンド単体でPDF出力しようとすると、`latexmk`のようにbiberが自動的に動作しないようです。
結果として、出力されたPDFの中で参考文献リストが正しく表示されません（同梱の`book2.pdf`を参照）。

※ そもそも、Pandocの`--biblatex`オプションはLaTeX出力専用のもの、ダイレクトなPDF出力で使用するものではないらしいです。

> `--biblatex`
> 
> Use `biblatex` for citations in LaTeX output. This option is not for use with the `pandoc-citeproc` filter or with PDF output. It is intended for use in producing a LaTeX file that can be processed with `bibtex` or `biber`.
> 
> [Pandoc - Pandoc User’s Guide](http://pandoc.org/MANUAL.html)

現状では、全部を`pandoc`コマンドでやるのは諦めて。`latexmk`に頼りましょう。
次のように、2つのステップで出力するようにしてください。

1. `pandoc`: Markdown (.md) → LaTeX (.tex)
2. `latexmk`: LaTeX (.tex) → PDF

## 最後に

さらに不具合があれば、GitHub Issuesか[Twitter: @sky_y](https://twitter.com/sky_y)まで連絡をください。
