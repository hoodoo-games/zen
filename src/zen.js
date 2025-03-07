let mod = undefined;

async function init() {
  mod = await loadWasm("./zig-out/bin/zen.wasm", {
    env: {
      console_log,
    },
  });

  mod.instance.exports.init();
}

async function loadWasm(url, imports) {
  return await WebAssembly.instantiateStreaming(fetch(url), imports);
}

function mem_to_str(start_ptr, len, mem) {
  const values = new Uint8Array(mem.buffer);
  const str = values.slice(start_ptr, start_ptr + len);
  return new TextDecoder("utf-8").decode(str);
}

function console_log(msg, len) {
  console.log(mem_to_str(msg, len, mod.instance.exports.memory));
}

init();
