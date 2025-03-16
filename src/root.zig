const std = @import("std");
const testing = std.testing;

const time = @import("time.zig");
const console = @import("console.zig");
const math = @import("math.zig");
const graphics = @import("graphics.zig");

export fn init() void {
    console.log("Hello Zen, from {s}!!!", .{"Wasm"});
    graphics.set_clear_color(math.f32x4(0, 0, 0, 1));
}

export fn update(dt: f32) void {
    time.update_time(dt);
    graphics.update();
}

//TODO fixed update
