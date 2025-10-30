const std = @import("std");
const zzd = @import("zzd");

const buffer_size: usize = 1024;
const line_size: usize = 16;

pub fn main() !void {
    const path: []const u8 = ".gitignore";
    var file: std.fs.File = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        return;
    };
    defer file.close();

    var buffer: [buffer_size]u8 = undefined;
    var reader: std.fs.File.Reader = std.fs.File.reader(file, &buffer);
    std.debug.print("reader: {any}\n", .{reader});

    const input: *std.Io.Reader = &reader.interface;
    std.debug.print("interface: {any}\n", .{input});

    std.debug.print("ok\n", .{});
}
