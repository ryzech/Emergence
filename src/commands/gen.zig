const std = @import("std");
const mem = std.mem;

const yazap = @import("yazap");

const App = yazap.App;
const Arg = yazap.Arg;

pub fn create(allocator: mem.Allocator, app: *App) !yazap.Command {
    _ = allocator;

    // Generations subcommand
    var cmd_generations = app.createCommand("gen", "Configure or view information about the generations.");
    {
        // Set command properties
        cmd_generations.setProperty(.help_on_empty_args);

        // List subcommand, show all generations
        try cmd_generations.addSubcommand(app.createCommand("list", "List all generations."));

        // Select subcommand, select specific generation as the selected one
        // or the one to be built.
        var cmd_generations_select = app.createCommand("select", "Select generation.");
        {
            try cmd_generations_select.addArg(Arg.positional("id", "Generation ID to select.", null));
        }
        try cmd_generations.addSubcommand(cmd_generations_select);

        // Build subcommand, build selected generation
        // or build a specific one.
        var cmd_generations_build = app.createCommand("build", "Build selected generation.");
        {
            try cmd_generations_build.addArg(Arg.positional("id", "Build specific generation, otherwise selected is built.", null));
        }
        try cmd_generations.addSubcommand(cmd_generations_build);

        // Create subcommand, create a new generation
        var cmd_generations_create = app.createCommand("create", "Create a new generation.");
        {
            try cmd_generations_create.addArg(Arg.singleValueOption("message", 'm', "Short description of the changes."));
        }
        try cmd_generations.addSubcommand(cmd_generations_create);
    }
    return cmd_generations;
}
