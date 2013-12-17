.PHONY: all clean

COMPILED = output

all:
	@mkdir -p ${COMPILED}
	@zod site ${COMPILED}

clean:
	@rm -r ${COMPILED}
