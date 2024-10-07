const std = @import("std");
const mem = std.mem;

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");
const data_dir = @import("../utils/data_dir.zig");

pub fn listGenerations(allocator: mem.Allocator) void {
    const dir = data_dir.getDataDir(allocator);
    defer allocator.free(dir);

    const directories = file.getDirectories(allocator, dir);
    defer {
        for (directories) |gen| {
            allocator.free(gen);
        }
        allocator.free(directories);
    }

    for (directories) |gen| {
        log.default("- {s}", .{gen});
    }
}
