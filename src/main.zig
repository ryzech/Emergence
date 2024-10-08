const std = @import("std");
const mem = std.mem;
const yazap = @import("yazap");
const build_options = @import("build_options");

const allocator = std.heap.page_allocator;
const log = @import("utils/log.zig");

const App = yazap.App;
const Arg = yazap.Arg;

// Commands
const init = @import("generations/init.zig");
const list = @import("generations/list.zig");
const gen = @import("generations/gen.zig");

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

        // Create subcommand, create a new generation
        var cmd_generations_create = app.createCommand("create", "Create a new generation.");
        {
            try cmd_generations_create.addArg(Arg.singleValueOption("message", 'm', "Short description of the changes."));
        }
        try cmd_generations.addSubcommand(cmd_generations_create);
    }

    // Init subcommands
    var cmd_init = app.createCommand("init", "Initialize new configuration.");
    {
        try cmd_init.addArg(Arg.booleanOption("git", null, "Initialize git repository."));
    }

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
                return;
            }
            log.info("Creating", .{});
            return;
        }
        return;
    }

    // Init command
    if (matches.containsArg("init")) {
        init.createConfig(allocator);
        return;
    }
}
