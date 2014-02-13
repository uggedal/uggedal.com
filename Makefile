.PHONY: clean watch

md := $(wildcard journal/*.md)
html := $(patsubst %.md,output/%.html,$(md))

all: output/journal $(html) output/index.html

output/journal:
	@mkdir -p $@

$(html): output/%.html: %.md
	@./mk.sh article $< $@

output/journal/index.atom: $(md)
	@./mk.sh feed $@ --limit 10 $(md)

output/journal/index.html: output/journal/index.atom
	@./mk.sh index $@ 'Journal' $(md)

output/index.html: output/journal/index.html
	@./mk.sh index $@ 'Latest Journal Entries' --limit 5 $(md)

clean:
	@rm -rf output

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
