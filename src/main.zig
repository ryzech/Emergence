const std = @import("std");
const mem = std.mem;
const yazap = @import("yazap");
const build_options = @import("build_options");

const allocator = std.heap.page_allocator;
const log = @import("utils/log.zig");

const App = yazap.App;
const Arg = yazap.Arg;

const init = @import("generations/init.zig");
const list = @import("generations/list.zig");
const gen = @import("generations/gen.zig");

const gen_cmd = @import("commands/gen.zig");
const init_cmd = @import("commands/init.zig");

// App name used for directories etc.
pub const name: []const u8 = "emergence";

pub fn main() anyerror!void {
    var app = App.init(allocator, "emergence", "NixOS-Like generations for gentoo based systems.");
    defer app.deinit();

    // Root command
    var emergence = app.rootCommand();
    emergence.setProperty(.help_on_empty_args);

    // Add args and subcommands to the root command
    try emergence.addSubcommand(try gen_cmd.create(allocator, &app));
    try emergence.addSubcommand(try init_cmd.create(allocator, &app));
    try emergence.addArg(Arg.booleanOption("version", 'v', "Display program version number"));

    const matches = try app.parseProcess();

    // Match arguments
    if (matches.containsArg("version")) {
        log.default("Version - {s}", .{
            build_options.version,
        });
        return;
    }

    // Gen command
    {
        if (matches.subcommandMatches("gen")) |gen_cmd_matches| {
            // List command
            if (gen_cmd_matches.containsArg("list")) {
                log.info("Listing all generations.", .{});
                list.listGenerations(allocator);
                return;
            }

            // Create command
            if (gen_cmd_matches.subcommandMatches("create")) |create_cmd_matches| {
                if (create_cmd_matches.containsArg("message")) {
                    const message: []const u8 = create_cmd_matches.getSingleValue("message") orelse "";
                    log.info("Creating with message: {s}", .{message});
                    gen.create(allocator, message);
                    return;
                }
                log.info("Creating", .{});
                gen.create(allocator, null);
                return;
            }
            return;
        }
    }

    // Init command
    {
        if (matches.containsArg("init")) {
            init.createConfig(allocator);
            return;
        }
    }
}
