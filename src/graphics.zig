const std = @import("std");

const alloc = std.heap.wasm_allocator;

const math = @import("math.zig");
const console = @import("console.zig");

var draw_queue = std.ArrayList(DrawCall).init(alloc);

pub const Program = struct {};
pub const Geometry = struct {};
pub const Texture = struct {};
pub const Color = math.F32x4;

const DrawCall = extern struct {
    program: usize,
    geometry: usize,
};

pub fn create_program() !Program {}
pub fn create_texture() !Texture {}

pub fn update() void {
    draw();
}

pub fn draw() void {
    clear();

    // TESTING
    draw_queue.append(.{ .program = 0, .geometry = 0 }) catch unreachable;

    // prevents rendering when draw_queue has invalid pointer
    if (draw_queue.items.len < 1) return;

    _draw(@intFromPtr(draw_queue.items.ptr), @sizeOf(DrawCall), draw_queue.items.len);
    draw_queue.clearRetainingCapacity();
}

pub fn clear() void {
    _clear();
}

pub fn set_clear_color(color: Color) void {
    draw_queue.clearRetainingCapacity();
    _set_clear_color(color[0], color[1], color[2], color[3]);
}

extern fn _set_clear_color(r: f32, g: f32, b: f32, a: f32) void;
extern fn _draw(queue: usize, stride: usize, len: usize) void;
extern fn _clear() void;
