const std = @import("std");
const os = std.os;
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;

const log = @import("log.zig");

// Create the config directory in the specified directory name, if failure return false.
pub fn createConfigDirectory(dir: []const u8) bool {
    // Create allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Get generic allocator from the arena allocator
    const allocator = arena.allocator();

    // Get the config directory and set the folder name (the name of the app)
    const config_dir = getConfigDir(allocator);
    const folder = dir;

    // Combine the paths into one
    const full_path = fs.path.join(allocator, &[_][]const u8{ config_dir, folder }) catch |err| {
        // Failed to join the pahts, return the error and return false.
        log.failure("Failed to join paths: {any}", .{err});
        return false;
    };

    // Try to make the directory, if exists tell the user
    fs.makeDirAbsolute(full_path) catch |err| {
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
    log.success("Created config directory.", .{});
    return true;
}

// Get $XDG_CONFIG_HOME or else default to $HOME/.config
pub fn getConfigDir(allocator: mem.Allocator) []const u8 {
    // Check for XDG_CONFIG_HOME environment variable
    if (posix.getenv("XDG_CONFIG_HOME")) |path| {
        // $XDG_CONFIG_HOME exists return the path
        return path;
    }

    // If XDG_CONFIG_HOME is not set, use the default ~/.config
    if (posix.getenv("HOME")) |home| {
        // Create path if succeeded
        const path = fs.path.join(allocator, &[_][]const u8{ home, ".config" }) catch |err| {
            // Failed to get config directory, exit app nothing you can do.
            log.failure("Failed to get config directory: {any}", .{err});
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
