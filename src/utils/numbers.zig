const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const log = @import("log.zig");

pub fn usizeToString(value: usize, allocator: mem.Allocator) []const u8 {
    const string = std.fmt.allocPrint(allocator, "{d}", .{value}) catch |err| {
        log.failure("Failed to format usize: {any}", .{err});
        posix.exit(1);
    };
    return string;
}

pub fn stringToUsize(value: []const u8) usize {
    const usize_val = std.fmt.parseInt(usize, value, 10) catch |err| {
        log.failure("Failed to format string: {any}", .{err});
        posix.exit(1);
    };
    return usize_val;
}
