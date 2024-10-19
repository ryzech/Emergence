const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const toml = @import("toml");

const log = @import("../utils/log.zig");
const file = @import("../utils/file.zig");

pub const SystemPackage = struct {
    packages: [][]const u8,
};

pub const GenerationConfig = struct {
    imports: [][]const u8,
    systems: toml.HashMap(SystemPackage),
};

pub const SystemConfig = struct {
    name: []const u8,
    display_name: []const u8,

    add: []const u8,
    remove: []const u8,
    sync: []const u8,
    update: []const u8,

    combine: bool,
};
