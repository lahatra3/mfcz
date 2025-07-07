const std = @import("std");

pub fn parseArgsConfig(allocator: std.mem.Allocator, args_config: [][:0]u8) !std.StringHashMap([]const u8) {
    var flags = std.StringHashMap([]const u8).init(allocator);

    for (args_config) |arg| {
        var iter = std.mem.splitAny(u8, arg, "=");
        const key = iter.next() orelse continue;
        const value = iter.next() orelse undefined;

        try flags.put(key, value);
    }

    return flags;
}

pub fn logUnexpectedArg(message: []const u8) void {
    std.log.warn(
        \\
        \\ Missing argments: {s}
        \\ Help:
        \\ $ ~ mfcz --ext=".csv" --dir="path/to/directory" --sink="path/to/destination_file"
        \\
    , .{message});
}
