// Takes in the AST and outputs bytecode

const std = @import("std");

const ast = @import("./ast.zig");

const opcodesMaps = @import("./opcodes.zig");

const File = std.fs.File;

fn u8ToHexDigit(n: u8) u8 {
    if (n < 10) {
        return n + '0';
    } else {
        return n - 10 + 'a';
    }
}

fn u8ToHexStr(
    n: u8,
) [2]u8 {
    return [2]u8{ u8ToHexDigit(n >> 4), u8ToHexDigit(n & 0x0F) };
}

pub fn print_assembly_block(blocks: std.ArrayList(ast.BaseBlocks)) !void {
    std.debug.print("=================================\n", .{});

    var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);

    for (blocks.items) |block| {
        try parse_nested_blocks(block, &bytescodes);
    }

    _ = try std.fs.cwd().createFile("./output.txt", .{});
    const file = try std.fs.cwd().openFile("./output.txt", .{ .mode = std.fs.File.OpenMode.read_write });

    for (bytescodes.items) |value| {
        std.debug.print("{x:0>2}", .{value});
        const aaaa = u8ToHexStr(value);

        _ = try file.write(aaaa[0..2]);
    }

    _ = file.close();

    std.debug.print("\n", .{});
    std.debug.print("=================================\n", .{});
}

fn parse_nested_blocks(block: ast.BaseBlocks, pointer: *std.ArrayList(u8)) !void {
    switch (block) {
        ast.BaseBlocks.IfBlock => |if_body| {
            var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);

            // If blocks can have nested blocks ....
            for (if_body.body.items) |b_block| {
                try parse_nested_blocks(b_block, &bytescodes);
            }

            // Prepare for the jump conditonlas
            const cmp_expression = if_body.cmp;
            if (std.mem.eql(u8, cmp_expression.expr_1, "sighash")) {
                // This meanas we need to push onto more opcodes onto the stack
                // TODO: I kinda want this to be processed by some other step so I can write in assembly here ...
                const map = opcodesMaps.Opcodes.init().OpcodesMap;
                // TODO First add this block to load the sighash
                // PUSH0
                // CALLDATALOAD
                // PUSH1 0xe0
                // SHR
                //

                const conditionals: [13]?opcodesMaps.Opcodemetdata = .{
                    map.get("PUSH0"),
                    map.get("CALLDATALOAD"),
                    map.get("PUSH1"),
                    opcodesMaps.Opcodemetdata{ .opcode = 0xe0, .inlineArgumentSize = 0 },
                    map.get("SHR"),
                    map.get("PUSH4"),
                    opcodesMaps.Opcodemetdata{ .opcode = 0xdeadbeef, .inlineArgumentSize = 0 },
                    map.get("EQ"),
                    map.get("PUSH1"),
                    // JUMPDEST
                    opcodesMaps.Opcodemetdata{ .opcode = @as(u32, @intCast((pointer.items.len))) + 15, .inlineArgumentSize = 0 },
                    map.get("JUMPI"),
                    map.get("STOP"), // WE STOP IT FOR NOW, LATER FIX
                    map.get("JUMPDEST"), // WE STOP IT FOR NOW, LATER FIX
                };
                // JUMPDEST
                //  PUSH0
                //  CALLDATALOAD
                //  PUSH1 0xe0
                //  SHR
                //  PUSH4 0xdeadbeef
                //  EQ
                //  PUSH1 0 // Offset to jump to ... Needs to be loaded after the JUMPI + 1
                //  JUMPI
                // Falls thorugh for the next block.

                try print_value(conditionals, pointer);
                // TODO: Clean this ?
                for (bytescodes.items) |item| {
                    try pointer.append(item);
                }
            }
        },
        ast.BaseBlocks.AssemblyBlock => |assembly_block| {
            for (assembly_block.opcodes.items) |c| {
                const value = c.opcode;

                //                std.debug.print("{x:0>2}", .{value});
                //                pointer.index += 1;
                //  try pointer.append(value);
                const numBytes = countBytes(value);

                for (0..numBytes) |index| {
                    const shift: u5 = @as(u5, @intCast((numBytes - index - 1) * 8));
                    const number = value;
                    var byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
                    try pointer.append(byteValue);
                }
            }
        },
        ast.BaseBlocks.Null => {},
    }
}

fn print_value(value: [13]?opcodesMaps.Opcodemetdata, pointer: *std.ArrayList(u8)) !void {
    for (value) |c| {
        if (c == null) {
            continue;
        }

        if (c.?.opcode == 0) {
            try pointer.append(0);
        } else {
            //  std.debug.print("{x:0>2}", .{c.?.opcode});
            const numBytes = countBytes(c.?.opcode);

            for (0..numBytes) |index| {
                const shift: u5 = @as(u5, @intCast((numBytes - index - 1) * 8));
                const number = c.?.opcode;
                var byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
                try pointer.append(byteValue);
            }
        }
    }
}

fn countBytes(number: u32) u8 {
    var count: u8 = 0;
    var temp: u32 = number;
    while (temp != 0) {
        count += 1;
        temp >>= 8;
    }
    return count;
}
