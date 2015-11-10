.PHONY: clean deploy
.SUFFIXES: .md .html

AUTHOR = Eivind Uggedal
WWW = /srv/http/uggedal.com

SRC != find journal/ -type f -name '*.md'
DOC = ${SRC:.md=.html}

all: ${DOC} journal/index.atom
	@rm -rf output
	@for s in $$(find . -name '*.html' -o -name '*.atom'); do \
		case $$s in \
			*index.*) t=output/$$s;; \
			*) t=output/$${s%.html}/index.html;; \
		esac; \
		mkdir -p $$(dirname $$t); \
		cp $$s $$t; \
	done
	@cp -r files/* output

.md.html:
	@echo Compiling $@
	@./mk article $< $@

index.html: ${SRC}
	@echo Creating $@
	@./mk index $@ "${AUTHOR}" 'Latest Journal Entries' --limit 5 ${SRC}

journal/index.html: index.html
	@echo Creating $@
	@./mk index $@ "Journal of ${AUTHOR}" 'Journal' ${SRC}

journal/index.atom: journal/index.html
	@echo Creating $@
	@./mk feed $@ --limit 10 ${SRC}

clean:
	@rm -rf output *.html journal/*.html journal/*.atom

deploy: all
	@rsync -a --info=NAME --force --delete -e ssh output/ ${HOST}:${WWW}
