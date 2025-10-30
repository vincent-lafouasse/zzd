const std = @import("std");

pub fn processLine(line: []const u8, offset: usize, writer: *std.Io.Writer) !void {
    try writer.print("{x}:\t", .{offset});
    try writer.print("{s}", .{line});
    try writer.print("\n", .{});
    try writer.flush();
}

pub fn readN(reader: *std.Io.Reader, n: usize) ![]const u8 {
    return reader.take(n) catch |err| switch (err) {
        error.ReadFailed => err,
        error.EndOfStream => if (reader.bufferedLen() == 0) err else try reader.take(reader.bufferedLen()),
    };
}
