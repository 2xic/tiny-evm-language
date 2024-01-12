const std = @import("std");
const testing = std.testing;

const tokenizer = @import("./tokenizer.zig");
const ast = @import("./ast.zig");
const output = @import("./output.zig");
const utils = @import("./utils.zig");

pub fn main() !void {
    const content = try utils.read_file();
    const results = try tokenizer.get_tokens(content);
    const assembly = try ast.get_get_ast(results);

    output.print_assembly_block(assembly);
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
