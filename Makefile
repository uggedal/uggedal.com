.PHONY: clean watch

md := $(wildcard journal/*.md)
html := $(patsubst %.md,%.html,$(md))

all : $(html) index.html

$(html) : %.html : %.md
	@./mk.sh article $^

journal/index.atom: $(md)
	@./mk.sh feed $@ --limit 10 $(md)

journal/index.html: journal/index.atom
	@./mk.sh index $@ 'Journal' $(md)

index.html: journal/index.html
	@./mk.sh index $@ 'Latest Journal Entries' --limit 5 $(md)

clean:
	@rm -f *.html journal/*.html journal/*.atom

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
