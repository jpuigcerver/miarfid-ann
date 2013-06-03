all:
	pdflatex report
	bibtex report
	pdflatex report
	pdflatex report

clean:
	rm -f *~ *.aux *.bbl *.blg *.log *.gz

distclean: clean
	rm -f *.pdf
