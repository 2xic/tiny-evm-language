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

const CaseInsensitiveContext = struct {
    pub fn hash(_: CaseInsensitiveContext, s: []const u8) u64 {
        var key = s;
        var buf: [64]u8 = undefined;
        var h = std.hash.Wyhash.init(0);
        while (key.len >= 64) {
            const lower = std.ascii.lowerString(buf[0..], key[0..64]);
            h.update(lower);
            key = key[64..];
        }

        if (key.len > 0) {
            const lower = std.ascii.lowerString(buf[0..key.len], key);
            h.update(lower);
        }
        return h.final();
    }

    pub fn eql(_: CaseInsensitiveContext, a: []const u8, b: []const u8) bool {
        return std.ascii.eqlIgnoreCase(a, b);
    }
};

pub fn print_assembly_block(blocks: std.ArrayList(ast.GlobalBaseBlocks)) !void {
    std.debug.print("=================================\n", .{});

    var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);
    var function_mappings = std.HashMap([]const u8, u32, CaseInsensitiveContext, 80).init(std.heap.page_allocator);
    for (blocks.items) |block| {
        try parse_nested_blocks(&function_mappings, block, &bytescodes);
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

fn parse_nested_blocks(function_mappings: *std.HashMap([]const u8, u32, CaseInsensitiveContext, 80), block: ast.GlobalBaseBlocks, pointer: *std.ArrayList(u8)) !void {
    switch (block) {
        ast.GlobalBaseBlocks.IfBlock => |if_body| {
            var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);

            // If blocks can have nested blocks ....
            for (if_body.body.items) |b_block| {
                switch (b_block) {
                    ast.BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.IfBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .IfBlock = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.FunctionCall => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .FunctionCall = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.Null => {
                        @panic("what");
                    },
                }
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
                // TODO: Clean this ?

                try print_value(conditionals, pointer);
                for (bytescodes.items) |item| {
                    try pointer.append(item);
                }
            }
        },
        ast.GlobalBaseBlocks.AssemblyBlock => |assembly_block| {
            for (assembly_block.opcodes.items) |c| {
                const value = c.opcode;

                const numBytes = countBytes(value);

                for (0..numBytes) |index| {
                    const shift: u5 = @as(u5, @intCast((numBytes - index - 1) * 8));
                    const number = value;
                    var byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
                    try pointer.append(byteValue);
                }

                for (c.arguments) |val| {
                    std.debug.print("token == {s} \n", .{val});

                    var value2 = parseToU8(val) catch {
                        @panic("what");
                    };
                    try pointer.append(value2);
                }
            }
        },
        ast.GlobalBaseBlocks.FunctionBlock => |function| {
            // Create a new function buffer
            // We will use this to find the location later
            // First generate the function size
            // Insert jump over it
            var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);
            for (function.body.items) |b_block| {
                switch (b_block) {
                    ast.BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.IfBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .IfBlock = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.FunctionCall => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .FunctionCall = assemblyBlock }, &bytescodes);
                    },
                    ast.BaseBlocks.Null => {
                        @panic("what");
                    },
                }
            }
            // var sizeOfBytecode = bytescodes.items.len;
            const map = opcodesMaps.Opcodes.init().OpcodesMap;
            try opcode_2_pointer(map.get("PUSH1").?.opcode, pointer);
            try opcode_2_pointer(@as(u32, @intCast(bytescodes.items.len)) + 5, pointer);
            try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);

            try function_mappings.put(function.name, @as(u32, @intCast(pointer.items.len)));
            try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);

            for (bytescodes.items) |item| {
                try pointer.append(item);
            }
            try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);
            try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);
        },
        ast.GlobalBaseBlocks.FunctionCall => |function| {
            // HM, we cannot generate this before the end of the buffer ...
            // Since there is things happening in between ...
            //
            // [normal opcodes]
            // JMP + Size of offset
            // [Function offset]
            // [HALT]
            //

            const offset = function_mappings.get(function.name);
            if (offset) |v| {
                // got value "v"
                const map = opcodesMaps.Opcodes.init().OpcodesMap;
                try opcode_2_pointer(map.get("PC").?.opcode, pointer); // Push the PC so we can return to it
                try opcode_2_pointer(map.get("PUSH1").?.opcode, pointer);
                try opcode_2_pointer(7, pointer);
                try opcode_2_pointer(map.get("ADD").?.opcode, pointer); // Push the PC so we can return to it

                try opcode_2_pointer(map.get("PUSH1").?.opcode, pointer);
                try opcode_2_pointer(@as(u32, @intCast(v)), pointer);
                try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);
                try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);
            } else {
                // doesn't exist
            }
        },
        ast.GlobalBaseBlocks.Null => {},
    }
}

fn opcode_2_pointer(opcode: u32, pointer: *std.ArrayList(u8)) !void {
    const numBytes = countBytes(opcode);

    for (0..numBytes) |index| {
        const shift: u5 = @as(u5, @intCast((numBytes - index - 1) * 8));
        const number = opcode;
        var byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
        try pointer.append(byteValue);
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
            try opcode_2_pointer(c.?.opcode, pointer);
        }
    }
}

pub fn parseToU8(input: []const u8) !u8 {
    var num: i32 = undefined;

    const is_hex = input.len > 2 and input[0] == '0' and (input[1] == 'x' or input[1] == 'X');
    if (is_hex) {
        num = try std.fmt.parseInt(i32, input[2..], 16);
    } else {
        num = try std.fmt.parseInt(i32, input, 10);
    }
    // Ensure the parsed number is within the range of u8
    if (num < 0 or num > 255) {
        return error.InvalidValue;
    }
    return @as(u8, @intCast(num));
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
