const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;
const line_size: usize = 16;

fn processLine(line: []const u8) void {
    std.debug.print("{s}\n", .{line});
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
        const maybeLine = ioReader.take(line_size);
        if (maybeLine) |line| {
            processLine(line);
        } else |err| {
            switch (err) {
                error.ReadFailed => {
                    std.debug.print("Failed to read line from file", .{});
                    return;
                },
                error.EndOfStream => {
                    const len = ioReader.bufferedLen();
                    if (len == 0) {
                        return;
                    } else {
                        const partialLine = try ioReader.take(ioReader.bufferedLen());
                        processLine(partialLine);
                    }
                },
            }
        }
    }

    std.debug.print("ok\n", .{});
}
