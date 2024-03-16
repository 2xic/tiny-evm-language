const std = @import("std");
const testing = std.testing;

const tokenizer = @import("./tokenizer.zig");
const ast = @import("./ast.zig");
const output = @import("./output.zig");
const utils = @import("./utils.zig");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);

    if (args.len < 2) {
        // Print a message if no command-line arguments are provided
        std.debug.print("Usage: cli [file path]\n", .{});
        return;
    }

    const file = args[1];
    // Note: default is to output the runtime code
    var compileDeployment = false;
    if (args.len >= 3) {
        const compileKind = args[2];
        if (std.mem.eql(u8, compileKind, "deploy")) {
            compileDeployment = true;
        }
    }

    var constructorArguments: u32 = 0;
    if (args.len >= 4) {
        constructorArguments = output.parseToU8(args[3]) catch {
            @panic("what");
        };
    }

    const content = try utils.read_file(file);
    const results = try tokenizer.get_tokens(content);
    const assembly = try ast.get_get_ast(results);

    std.debug.print("Optional argument: {?}\n", .{compileDeployment});
    try output.print_assembly_block(assembly, compileDeployment, constructorArguments);
}

test "test" {
    // Verify that we correctly split the tokens
    const results = try tokenizer.get_tokens("test world"[0..]);
    const tokenCount = results.len;

    try testing.expectEqual(@as(usize, 2), tokenCount);
}
