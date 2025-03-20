const std = @import("std");

const Alloc = std.mem.Allocator;
const alloc = std.heap.wasm_allocator;

const math = @import("math.zig");
const console = @import("console.zig");
const time = @import("time.zig");

var draw_queue = std.ArrayList(DrawCall).init(alloc);

pub const Color = math.F32x4;

const DrawCall = extern struct {
    program_id: usize,
    draw_context_id: usize,
    geometry_buffer_ptr: usize,
    vertex_count: usize,
    texture_buffer_ptr: usize,
    texture_count: usize,
    attribute_buffer_ptr: usize,
    instance_count: usize,
};

pub fn create_program(vert_src_id: usize, frag_src_id: usize) !usize {
    const id = _create_program(vert_src_id, frag_src_id);
    return id; //TODO error handling
}

pub fn create_draw_context(program_id: usize) !usize {
    const id = _create_draw_context(program_id);
    return id; //TODO error handling
}

pub const Shader = struct {
    allocator: Alloc,
    id: usize = 0, // set when compiled, points to JS asset
    kind: Kind,
    main_body_src: []const u8,

    uniforms: std.ArrayList(Variable),
    samplers: std.ArrayList(Sampler),
    attributes: std.ArrayList(Variable),
    varyings: std.ArrayList(Variable),
    functions: std.ArrayList(Function),

    pub fn init(kind: Kind, main_body_src: []const u8, allocator: Alloc) Shader {
        return .{
            .allocator = allocator,
            .kind = kind,
            .main_body_src = main_body_src,
            .uniforms = std.ArrayList(Variable).init(allocator),
            .samplers = std.ArrayList(Sampler).init(allocator),
            .attributes = std.ArrayList(Variable).init(allocator),
            .varyings = std.ArrayList(Variable).init(allocator),
            .functions = std.ArrayList(Function).init(allocator),
        };
    }

    pub fn deinit(this: *Shader) void {
        this.uniforms.deinit();
        this.samplers.deinit();
        this.attributes.deinit();
        this.varyings.deinit();
        this.functions.deinit();
    }

    pub fn compile(this: *Shader) !void {
        var src = std.ArrayList(u8).init(this.allocator);
        src.appendSlice("#version 300 es\n\n") catch unreachable;

        var line_buf: [256]u8 = @splat(0);

        //TODO VERTEX/FRAGMENT differences

        //TODO uniforms

        //TODO samplers

        // attributes
        for (this.attributes.items) |u| {
            const line = std.fmt.bufPrint(&line_buf, "in {s} {s};\n", .{ u.datatype.to_string(), u.name }) catch unreachable;
            src.appendSlice(line) catch unreachable;
        }

        src.append('\n') catch unreachable;

        //TODO varyings
        for (this.varyings.items) |u| {
            const line = std.fmt.bufPrint(&line_buf, "out {s} {s};\n", .{ u.datatype.to_string(), u.name }) catch unreachable;
            src.appendSlice(line) catch unreachable;
        }

        src.append('\n') catch unreachable;

        //TODO functions

        // main function
        const main = std.fmt.bufPrint(&line_buf, "void main() {{\n{s}\n}}", .{this.main_body_src}) catch unreachable;
        src.appendSlice(main) catch unreachable;

        //TODO generate shader glsl src string and compile with JS
        _compile_shader(src.items.ptr, src.items.len, this.kind);
    }

    pub fn add_uniform(this: *Shader, name: []const u8, datatype: Datatype) void {
        this.uniforms.append(.{ .name = name, .datatype = datatype }) catch unreachable;
    }

    pub fn add_sampler(this: *Shader, name: []const u8) void {
        this.samplers.append(.{ .name = name }) catch unreachable;
    }

    pub fn add_attribute(this: *Shader, name: []const u8, datatype: Datatype) void {
        this.attributes.append(.{ .name = name, .datatype = datatype }) catch unreachable;
    }

    pub fn add_varying(this: *Shader, name: []const u8, datatype: Datatype) void {
        this.varyings.append(.{ .name = name, .datatype = datatype }) catch unreachable;
    }

    pub fn add_function(this: *Shader, function: Function) void {
        this.functions.append(function) catch unreachable;
    }

    const Datatype = struct {
        type: Type,
        columns: usize = 1, // 1..4
        rows: usize = 1, // 1..4

        const Type = enum {
            int,
            uint,
            float,
        };

        fn to_string(this: *const Datatype) [10]u8 {
            var buf: [10]u8 = @splat(0);

            //TODO non-float support

            if (this.columns == 1 and this.rows == 1) {
                _ = std.fmt.bufPrint(&buf, "float", .{}) catch unreachable;
            } else if (this.columns > 1 and this.rows == 1) {
                _ = std.fmt.bufPrint(&buf, "vec{d}", .{this.columns}) catch unreachable;
            } else if (this.rows > 1 and this.columns == 1) {
                _ = std.fmt.bufPrint(&buf, "vec{d}", .{this.columns}) catch unreachable;
            } else {
                _ = std.fmt.bufPrint(&buf, "mat{d}", .{this.columns}) catch unreachable;
            }

            return buf;
        }
    };

    const Kind = enum(usize) { vertex, fragment };

    //TODO default value (needed for control over fallback)
    const Variable = struct {
        name: []const u8,
        datatype: Datatype,
    };

    const Sampler = struct {
        name: []const u8,
        //TODO sampler settings
    };

    const Function = struct {
        name: []const u8,
        args: []Variable,
        return_type: Datatype,
        body: []const u8,

        pub fn init() Function {}
        pub fn deinit(_: *Function) void {}
    };
};

const Program = struct {
    id: usize, // points to JS asset
    name: []const u8,

    pub fn init(_: []const u8, _: Shader, _: Shader) Program {}
    pub fn deinit() void {}
};

// determines structure of geometry and instance buffers
const DrawContext = struct {
    id: usize, // points to JS asset

    pub fn init(_: Program) DrawContext {}
    pub fn deinit() void {}
};

// SET DRAW CONTEXT
// SET GEOMETRY BUFFER
// SET INSTANCE BUFFER
// ENQUEUE DRAW CALL

pub fn create_texture() !usize {}

extern fn _create_program(vert_src_id: usize, frag_src_id: usize) usize;
extern fn _create_draw_context(program_id: usize) usize;
extern fn _compile_shader(src: [*]u8, len: usize, type: Shader.Kind) void;

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
        .draw_context_id = 1,
        .geometry_buffer_ptr = @intFromPtr(&geo_buffer[0]),
        .vertex_count = geo_buffer.len / 2,
        .texture_buffer_ptr = 0,
        .texture_count = 0,
        .attribute_buffer_ptr = @intFromPtr(&attr_buffer[0]),
        .instance_count = attr_buffer.len,
    }) catch unreachable;

    const geo_buffer_2 = [_]f32{ -0.1, -0.1, -0.1, 0.1, 0.1, -0.1, 0.1, 0.1, 0.1, -0.1, -0.1, 0.1 };
    var attr_buffer_2 = [_]f32{ -0.25, 0.25, 0.4, -0.4, 0.2, 0.2, -0.2, -0.2 };

    attr_buffer_2[0] += @floatCast(0.1 * @sin(time.time));
    attr_buffer_2[1] += @floatCast(0.1 * @sin(time.time));

    // TESTING
    draw_queue.append(.{
        .program_id = 2, //TODO dynamic ids
        .draw_context_id = 3,
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

//TODO enqueue draw call
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
