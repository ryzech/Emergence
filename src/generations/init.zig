const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const log = @import("../utils/log.zig");
const os = @import("../utils/os.zig");
const config_dir = @import("../utils/config_dir.zig");
const data_dir = @import("../utils/data_dir.zig");
const paths = @import("../utils/paths.zig");
const file = @import("../utils/file.zig");
const main = @import("../main.zig");

pub fn init(allocator: mem.Allocator) void {
    createConfig(allocator);
    createData(allocator);
}

pub fn createConfig(allocator: mem.Allocator) void {
    log.info("Creating config folder...", .{});
    if (config_dir.create(allocator)) {
        const host_gen_path = file.joinPaths(
            paths.getHostnameDir(os.getHostname(allocator), allocator),
            "main.toml",
            allocator,
        );
        // Create the directories for system specific configuration
        if (!file.createDirectory(paths.getHostsDir(allocator))) {
            log.warn("Couldn't create hosts path!", .{});
        }

        if (!file.createDirectory(paths.getHostnameDir(os.getHostname(allocator), allocator))) {
            log.warn("Couldn't create hostname path!", .{});
        } else {
            if (!file.createFile(host_gen_path, @embedFile("../embeds/main.toml"), .{})) {
                log.warn("Couldn't create default generation config!", .{});
            }
        }

        // Create the directory for package manager definitions
        if (!file.createDirectory(paths.getSystemsDir(allocator))) {
            log.warn("Couldn't create systems path!", .{});
        }

        log.success("Successfully initialized config.", .{});
        return;
    }
    log.failure("Failed to initialize config directory.", .{});
    return;
}

pub fn createData(allocator: mem.Allocator) void {
    // Create the directory for data storage (where the generations are stored)
    log.info("Creating data folder...", .{});
    if (data_dir.create(allocator)) {
        log.success("Successfully initialized data.", .{});
        return;
    }
    log.failure("Failed to initialize data directory.", .{});
    return;
}
