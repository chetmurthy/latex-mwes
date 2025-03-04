
#EPUBCHECK=epubcheck
EPUBCHECK=java -jar ../../tools/epubcheck/epubcheck-5.2.1.jar

all:: main.FULL

.tex.FULL:
	$(MAKE) clean
	killall -9 okular ebook-viewer || /bin/true
	rm -f $*.pdf $*.epub
	$(MAKE) $*.pdf $*.epub || /bin/true
	$(MAKE) $*.UNPACKED
	$(MAKE) $*.CHECK

.epub.CHECK:
	$(EPUBCHECK) $<

.tex.EPUB+CHECK:
	$(MAKE) $*.epub || /bin/true
	$(MAKE) $*.UNPACKED
	$(MAKE) $*.CHECK
 
.tex.VIEW:
	okular $*.pdf &
	ebook-viewer $*.epub&

view::
	okular foo.pdf &
	ebook-viewer foo.epub&

%.pdf: %.tex *.tex
	lualatex $*
	makeindex $*
	lualatex $*

.tex.epub:
	tex4ebook -c config.cfg $<

.epub.UNPACKED:
	mkdir -p $@
	cd $@ && unzip -U -qq ../$<

.SUFFIXES: .text .epub .pdf .FULL .VIEW .UNPACKED .CHECK .EPUB+CHECK

clean:
	rm -f *~ *.ind *.ilg *.pdx *.aux */*.aux */*/*.aux *.out *.toc *.idx *.pdf *.log *.epub *.png *.lot *.lof
	rm -f *.opf *.4tc *.4ct *.css *.dvi *.html *.lg *.ncx *.tmp *.xref *.svg *.idv
	rm -rf *-epub *.epub
	rm -rf *.UNPACKED
