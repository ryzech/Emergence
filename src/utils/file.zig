const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;

const log = @import("../utils/log.zig");

pub fn getDirectoryCount(path: []const u8) usize {
    var dir = fs.cwd().openDir(path, .{
        .iterate = true,
    }) catch |err| {
        log.failure("Failed to open directory: {any}", .{err});
        posix.exit(1);
    };
    defer dir.close();

    var count: usize = 0;
    var iter = dir.iterate();
    while (iter.next() catch |err| {
        log.failure("Failed to search directory: {any}", .{err});
        posix.exit(1);
    }) |entry| {
        if (entry.kind == .directory) {
            count += 1;
        }
    }

    return count;
}

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

pub fn createDirectory(path: []const u8) bool {
    // Try to make the directory, if exists tell the user
    fs.makeDirAbsolute(path) catch |err| {
        if (err == error.PathAlreadyExists) {
            // Folder already exits, return true but warn that it already exists, and skipped creating.
            log.warn("The folder already exists, skipping.", .{});
            return true;
        }

        // Failed to create, return false
        log.failure(
            "An error occurred trying to create the folder: {any}",
            .{err},
        );
        return false;
    };

    log.info("Created directory at \"{s}\"", .{path});
    return true;
}
