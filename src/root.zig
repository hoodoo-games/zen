const std = @import("std");
const testing = std.testing;

const time = @import("time.zig");
const console = @import("console.zig");
const math = @import("math.zig");

export fn init() void {
    console.log("Hello Zen, from {s}!!!", .{"Wasm"});
}

export fn update(dt: f32) void {
    time.update_time(dt);
}
