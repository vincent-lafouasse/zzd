const std = @import("std");
const zzd = @import("zzd");

pub fn main() !void {
    const path = ".gitignore";
    var file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        return;
    };
    defer file.close();

    var buffer: [1024]u8 = undefined;
    const reader = std.fs.File.reader(file, &buffer);
    std.debug.print("reader: {any}\n", .{reader});

    std.debug.print("ok\n", .{});
}
