const std = @import("std");

// const Flag = struct {
//     short: []const u8,
//     long: []const u8,
//     argumentName: ?[]const u8,
//     description: []const u8,
//
//     fn columns() Flag {
//         return Flag{
//             .short = "-c",
//             .long = "--columns",
//             .argumentName = "cols",
//             .description = "format <cols> octets per line. Default 16.",
//         };
//     }
//
//     fn help() Flag {
//         return Flag{ .short = "-h", .long = "--help", .argumentName = null, .description = "print this summary." };
//     }
// };

pub const Config = struct {
    infilePath: ?[]const u8 = null,
    line_width: usize = 16,

    const Self = @This();

    pub fn parse(args: [][*:0]u8) Self {
        const infilePath: ?[]const u8 = if (args.len == 0) null else std.mem.span(args[0]);
        const line_width: usize = 16;

        return .{ .infilePath = infilePath, .line_width = line_width };
    }
};
