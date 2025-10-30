const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;
const line_size: usize = 16;

fn processLine(line: []const u8) void {
    std.debug.print("{s}\n", .{line});
}

fn readN(reader: *std.Io.Reader, n: usize) ![]const u8 {
    return reader.take(n) catch |err| switch (err) {
        error.ReadFailed => err,
        error.EndOfStream => if (reader.bufferedLen() == 0) err else try reader.take(reader.bufferedLen()),
    };
}

pub fn main() !void {
    const path: []const u8 = ".gitignore";
    var file: std.fs.File = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        return;
    };
    defer file.close();

    var buffer: [buffer_size]u8 = undefined;
    var reader: std.fs.File.Reader = std.fs.File.reader(file, &buffer);

    const ioReader: *std.Io.Reader = &reader.interface;

    while (true) {
        const maybeLine = readN(ioReader, line_size);
        const line = if (maybeLine) |line| line else |err| switch (err) {
            std.Io.Reader.Error.ReadFailed => {
                std.debug.print("Read failed\n\t{any}", .{err});
                return;
            },
            std.Io.Reader.Error.EndOfStream => {
                std.debug.print("ok\n", .{});
                return;
            },
        };

        processLine(line);
    }
}
