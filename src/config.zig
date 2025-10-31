const Flag = struct {
    short: []const u8,
    long: []const u8,
    argumentName: ?[]const u8,
    description: []const u8,

    fn columns() Flag {
        return Flag{
            .short = "-c",
            .long = "--columns",
            .argumentName = "cols",
            .description = "format <cols> octets per line. Default 16.",
        };
    }

    fn help() Flag {
        return Flag{ .short = "-h", .long = "--help", .argumentName = null, .description = "print this summary." };
    }
};

pub const Config = struct {
    line_width: usize,
    colors: bool,

    const Self = @This();

    pub fn default() Self {
        return Self{ .line_width = 16, .colors = true };
    }
};
