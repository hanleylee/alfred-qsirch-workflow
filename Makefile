SHELL:=/usr/bin/env bash
ALFRED_EUDIC_WORKFLOW="/Users/hanley/Library/Mobile Documents/com~apple~CloudDocs/ihanley/config/Alfred/Alfred.alfredpreferences/workflows/user.workflow.85F7045B-6A2B-4980-A929-A172079488B2"

.PHONY: all build install run clean
all: build run

build:
	# swift build -c release --build-path ".build" --target alfred-qsirch
	swift build -c release --build-path ".build"
install:
	@install -D -m 755 .build/release/alfred-qsirch $(ALFRED_EUDIC_WORKFLOW)/bin/alfred-qsirch
run:
	swift run --build-path .build alfred-qsirch search example
a:
	@echo "a is $$0"
b:
	@echo "b is $$0"
