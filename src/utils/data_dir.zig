const std = @import("std");
const os = std.os;
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const main = @import("../main.zig");
const file = @import("file.zig");
const folders = @import("known-folders");

const log = @import("log.zig");

/// Create the config directory in the specified directory name, if failure return false.
pub fn create(allocator: mem.Allocator) bool {
    // Get the config directory and set the folder name (the name of the app)
    const data_dir = getDataDir(allocator);

    // Create the directory
    if (!file.createDirectory(data_dir)) return false;

    // Created successfully, return true
    log.info("Created data directory.", .{});
    return true;
}

/// Get data directory at $HOME/.local/share
pub fn getDataDir(allocator: mem.Allocator) []const u8 {
    const data = folders.getPath(allocator, folders.KnownFolder.data) catch |err| {
        log.failure("Failed to get data directory: {any}", .{err});
        posix.exit(1);
    } orelse "";
    return fs.path.join(allocator, &[_][]const u8{ data, main.name }) catch |err| {
        // Failed to get config directory, exit app nothing you can do.
        log.failure("Failed to append data directory: {any}", .{err});
        posix.exit(1);
    };
}
