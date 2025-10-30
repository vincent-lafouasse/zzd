const std = @import("std");

pub const Config = struct {
    line_width: usize,
};

fn writeOffset(offset: usize, writer: *std.Io.Writer) !void {
    try writer.print("{x:08}: ", .{offset});
}

fn writeHex(line: []const u8, writer: *std.Io.Writer, line_width: usize) !void {
    const len = line.len;
    var i: @TypeOf(len) = 0;

    while (i < line_width) : (i += 1) {
        if (i < len) {
            try writer.print("{x:02}", .{line[i]});
        } else {
            try writer.print("  ", .{});
        }

        if (i % 2 == 1) {
            try writer.print(" ", .{});
        }
    }
    try writer.print(" ", .{});
}

fn isPrintable(c: u8) bool {
    return (c >= 0x20) and (c != 0x7f);
}

fn writeAscii(line: []const u8, writer: *std.Io.Writer) !void {
    for (line) |c| {
        const char = if (isPrintable(c)) c else '.';
        try writer.print("{c}", .{char});
    }
}

pub fn processLine(line: []const u8, offset: usize, writer: *std.Io.Writer, cfg: Config) !void {
    try writeOffset(offset, writer);
    try writeHex(line, writer, cfg.line_width);
    try writeAscii(line, writer);
    try writer.print("\n", .{});
    try writer.flush();
}

pub fn readN(reader: *std.Io.Reader, n: usize) ![]const u8 {
    return reader.take(n) catch |err| switch (err) {
        error.ReadFailed => err,
        error.EndOfStream => if (reader.bufferedLen() == 0) err else try reader.take(reader.bufferedLen()),
    };
}
