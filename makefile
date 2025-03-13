OUT="zig-out/bin/zen.wasm"

.SILENT:
.PHONY:

build:
	zig build

test:
	zig build test

up:
	sh -c 'trap "kill 0" SIGINT; zig build --watch & python3 -m http.server 8080 --bind 0.0.0.0 & wait'

clean:
	rm -rf zig-out .zig-cache

wat:
	wasm-dis $(OUT)

stat:
	ls -lh $(OUT)
	echo

cloc:
	cloc src/*
