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

    pub fn addOpcode(self: *AssemblyBlock, value: Opcode) void {
        _ = value;
        _ = self;
        //  self.opcodes.append(value);
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
        // const currentSymbol = parser.get_next_symbol();
        // if (std.mem.eql(u8, currentSymbol, "assembly") and std.mem.eql(u8, nextSymbol, "{")) {
        //     // Perform your action when "assembly" is followed by "{"
        //     std.debug.print("Found 'assembly' followed by!\n", .{});
        // }
        return try parse_assembly_block(parser);
    }

    @panic("Something went wrong! Unknown opcode");
}

fn parse_assembly_block(parser: Parser) !AssemblyBlock {
    var parser_var = parser;
    const currentSymbol = parser_var.get_next_symbol();
    const nextSymbol = parser_var.get_next_symbol();

    //    var allocator = std.heap.page_allocator;

    //    var opcodes = try std.ArrayList(Opcode).init(allocator);
    var opcodes = std.ArrayList(Opcode).init(std.heap.page_allocator);

    if (std.mem.eql(u8, currentSymbol, "assembly") and std.mem.eql(u8, nextSymbol, "{")) {
        // While we don't see a "}" we are inside a assembly block
        while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
            // Opcodes I hope  ...
            const value = parser_var.get_next_symbol();
            if (std.mem.eql(u8, value, "PUSH0")) {
                // std.debug.print("Found push0\n", .{});
                var opcode = Opcode.init("PUSH0", 0x5F);
                // std.debug.print("created push0\n", .{});
                try opcodes.append(opcode);
                //opcodes
                // std.debug.print("Found push0\n", .{});

                // const next_vlaue = parser_var.get_next_symbol();
                // if (std.mem.eql(u8, next_vlaue, ";")) {
                //     std.debug.print("Found the ; blockn", .{});
                // } else {
                //     std.debug.print("token == {s}\n", .{next_vlaue});

                //     @panic("Something went wrong! Unknown terminator");
                // }*/
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
