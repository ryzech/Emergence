const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub const no_color: []const u8 = "\x1b[0m";
pub const green: []const u8 = "\x1b[32m";
pub const red: []const u8 = "\x1b[31m";
pub const orange: []const u8 = "\x1b[33m";
pub const light_gray: []const u8 = "\x1b[37m";

pub fn default(comptime format: []const u8, args: anytype) void {
    const message = std.fmt.allocPrint(
        std.heap.page_allocator,
        format,
        args,
    ) catch |err| {
        std.debug.print(
            "Error formatting log message: {}\n",
            .{err},
        );
        return;
    };
    defer std.heap.page_allocator.free(message);

    // TODO: switch this out for a better print method later
    std.debug.print("{s}\n", .{message});
}

pub fn info(comptime format: []const u8, args: anytype) void {
    const prefix = std.fmt.comptimePrint("{s}[{s}INFO{s}]{s} ", .{
        light_gray,
        green,
        light_gray,
        no_color,
    });

    const message = std.fmt.allocPrint(
        std.heap.page_allocator,
        prefix ++ format,
        args,
    ) catch |err| {
        std.debug.print(
            "Error formatting log message: {}\n",
            .{err},
        );
        return;
    };
    defer std.heap.page_allocator.free(message);

    // TODO: switch this out for a better print method later
    std.debug.print("{s}\n", .{message});
}

pub fn warn(comptime format: []const u8, args: anytype) void {
    const prefix = std.fmt.comptimePrint("{s}[{s}WARN{s}]{s} ", .{
        light_gray,
        orange,
        light_gray,
        no_color,
    });

    const message = std.fmt.allocPrint(
        std.heap.page_allocator,
        prefix ++ format,
        args,
    ) catch |err| {
        std.debug.print(
            "Error formatting log message: {}\n",
            .{err},
        );
        return;
    };
    defer std.heap.page_allocator.free(message);

    // TODO: switch this out for a better print method later
    std.debug.print("{s}\n", .{message});
}

pub fn failure(comptime format: []const u8, args: anytype) void {
    const prefix = std.fmt.comptimePrint("{s}[{s}FAILURE{s}]{s} ", .{
        light_gray,
        red,
        light_gray,
        no_color,
    });

    const message = std.fmt.allocPrint(
        std.heap.page_allocator,
        prefix ++ format,
        args,
    ) catch |err| {
        std.debug.print(
            "Error formatting log message: {}\n",
            .{err},
        );
        return;
    };
    defer std.heap.page_allocator.free(message);

    // TODO: switch this out for a better print method later
    std.debug.print("{s}\n", .{message});
}

pub fn success(comptime format: []const u8, args: anytype) void {
    const prefix = std.fmt.comptimePrint("{s}[{s}SUCCESS{s}]{s} ", .{
        light_gray,
        green,
        light_gray,
        no_color,
    });

    const message = std.fmt.allocPrint(
        std.heap.page_allocator,
        prefix ++ format,
        args,
    ) catch |err| {
        std.debug.print(
            "Error formatting log message: {}\n",
            .{err},
        );
        return;
    };
    defer std.heap.page_allocator.free(message);

    // TODO: switch this out for a better print method later
    std.debug.print("{s}\n", .{message});
}
