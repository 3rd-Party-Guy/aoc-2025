const std = @import("std");

var lineLength: usize = undefined;

pub fn main() !void {
    const content: []const u8 = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var numRollsAccessableTotal: u32 = 0;

    var rollCleanedTracker: []bool = try std.heap.page_allocator.alloc(bool, 512 * 512);
    defer std.heap.page_allocator.free(rollCleanedTracker);

    var rollCleanedTrackerNew: []bool = try std.heap.page_allocator.alloc(bool, 512 * 512);
    defer std.heap.page_allocator.free(rollCleanedTrackerNew);

    @memset(rollCleanedTracker, false);
    @memset(rollCleanedTrackerNew, false);

    while (true) {
        var top: ?[]const u8 = null;
        var y: usize = 0;
        var numRollsAccessableRun: u32 = 0;

        var lines = std.mem.tokenizeScalar(u8, content, '\n');
        lineLength = lines.peek().?.len;

        while (lines.next()) |middle| {
            const bottom = lines.peek();
            var numRollsAccessable: u32 = 0;

            for (0..lineLength) |x| {
                if (middle[x] == '.' or rollCleanedTracker[y * lineLength + x]) continue;
                if (isPositionAccessable(bottom, middle, top, x, y, rollCleanedTracker)) {
                    numRollsAccessable += 1;
                    rollCleanedTrackerNew[y * lineLength + x] = true;
                }
            }

            numRollsAccessableRun += numRollsAccessable;
            top = middle;
            y += 1;
        }

        if (numRollsAccessableRun == 0) {
            break;
        }
        numRollsAccessableTotal += numRollsAccessableRun;
        @memcpy(rollCleanedTracker, rollCleanedTrackerNew);

        std.debug.print("Num rolls accessable run: {}\nNum rolls accessable total: {}\n", .{
            numRollsAccessableRun,
            numRollsAccessableTotal,
        });
    }

    std.debug.print("Final total: {}\n", .{numRollsAccessableTotal});
}

inline fn isPositionAccessable(bottom: ?[]const u8, middle: []const u8, top: ?[]const u8, x: usize, y: usize, cleanTracker: []const bool) bool {
    var numRollsAround: u8 = 0;
    if (top) |t| {
        numRollsAround += evaluateLine(t, x, y-1, false, cleanTracker);
    }
    if (bottom) |b| {
        numRollsAround += evaluateLine(b, x, y+1, false, cleanTracker);
    }

    numRollsAround += evaluateLine(middle, x, y, true, cleanTracker);

    return (numRollsAround < 4);
}

inline fn evaluateLine(line: []const u8, x: usize, y: usize, isMiddle: bool, cleanTracker: []const bool) u8 {
    var numRolls: u8 = 0;
    if (x > 0) {
        if (isRoll(line[x - 1]) and !cleanTracker[lineLength * y + (x - 1)]) numRolls += 1;
    }
    if (x < lineLength - 1) {
        if (isRoll(line[x + 1]) and !cleanTracker[lineLength * y + (x + 1)]) numRolls += 1;
    }

    if (!isMiddle) {
        if (isRoll(line[x]) and !cleanTracker[lineLength * y + x]) numRolls += 1;
    }

    return numRolls;
}

inline fn isRoll(c: u8) bool {
    return (c == '@');
}
