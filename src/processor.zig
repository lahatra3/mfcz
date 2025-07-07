const std = @import("std");

pub fn findSourcesFiles(allocator: std.mem.Allocator, directory_name: []const u8, file_extension_filter: []const u8) !std.ArrayList([]const u8) {
    const directory_path = try std.fs.cwd().realpathAlloc(allocator, directory_name);
    defer allocator.free(directory_path);

    var sources_files = std.ArrayList([]const u8).init(allocator);

    const dir = try std.fs.cwd().openDir(directory_path, .{ .iterate = true });

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |file| {
        const ext = std.fs.path.extension(file.basename);
        if (std.mem.eql(u8, ext, file_extension_filter) and file.kind == .file) {
            const file_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ directory_path, file.path });
            try sources_files.append(file_path);
        }
    }

    return sources_files;
}

fn fileProcessor(allocator: std.mem.Allocator, file_path: []const u8, writer: anytype) !void {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    const chunk_size = 16 * 1024;
    var buffer = try allocator.alloc(u8, chunk_size);
    defer allocator.free(buffer);

    while (true) {
        const bytes_read = try reader.read(buffer);
        if (bytes_read == 0) {
            try writer.writeAll("\n");
            break;
        }

        const chunk = buffer[0..bytes_read];
        try writer.writeAll(chunk);
    }
}

pub fn mergeFilesContents(allocator: std.mem.Allocator, sources_files: [][]const u8, sink_file: []const u8) !void {
    const file = try std.fs.cwd().createFile(sink_file, .{ .truncate = true });
    defer file.close();

    var buffered_writer = std.io.bufferedWriter(file.writer());
    const writer = buffered_writer.writer();

    for (sources_files) |value| {
        std.log.info("Process >>> {s}", .{value});
        try fileProcessor(allocator, value, writer);
    }

    try buffered_writer.flush();
}
