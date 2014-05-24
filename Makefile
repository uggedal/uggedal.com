.PHONY: clean deploy watch

author := Eivind Uggedal
out := output
www := /var/www/uggedal.com

md := $(wildcard journal/*.md)
html := $(patsubst %.md,$(out)/%/index.html,$(md))

static_src := $(shell find static/ -type f)
static_out := $(patsubst %,$(out)/%,$(static_src))

all: $(html) $(out)/index.html $(static_out)

$(html): $(out)/%/index.html: %.md
	@mkdir -p $(dir $@)
	@./mk article $< $@

$(out)/journal/index.atom: $(md)
	@./mk feed $@ --limit 10 $(md)

$(out)/journal/index.html: $(out)/journal/index.atom
	@./mk index $@ "Journal of $(author)" 'Journal' $(md)

$(out)/index.html: $(out)/journal/index.html
	@./mk index $@ "$(author)" 'Latest Journal Entries' --limit 5 $(md)

$(static_out): $(out)/%: %
	@mkdir -p $(dir $@)
	@cp $< $@

clean:
	@rm -rf $(out)/*

deploy: all
	@sudo rsync -a --info=NAME --force --delete $(out)/ $(www)

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
