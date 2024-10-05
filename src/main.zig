const std = @import("std");

const yazap = @import("yazap");
const build_options = @import("build_options");

const allocator = std.heap.page_allocator;
const log = std.log;
const App = yazap.App;
const Arg = yazap.Arg;

pub fn main() anyerror!void {
    var app = App.init(allocator, "emergence", "NixOS-Like generations for gentoo based systems.");
    defer app.deinit();

    var emergence = app.rootCommand();
    emergence.setProperty(.help_on_empty_args);

    try emergence.addArg(Arg.booleanOption("version", 'v', "Display program version number"));

    const matches = try app.parseProcess();

    if (matches.containsArg("version")) {
        log.info("{s}", .{
            build_options.version,
        });
        return;
    }
}
