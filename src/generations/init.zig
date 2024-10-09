const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const log = @import("../utils/log.zig");
const os = @import("../utils/os.zig");
const config_dir = @import("../utils/config_dir.zig");
const data_dir = @import("../utils/data_dir.zig");
const file = @import("../utils/file.zig");
const main = @import("../main.zig");

pub fn init(allocator: mem.Allocator) void {
    createConfig(allocator);
    createData(allocator);
}

pub fn createConfig(allocator: mem.Allocator) void {
    log.info("Creating config folder...", .{});
    if (config_dir.create(allocator)) {
        const config_path = config_dir.getConfigDir(allocator);
        const host_path = file.joinPaths(config_path, "hosts", allocator);
        const host_name_path = file.joinPaths(
            host_path,
            os.getHostname(allocator),
            allocator,
        );
        const systems_path = file.joinPaths(
            config_path,
            "systems",
            allocator,
        );

        // Create the directories for system specific configuration
        if (!file.createDirectory(host_path)) {
            log.warn("Couldn't create hosts path!", .{});
        }
        if (!file.createDirectory(host_name_path)) {
            log.warn("Couldn't create hostname path!", .{});
        }

        // Create the directory for package manager definitions
        if (!file.createDirectory(systems_path)) {
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
