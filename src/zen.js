let mod = undefined;
let canvas = undefined;
let canvasToDisplaySizeMap = undefined;
let resizeObserver = undefined;
let prev_time = 0;

async function init() {
  mod = await loadWasm("./zig-out/bin/zen.wasm", {
    env: {
      console_log,
    },
  });

  mod.instance.exports.init();

  canvas = document.querySelector("#zen-canvas");
  if (!canvas) throw new Error("canvas with id zen-canvas not found");

  canvasToDisplaySizeMap = new Map([[canvas, [300, 150]]]);

  resizeObserver = new ResizeObserver(onResize);
  resizeObserver.observe(canvas, { box: "content-box" });

  requestAnimationFrame(update);
}

function update(t) {
  resizeCanvasToDisplaySize(canvas);
  mod.instance.exports.update(t - prev_time);

  prev_time = t;
  requestAnimationFrame(update);
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

// credit to https://webgl2fundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
function resizeCanvasToDisplaySize(canvas) {
  // Get the size the browser is displaying the canvas in device pixels.
  const [displayWidth, displayHeight] = canvasToDisplaySizeMap.get(canvas);

  // Check if the canvas is not the same size.
  const needResize =
    canvas.width !== displayWidth || canvas.height !== displayHeight;

  if (needResize) {
    // Make the canvas the same size
    canvas.width = displayWidth;
    canvas.height = displayHeight;
  }

  return needResize;
}

// credit to https://webgl2fundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
function onResize(entries) {
  for (const entry of entries) {
    let width;
    let height;
    let dpr = window.devicePixelRatio;
    if (entry.devicePixelContentBoxSize) {
      // NOTE: Only this path gives the correct answer
      // The other 2 paths are an imperfect fallback
      // for browsers that don't provide anyway to do this
      width = entry.devicePixelContentBoxSize[0].inlineSize;
      height = entry.devicePixelContentBoxSize[0].blockSize;
      dpr = 1; // it's already in width and height
    } else if (entry.contentBoxSize) {
      if (entry.contentBoxSize[0]) {
        width = entry.contentBoxSize[0].inlineSize;
        height = entry.contentBoxSize[0].blockSize;
      } else {
        // legacy
        width = entry.contentBoxSize.inlineSize;
        height = entry.contentBoxSize.blockSize;
      }
    } else {
      // legacy
      width = entry.contentRect.width;
      height = entry.contentRect.height;
    }

    const displayWidth = Math.round(width * dpr);
    const displayHeight = Math.round(height * dpr);
    canvasToDisplaySizeMap.set(entry.target, [displayWidth, displayHeight]);
  }
}

init();
