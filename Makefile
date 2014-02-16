.PHONY: clean watch

out := output

md := $(wildcard journal/*.md)
html := $(patsubst %.md,$(out)/%/index.html,$(md))

static_src := $(shell find static/ -type f)
static_out := $(patsubst %,$(out)/%,$(static_src))

all: $(html) $(out)/index.html $(static_out)

$(html): $(out)/%/index.html: %.md
	@mkdir -p $(dir $@)
	@./mk.sh article $< $@

$(out)/journal/index.atom: $(md)
	@./mk.sh feed $@ --limit 10 $(md)

$(out)/journal/index.html: $(out)/journal/index.atom
	@./mk.sh index $@ 'Journal' $(md)

$(out)/index.html: $(out)/journal/index.html
	@./mk.sh index $@ 'Latest Journal Entries' --limit 5 $(md)

$(static_out): $(out)/%: %
	@mkdir -p $(dir $@)
	@cp $< $@

clean:
	@rm -rf $(out)/*

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
