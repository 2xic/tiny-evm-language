const std = @import("std");
const testing = std.testing;

const tokenizer = @import("./tokenizer.zig");
const ast = @import("./ast.zig");
const output = @import("./output.zig");

pub fn main() !void {
    const results = try tokenizer.get_tokens("assembly {\nPUSH0;\n}"[0..]);
    const assembly = try ast.get_get_ast(results);

    output.print_assembly_block(assembly);

    //  std.debug.print("Hello, World!\n", .{});
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
