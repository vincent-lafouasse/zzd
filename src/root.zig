const std = @import("std");

const AnsiColors = enum {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Purple,
    Cyan,
    White,
    None,

    const Self = @This();
    const reset = "\x1b[0m";

    fn code(self: Self) []const u8 {
        return switch (self) {
            Self.Black => "\x1b[0;30m",
            Self.Red => "\x1b[0;31m",
            Self.Green => "\x1b[0;32m",
            Self.Yellow => "\x1b[0;33m",
            Self.Blue => "\x1b[0;34m",
            Self.Purple => "\x1b[0;35m",
            Self.Cyan => "\x1b[0;36m",
            Self.White => "\x1b[0;37m",
            Self.None => "",
        };
    }
};

fn byteColor(byte: u8) AnsiColors {
    return switch (byte) {
        0x00 => AnsiColors.None,
        0xff => AnsiColors.Blue,
        0x20...0xfe => AnsiColors.Green, // printable
        0x09...0x0d => AnsiColors.Yellow, // spaces
        else => AnsiColors.Red, // non printable
    };
}

fn coloredPrint(writer: *std.Io.Writer, comptime fmt: []const u8, args: anytype, color: AnsiColors) !void {
    if (color != AnsiColors.None) {
        try writer.print("{s}", .{color.code()});
    }
    try writer.print(fmt, args);
    if (color != AnsiColors.None) {
        try writer.print("{s}", .{AnsiColors.reset});
    }
}

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
            const c = line[i];
            try coloredPrint(writer, "{x:02}", .{c}, byteColor(c));
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
    return (c >= 0x20) and (c < 0x7f);
}

fn writeAscii(line: []const u8, writer: *std.Io.Writer) !void {
    for (line) |c| {
        const char = if (isPrintable(c)) c else '.';
        try coloredPrint(writer, "{c}", .{char}, byteColor(char));
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
