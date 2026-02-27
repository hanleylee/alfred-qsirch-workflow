SHELL:=/usr/bin/env bash
BINARY_NAME:=alfred-qsirch

.PHONY: all build run clean
all: build run clean

build:
	cargo build --release
build-multi-arch:
	cargo build --release --target aarch64-apple-darwin
	cargo build --release --target x86_64-apple-darwin
	lipo -create -output "target/release/$(BINARY_NAME)" "target/aarch64-apple-darwin/release/$(BINARY_NAME)" "target/x86_64-apple-darwin/release/$(BINARY_NAME)"
run:
	cargo run --release -- search example
clean:
	cargo clean
a:
	@echo "a is $$0"
b:
	@echo "b is $$0"
