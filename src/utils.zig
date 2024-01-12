const std = @import("std");

pub fn read_file() ![]u8 {
    const allocator = std.heap.page_allocator;

    const filePath = "./programs/your_first_program.golf";

    const file = try std.fs.cwd().openFile(filePath, .{});


    const fileInfo = try file.stat();

    const fileSize = fileInfo.size;

    var fileContents: []u8 = try allocator.alloc(u8, fileSize);

    // TODO: Need to handle these comments ? 
    _ = try file.read(fileContents);

    _ = file.close();

    return fileContents;
}
