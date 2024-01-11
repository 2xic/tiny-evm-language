const std = @import("std");
const testing = std.testing;

const tokenizer = @import("./tokenizer.zig");

pub fn main() !void {
    std.debug.print("Hello, World!\n", .{});
}

pub fn test_func() usize {
    return 10;
}

test "test" {
    // Verify that we correctly split the tokens
    const results = try tokenizer.get_tokens("test world"[0..]);
    const tokenCount = results.len;

    try testing.expectEqual(@as(usize, 2), tokenCount);
}
