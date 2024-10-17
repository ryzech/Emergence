const std = @import("std");
const mem = std.mem;
const posix = std.posix;

const config = @import("config.zig");
const log = @import("../utils/log.zig");

pub fn getSystems(allocator: mem.Allocator) std.ArrayList([]const u8) {}
