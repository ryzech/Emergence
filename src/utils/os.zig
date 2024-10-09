const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const log = @import("log.zig");

pub fn getHostname(allocator: mem.Allocator) []const u8 {
    var buffer: [posix.HOST_NAME_MAX]u8 = undefined;
    const hostname = posix.gethostname(&buffer) catch |err| {
        log.warn("Failed to get hostname! Defaulting to localhost: {any}", .{err});
        return "localhost";
    };
    return allocator.dupe(u8, hostname) catch |err| {
        log.warn("Failed to get hostname! Defaulting to localhost: {any}", .{err});
        return "localhost";
    };
}
