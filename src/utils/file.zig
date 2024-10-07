const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;

const log = @import("../utils/log.zig");

pub fn getDirectories(allocator: mem.Allocator, path: []const u8) [][]const u8 {
    var dir = fs.cwd().openDir(path, .{
        .iterate = true,
    }) catch |err| {
        log.failure("Failed to open directory: {any}", .{err});
        posix.exit(1);
    };
    defer dir.close();

    var dir_list = std.ArrayList([]const u8).init(allocator);
    defer {
        for (dir_list.items) |item| {
            allocator.free(item);
        }
        dir_list.deinit();
    }

    var iter = dir.iterate();
    while (iter.next() catch |err| {
        log.failure("Failed to search directory: {any}", .{err});
        posix.exit(1);
    }) |entry| {
        if (entry.kind == .directory) {
            const name = allocator.dupe(u8, entry.name) catch |err| {
                log.failure("Couldn't duplication the dir name: {any}", .{err});
                posix.exit(1);
            };
            dir_list.append(name) catch |err| {
                log.failure("Failed to append directory to list: {any}", .{err});
            };
        }
    }

    return dir_list.toOwnedSlice() catch |err| {
        log.failure("Failed to convert list: {any}", .{err});
        posix.exit(1);
    };
}