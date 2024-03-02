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

        opcodeMap.put("PUSH4", Opcodemetdata{ .opcode = 0x63, .inlineArgumentSize = 4 }) catch |err| {
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

        return Opcodes{ .OpcodesMap = opcodeMap };
    }
};
