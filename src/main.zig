const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;
const line_size: usize = 16;

pub fn main() !void {
    const argv = std.os.argv;

    const path: []const u8 = if (argv.len == 1) ".gitignore" else std.mem.span(argv[1]);

    var file: std.fs.File = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        return;
    };
    defer file.close();

    var inputBuffer: [buffer_size]u8 = undefined;
    var reader: std.fs.File.Reader = std.fs.File.reader(file, &inputBuffer);

    var outputBuffer: [buffer_size]u8 = undefined;
    const stdout: std.fs.File = std.fs.File.stdout();
    var writer: std.fs.File.Writer = std.fs.File.writer(stdout, &outputBuffer);

    const ioReader: *std.Io.Reader = &reader.interface;
    const ioWriter: *std.Io.Writer = &writer.interface;

    while (true) {
        const offset = ioReader.seek;
        const line = zzd.readN(ioReader, line_size) catch |err| switch (err) {
            std.Io.Reader.Error.ReadFailed => {
                std.debug.print("Read failed\n\t{any}", .{err});
                break;
            },
            std.Io.Reader.Error.EndOfStream => {
                std.debug.print("ok\n", .{});
                break;
            },
        };

        zzd.processLine(line, offset, ioWriter) catch |err| {
            std.debug.print("Error:\n\t{any}\n", .{err});
            break;
        };
    }
}
