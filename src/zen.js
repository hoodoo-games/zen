let mod = undefined;
let prev_time = 0;

async function init() {
  mod = await loadWasm("./zig-out/bin/zen.wasm", {
    env: {
      _console_log,
      _set_clear_color,
      _draw,
      _clear,
    },
  });

  canvas = document.querySelector("#zen-canvas");
  if (!canvas) throw new Error("canvas with id zen-canvas not found");

  resizeObserver = new ResizeObserver(onResize);
  resizeObserver.observe(canvas, { box: "content-box" });

  initGraphics();
  initGraphicsTest();

  mod.instance.exports.init();

  requestAnimationFrame(update);
}

//TODO handle visibility changes (pause loop when not visible)

function update(t) {
  resizeCanvasToDisplaySize(gl.canvas);
  mod.instance.exports.update(t - prev_time);

  drawTest();

  prev_time = t;
  requestAnimationFrame(update);
}

async function loadWasm(url, imports) {
  return await WebAssembly.instantiateStreaming(fetch(url), imports);
}

function memToStr(start_ptr, len, mem) {
  const values = new Uint8Array(mem.buffer);
  const str = values.slice(start_ptr, start_ptr + len);
  return new TextDecoder("utf-8").decode(str);
}

function _console_log(msg, len) {
  console.log(memToStr(msg, len, mod.instance.exports.memory));
}

// --------------------------------------------------------------------------- //
// Graphics
// --------------------------------------------------------------------------- //
let canvas = undefined;
let canvasToDisplaySizeMap = undefined;
let resizeObserver = undefined;
let gl = undefined;

let test_program;
let test_vao;

function initGraphicsTest() {
  //TEST
  const vert = createShader(
    gl.VERTEX_SHADER,
    `#version 300 es
    in vec4 a_position;
    out vec3 pos;

    void main() {

      // gl_Position is a special variable a vertex shader
      // is responsible for setting
      gl_Position = a_position;
      pos = a_position.xyz;
    }`,
  );

  const frag = createShader(
    gl.FRAGMENT_SHADER,
    `#version 300 es
    precision highp float;

    in vec3 pos;
    out vec4 outColor;

    void main() {
      // Just set the output to a constant reddish-purple
      outColor = vec4(pos, 1);
    }`,
  );

  test_program = createProgram(vert, frag);

  var positionAttributeLocation = gl.getAttribLocation(
    test_program,
    "a_position",
  );
  var positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

  var positions = [-1, -1, -1, 1, 1, -1, 1, 1, 1, -1, -1, 1];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  test_vao = createVertexArray([
    {
      location: positionAttributeLocation,
      size: 2,
      stride: 0,
      offset: 0,
    },
  ]);
}

function drawTest() {
  gl.clear(gl.COLOR_BUFFER_BIT);
  gl.useProgram(test_program);
  gl.bindVertexArray(test_vao);
  gl.drawArrays(gl.TRIANGLES, 0, 6); // offset, count
  gl.bindVertexArray(null);
}

function useTexture(id, sampler) {
  //TODO if unbound, bind and update sampler value
}

function createVertexArray(attributes) {
  const vao = gl.createVertexArray();
  gl.bindVertexArray(vao);

  // set up attributes
  for (const a of attributes) {
    gl.enableVertexAttribArray(a.location);

    gl.vertexAttribPointer(
      a.location,
      a.size, // can be 1-4 (components)
      gl.FLOAT, // 32-bit float
      false, // do not normalize
      a.stride, // move forward size * sizeof(type) each iteration to get the next position
      a.offset, // start at the beginning of the buffer
    );
  }

  gl.bindVertexArray(null);
  return vao;
}

function _draw(queuePtr, stride, len) {
  // get draw queue from wasm mem
  const mem = mod.instance.exports.memory;
  const queue = new Uint32Array(mem.buffer, queuePtr, stride * len);

  for (let i = 0; i < len; i++) {
    const offset = i * stride;

    const programId = queue[0 + offset];
    const vaoId = queue[4 + offset];

    // mesh vertices
    const geometryBufferPtr = 0;
    const vertexCount = 0;

    // textures to use
    const textureBufferPtr = 0;
    const textureCount = 0;

    // instance vertex attribute values
    const attributeBufferPtr = 0;
    const instanceCount = 0;

    //TODO init gl rendering state
    // gl.useProgram(program);
    // gl.bindVertexArray(program);

    //TODO update vertex buffers
    // attribute layout is included in the VAO
    // zig data will follow that layout to enable direct copying
    // [array of structures format]

    //TODO render triangles
    // gl.drawArraysInstanced(gl.TRIANGLES, 0, vertexCount, instanceCount);
    gl.bindVertexArray(null);
  }
}

function _clear() {
  gl.clear(gl.COLOR_BUFFER_BIT);
}

function initGraphics() {
  gl = canvas.getContext("webgl2");
  if (!gl) throw new Error("WebGl2 not supported");

  canvasToDisplaySizeMap = new Map([[canvas, [300, 300]]]);
  resizeCanvasToDisplaySize(gl.canvas);
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  gl.clearColor(0, 0, 0, 0);
  gl.clear(gl.COLOR_BUFFER_BIT);
}

function createShader(type, source) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
  if (success) {
    return shader;
  }

  console.log(gl.getShaderInfoLog(shader));
  gl.deleteShader(shader);
}

function createProgram(vert, frag) {
  var program = gl.createProgram();
  gl.attachShader(program, vert);
  gl.attachShader(program, frag);
  gl.linkProgram(program);
  var success = gl.getProgramParameter(program, gl.LINK_STATUS);
  if (success) return program;

  console.log(gl.getProgramInfoLog(program));
  gl.deleteProgram(program);
}

function _set_clear_color(r, g, b, a) {
  gl.clearColor(r, g, b, a);
}

// https://webgl2fundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
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

  if (gl) gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  return needResize;
}

// https://webgl2fundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
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

// --------------------------------------------------------------------------- //
// Launch
// --------------------------------------------------------------------------- //

init();
