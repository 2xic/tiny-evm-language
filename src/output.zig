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

pub fn print_assembly_block(blocks: std.ArrayList(ast.GlobalBaseBlocks), compileDeployment: bool, constructorArguments: u32) !void {
    std.debug.print("=================================\n", .{});

    var runtimeCode = std.ArrayList(u8).init(std.heap.page_allocator);
    var function_mappings = std.HashMap([]const u8, u32, CaseInsensitiveContext, 80).init(std.heap.page_allocator);
    for (blocks.items) |block| {
        try parse_nested_blocks(&function_mappings, block, &runtimeCode, 0);
    }

    _ = try std.fs.cwd().createFile("./runtime.txt", .{});
    const file = try std.fs.cwd().openFile("./runtime.txt", .{ .mode = std.fs.File.OpenMode.read_write });

    std.debug.print("\n", .{});
    std.debug.print("Runtime code: \n", .{});
    for (runtimeCode.items) |value| {
        std.debug.print("{x:0>2}", .{value});
        const aaaa = u8ToHexStr(value);

        _ = try file.write(aaaa[0..2]);
    }

    _ = file.close();

    std.debug.print("\n", .{});

    if (compileDeployment == true) {
        // 1. Run a code copy of the section where we placed our runtime code
        // 2. Jump to the end.
        // 3. Return that code.
        // Victory ?
        // [Jump]
        // [Runtime code]
        // [Return logic]
        var deploymentCode = std.ArrayList(u8).init(std.heap.page_allocator);
        const map = opcodesMaps.Opcodes.init().OpcodesMap;
        const runtimeCodeSize = @as(u32, @intCast((runtimeCode.items.len)));
        const padding: u32 = get_push_number(runtimeCodeSize);

        try push_opcode_2_number(runtimeCodeSize + padding, &deploymentCode);
        try opcode_2_pointer(map.get("JUMP").?.opcode, &deploymentCode);
        // [Jump target after the runtime code]
        for (runtimeCode.items) |value| {
            try deploymentCode.append(value);
        }
        try opcode_2_pointer(map.get("JUMPDEST").?.opcode, &deploymentCode);

        // SIZE
        try push_opcode_2_number(runtimeCodeSize, &deploymentCode);

        // OFFSET
        try opcode_2_pointer(map.get("PUSH1").?.opcode, &deploymentCode);
        try opcode_2_pointer(padding, &deploymentCode);
        // DEST OFFSET
        try opcode_2_pointer(map.get("PUSH1").?.opcode, &deploymentCode);
        try opcode_2_pointer(0, &deploymentCode);
        try opcode_2_pointer(map.get("CODECOPY").?.opcode, &deploymentCode);

        // NOW WE LOAD IN CONSTRUCTOR ARGUMENTS IF NEEDED ? WE LOAD IN 32 BYTES CHUNK! WE DON'T CARE WHAT IT IS
        const deploymentSize = @as(u32, @intCast((deploymentCode.items.len)));
        const endOfOpcodeSize: u32 = deploymentSize + 5;
        for (0..constructorArguments) |index| {
            const indexu32 = @as(u32, @intCast((index)));
            // Load in the constructor value
            const loadSizeOpcodes: u32 = 6;
            const locationOfArugment = endOfOpcodeSize + constructorArguments * loadSizeOpcodes + 32 * indexu32;
            try push_opcode_2_number(locationOfArugment, &deploymentCode);

            try opcode_2_pointer(map.get("CALLDATALOAD").?.opcode, &deploymentCode);

            // Load in the key = index of the constructor argument'
            try push_opcode_2_number(indexu32, &deploymentCode);

            try opcode_2_pointer(map.get("SSTORE").?.opcode, &deploymentCode);
        }

        // RETURN THE DEPLOYED CODE
        // SIZE
        try push_opcode_2_number(runtimeCodeSize, &deploymentCode);
        // OFFSET
        try opcode_2_pointer(map.get("PUSH1").?.opcode, &deploymentCode);
        try opcode_2_pointer(0, &deploymentCode);
        try opcode_2_pointer(map.get("RETURN").?.opcode, &deploymentCode);
        // [ Here we could potentially have constructor arguments .... ]

        std.debug.print("\n", .{});
        std.debug.print("Deployed code: \n", .{});

        _ = try std.fs.cwd().createFile("./deploy.txt", .{});
        const deployFile = try std.fs.cwd().openFile("./deploy.txt", .{ .mode = std.fs.File.OpenMode.read_write });

        for (deploymentCode.items) |value| {
            std.debug.print("{x:0>2}", .{value});
            const aaaa = u8ToHexStr(value);

            _ = try deployFile.write(aaaa[0..2]);
        }
        std.debug.print("\n", .{});
        std.debug.print("\n", .{});

        _ = deployFile.close();
    }
    std.debug.print("=================================\n", .{});
}

fn parse_nested_blocks(function_mappings: *std.HashMap([]const u8, u32, CaseInsensitiveContext, 80), block: ast.GlobalBaseBlocks, pointer: *std.ArrayList(u8), additionalAdding: u32) !void {
    switch (block) {
        ast.GlobalBaseBlocks.IfBlock => |if_body| {
            var ifBodyBytescodes = std.ArrayList(u8).init(std.heap.page_allocator);
            var elseBodyBytescodes = std.ArrayList(u8).init(std.heap.page_allocator);

            // If blocks can have nested blocks ....
            for (if_body.body.items) |b_block| {
                switch (b_block) {
                    ast.BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock }, &ifBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.IfBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .IfBlock = assemblyBlock }, &ifBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.FunctionCall => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .FunctionCall = assemblyBlock }, &ifBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.Null => {
                        @panic("Got null block, expected base block to be defined");
                    },
                }
            }
            // Else body could have nested blocks ....
            for (if_body.elseBody.items) |b_block| {
                switch (b_block) {
                    ast.BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock }, &elseBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.IfBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .IfBlock = assemblyBlock }, &elseBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.FunctionCall => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .FunctionCall = assemblyBlock }, &elseBodyBytescodes, additionalAdding);
                    },
                    ast.BaseBlocks.Null => {
                        @panic("Got null block, expected base block to be defined");
                    },
                }
            }

            // Prepare for the jump conditonlas
            const cmp_expression = if_body.cmp;
            if (std.mem.eql(u8, cmp_expression.expr_1, "sighash")) {
                const map = opcodesMaps.Opcodes.init().OpcodesMap;
                // TODO First add this block to load the sighash
                // PUSH0
                // CALLDATALOAD
                // PUSH1 0xe0
                // SHR
                const sighashValue = parse_to_u32(cmp_expression.expr_2) catch {
                    @panic("Failed to parse u32 number");
                };

                //      const pointerSize = @as(u32, @intCast((pointer.items.len)));
                const elseBodySize = @as(u32, @intCast((elseBodyBytescodes.items.len)));

                const conditionals: [8]?opcodesMaps.Opcodemetdata = .{
                    map.get("PUSH0"),
                    map.get("CALLDATALOAD"),
                    map.get("PUSH1"),
                    opcodesMaps.Opcodemetdata{ .opcode = 0xe0, .inlineArgumentSize = 0 },
                    map.get("SHR"),
                    map.get("PUSH4"),
                    opcodesMaps.Opcodemetdata{ .opcode = sighashValue, .inlineArgumentSize = 0 },
                    map.get("EQ"),
                };
                try print_value(conditionals, pointer);

                try push_opcode_2_number(elseBodySize + 3, pointer);
                try opcode_2_pointer(map.get("PC").?.opcode, pointer);
                try opcode_2_pointer(map.get("ADD").?.opcode, pointer);
                try opcode_2_pointer(map.get("JUMPI").?.opcode, pointer);

                // TODO: Clean this up ?
                if (elseBodyBytescodes.items.len == 0) {
                    // TODO: No else body === stop currently, but should be jump.
                    try opcode_2_pointer(map.get("STOP").?.opcode, pointer);
                } else {
                    for (elseBodyBytescodes.items) |item| {
                        try pointer.append(item);
                    }
                }

                try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);
                for (ifBodyBytescodes.items) |item| {
                    try pointer.append(item);
                }
            } else if (std.mem.eql(u8, cmp_expression.expr_1, "stack_top_is_zero")) {
                const map = opcodesMaps.Opcodes.init().OpcodesMap;
                const conditionals: [3]?opcodesMaps.Opcodemetdata = .{
                    map.get("JUMPI"),
                    // TODO: WE STOP IT FOR NOW, LATER FIX
                    map.get("STOP"),
                    map.get("JUMPDEST"),
                };

                // TODO: Clean this up ?
                const stack_is_zero_destination = additionalAdding + @as(u32, @intCast((pointer.items.len))) + 8;
                try push_opcode_2_number(stack_is_zero_destination, pointer);

                try print_value_four(conditionals, pointer);
                for (ifBodyBytescodes.items) |item| {
                    try pointer.append(item);
                }
            }
        },
        ast.GlobalBaseBlocks.AssemblyBlock => |assembly_block| {
            for (assembly_block.opcodes.items) |c| {
                const value = c.opcode;
                const numBytes = count_bytes(value);

                if (numBytes == 0) {
                    try pointer.append(0);
                } else {
                    for (0..numBytes) |index| {
                        try pointer.append(get_byte_number(value, index, numBytes));
                    }
                }

                for (c.arguments) |val| {
                    const value2 = parse_to_u256(val) catch {
                        @panic("Failed to parse the PUSH argument value");
                    };
                    const numBytesValue = count_bytes(value2);

                    if (numBytesValue == 0) {
                        try pointer.append(0);
                    } else {
                        for (0..numBytesValue) |index| {
                            try pointer.append(get_byte_number(value2, index, numBytesValue));
                        }
                    }
                }
            }
        },
        ast.GlobalBaseBlocks.FunctionBlock => |function| {
            const map = opcodesMaps.Opcodes.init().OpcodesMap;

            // We should always store the init location of the function so we can look that up in a recursvie function
            const function_jumpdest_location = @as(u32, @intCast(pointer.items.len)) + 3;
            try function_mappings.put(function.name, function_jumpdest_location);

            var bytescodes = std.ArrayList(u8).init(std.heap.page_allocator);
            const sizeOPcode = @as(u32, @intCast(pointer.items.len));

            for (function.body.items) |b_block| {
                switch (b_block) {
                    ast.BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock }, &bytescodes, sizeOPcode);
                    },
                    ast.BaseBlocks.IfBlock => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .IfBlock = assemblyBlock }, &bytescodes, sizeOPcode);
                    },
                    ast.BaseBlocks.FunctionCall => |assemblyBlock| {
                        try parse_nested_blocks(function_mappings, ast.GlobalBaseBlocks{ .FunctionCall = assemblyBlock }, &bytescodes, sizeOPcode);
                    },
                    ast.BaseBlocks.Null => {
                        @panic("Got null block, expected base block to be defined");
                    },
                }
            }

            // NOTE: This should probably only be added for the head blocks ?
            const jump_location = sizeOPcode + @as(u32, @intCast(bytescodes.items.len)) + 5;
            if (256 < jump_location) {
                @panic("WE DONT SUPPORT THIS FAR JUMP YET");
            }
            try push_opcode_2_number(jump_location, pointer);
            try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);
            try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);

            for (bytescodes.items) |item| {
                try pointer.append(item);
            }
            try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);
            try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);
        },
        ast.GlobalBaseBlocks.FunctionCall => |function| {
            const offset = function_mappings.get(function.name);
            if (offset) |offset_value| {
                const jump_location = @as(u32, @intCast(offset_value));
                std.debug.print("Constructing the function jump offset = {} \n", .{jump_location});

                const map = opcodesMaps.Opcodes.init().OpcodesMap;
                // Push over to the return location
                try opcode_2_pointer(map.get("PC").?.opcode, pointer);
                try opcode_2_pointer(map.get("PUSH1").?.opcode, pointer);
                try opcode_2_pointer(7, pointer);
                try opcode_2_pointer(map.get("ADD").?.opcode, pointer);
                // Push on the function be called
                try push_opcode_2_number(jump_location, pointer);

                try opcode_2_pointer(map.get("JUMP").?.opcode, pointer);
                try opcode_2_pointer(map.get("JUMPDEST").?.opcode, pointer);
            } else {
                // doesn't exist
                @panic("Function location not found :'( )");
            }
        },
        ast.GlobalBaseBlocks.Null => {},
    }
}

fn get_push_number(value: u32) u32 {
    if (value < 255) {
        return 3;
    } else if (value < 0xFFFF) {
        return 4;
    } else {
        @panic("Value larger than supported push opcode size");
    }
}

fn push_opcode_2_number(value: u32, pointer: *std.ArrayList(u8)) !void {
    if (value < 255) {
        const map = opcodesMaps.Opcodes.init().OpcodesMap;

        try opcode_2_pointer(map.get("PUSH1").?.opcode, pointer);
        try opcode_2_pointer(value, pointer);
    } else if (value < 0xFFFF) {
        const map = opcodesMaps.Opcodes.init().OpcodesMap;

        try opcode_2_pointer(map.get("PUSH2").?.opcode, pointer);
        try opcode_2_pointer(value, pointer);
    } else {
        @panic("UNKNOWN");
    }
}

fn opcode_2_pointer(opcode: u32, pointer: *std.ArrayList(u8)) !void {
    const numBytes = count_bytes(opcode);

    if (opcode == 0) {
        try pointer.append(0);
    } else {
        for (0..numBytes) |index| {
            const shift: u5 = @as(u5, @intCast((numBytes - index - 1) * 8));
            const number = opcode;
            const byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
            try pointer.append(byteValue);
        }
    }
}

fn print_value(value: [8]?opcodesMaps.Opcodemetdata, pointer: *std.ArrayList(u8)) !void {
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

fn print_value_four(value: [3]?opcodesMaps.Opcodemetdata, pointer: *std.ArrayList(u8)) !void {
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

pub fn parse_to_u256(input: []const u8) !u256 {
    var num: u256 = undefined;

    const is_hex = input.len > 2 and input[0] == '0' and (input[1] == 'x' or input[1] == 'X');
    if (is_hex) {
        num = try std.fmt.parseInt(u256, input[2..], 16);
    } else {
        num = try std.fmt.parseInt(u256, input, 10);
    }
    return num;
}

pub fn parse_to_u32(input: []const u8) !u32 {
    const num: u256 = parse_to_u256(input) catch {
        @panic("Failed to parse number as uint256");
    };
    // Ensure the parsed number is within the range of u8
    if (num < 0 or num > 4294967296) {
        return error.InvalidValue;
    }
    return @as(u32, @intCast(num));
}

fn count_bytes(number: u256) u8 {
    var count: u8 = 0;
    var temp: u256 = number;
    while (temp != 0) {
        count += 1;
        temp >>= 8;
    }
    return count;
}

fn get_byte_number(number: u256, index: usize, numBytes: u8) u8 {
    const shift: u8 = @as(u8, @intCast((numBytes - index - 1) * 8));
    const byteValue: u8 = @as(u8, @intCast((number >> shift) & 0xFF));
    return byteValue;
}
