.PHONY: clean watch

md := $(wildcard journal/*.md)
html := $(patsubst %.md,output/%.html,$(md))
out := output

all: $(out)/journal $(html) $(out)/index.html

$(out)/journal:
	@mkdir -p $@

$(html): $(out)/%.html: %.md
	@./mk.sh article $< $@

$(out)/journal/index.atom: $(md)
	@./mk.sh feed $@ --limit 10 $(md)

$(out)/journal/index.html: $(out)/journal/index.atom
	@./mk.sh index $@ 'Journal' $(md)

$(out)/index.html: $(out)/journal/index.html
	@./mk.sh index $@ 'Latest Journal Entries' --limit 5 $(md)

clean:
	@rm -rf $(out)

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
