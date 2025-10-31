pub const Config = struct {
    line_width: usize,
    colors: bool,

    const Self = @This();

    pub fn default() Self {
        return Self{ .line_width = 16, .colors = true };
    }
};
