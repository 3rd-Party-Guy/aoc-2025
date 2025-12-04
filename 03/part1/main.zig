const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);
    var iter = std.mem.tokenizeScalar(u8, content, '\n');
    var totalVoltage: u32 = 0;

    while (iter.next()) |line| {
        var bestPrefix: u8 = line[0] - '0';
        var lineBest: u8 = 0;

        for (line[1..]) |c| {
            const d: u8 = c - '0';
            const newSum: u8 = bestPrefix * 10 + d;

            if (d > bestPrefix) bestPrefix = d;
            if (newSum > lineBest) lineBest = newSum;
            if (lineBest == 99) break;
        }

        totalVoltage += lineBest;
    }

    std.debug.print("Total Voltage: {}\n", .{totalVoltage});
}
