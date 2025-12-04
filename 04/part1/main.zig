const std = @import("std");

var lineLength: usize = undefined;

pub fn main() !void {
    const content: []const u8 = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var numRollsAccessable: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var top: ?[]const u8 = null;
    lineLength = lines.peek().?.len;

    while (lines.next()) |middle| {
        const bottom = lines.peek();

        for (0..lineLength) |i| {
            if (middle[i] == '.') continue;
            if (isPositionAccessable(bottom, middle, top, i)) numRollsAccessable += 1;
        }

        top = middle;
    }

    std.debug.print("Num rolls accessable: {}\n", .{numRollsAccessable});
}

inline fn isPositionAccessable(bottom: ?[]const u8, middle: []const u8, top: ?[]const u8, x: usize) bool {
    var numRollsAround: u8 = 0;
    if (top) |t| {
        numRollsAround += evaluateLine(t, x, false);
    }
    if (bottom) |b| {
        numRollsAround += evaluateLine(b, x, false);
    }

    numRollsAround += evaluateLine(middle, x, true);

    return (numRollsAround < 4);
}

inline fn evaluateLine(line: []const u8, x: usize, isMiddle: bool) u8 {
    var numRolls: u8 = 0;
    if (x > 0) {
        if (isRoll(line[x - 1])) numRolls += 1;
    }
    if (x < lineLength - 1) {
        if (isRoll(line[x + 1])) numRolls += 1;
    }

    if (!isMiddle) {
        if (isRoll(line[x])) numRolls += 1;
    }

    return numRolls;
}

inline fn isRoll(c: u8) bool {
    return (c == '@');
}
