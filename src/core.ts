export * as Entities from "./entities";

let running: boolean = false;

let canvas: HTMLCanvasElement;
let canvasResizeObserver: ResizeObserver;

// timing
let elapsedTime: number = 0;
let deltaTime: number = 0;
let currentTime: DOMHighResTimeStamp = 0;
let previousTime: DOMHighResTimeStamp = 0;

export async function start(options: { canvas: HTMLCanvasElement }) {
  running = true;

  canvas = options.canvas;
  initCanvasResize();

  requestAnimationFrame(update);
}

export function stop() {
  running = false;
  canvasResizeObserver.disconnect();
}

function update(ts: DOMHighResTimeStamp) {
  if (!running) return;

  previousTime = currentTime;
  currentTime = ts * 0.001;
  deltaTime = currentTime - previousTime;
  elapsedTime += deltaTime;

  requestAnimationFrame(update);
}

function initCanvasResize() {
  canvasResizeObserver = new ResizeObserver((entries) => {
    for (const entry of entries) {
      const pixelBox = entry.devicePixelContentBoxSize?.[0];
      const contentBox = entry.contentBoxSize[0];
      const dpr = window.devicePixelRatio;

      const width = pixelBox.inlineSize || contentBox.inlineSize * dpr;
      const height = pixelBox.blockSize || contentBox.blockSize * dpr;

      const c = entry.target as HTMLCanvasElement;
      // const maxTexSize = this.gpu.device!.limits.maxTextureDimension2D;
      const maxTexSize = 4096;

      c.width = Math.max(1, Math.min(width, maxTexSize));
      c.height = Math.max(1, Math.min(height, maxTexSize));

      // re-render
      // render();
    }
  });

  try {
    canvasResizeObserver.observe(canvas, { box: "device-pixel-content-box" });
  } catch {
    canvasResizeObserver.observe(canvas, { box: "content-box" });
  }
}
