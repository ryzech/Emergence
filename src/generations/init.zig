const std = @import("std");
const fs = std.fs;

const log = @import("../utils/log.zig");
const files = @import("../utils/files.zig");
const main = @import("../main.zig");

pub fn createConfig() void {
    log.info("Creating config folder...", .{});
    if (files.createConfigDirectory(main.name)) {
        log.success("Successfully initialized config.", .{});
        return;
    }
    log.failure("Failed to initialize config.", .{});
    return;
}
