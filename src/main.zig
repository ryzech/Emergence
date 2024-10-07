const std = @import("std");
const yazap = @import("yazap");
const build_options = @import("build_options");

const allocator = std.heap.page_allocator;
const log = @import("utils/log.zig");

const App = yazap.App;
const Arg = yazap.Arg;

// Commands
const init = @import("generations/init.zig");

// App name used for directories etc.
pub const name: []const u8 = "emergence/";

pub fn main() anyerror!void {
    var app = App.init(allocator, "emergence", "NixOS-Like generations for gentoo based systems.");
    defer app.deinit();

    // Root command
    var emergence = app.rootCommand();
    emergence.setProperty(.help_on_empty_args);

    // Generations subcommand
    var cmd_generations = app.createCommand("gen", "Configure or view information about the generations.");
    {
        // Set command properties
        cmd_generations.setProperty(.help_on_empty_args);

        // List subcommand, show all generations
        try cmd_generations.addSubcommand(app.createCommand("list", "List all generations."));
    }

    // Init subcommands
    const cmd_init = app.createCommand("init", "Initialize new configuration.");

    // Add args and subcommands to the root command
    try emergence.addSubcommand(cmd_generations);
    try emergence.addSubcommand(cmd_init);
    try emergence.addArg(Arg.booleanOption("version", 'v', "Display program version number"));

    const matches = try app.parseProcess();

    // Match arguments
    if (matches.containsArg("version")) {
        log.default("Version - {s}", .{
            build_options.version,
        });
        return;
    }

    // Match subcommands
    if (matches.subcommandMatches("gen")) |gen_cmd_matches| {
        if (gen_cmd_matches.containsArg("list")) {
            log.info("Listing all generations.", .{});
            return;
        }
        return;
    }

    if (matches.subcommandMatches("init")) |_| {
        init.createConfig();
        return;
    }
}
