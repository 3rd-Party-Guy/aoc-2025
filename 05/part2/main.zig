const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var iter = std.mem.splitScalar(u8, content, '\n');

    var starts = try std.heap.page_allocator.alloc(u128, 1024);
    var ends = try std.heap.page_allocator.alloc(u128, 1024);
    var nextRangeIndex: usize = 0;

    // collect ranges
    while (iter.next()) |line| {
        const dashIndex = std.mem.indexOf(u8, line, "-");
        if (dashIndex == null) break;

        const start = try std.fmt.parseInt(u128, line[0..dashIndex.?], 10);
        const end = try std.fmt.parseInt(u128, line[dashIndex.? + 1 ..], 10);

        starts[nextRangeIndex] = start;
        ends[nextRangeIndex] = end;
        nextRangeIndex += 1;
    }

    quicksort(0, nextRangeIndex - 1, starts, ends);
    const numEntries = merge(starts, ends, nextRangeIndex);

    var numConsideredFresh: usize = 0;
    for (0..numEntries) |i| {
        numConsideredFresh += @intCast(ends[i] - starts[i] + 1);
    }

    std.debug.print("Num considered fresh: {}\n", .{numConsideredFresh});
}

fn debugPrint(prefix: []const u8, starts: []const u128, ends: []const u128, length: usize) void {
    std.debug.print("{s}\n", .{prefix});

    for (0..length) |i| {
        std.debug.print("{}-{}\n", .{ starts[i], ends[i] });
    }
}

fn contains(starts: []const u128, ends: []const u128, length: usize, id: u128) bool {
    var lo: usize = 0;
    var hi: usize = length;

    while (lo < hi) {
        const mid = (lo + hi) >> 1;
        if (starts[mid] <= id) lo = mid + 1 else hi = mid;
    }

    if (lo == 0) return false;
    return id <= ends[lo - 1];
}

fn quicksort(lo: usize, hi: usize, s: []u128, e: []u128) void {
    if (lo >= hi) return;

    const pivot = s[hi];
    var i: usize = lo;
    for (lo..hi) |j| {
        if (s[j] < pivot) {
            swap(i, j, s, e);
            i += 1;
        }
    }

    swap(i, hi, s, e);
    if (i > 0) quicksort(lo, i - 1, s, e);
    quicksort(i + 1, hi, s, e);
}

fn merge(starts: []u128, ends: []u128, length: usize) usize {
    var wi: usize = 0;

    for (1..length) |ri| {
        if (starts[ri] <= ends[wi] + 1) {
            if (ends[ri] > ends[wi]) ends[wi] = ends[ri];
        } else {
            wi += 1;
            starts[wi] = starts[ri];
            ends[wi] = ends[ri];
        }
    }

    return wi + 1;
}

inline fn swap(i: usize, j: usize, s: []u128, e: []u128) void {
    const tmpS = s[i];
    s[i] = s[j];
    s[j] = tmpS;
    const tmpE = e[i];
    e[i] = e[j];
    e[j] = tmpE;
}
