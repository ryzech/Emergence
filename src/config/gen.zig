const std = @import("std");
const yaml = @import("yaml");
const mem = std.mem;
const fs = std.fs;
const math = std.math;
const posix = std.posix;

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");
const config = @import("config.zig");

pub fn getImports(path: []const u8, allocator: mem.Allocator) std.ArrayList([]const u8) {
    var conf = config.loadConfig(path, allocator);
    defer conf.deinit();

    if (conf.docs.items.len == 0) {
        log.warn("Empty YAML file: {s}", .{path});
    }

    var imports = std.ArrayList([]const u8).init(allocator);
    errdefer {
        for (imports.items) |item| {
            allocator.free(item);
        }
        imports.deinit();
    }

    if (conf.docs.items[0].map.get("import")) |import| {
        for (import.list) |import_path| {
            const duped_path = allocator.dupe(u8, import_path.string) catch |err| {
                log.failure("Failed to duplicate import: {any}", .{err});
                continue;
            };

            imports.append(duped_path) catch |err| {
                log.failure("Failed to append import to list: {any}", .{err});
                allocator.free(duped_path);
                continue;
            };
        }
    }

    return imports;
}
