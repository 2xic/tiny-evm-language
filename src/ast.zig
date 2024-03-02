// assembly ->
const std = @import("std");

const OpcodesMap = @import("./opcodes.zig");

const Opcode = struct {
    name: []const u8, // Field with the name
    opcode: u32,
    // arguments: [][]const u8, // Field with the name

    pub fn init(name: []const u8, opcode: u32) Opcode {
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
    expr_1: []const u8,
    expr_2: []const u8,
};

pub const IfBlock = struct {
    // This could also ohld AssemblyBlocks ...
    cmp: CompareBlock,
    body: std.ArrayList(BaseBlocks),
};

pub const IfBlockError = union(enum) {
    IfBlock: IfBlock,
    Null: void,
};

pub const FunctionBlock = struct {
    name: []const u8,
    // This could also ohld AssemblyBlocks ...
    body: std.ArrayList(BaseBlocks),
};

pub const FunctionBlockError = union(enum) {
    FunctionBlock: FunctionBlock,
    Null: void,
};

pub const BaseBlocks = union(enum) {
    IfBlock: IfBlock,
    AssemblyBlock: AssemblyBlock,
    Null: void,
};

pub const GlobalBaseBlocks = union(enum) {
    IfBlock: IfBlock,
    AssemblyBlock: AssemblyBlock,
    FunctionBlock: FunctionBlock,
    Null: void,
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

pub fn get_get_ast(entries: [][]const u8) !std.ArrayList(GlobalBaseBlocks) {
    // First get tokens ... Then we need to compare that against all the next blocks
    for (entries, 0..) |entry, i| {
        std.debug.print("token ({}) == {s} \n", .{ i, entry });
    }

    std.debug.print("=====END====\n", .{});

    var parser = Parser.init(entries);

    var opcodes = std.ArrayList(GlobalBaseBlocks).init(std.heap.page_allocator);
    var oldIndex = parser.currentIndex;
    while (parser.currentIndex + 1 < entries.len) {
        const function: FunctionBlockError = get_function_block(&parser);
        switch (function) {
            FunctionBlockError.FunctionBlock => |assemblyBlock| {
                try opcodes.append(GlobalBaseBlocks{ .FunctionBlock = assemblyBlock });
                std.debug.print("SSSS\n", .{});
            },
            FunctionBlockError.Null => {
                parser.currentIndex = oldIndex;
                std.debug.print("FAILED?\n", .{});
                std.debug.print("index == {} / {} \n", .{ .val = parser.currentIndex, .aa = entries.len });

                const opcode: BaseBlocks = get_base_block(&parser);
                switch (opcode) {
                    BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try opcodes.append(GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock });
                    },
                    BaseBlocks.IfBlock => |assemblyBlock| {
                        try opcodes.append(GlobalBaseBlocks{ .IfBlock = assemblyBlock });
                    },
                    BaseBlocks.Null => {
                        @panic("what");
                    },
                }
            },
        }
        if (oldIndex == parser.currentIndex) {
            @panic("what");
        }
        oldIndex = parser.currentIndex;
    }

    return opcodes;
}

fn get_function_block(parser: *Parser) FunctionBlockError {
    var parser_var = parser;

    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "function")) {
        const _function_def = parser_var.get_next_symbol();
        _ = _function_def;

        const _function_name = parser_var.get_next_symbol();

        const start_symbol = parser_var.get_next_symbol();
        if (std.mem.eql(u8, start_symbol, "{")) {
            var body = std.ArrayList(BaseBlocks).init(std.heap.page_allocator);

            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                // Okay now we can load in other blocks ... Like assembly blocks
                const assembly: BaseBlocks = get_base_block(parser);
                std.debug.print("BLOCK\n", .{});

                body.append(assembly) catch |err| {
                    switch (err) {
                        OutOfMemoryError.OutOfMemory => {
                            return FunctionBlockError.Null;
                        },
                    }
                };
            }
            // Read out the }
            _ = parser_var.get_next_symbol();

            return .{ .FunctionBlock = FunctionBlock{ .name = _function_name, .body = body } };
        }
    }
    return .{ .Null = {} };
}

fn get_base_block(_parser: *Parser) BaseBlocks {
    var parser = _parser;
    const currentPosition = parser.currentIndex;
    const value = parse_assembly_block(parser);

    switch (value) {
        ErrorOrBlock.AssemblyBlock => |assemblyBlock| {
            return (.{ .AssemblyBlock = assemblyBlock });
        },
        ErrorOrBlock.Null => {
            parser.currentIndex = currentPosition;
            const if_value = parrse_if_block(parser);
            switch (if_value) {
                IfBlockError.IfBlock => |block| {
                    return (.{ .IfBlock = block });
                },
                IfBlockError.Null => {
                    @panic("Something went wrong! Unknown code at position");
                },
            }
            @panic("Something went wrong! Unknown code at position");
        },
    }
    @panic("Something went wrong! Unknown code at position");
}

// TDOO:
// My idea of this is
// We have top level blocks and lower level blocks ...
// Then we parse them ...
fn parrse_if_block(parser: *Parser) IfBlockError {
    var parser_var = parser;

    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "if")) {
        const _if_name = parser_var.get_next_symbol();
        _ = _if_name;
        // TODO
        const expr_1 = parser_var.get_next_symbol();
        const op = parser_var.get_next_symbol();
        // Assert that it is a equal ?
        if (!std.mem.eql(u8, op, "==")) {
            @panic("Expected === ");
        }
        const expr_2 = parser_var.get_next_symbol();
        // Then add CMP op

        const start_symbol = parser_var.get_next_symbol();
        if (std.mem.eql(u8, start_symbol, "{")) {
            var body = std.ArrayList(BaseBlocks).init(std.heap.page_allocator);

            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                // Okay now we can load in other blocks ... Like assembly blocks
                const assembly: BaseBlocks = get_base_block(parser);
                body.append(assembly) catch |err| {
                    switch (err) {
                        OutOfMemoryError.OutOfMemory => {
                            return IfBlockError.Null;
                        },
                    }
                };
            }
            _ = parser_var.get_next_symbol();

            return .{ .IfBlock = IfBlock{ .cmp = CompareBlock{ .expr_1 = expr_1, .expr_2 = expr_2 }, .body = body } };
        }
    }
    return .{ .Null = {} };
}

const ErrorOrBlock = union(enum) {
    AssemblyBlock: AssemblyBlock,
    Null: void,
};

const OutOfMemoryError = error{OutOfMemory};

fn parse_assembly_block(parser: *Parser) ErrorOrBlock {
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
                var opcodeMap = OpcodesMap.Opcodes.init().OpcodesMap;

                const opcodeType = opcodeMap.get(value);

                if (opcodeType == null) {
                    // Handle the case when the value is not in the opcode map
                    @panic("Something went wrong! Unknown opcode");
                }

                opcodes.append(Opcode.init(value, opcodeType.?.opcode)) catch |err| {
                    switch (err) {
                        OutOfMemoryError.OutOfMemory => {
                            return ErrorOrBlock.Null;
                        },
                    }
                };
            }
            _ = parser_var.get_next_symbol();

            return .{ .AssemblyBlock = AssemblyBlock.init(opcodes) };
        }
    }
    return .{ .Null = {} };
}

test "assembly block" {}
