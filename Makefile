.PHONY: all test docs

all:	test

test:
	crystal spec

docs:
	crystal docs
