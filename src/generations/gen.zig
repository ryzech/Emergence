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
    const data_path = data_dir.getDataDir(allocator);
    const full_path = file.joinPaths(data_path, dir, allocator);
    const info_file = file.joinPaths(full_path, "info", allocator);

    const id = numbers.stringToUsize(dir);
    const desc = file.readContents(info_file, allocator);

    const gen: Generation = .{
        .id = id,
        .built = false,
        .selected = false,
        .description = desc,
    };

    return gen;
}

pub fn create(allocator: mem.Allocator, message: ?[]const u8) void {
    const desc = message orelse "";
    const dir = data_dir.getDataDir(allocator);
    const total_generations: usize = file.getDirectoryCount(dir);

    const num = total_generations + 1;
    const id = numbers.usizeToString(num, allocator);
    const full_dir = file.joinPaths(dir, id, allocator);
    const info_file = file.joinPaths(full_dir, "info", allocator);

    if (!file.createDirectory(full_dir)) {
        log.failure("Failed to create new generation: {s}", .{id});
    }

    if (!file.createFile(info_file, desc)) {
        log.failure("Failed to create info file for generation {s}", .{id});
    }
}
