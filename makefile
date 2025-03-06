.SILENT:
.PHONY:

build:
	zig build

test:
	zig build test

clean:
	rm -rf zig-out .zig-cache

wat:
	wasm2wat zig-out/bin/zen.wasm

cloc:
	cloc src/*
