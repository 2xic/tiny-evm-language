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
        return try parse_assembly_block(parser);
    }

    @panic("Something went wrong! Unknown opcode");
}

fn parse_assembly_block(parser: Parser) !AssemblyBlock {
    var parser_var = parser;
    const currentSymbol = parser_var.get_next_symbol();
    const nextSymbol = parser_var.get_next_symbol();

    var opcodes = std.ArrayList(Opcode).init(std.heap.page_allocator);

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
        }
    } else {
        @panic("Something went wrong! Unknown opcode");
    }

    return AssemblyBlock.init(opcodes);
}

test "assembly block" {}
