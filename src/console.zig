const std = @import("std");

extern fn console_log(msg: [*]const u8, len: usize) void;

const buf_len = 256;

// message buffer
var buf: [buf_len]u8 = @splat(0);

pub fn log(comptime fmt: []const u8, args: anytype) void {
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch blk: {
        // msg was too long, truncate with ellipse
        buf[buf_len - 1] = '.';
        buf[buf_len - 2] = '.';
        buf[buf_len - 3] = '.';
        break :blk buf[0..];
    };

    console_log(msg.ptr, msg.len);
}
