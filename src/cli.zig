const std = @import("std");
const testing = std.testing;

pub fn main() !void {
    std.debug.print("Hello, World!\n", .{});
}

pub fn test_func() usize {
    return 10;
}

test "test" {
    try testing.expectEqual(@as(usize, 10), test_func());
}
