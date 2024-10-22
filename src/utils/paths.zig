const std = @import("std");
const mem = std.mem;

const file = @import("file.zig");
const config_dir = @import("config_dir.zig");
const data_dir = @import("data_dir.zig");

pub fn getDataDir(allocator: mem.Allocator) []const u8 {
    return data_dir.getDataDir(allocator);
}

pub fn getConfigDir(allocator: mem.Allocator) []const u8 {
    return config_dir.getConfigDir(allocator);
}

pub fn getHostsDir(allocator: mem.Allocator) []const u8 {
    return file.joinPaths(getConfigDir(allocator), "hosts/", allocator);
}

pub fn getSystemsDir(allocator: mem.Allocator) []const u8 {
    return file.joinPaths(getConfigDir(allocator), "systems/", allocator);
}

pub fn getHostnameDir(hostname: []const u8, allocator: mem.Allocator) []const u8 {
    return file.joinPaths(getHostsDir(allocator), hostname, allocator);
}
