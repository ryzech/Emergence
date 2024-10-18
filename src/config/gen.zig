const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const log = @import("../utils/log.zig");
const config = @import("config.zig");
const config_dir = @import("../utils/config_dir.zig");
const toml = @import("toml");
const file = @import("../utils/file.zig");

pub fn getImports(hostname: []const u8, path: []const u8, allocator: mem.Allocator) [][]const u8 {
    var import_list = std.ArrayList([]const u8).init(allocator);
    defer {
        for (import_list.items) |item| {
            allocator.free(item);
        }
        import_list.deinit();
    }

    parseImports(hostname, path, &import_list, allocator);

    return import_list.toOwnedSlice() catch |err| {
        log.failure("Failed to convert list: {any}", .{err});
        posix.exit(1);
    };
}

fn parseImports(hostname: []const u8, path: []const u8, list: *std.ArrayList([]const u8), allocator: mem.Allocator) void {
    const config_path = config_dir.getConfigDir(allocator);
    const host_path = file.joinPaths(config_path, "hosts", allocator);
    const host_name_path = file.joinPaths(
        host_path,
        hostname,
        allocator,
    );
    const full_path = file.joinPaths(host_name_path, path, allocator);

    var parser = toml.Parser(config.GenerationConfig).init(allocator);
    defer parser.deinit();

    var result = parser.parseFile(full_path) catch |err| {
        switch (err) {
            error.CannotParseValue => {
                return;
            },
            else => {
                log.failure("Failed to parse file: \"{s}\" {any}", .{
                    full_path,
                    err,
                });
                posix.exit(1);
            },
        }
    };
    defer result.deinit();

    const gen_config = result.value;

    list.append(allocator.dupe(u8, path) catch |err| {
        log.failure("Failed to duplicate the path: {any}", .{err});
        posix.exit(1);
    }) catch |err| {
        log.failure("Failed to append import to list: {any}", .{err});
        posix.exit(1);
    };

    if (gen_config.imports.len == 0) {
        return;
    }

    for (gen_config.imports) |import_path| {
        parseImports(hostname, import_path, list, allocator);
    }
}
