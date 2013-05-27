build: build-grammar
	@coffee --compile --output lib src

build-grammar:
	@./node_modules/.bin/pegjs ./src/grammar.pegjs ./lib/grammar.pegjs



.PHONY: build-grammar
