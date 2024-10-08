const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;

const file = @import("../utils/file.zig");
const log = @import("../utils/log.zig");
const data_dir = @import("../utils/data_dir.zig");
const numbers = @import("../utils/numbers.zig");

pub const Generation = struct {
    selected: bool,
    built: bool,
    description: []const u8,
    id: usize,
};

pub fn genFromDir(dir: []const u8, allocator: mem.Allocator) Generation {
    _ = allocator;
    //const data_path = data_dir.getDataDir(allocator);
    //const full_path = fs.path.join(allocator, &[_][]const u8{ data_path, dir }) catch |err| {
    //    // Failed to get generation directory, exit app nothing you can do.
    //    log.failure("Failed to append directory: {any}", .{err});
    //    posix.exit(1);
    //};
    const id = numbers.stringToUsize(dir);

    const gen: Generation = .{
        .id = id,
        .built = false,
        .selected = false,
        .description = "test",
    };

    return gen;
}

pub fn create(allocator: mem.Allocator, message: ?[]const u8) void {
    _ = message;
    //const desc = message orelse "";
    const dir = data_dir.getDataDir(allocator);
    const total_generations: usize = file.getDirectoryCount(dir);

    const num = total_generations + 1;
    const id = numbers.usizeToString(num, allocator);
    const full_dir = fs.path.join(allocator, &[_][]const u8{ dir, id }) catch |err| {
        // Failed to get data directory, exit app nothing you can do.
        log.failure("Failed to append directory id: {any}", .{err});
        posix.exit(1);
    };

    if (!file.createDirectory(full_dir)) {
        log.failure("Failed to create new generation: {s}", .{id});
    }
}
