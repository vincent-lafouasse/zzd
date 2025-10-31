const std = @import("std");

pub const Config = @import("config.zig").Config;

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

const ColorWriter = struct {
    writer: *std.Io.Writer,
    active: bool,

    fn new(writer: *std.Io.Writer) ColorWriter {
        return .{ .writer = writer, .active = true };
    }

    fn printColor(self: ColorWriter, comptime fmt: []const u8, args: anytype, color: AnsiColors) !void {
        if (self.active and color != AnsiColors.None) {
            try self.print("{s}", .{color.code()});
        }
        try self.print(fmt, args);
        if (self.active and color != AnsiColors.None) {
            try self.print("{s}", .{AnsiColors.reset});
        }
    }

    fn print(self: ColorWriter, comptime fmt: []const u8, args: anytype) !void {
        try self.writer.print(fmt, args);
    }

    fn activate(self: *ColorWriter) void {
        self.active = true;
    }

    fn deactivate(self: *ColorWriter) void {
        self.active = false;
    }
};

fn byteColor(byte: u8) AnsiColors {
    return switch (byte) {
        0x00 => AnsiColors.None,
        0xff => AnsiColors.Blue,
        0x09, 0x0a, 0x0d => AnsiColors.Yellow,
        0x20...0x7e => AnsiColors.Green,
        else => AnsiColors.Red,
    };
}

fn writeOffset(offset: usize, writer: ColorWriter) !void {
    try writer.print("{x:08}: ", .{offset});
}

fn writeHex(line: []const u8, writer: ColorWriter, line_width: usize) !void {
    const len = line.len;
    var i: @TypeOf(len) = 0;

    while (i < line_width) : (i += 1) {
        if (i < len) {
            const c = line[i];
            try writer.printColor("{x:02}", .{c}, byteColor(c));
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

fn writeAscii(line: []const u8, writer: ColorWriter) !void {
    for (line) |c| {
        const char = if (isPrintable(c)) c else '.';
        try writer.printColor("{c}", .{char}, byteColor(c));
    }
}

pub fn processLine(line: []const u8, offset: usize, writer: *std.Io.Writer, cfg: Config) !void {
    const colorWriter = ColorWriter.new(writer);
    try writeOffset(offset, colorWriter);
    try writeHex(line, colorWriter, cfg.line_width);
    try writeAscii(line, colorWriter);
    try writer.print("\n", .{});
    try writer.flush();
}

pub fn readN(reader: *std.Io.Reader, n: usize) ![]const u8 {
    return reader.take(n) catch |err| switch (err) {
        error.ReadFailed => err,
        error.EndOfStream => if (reader.bufferedLen() == 0) err else try reader.take(reader.bufferedLen()),
    };
}
