const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;

const log = @import("../utils/log.zig");
const data_dir = @import("../utils/data_dir.zig");

pub const Generation = struct {
    selected: bool,
    built: bool,
    description: []const u8,
    id: []const u8,
};

pub fn genFromDir(dir: []const u8, allocator: mem.Allocator) Generation {
    _ = allocator;
    //const data_path = data_dir.getDataDir(allocator);
    //const full_path = fs.path.join(allocator, &[_][]const u8{ data_path, dir }) catch |err| {
    //    // Failed to get generation directory, exit app nothing you can do.
    //    log.failure("Failed to append directory: {any}", .{err});
    //    posix.exit(1);
    //};

    const gen: Generation = .{
        .id = dir,
        .built = false,
        .selected = false,
        .description = "test",
    };

    return gen;
}
