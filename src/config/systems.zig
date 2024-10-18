const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const config = @import("config.zig");
const config_dir = @import("../utils/config_dir.zig");
const file = @import("../utils/file.zig");
const log = @import("../utils/log.zig");

pub fn getSystems(allocator: mem.Allocator) void {
    const dir = config_dir.getConfigDir(allocator);
    defer allocator.free(dir);

    const system_dir = file.joinPaths(dir, "systems", allocator);
    defer allocator.free(system_dir);

    const systems_files = file.getFiles(allocator, system_dir);
    defer {
        for (systems_files) |files| {
            allocator.free(files);
        }
        allocator.free(systems_files);
    }

    for (systems_files) |files| {
        const system: config.System = config.System.fromFile(files, allocator);
        log.default("Name: {s} Display Name: {s}", .{
            system.name,
            system.display_name,
        });
    }
}
