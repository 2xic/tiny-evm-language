// Takes in the AST and outputs bytecode

const std = @import("std");

const ast = @import("./ast.zig");

pub fn print_assembly_block(assembly_block: ast.AssemblyBlock) void {
    std.debug.print("=================================\n", .{});
    for (assembly_block.opcodes.items) |c| {
        const value = c.opcode;

        std.debug.print("{x:0>2}", .{value});
    }
    std.debug.print("\n", .{});
    std.debug.print("=================================\n", .{});
}
