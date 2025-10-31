const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;

const cfg = zzd.Config.default();

pub fn main() !void {
    const argv = std.os.argv;

    const path: []const u8 = if (argv.len == 1) ".gitignore" else std.mem.span(argv[1]);

    var file: std.fs.File = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        std.process.exit(1);
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
        const line = zzd.readN(ioReader, cfg.line_width) catch |err| switch (err) {
            std.Io.Reader.Error.ReadFailed => {
                std.debug.print("Read failed\n\t{any}", .{err});
                std.process.exit(1);
            },
            std.Io.Reader.Error.EndOfStream => {
                break;
            },
        };

        zzd.processLine(line, offset, ioWriter, cfg) catch |err| {
            std.debug.print("Error:\n\t{any}\n", .{err});
            std.process.exit(1);
        };
    }
}
