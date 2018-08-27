$lualatex = 'lualatex -synctex=1 -halt-on-error %O %S';
$bibtex = 'upbibtex %O %B';
$bibtex_use = 2;
$biber = 'biber %O --bblencoding=utf8 -u -U --output_safechars %B';
# $makeindex = 'upmendex %O -o %D %S';
$makeindex = 'upmendex -s dot.ist %O -o %D %S';
$pdf_previewer = '"/mnt/c/Program Files/SumatraPDF/SumatraPDF.exe" -reuse-instance %O %S';
$max_repeat = 10;
