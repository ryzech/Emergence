const std = @import("std");
const mem = std.mem;
const yazap = @import("yazap");
const build_options = @import("build_options");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const log = @import("utils/log.zig");

const App = yazap.App;
const Arg = yazap.Arg;

const init = @import("generations/init.zig");
const list = @import("generations/list.zig");
const gen = @import("generations/gen.zig");

const gen_cmd = @import("commands/gen.zig");
const init_cmd = @import("commands/init.zig");

const gen_conf = @import("config/gen.zig");
const sys_conf = @import("config/systems.zig");

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
    try emergence.addArg(Arg.booleanOption("version", 'v', "Display program version number."));
    try emergence.addArg(Arg.booleanOption("verbose", 'V', "Enable verbose logging."));

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
                    const message = create_cmd_matches.getSingleValue("message") orelse "";
                    log.info("Creating with message: {s}", .{message});
                    gen.create(allocator, message);
                    return;
                }
                log.warn("No message specified, this won't cause any issues but it's a good idea to document changes.", .{});
                log.info("Creating", .{});
                gen.create(allocator, null);
                return;
            }

            if (gen_cmd_matches.subcommandMatches("select")) |select_cmd_matches| {
                if (select_cmd_matches.containsArg("id")) {
                    const id = select_cmd_matches.getSingleValue("id") orelse "";
                    gen.Generation.select(id, allocator);
                    log.success("Set generation {s} as selected.", .{id});
                    return;
                }
                log.warn("No ID given! Please specify an ID.", .{});
                return;
            }

            if (gen_cmd_matches.subcommandMatches("build")) |build_cmd_matches| {
                if (build_cmd_matches.containsArg("id")) {
                    const id = build_cmd_matches.getSingleValue("id") orelse "";
                    log.info("Building generation {s}...", .{id});

                    gen.Generation.build(id, allocator);

                    log.success("Built generation {s}.", .{id});
                    return;
                }
                const id = gen.getSelected(allocator);
                log.info("Building generation {s}...", .{id});

                gen.Generation.build(id, allocator);

                log.success("Built generation {s}.", .{id});
                return;
            }
            return;
        }
    }

    // Init command
    {
        if (matches.containsArg("init")) {
            init.init(allocator);
            return;
        }
    }
}
