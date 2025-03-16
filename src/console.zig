const std = @import("std");

extern fn _console_log(msg: [*]const u8, len: usize) void;

const buf_len = 256;

// message buffer
var buf: [buf_len]u8 = @splat(0);

pub fn log(comptime fmt: []const u8, args: anytype) void {
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch blk: {
        // msg was too long, truncate with ellipse
        @memcpy(buf[buf_len - 3 ..], "...");
        break :blk buf[0..];
    };

    _console_log(msg.ptr, msg.len);
}
