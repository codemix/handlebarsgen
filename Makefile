build: build-grammar
	@coffee --compile --output lib src

build-grammar:
	@./node_modules/.bin/pegjs ./src/grammar.pegjs ./lib/parser.js

.PHONY: build-grammar
