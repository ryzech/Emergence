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
    const config_dir = getConfigDir(allocator);

    // Create the config directory
    if (!file.createDirectory(config_dir)) return false;

    // Created successfully, return true
    log.info("Created config directory.", .{});
    return true;
}

/// Get $XDG_CONFIG_HOME or else default to $HOME/.config
pub fn getConfigDir(allocator: mem.Allocator) []const u8 {
    const config = folders.getPath(allocator, folders.KnownFolder.local_configuration) catch |err| {
        log.failure("Failed to get config directory: {any}", .{err});
        posix.exit(1);
    } orelse "";
    return file.joinPaths(config, main.name, allocator);
}
