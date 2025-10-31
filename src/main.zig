const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;

const cfg = zzd.Config.default();

const IoContext = struct {
    infile: ?std.fs.File,
    inputBuffer: [buffer_size]u8,
    outputBuffer: [buffer_size]u8,
    rawReader: std.fs.File.Reader,
    rawWriter: std.fs.File.Writer,

    const Self = @This();

    fn open(infilePath: ?[]const u8) !Self {
        var out: Self = undefined;

        const infile = if (infilePath) |path| try std.fs.cwd().openFile(path, .{}) else std.fs.File.stdin();
        const outfile = std.fs.File.stdout();

        out.rawReader = infile.reader(&out.inputBuffer);
        out.rawWriter = outfile.writer(&out.outputBuffer);
        out.infile = if (infilePath) |_| infile else null;

        return out;
    }

    fn close(self: Self) void {
        if (self.infile) |infile| {
            infile.close();
        }
    }
};

pub fn main() !void {
    const argv = std.os.argv;

    const infilePath: []const u8 = if (argv.len == 1) ".gitignore" else std.mem.span(argv[1]);
    var ioCtx = try IoContext.open(infilePath);
    defer ioCtx.close();

    const reader: *std.Io.Reader = &ioCtx.rawReader.interface;
    const writer: *std.Io.Writer = &ioCtx.rawWriter.interface;

    while (true) {
        const offset = reader.seek;
        const line = zzd.readN(reader, cfg.line_width) catch |err| switch (err) {
            std.Io.Reader.Error.ReadFailed => {
                std.debug.print("Read failed\n\t{any}", .{err});
                std.process.exit(1);
            },
            std.Io.Reader.Error.EndOfStream => {
                break;
            },
        };

        zzd.processLine(line, offset, writer, cfg) catch |err| {
            std.debug.print("Error:\n\t{any}\n", .{err});
            std.process.exit(1);
        };
    }
}
