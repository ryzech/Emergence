const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;

const version = "0.1.0-dev";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Credit to RiverWM for the manpages generation
    // Star them at https://codeberg.org/river/river
    const man_pages = b.option(
        bool,
        "man-pages",
        "Set to true to build man pages. Requires scdoc. Defaults to true if scdoc is found.",
    ) orelse scdoc_found: {
        _ = b.findProgram(&.{"scdoc"}, &.{}) catch |err| switch (err) {
            error.FileNotFound => break :scdoc_found false,
            else => return err,
        };
        break :scdoc_found true;
    };

    // Credit to RiverWM for this versioning system!
    // Star them at https://codeberg.org/river/river
    const full_version = blk: {
        if (mem.endsWith(u8, version, "-dev")) {
            var ret: u8 = undefined;

            const git_describe_long = b.runAllowFail(
                &.{ "git", "-C", b.build_root.path orelse ".", "describe", "--all", "--long" },
                &ret,
                .Inherit,
            ) catch break :blk version;

            var it = mem.split(u8, mem.trim(u8, git_describe_long, &std.ascii.whitespace), "-");
            _ = it.next().?; // previous tag
            const commit_count = it.next().?;
            const commit_hash = it.next().?;
            assert(it.next() == null);
            assert(commit_hash[0] == 'g');

            // Follow semantic versioning, e.g. 0.2.0-dev.42+d1cf95b
            break :blk b.fmt(version ++ ".{s}+{s}", .{ commit_count, commit_hash[1..] });
        } else {
            break :blk version;
        }
    };

    const options = b.addOptions();
    options.addOption([]const u8, "version", full_version);

    const yazap = b.dependency("yazap", .{});

    const emergence = b.addExecutable(.{
        .name = "emergence",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    emergence.root_module.addOptions("build_options", options);
    emergence.root_module.addImport("yazap", yazap.module("yazap"));

    b.installArtifact(emergence);

    const run_cmd = b.addRunArtifact(emergence);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Credit to RiverWM for the manpages generation
    // Star them at https://codeberg.org/river/river
    if (man_pages) {
        inline for (.{"emergence"}) |page| {
            // Workaround for https://github.com/ziglang/zig/issues/16369
            // Even passing a buffer to std.Build.Step.Run appears to be racy and occasionally deadlocks.
            const scdoc = b.addSystemCommand(&.{ "/bin/sh", "-c", "scdoc < docs/" ++ page ++ ".1.scd" });
            // This makes the caching work for the Workaround, and the extra argument is ignored by /bin/sh.
            scdoc.addFileArg(b.path("docs/" ++ page ++ ".1.scd"));

            const stdout = scdoc.captureStdOut();
            b.getInstallStep().dependOn(&b.addInstallFile(stdout, "share/man/man1/" ++ page ++ ".1").step);
        }
    }
}
