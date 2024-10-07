const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const log = @import("../utils/log.zig");
const config_dir = @import("../utils/config_dir.zig");
const data_dir = @import("../utils/data_dir.zig");
const main = @import("../main.zig");

pub fn createConfig(allocator: mem.Allocator) void {
    log.info("Creating config folder...", .{});
    log.info("Creating data folder...", .{});
    if (config_dir.create(allocator) and data_dir.create(allocator)) {
        log.success("Successfully initialized config.", .{});
        log.success("Successfully initialized data directory.", .{});
        return;
    }
    log.failure("Failed to initialize config or data directory.", .{});
    return;
}
