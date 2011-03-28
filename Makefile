library_dependencies.pdf: library_dependencies.dot
	dot -Tpdf $< > $@

