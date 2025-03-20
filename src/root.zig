const std = @import("std");
const testing = std.testing;

const alloc = std.heap.wasm_allocator;

const time = @import("time.zig");
const console = @import("console.zig");
const math = @import("math.zig");
const graphics = @import("graphics.zig");

export fn init() void {
    console.log("Hello Zen, from {s}!!!", .{"Wasm"});
    graphics.set_clear_color(math.f32x4(0, 0, 0, 1));

    var vert = graphics.Shader.init(.vertex,
        \\gl_Position = a_position;
        \\pos = a_position.xyz;
    , alloc);

    vert.add_attribute("a_position", .{ .type = .float, .columns = 4 });
    vert.add_varying("pos", .{ .type = .float, .columns = 3 });

    vert.compile() catch unreachable;
}

export fn update(dt: f32) void {
    time.update_time(dt);
    graphics.update();
}

//TODO fixed update
