const std = @import("std");

pub fn main() !void {
    const content: []u8 = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var idx: u32 = 50;
    var hits: u32 = 0;

    var i: usize = 0;
    while (i < content.len) {
        const dir = content[i];
        i += 1;

        var delta: u32 = 0;
        while (i < content.len and content[i] >= '0' and content[i] <= '9') : (i += 1) {
            delta = delta * 10 + (content[i] - '0');
        }

        const res = if (dir == 'R') updatePositive(idx, delta) else updateNegative(idx, delta);
        idx = res[0];
        hits += res[1];

        while (i < content.len and content[i] == '\n') i += 1;
    }

    std.debug.assert(hits == 6892);
}

// returns: newIndex, numHits
inline fn updatePositive(idx: u32, delta: u32) struct { u32, u32 } {
    const newIndex = (idx + delta) % 100;
    const numHits = (idx + delta) / 100;

    return .{ newIndex, numHits };
}

// returns: newIndex, numHits
inline fn updateNegative(idx: u32, delta: u32) struct { u32, u32 } {
    const steps = delta % 100;
    const newIndex: u32 = (idx + 100 - steps) % 100;
    const numHitsOffset: u32 = if (idx == 0) 1 else 0;
    const numHits: u32 = (delta + (100 - idx)) / 100 - numHitsOffset;

    return .{ newIndex, numHits };
}
