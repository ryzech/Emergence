const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const yaml = @import("yaml");

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");

pub fn loadConfig(path: []const u8, allocator: mem.Allocator) yaml.Yaml {
    const source = file.readContents(path, allocator);

    const config = yaml.Yaml.load(allocator, source) catch |err| {
        log.failure("Failed to parse file: \"{s}\" {any}", .{
            path,
            err,
        });
        posix.exit(1);
    };

    return config;
}
