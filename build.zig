const std = @import("std");
// Import the project from zon file.
const rlzb = @import("raylib-zig-bindings");

pub fn build(b: *std.Build) !void {
    // Default zig setup
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Adding rlzb binding files for us to use in the main.zig file.
    const bindings = b.dependency("raylib-zig-bindings", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("rlzb", bindings.module("raylib-zig-bindings"));

    // Compiling raylib with main.zig
    // You can select which raylib C file to add in the third parameter
    var setup = try rlzb.Setup.init(b, .{ .cwd_relative = "raylib/src" }, .{});
    defer setup.deinit();

    // This line copy the raygui.h file into raylib/src to build with it.
    try setup.addRayguiToRaylibSrc(b, .{ .cwd_relative = "raygui/src/raygui.h" });

    // If you have some raylib's C #define requirements that need to be at build time. You can set them here.
    setup.setRayguiOptions(b, exe, .{});
    setup.setRCameraOptions(b, exe, .{});
    setup.setRlglOptions(b, exe, .{});

    // Build specific for platform.
    switch (target.result.os.tag) {
        .windows => try setup.linkWindows(b, exe),
        .macos => try setup.linkMacos(b, exe),
        .linux => try setup.linkLinux(b, exe, .{ .platform = .DESKTOP, .backend = .X11 }),
        else => @panic("Unsupported os"),
    }

    // Add everything to the exe.
    setup.finalize(b, exe);

    // Default zig build run command setup
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
