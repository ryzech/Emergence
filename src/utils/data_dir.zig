const std = @import("std");
const os = std.os;
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const main = @import("../main.zig");

const log = @import("log.zig");

/// Create the config directory in the specified directory name, if failure return false.
pub fn create(allocator: mem.Allocator) bool {
    // Get the config directory and set the folder name (the name of the app)
    const data_dir = getDataDir(allocator);

    // Try to make the directory, if exists tell the user
    fs.makeDirAbsolute(data_dir) catch |err| {
        if (err == error.PathAlreadyExists) {
            // Folder already exits, return true but warn that it already exists, and skipped creating.
            log.warn("The folder already exists, skipping.", .{});
            return true;
        }

        // Failed to create, return false
        log.failure("An error occurred trying to create the folder: {any}", .{err});
        return false;
    };

    // Created successfully, return true
    log.success("Created data directory.", .{});
    return true;
}

/// Get data directory at $HOME/.local/share
pub fn getDataDir(allocator: mem.Allocator) []const u8 {
    if (posix.getenv("HOME")) |home| {
        // Create path if succeeded
        const path = fs.path.join(allocator, &[_][]const u8{ home, ".local/share", main.name }) catch |err| {
            // Failed to get config directory, exit app nothing you can do.
            log.failure("Failed to get data directory: {any}", .{err});
            posix.exit(1);
        };

        // Return path
        return path;
    } else {
        // Failed to get home directory, exit app nothing you can do.
        log.failure("Failed to get home environment.", .{});
        posix.exit(1);
    }
}