const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);
    var iter = std.mem.tokenizeScalar(u8, content, '\n');
    var totalVoltage: u64 = 0;

    while (iter.next()) |line| {
        const best: []const u8 = maxLexicSubseqOfLength(line, 12);
        var finalValue: u64 = 0;
        for (best) |d| finalValue = finalValue * 10 + d;

        totalVoltage += finalValue;
    }

    std.debug.print("Total Voltage: {}\n", .{totalVoltage});
}

fn maxLexicSubseqOfLength(line: []const u8, length: u8) []const u8 {
    var result_storage: [255]u8 = undefined;
    var result_length: usize = 0;

    const n = line.len;

    for (line, 0..) |c, idx| {
        const d: u8 = c - '0';

        while (result_length > 0 and result_storage[result_length - 1] < d and (result_length - 1 + (n - idx)) >= length) {
            result_length -= 1;
        }

        if (result_length < length) {
            result_storage[result_length] = d;
            result_length += 1;
        }
    }

    return result_storage[0..result_length];
}
