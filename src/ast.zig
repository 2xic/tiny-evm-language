// assembly ->
const std = @import("std");

const Opcodemetdata = struct {
    opcode: u8,
};

const Opcode = struct {
    name: []const u8, // Field with the name
    opcode: u8,
    // arguments: [][]const u8, // Field with the name

    pub fn init(name: []const u8, opcode: u8) Opcode {
        return Opcode{
            .name = name,
            .opcode = opcode,
        };
    }
};

pub const AssemblyBlock = struct {
    opcodes: std.ArrayList(Opcode),

    pub fn init(opcodes: std.ArrayList(Opcode)) AssemblyBlock {
        return AssemblyBlock{ .opcodes = opcodes };
    }
};

pub const CompareBlock = struct {
    expr_1: u8,
    expr_2: u8,
};

pub const IfBlock = struct {
    // This could also ohld AssemblyBlocks ...
    cmp: CompareBlock,
};

fn initEmptyOpcodeSlice() []Opcode {
    return &[]Opcode{};
}

const Parser = struct {
    entries: [][]const u8,
    currentIndex: usize,

    pub fn init(entries: [][]const u8) Parser {
        return Parser{ .entries = entries, .currentIndex = 0 };
    }

    pub fn get_next_symbol(self: *Parser) []const u8 {
        const symbol = self.peek_nexy_symbol();
        self.currentIndex += 1;
        return symbol;
    }

    pub fn peek_nexy_symbol(self: *Parser) []const u8 {
        const symbol = self.entries[self.currentIndex];
        return symbol;
    }
};

pub fn get_get_ast(entries: [][]const u8) !AssemblyBlock {
    // First get tokens ... Then we need to compare that against all the next blocks
    for (entries) |entry| {
        std.debug.print("token == {s}\n", .{entry});
    }

    std.debug.print("=====END====\n", .{});

    var parser = Parser.init(entries);

    while (parser.currentIndex + 1 < entries.len) {
        const value = try parse_assembly_block(&parser);
        std.debug.print("wwowoow\n", .{});

        const typeName = @TypeOf(value);
        std.debug.print("Type of myValue is: {}\n", .{typeName});

        switch (value) {
            ErrorOrBlock.AssemblyBlock => |assemblyBlock| {
                return assemblyBlock;
            },
            ErrorOrBlock.Null => {
                const if_value = try parrse_if_block(&parser);
                switch (if_value) {
                    ErrorIfBLock.IfBlock => |block| {
                        _ = block;
                        std.debug.print("You are winner! {}\n", .{typeName});
                    },
                    ErrorIfBLock.Null => {
                        @panic("Something went wrong! Unknown code");
                    },
                }
            },
        }
    }

    @panic("Something went wrong! Unknown opcode");
}

const ErrorIfBLock = union(enum) {
    IfBlock: IfBlock,
    Null: void,
};

// TDOO:
// My idea of this is
// We have top level blocks and lower level blocks ...
// Then we parse them ...
fn parrse_if_block(parser: *Parser) !ErrorIfBLock {
    var parser_var = parser;

    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "if")) {
        const _if_name = parser_var.get_next_symbol();
        _ = _if_name;
        // TODO
        const expr_1 = parser_var.get_next_symbol();
        _ = expr_1;
        const op = parser_var.get_next_symbol();
        _ = op;
        const expr_2 = parser_var.get_next_symbol();
        _ = expr_2;
        // Then add CMP op

        const start_symbol = parser_var.get_next_symbol();
        if (std.mem.eql(u8, start_symbol, "{")) {
            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                // Okay now we can load in other blocks ... Like assembly blocks
                _ = try parse_assembly_block(parser);
            }
            return .{ .IfBlock = IfBlock{ .cmp = CompareBlock{ .expr_1 = 0, .expr_2 = 0 } } };
        }
    }
    return .{ .Null = {} };
}

const ErrorOrBlock = union(enum) {
    AssemblyBlock: AssemblyBlock,
    Null: void,
};

fn parse_assembly_block(parser: *Parser) !ErrorOrBlock {
    var parser_var = parser;

    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "assembly")) {
        var opcodes = std.ArrayList(Opcode).init(std.heap.page_allocator);

        const currentSymbol = parser_var.get_next_symbol();
        const nextSymbol = parser_var.get_next_symbol();

        if (std.mem.eql(u8, currentSymbol, "assembly") and std.mem.eql(u8, nextSymbol, "{")) {
            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                // Opcodes I hope  ...
                const value = parser_var.get_next_symbol();

                // Opcode metadata
                var opcodeMap = std.StringHashMap(Opcodemetdata).init(std.heap.page_allocator);
                try opcodeMap.put("STOP", Opcodemetdata{ .opcode = 0x00 });
                try opcodeMap.put("PUSH0", Opcodemetdata{ .opcode = 0x5F });
                try opcodeMap.put("ADD", Opcodemetdata{ .opcode = 0x01 });

                const opcodeType = opcodeMap.get(value);

                if (opcodeType == null) {
                    // Handle the case when the value is not in the opcode map
                    @panic("Something went wrong! Unknown opcode");
                }

                try opcodes.append(Opcode.init(value, opcodeType.?.opcode));
                return .{ .AssemblyBlock = AssemblyBlock.init(opcodes) };
            }
        }
    }
    return .{ .Null = {} };
}

test "assembly block" {}
