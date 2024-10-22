const std = @import("std");
const mem = std.mem;
const posix = std.posix;
const toml = @import("toml");

const config = @import("config.zig");
const config_dir = @import("../utils/config_dir.zig");
const file = @import("../utils/file.zig");
const paths = @import("../utils/paths.zig");
const log = @import("../utils/log.zig");

pub fn getSystems(allocator: mem.Allocator) void {
    const systems_files = file.getFiles(allocator, paths.getSystemsDir(allocator));
    defer {
        for (systems_files) |files| {
            allocator.free(files);
        }
        allocator.free(systems_files);
    }

    for (systems_files) |files| {
        const file_name = file.joinPaths(paths.getSystemsDir(allocator), files, allocator);

        var parser = toml.Parser(config.SystemConfig).init(allocator);
        defer parser.deinit();

        var result = parser.parseFile(file_name) catch |err| {
            switch (err) {
                error.CannotParseValue => {
                    return;
                },
                else => {
                    log.failure("Failed to parse file: \"{s}\" {any}", .{
                        file_name,
                        err,
                    });
                    posix.exit(1);
                },
            }
        };
        defer result.deinit();

        const system_config = result.value;

        log.info("{s}", .{system_config.display_name});
    }
}
