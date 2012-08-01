.PHONY: serve build all

serve:
	@python site.py serve

build:
	@python site.py build

all: build
	@cd pkg && makepkg -f --skipchecksums
