const std = @import("std");
const mem = std.mem;

const yazap = @import("yazap");

const App = yazap.App;
const Arg = yazap.Arg;

pub fn create(allocator: mem.Allocator, app: *App) !yazap.Command {
    _ = allocator;

    // Init subcommands
    var cmd_init = app.createCommand("init", "Initialize new configuration.");
    {
        try cmd_init.addArg(Arg.booleanOption("git", null, "Initialize git repository."));
    }
    return cmd_init;
}
