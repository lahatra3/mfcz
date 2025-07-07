const std = @import("std");
const processor = @import("./processor.zig");
const utils = @import("./utils.zig");
const constant = @import("./constant.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const args_config = args[1..];

    var flags = try utils.parseArgsConfig(allocator, args_config);
    defer flags.deinit();

    const file_extension: []const u8 = flags.get("--ext") orelse "";
    const directory_name: []const u8 = flags.get("--dir") orelse {
        utils.logUnexpectedArg(constant.DIRECTORY_NOT_SPECIFIED_MESSAGE);
        return;
    };
    const sink_file: []const u8 = flags.get("--sink") orelse {
        utils.logUnexpectedArg(constant.DEST_FILE_NOT_SPECIFIED_MESSAGE);
        return;
    };

    {
        var sources_files = processor.findSourcesFiles(allocator, directory_name, file_extension) catch {
            std.log.err(constant.DIRECTORY_NOT_FOUND_MESSAGE, .{directory_name});
            return;
        };
        defer sources_files.deinit();

        if (sources_files.items.len < 1) {
            std.log.warn(constant.NO_FILES_FOUND_MESSAGE, .{});
            return;
        }

        defer {
            for (sources_files.items) |value| {
                allocator.free(value);
            }
        }

        std.log.info("🚗 Start processing... 🚗", .{});
        try processor.mergeFilesContents(allocator, sources_files.items, sink_file);
        std.log.info("✅ Successfully sink into {s} ... 💯", .{sink_file});
    }
}
