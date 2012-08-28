.PHONY: serve build all

all: build
	@cd pkg && makepkg -f --skipchecksums

serve:
	@python site.py serve

build:
	@python site.py build
