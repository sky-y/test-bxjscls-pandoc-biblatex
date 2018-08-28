# Pandoc/LuaLaTeXでPDFを生成するMakefile

# make all
.PHONY: all
all: book.pdf

book.pdf: book.md
	pandoc -s -N --biblatex --bibliography=reference.bib book.md -o book.tex
	latexmk -pdflua book.tex

# make clean
.PHONY: clean
clean:
	latexmk -f -c book.tex
	rm -rf book.tex book.run.xml
