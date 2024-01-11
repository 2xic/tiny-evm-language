const std = @import("std");
const ArrayList = std.ArrayList;

// This file should just split up tokens

pub fn get_tokens(value: []const u8) ![][]const u8 {
    const space: u8 = ' ';
    const new_line: u8 = '\n';
    const start_block: u8 = '{';
    const end_block: u8 = '{';
    const split_opcodes: u8 = ';';
    var tokens = std.ArrayList([]const u8).init(std.heap.page_allocator);

    var token_start: usize = 0;

    for (value, 0..) |c, i| {
        if (c == space or c == new_line or c == start_block or c == end_block or c == split_opcodes) {
            if (i != token_start) {
                const token_slice: []const u8 = value[token_start..i];
                try tokens.append(token_slice);
            } else if (c == start_block or c == end_block or c == split_opcodes) {
                // We are a special token ... lets add it!
                const token_slice: []const u8 = value[token_start .. i + 1];
                try tokens.append(token_slice);
            }
            token_start = i + 1;
        }
    }

    // Adding the last token
    if (token_start < value.len) {
        const last_token_slice: []const u8 = value[token_start..];
        try tokens.append(last_token_slice);
    }

    return tokens.toOwnedSlice();
}
