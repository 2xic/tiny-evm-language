const std = @import("std");

const OpcodesMap = @import("./opcodes.zig");

const Opcode = struct {
    name: []const u8,
    opcode: u32,
    arguments: [][]const u8,

    pub fn init(name: []const u8, opcode: u32, arguments: [][]const u8) Opcode {
        return Opcode{ .name = name, .opcode = opcode, .arguments = arguments };
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
    cmp: CompareBlock,
    body: std.ArrayList(BaseBlocks),
    elseBody: std.ArrayList(BaseBlocks),
};

pub const IfBlockError = union(enum) {
    IfBlock: IfBlock,
    Null: void,
};

pub const FunctionBlock = struct {
    name: []const u8,
    body: std.ArrayList(BaseBlocks),
};

pub const FunctionCall = struct {
    name: []const u8,
};
pub const FunctionCallError = union(enum) {
    FunctionCall: FunctionCall,
    Null: void,
};

pub const FunctionBlockError = union(enum) {
    FunctionBlock: FunctionBlock,
    Null: void,
};

pub const BaseBlocks = union(enum) {
    IfBlock: IfBlock,
    AssemblyBlock: AssemblyBlock,
    FunctionCall: FunctionCall,
    Null: void,
};

pub const GlobalBaseBlocks = union(enum) {
    IfBlock: IfBlock,
    AssemblyBlock: AssemblyBlock,
    FunctionBlock: FunctionBlock,
    FunctionCall: FunctionCall,
    Null: void,
};

const Parser = struct {
    entries: [][]const u8,
    currentIndex: usize,
    functions: std.ArrayList([]const u8),
    functionsName: []const u8,

    pub fn init(entries: [][]const u8, functions: std.ArrayList([]const u8)) Parser {
        return Parser{ .entries = entries, .currentIndex = 0, .functions = functions, .functionsName = "" };
    }

    pub fn has_next_symbol(self: *Parser) bool {
        return (self.currentIndex + 1) < self.entries.len;
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

    pub fn add_function(self: *Parser, functionName: []const u8) !void {
        try self.functions.append(functionName);
        return;
    }

    pub fn set_current_function_name(self: *Parser, functionName: []const u8) !void {
        self.functionsName = functionName;
        return;
    }
};

pub fn get_get_ast(entries: [][]const u8) !std.ArrayList(GlobalBaseBlocks) {
    const functions = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var parser = Parser.init(entries, functions);

    var opcodes = std.ArrayList(GlobalBaseBlocks).init(std.heap.page_allocator);
    var oldIndex = parser.currentIndex;
    while (parser.currentIndex < entries.len) {
        const function: FunctionBlockError = get_function_block(&parser);

        switch (function) {
            FunctionBlockError.FunctionBlock => |assemblyBlock| {
                try opcodes.append(GlobalBaseBlocks{ .FunctionBlock = assemblyBlock });
                try parser.add_function(assemblyBlock.name);
            },
            FunctionBlockError.Null => {
                parser.currentIndex = oldIndex;

                const opcode: BaseBlocks = get_base_block(&parser);
                switch (opcode) {
                    BaseBlocks.AssemblyBlock => |assemblyBlock| {
                        try opcodes.append(GlobalBaseBlocks{ .AssemblyBlock = assemblyBlock });
                    },
                    BaseBlocks.IfBlock => |assemblyBlock| {
                        try opcodes.append(GlobalBaseBlocks{ .IfBlock = assemblyBlock });
                    },
                    BaseBlocks.FunctionCall => |assemblyBlock| {
                        try opcodes.append(GlobalBaseBlocks{ .FunctionCall = assemblyBlock });
                    },
                    BaseBlocks.Null => {
                        @panic("Got null block, expected block to be defined");
                    },
                }
            },
        }

        if (oldIndex == parser.currentIndex) {
            std.debug.print("Parser index == {} / {} \n", .{ .val = parser.currentIndex, .aa = entries.len });
            @panic("Index was unchanged");
        }
        oldIndex = parser.currentIndex;
    }

    return opcodes;
}

fn get_function_block(parser: *Parser) FunctionBlockError {
    var parser_var = parser;

    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "function")) {
        // TODO: Clean up the api for this interaction
        const _function_def = parser_var.get_next_symbol();
        _ = _function_def;

        const _function_name = parser_var.get_next_symbol();

        try parser_var.set_current_function_name(_function_name);

        const start_symbol = parser_var.get_next_symbol();
        if (std.mem.eql(u8, start_symbol, "{")) {
            var body = std.ArrayList(BaseBlocks).init(std.heap.page_allocator);

            // TODO: Clean up this interaction
            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                const assembly: BaseBlocks = get_base_block(parser);

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
                    parser.currentIndex = currentPosition;
                    const function_call_value = parse_function_call(parser);
                    switch (function_call_value) {
                        FunctionCallError.FunctionCall => |block| {
                            return .{ .FunctionCall = block };
                        },
                        FunctionCallError.Null => {},
                    }
                },
            }
            @panic("Something went wrong! Unknown code state when fetching base block");
        },
    }
    @panic("Something went wrong! Unknown code state when fetching base block");
}

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

            var elseBody = std.ArrayList(BaseBlocks).init(std.heap.page_allocator);

            // THE NEXT BLOCK COULD BE AN ELSE !!!!
            if (parser_var.has_next_symbol()) {
                if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), "else")) {
                    _ = parser_var.get_next_symbol();
                    _ = parser_var.get_next_symbol();
                    while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                        const assembly: BaseBlocks = get_base_block(parser);
                        elseBody.append(assembly) catch |err| {
                            switch (err) {
                                OutOfMemoryError.OutOfMemory => {
                                    return IfBlockError.Null;
                                },
                            }
                        };
                    }
                    _ = parser_var.get_next_symbol();
                }
            }

            return .{ .IfBlock = IfBlock{ .cmp = CompareBlock{ .expr_1 = expr_1, .expr_2 = expr_2 }, .body = body, .elseBody = elseBody } };
        }
    }
    return .{ .Null = {} };
}

fn parse_function_call(parser: *Parser) FunctionCallError {
    var parser_var = parser;
    if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), parser_var.functionsName)) {
        const name = parser_var.get_next_symbol();
        return .{ .FunctionCall = FunctionCall{ .name = name } };
    }

    for (parser.functions.items) |elem| {
        if (std.mem.eql(u8, parser_var.peek_nexy_symbol(), elem)) {
            const name = parser_var.get_next_symbol();

            return .{ .FunctionCall = FunctionCall{ .name = name } };
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
            // TODO: Improve this interface
            // While we don't see a "}" we are inside a assembly block
            while (!std.mem.eql(u8, parser_var.peek_nexy_symbol(), "}")) {
                // Opcodes I hope  ...
                const value = parser_var.get_next_symbol();
                var opcodeMap = OpcodesMap.Opcodes.init().OpcodesMap;
                const opcodeType = opcodeMap.get(value);

                if (opcodeType == null) {
                    // Handle the case when the value is not in the opcode map
                    @panic("Something went wrong! Unknown opcode");
                }

                const allocator = std.heap.page_allocator;
                var array: [][]const u8 = allocator.alloc([]const u8, opcodeType.?.inlineArgumentSize) catch |err| {
                    switch (err) {
                        OutOfMemoryError.OutOfMemory => {
                            return ErrorOrBlock.Null;
                        },
                    }
                };

                // TODO: Here we should do validation of the size and padding also if the value is less than what is specified.
                for (0..opcodeType.?.inlineArgumentSize) |index| {
                    array[index] = parser_var.get_next_symbol();
                }

                opcodes.append(Opcode.init(value, opcodeType.?.opcode, array)) catch |err| {
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
