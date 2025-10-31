const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;

const IoContext = struct {
    infile: ?std.fs.File, // null means stdin so no cleanup
    inputBuffer: [buffer_size]u8,
    outputBuffer: [buffer_size]u8,
    rawReader: std.fs.File.Reader,
    rawWriter: std.fs.File.Writer,

    const Self = @This();

    // expose the interface not the implementation
    fn reader(self: *Self) *std.Io.Reader {
        return &self.rawReader.interface;
    }

    fn writer(self: *Self) *std.Io.Writer {
        return &self.rawWriter.interface;
    }

    // only failure path is openFile()
    fn open(infilePath: ?[]const u8) !Self {
        const infile = if (infilePath) |path| try std.fs.cwd().openFile(path, .{}) else std.fs.File.stdin();
        const outfile = std.fs.File.stdout();

        var inputBuffer: [buffer_size]u8 = undefined;
        var outputBuffer: [buffer_size]u8 = undefined;
        const rawReader = infile.reader(&inputBuffer);
        const rawWriter = outfile.writer(&outputBuffer);

        return Self{
            .infile = if (infilePath) |_| infile else null,
            .inputBuffer = inputBuffer,
            .outputBuffer = outputBuffer,
            .rawReader = rawReader,
            .rawWriter = rawWriter,
        };
    }

    fn close(self: Self) void {
        if (self.infile) |infile| {
            infile.close();
        }
    }
};

fn die(status: u8, comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print(fmt, args);
    std.process.exit(status);
}

pub fn main() !void {
    // yes std.os.argv is not portable, no i do not care
    const cfg = zzd.Config.parse(std.os.argv[1..]);

    var io = IoContext.open(cfg.infilePath) catch |err| die(1, "Failed to open file {s}\n\t{any}\n", .{ cfg.infilePath.?, err });
    defer io.close();

    var offset: usize = 0;
    while (true) {
        const line = zzd.readN(io.reader(), cfg.line_width) catch |err| switch (err) {
            std.Io.Reader.Error.ReadFailed => die(1, "Read failed\n\t{any}", .{err}),
            std.Io.Reader.Error.EndOfStream => break,
        };

        zzd.processLine(line, offset, io.writer(), cfg) catch |err|
            die(1, "Error:\n\t{any}\n", .{err});
        offset += line.len;
    }
}
