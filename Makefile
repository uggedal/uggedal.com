.PHONY: all

all:
	@cd pkg && makepkg -f --skipchecksums
