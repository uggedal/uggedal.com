.PHONY: clean watch

md := $(wildcard journal/*.md)
html := $(patsubst %.md,%.html,$(md))

all : $(html) index.html

$(html) : %.html : %.md
	@./mk.sh article $^

journal/index.html: $(md)
	@./mk.sh index $@ $(md)

index.html: journal/index.html
	@./mk.sh index $@ --limit 5 $(md)

clean:
	@rm -f journal/*.html

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
