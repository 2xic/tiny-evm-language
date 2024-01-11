// assembly ->
const std = @import("std");

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
            // TODO: Is there a nicer way to deal with this ?
            if (std.mem.eql(u8, value, "PUSH0")) {
                var opcode = Opcode.init("PUSH0", 0x5F);
                try opcodes.append(opcode);
            } else if (std.mem.eql(u8, value, "ADD")) {
                var opcode = Opcode.init("ADD", 0x01);
                try opcodes.append(opcode);
            } else {
                // We failed
                @panic("Something went wrong! Unknown opcode");
            }
        }
    } else {
        @panic("Something went wrong! Unknown opcode");
    }

    return AssemblyBlock.init(opcodes);
}

test "assembly block" {}
