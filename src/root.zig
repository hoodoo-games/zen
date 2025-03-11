const std = @import("std");
const testing = std.testing;

const console = @import("console.zig");
const math = @import("math.zig");

export fn init() void {
    const cos = math.cos(math.f32x4(0, 1, 2, 3));
    console.log("Hello Zen, from {s}!!! {d}", .{ "Wasm", cos[0] });
}
