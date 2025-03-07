.SILENT:
.PHONY:

build:
	zig build

test:
	zig build test

up:
	sh -c 'trap "kill 0" SIGINT; zig build --watch & python3 -m http.server 8080 --bind 127.0.0.1 & wait'

clean:
	rm -rf zig-out .zig-cache

wat:
	wasm2wat zig-out/bin/zen.wasm

cloc:
	cloc src/*
