const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    _ = target;
    const exe = b.addExecutable(.{ .name = "cli", .root_source_file = .{ .path = "src/cli.zig" } });

    b.installArtifact(exe);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/cli.zig" },
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
