const std = @import("std");

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");
const data_dir = @import("../utils/data_dir.zig");

pub fn listGenerations() void {
    // Create allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Get generic allocator from the arena allocator
    const allocator = arena.allocator();

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
