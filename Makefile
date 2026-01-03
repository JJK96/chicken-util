install: util.json.import.scm util.web.import.scm
	chicken-install

%.import.scm: %.scm
	csc -s -J $^
