
EPUBCHECK=java -jar ../../tools/epubcheck/epubcheck-5.2.1.jar

sample.FULL: sample.tex
	$(MAKE) clean
	lualatex $<
	makeindex $<
	lualatex $<
	tex4ebook -c config.cfg -e build.lua $< || /bin/true
	rm -rf $*.UNPACKED && mkdir -p $*.UNPACKED
	cd $*.UNPACKED && unzip -U -qq ../$*.epub
	$(EPUBCHECK) $*.epub

.SUFFIXES: .text .epub .pdf .FULL .VIEW .UNPACKED .CHECK .EPUB+CHECK

clean:
	rm -f *~ *.ind *.ilg *.pdx *.aux */*.aux */*/*.aux *.out *.toc *.idx *.pdf *.log *.epub *.png *.lot *.lof
	rm -f *.opf *.4tc *.4ct *.css *.dvi *.html *.lg *.ncx *.tmp *.xref *.svg *.idv
	rm -rf *-epub *.epub
	rm -rf *.UNPACKED
