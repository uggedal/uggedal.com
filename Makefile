.PHONY: clean watch

md := $(wildcard journal/*.md)
html := $(patsubst %.md,%.html,$(md))

all : $(html)

$(html) : %.html : %.md
	@./mk.sh $^

clean:
	@rm -f journal/*.html

watch:
	@while inotifywait -qqre create,delete,modify .; do make; done
