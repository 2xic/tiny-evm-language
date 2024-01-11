const std = @import("std");
const ArrayList = std.ArrayList;

// This file should just split up tokens

pub fn get_tokens(value: []const u8) ![][]const u8 {
    const space: u8 = ' ';
    var tokens = std.ArrayList([]const u8).init(std.heap.page_allocator);

    var token_start: usize = 0;

    for (value, 0..) |c, i| {
        if (c == space) {
            if (i != token_start) {
                const token_slice: []const u8 = value[token_start..i];
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
