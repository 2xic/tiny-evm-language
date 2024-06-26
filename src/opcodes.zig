const std = @import("std");

pub const Opcodemetdata = struct { opcode: u32, inlineArgumentSize: u8 };

const OutOfMemoryError = error{OutOfMemory};

pub const Opcodes = struct {
    OpcodesMap: std.StringHashMap(Opcodemetdata),

    // TODO: Add more opcodes

    pub fn init() Opcodes {
        var opcodeMap = std.StringHashMap(Opcodemetdata).init(std.heap.page_allocator);
        opcodeMap.put("STOP", Opcodemetdata{ .opcode = 0x00, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("POP", Opcodemetdata{ .opcode = 0x50, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("MSTORE", Opcodemetdata{ .opcode = 0x52, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("MLOAD", Opcodemetdata{ .opcode = 0x51, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("GAS", Opcodemetdata{ .opcode = 0x5A, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("PUSH0", Opcodemetdata{ .opcode = 0x5F, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("PUSH1", Opcodemetdata{ .opcode = 0x60, .inlineArgumentSize = 1 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("PUSH2", Opcodemetdata{ .opcode = 0x61, .inlineArgumentSize = 1 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        // NOTE: inlineArgumentSize is confusing here - FIX IT!
        // It should just be used to validate (or pad) the next variable if it's not having the correct size in bytes.
        opcodeMap.put("PUSH4", Opcodemetdata{ .opcode = 0x63, .inlineArgumentSize = 1 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("PUSH20", Opcodemetdata{ .opcode = 0x73, .inlineArgumentSize = 1 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("PUSH32", Opcodemetdata{ .opcode = 0x7F, .inlineArgumentSize = 1 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("ADD", Opcodemetdata{ .opcode = 0x01, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("MUL", Opcodemetdata{ .opcode = 0x02, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("LT", Opcodemetdata{ .opcode = 0x10, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("SHL", Opcodemetdata{ .opcode = 0x1b, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("SHR", Opcodemetdata{ .opcode = 0x1c, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("EQ", Opcodemetdata{ .opcode = 0x14, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("JUMP", Opcodemetdata{ .opcode = 0x56, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("JUMPI", Opcodemetdata{ .opcode = 0x57, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("PC", Opcodemetdata{ .opcode = 0x58, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("JUMPDEST", Opcodemetdata{ .opcode = 0x5B, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("CALLDATALOAD", Opcodemetdata{ .opcode = 0x35, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("DUP1", Opcodemetdata{ .opcode = 0x80, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("DUP2", Opcodemetdata{ .opcode = 0x81, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("DUP5", Opcodemetdata{ .opcode = 0x84, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("DUP6", Opcodemetdata{ .opcode = 0x85, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("DUP7", Opcodemetdata{ .opcode = 0x86, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("DUP8", Opcodemetdata{ .opcode = 0x87, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("DUP9", Opcodemetdata{ .opcode = 0x88, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("ISZERO", Opcodemetdata{ .opcode = 0x15, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("CALL", Opcodemetdata{ .opcode = 0xF1, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("CODECOPY", Opcodemetdata{ .opcode = 0x39, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("RETURN", Opcodemetdata{ .opcode = 0xF3, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("SLOAD", Opcodemetdata{ .opcode = 0x54, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("SSTORE", Opcodemetdata{ .opcode = 0x55, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("ADDRESS", Opcodemetdata{ .opcode = 0x30, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("REVERT", Opcodemetdata{ .opcode = 0x7D, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };

        opcodeMap.put("CALLER", Opcodemetdata{ .opcode = 0x33, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        opcodeMap.put("SELFDESTRUCT", Opcodemetdata{ .opcode = 0xFF, .inlineArgumentSize = 0 }) catch |err| {
            switch (err) {
                OutOfMemoryError.OutOfMemory => {
                    @panic("Out of memory");
                },
            }
        };
        return Opcodes{ .OpcodesMap = opcodeMap };
    }
};
