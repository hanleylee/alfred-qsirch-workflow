SHELL:=/usr/bin/env bash

.PHONY: all generate preview

all: build run

build:
	# swift build -c release --build-path ".build" --target alfred-qsirch
	swift build -c release --build-path ".build"
run:
	swift run --build-path .build alfred-qsirch search example
a:
	@echo "a is $$0"
b:
	@echo "b is $$0"
