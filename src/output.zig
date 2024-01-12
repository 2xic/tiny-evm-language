// Takes in the AST and outputs bytecode

const std = @import("std");

const ast = @import("./ast.zig");

pub fn print_assembly_block(blocks: std.ArrayList(ast.BaseBlocks)) void {
    std.debug.print("=================================\n", .{});

    for (blocks.items) |block| {
        parse_nested_blocks(block);
    }

    std.debug.print("\n", .{});
    std.debug.print("=================================\n", .{});
}

fn parse_nested_blocks(block: ast.BaseBlocks) void {
    switch (block) {
        ast.BaseBlocks.IfBlock => |if_body| {
            // If blocks can have nested blocks ....
            for (if_body.body.items) |b_block| {
                parse_nested_blocks(b_block);
            }
        },
        ast.BaseBlocks.AssemblyBlock => |assembly_block| {
            for (assembly_block.opcodes.items) |c| {
                const value = c.opcode;

                std.debug.print("{x:0>2}", .{value});
            }
        },
        ast.BaseBlocks.Null => {},
    }
}
