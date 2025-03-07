const std = @import("std");
const testing = std.testing;

const console = @import("console.zig");

export fn init() void {
    console.log("Hello Zen, from {s}!!", .{"Wasm"});
}
