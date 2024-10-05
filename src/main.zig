const std = @import("std");
const yazap = @import("yazap");
const build_options = @import("build_options");

const allocator = std.heap.page_allocator;
const log = std.log;
const color = @import("utils/color.zig");

const App = yazap.App;
const Arg = yazap.Arg;

pub fn main() anyerror!void {
    var app = App.init(allocator, "emergence", "NixOS-Like generations for gentoo based systems.");
    defer app.deinit();

    // Root command
    var emergence = app.rootCommand();
    emergence.setProperty(.help_on_empty_args);

    // Generations subcommand
    var cmd_generations = app.createCommand("generations", "Configure or view information about the generations.");
    cmd_generations.setProperty(.help_on_empty_args);

    // List subcommand, show all generations
    try cmd_generations.addSubcommand(app.createCommand("list", "List all generations."));

    // Add args and subcommands to the root command
    try emergence.addSubcommand(cmd_generations);
    try emergence.addArg(Arg.booleanOption("version", 'v', "Display program version number"));

    const matches = try app.parseProcess();

    if (matches.containsArg("version")) {
        color.info();
        log.info("{s}", .{
            build_options.version,
        });
        return;
    }
}
