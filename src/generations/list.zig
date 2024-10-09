const std = @import("std");
const mem = std.mem;

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");
const gen = @import("gen.zig");
const data_dir = @import("../utils/data_dir.zig");

pub fn listGenerations(allocator: mem.Allocator) void {
    const dir = data_dir.getDataDir(allocator);
    defer allocator.free(dir);

    const directories = file.getDirectories(allocator, dir);
    defer {
        for (directories) |generation| {
            allocator.free(generation);
        }
        allocator.free(directories);
    }

    for (directories) |generation| {
        const gen_data = gen.genFromDir(generation, allocator);
        log.default("- {d} {s}", .{
            gen_data.id,
            gen_data.description,
        });
    }
    log.info("Total generations: {any}", .{file.getDirectoryCount(dir)});
}
