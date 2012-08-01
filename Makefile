.PHONY: all build

build:
	@python site.py build

all: build
	@cd pkg && makepkg -f --skipchecksums
