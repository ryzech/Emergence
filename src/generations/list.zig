const std = @import("std");
const mem = std.mem;

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");
const gen = @import("gen.zig");
const paths = @import("../utils/paths.zig");

pub fn listGenerations(allocator: mem.Allocator) void {
    const dir = paths.getDataDir(allocator);
    defer allocator.free(dir);

    const directories = file.getDirectories(allocator, dir);
    defer {
        for (directories) |generation| {
            allocator.free(generation);
        }
        allocator.free(directories);
    }

    for (directories) |generation| {
        const gen_data = gen.Generation.fromDir(generation, allocator);
        log.default("- {d} {s} {s} {s}", .{
            gen_data.id,
            gen_data.description,
            if (gen_data.selected) "(selected)" else "",
            if (gen_data.built) "(built)" else "",
        });
    }
    log.info("Total generations: {any}", .{file.getDirectoryCount(dir)});
}
