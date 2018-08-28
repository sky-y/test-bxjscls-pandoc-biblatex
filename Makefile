# Pandoc/LuaLaTeXでPDFを生成するMakefile

.PHONY: all
all: book.pdf

book.pdf: book.md
	pandoc -s -N --biblatex --bibliography=reference.bib book.md -o book.tex
	latexmk -pdflua book.tex

.PHONY: clean
clean:
	latexmk -f -C book.tex
	rm -rf book.tex book.run.xml
