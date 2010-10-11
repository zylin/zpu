TARGET=vortrag


all:	vortrag.pdf

$(TARGET).pdf: $(TARGET).tex
	pdflatex $(TARGET).tex

clean:
	rm -f $(TARGET).aux
	rm -f $(TARGET).log
	rm -f $(TARGET).nav
	rm -f $(TARGET).out
	rm -f $(TARGET).snm
	rm -f $(TARGET).toc
