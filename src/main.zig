const std = @import("std");
const zzd = @import("zzd");

pub fn main() !void {
    const path = ".gitignore";
    var file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Failed to open file {s}:\n\t{any}\n", .{ path, err });
        return;
    };
    defer file.close();

    std.debug.print("ok\n", .{});
}
