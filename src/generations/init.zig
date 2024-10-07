const std = @import("std");
const fs = std.fs;

const log = @import("../utils/log.zig");
const config_dir = @import("../utils/config_dir.zig");
const data_dir = @import("../utils/data_dir.zig");
const main = @import("../main.zig");

pub fn createConfig() void {
    // Create allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Get generic allocator from the arena allocator
    const alloc = arena.allocator();

    log.info("Creating config folder...", .{});
    if (config_dir.create(alloc) and data_dir.create(alloc)) {
        log.success("Successfully initialized config.", .{});
        log.success("Successfully initialized data directory.", .{});
        return;
    }
    log.failure("Failed to initialize config or data directory.", .{});
    return;
}
