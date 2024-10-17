const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const log = @import("../utils/log.zig");
const config = @import("config.zig");
const config_dir = @import("../utils/config_dir.zig");
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

    var imported_file = config.loadConfig(full_path, allocator);
    defer imported_file.deinit();

    if (imported_file.docs.items.len == 0) {
        return;
    }

    const map = imported_file.docs.items[0].map;
    const imports_node = map.get("import") orelse return;

    list.append(allocator.dupe(u8, path) catch |err| {
        log.failure("Failed to duplicate the path: {any}", .{err});
        posix.exit(1);
    }) catch |err| {
        log.failure("Failed to append import to list: {any}", .{err});
        posix.exit(1);
    };

    if (imports_node.list.len == 0) {
        return;
    }

    const imports = imports_node.list;

    for (imports) |import_path| {
        parseImports(hostname, import_path.string, list, allocator);
    }
}
