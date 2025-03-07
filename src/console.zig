extern fn console_log(msg: [*]const u8, len: usize) void;

pub fn log(msg: []const u8) void {
    console_log(msg.ptr, msg.len);
}
