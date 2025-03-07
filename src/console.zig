extern fn console_log(msg: [*]const u8) void;

fn log(msg: []const u8) void {
    console_log(msg);
}
