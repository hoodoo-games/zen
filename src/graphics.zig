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
    program_id: usize,
    draw_config_id: usize,
    geometry_buffer_ptr: usize,
    vertex_count: usize,
    texture_buffer_ptr: usize,
    texture_count: usize,
    attribute_buffer_ptr: usize,
    instance_count: usize,
};

pub fn create_program() !Program {}
pub fn create_texture() !Texture {}

pub fn update() void {
    render();
}

fn render() void {
    clear();

    const geo_buffer = [_]f32{ -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, -1, 1 };
    const attr_buffer = [_]f32{0};

    // TESTING
    draw_queue.append(.{
        .program_id = 0,
        .draw_config_id = 1,
        .geometry_buffer_ptr = @intFromPtr(&geo_buffer[0]),
        .vertex_count = geo_buffer.len / 2,
        .texture_buffer_ptr = 0,
        .texture_count = 0,
        .attribute_buffer_ptr = @intFromPtr(&attr_buffer[0]),
        .instance_count = attr_buffer.len,
    }) catch unreachable;

    const geo_buffer_2 = [_]f32{ -0.1, -0.1, -0.1, 0.1, 0.1, -0.1, 0.1, 0.1, 0.1, -0.1, -0.1, 0.1 };
    const attr_buffer_2 = [_]f32{ -0.25, 0.25, 0.4, -0.4 };

    // TESTING
    draw_queue.append(.{
        .program_id = 2, //TODO dynamic ids
        .draw_config_id = 3,
        .geometry_buffer_ptr = @intFromPtr(&geo_buffer_2[0]),
        .vertex_count = geo_buffer_2.len / 2,
        .texture_buffer_ptr = 0,
        .texture_count = 0,
        .attribute_buffer_ptr = @intFromPtr(&attr_buffer_2[0]),
        .instance_count = attr_buffer_2.len / 2,
    }) catch unreachable;

    // prevents rendering when draw_queue has invalid pointer
    if (draw_queue.items.len < 1) return;

    _render(@intFromPtr(draw_queue.items.ptr), @sizeOf(DrawCall) / @sizeOf(usize), draw_queue.items.len);
    draw_queue.clearRetainingCapacity();
}

pub fn draw() void {}

pub fn clear() void {
    _clear();
}

pub fn set_clear_color(color: Color) void {
    draw_queue.clearRetainingCapacity();
    _set_clear_color(color[0], color[1], color[2], color[3]);
}

extern fn _set_clear_color(r: f32, g: f32, b: f32, a: f32) void;
extern fn _render(queue: usize, stride: usize, len: usize) void;
extern fn _clear() void;
