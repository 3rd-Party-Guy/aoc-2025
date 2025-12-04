const std = @import("std");

pub fn main() !void {
    const content: []const u8 = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);
    var ci: usize = 0;

    var curReadRangeStart: u64 = 0;
    var curReadRangeEnd: u64 = 0;

    var isReadingStart: bool = true;
    var rangeInsertIndex: u8 = 0;

    var rangesList: []u64 = try std.heap.page_allocator.alloc(u64, 255);
    defer std.heap.page_allocator.free(rangesList);

    while (ci < content.len) : (ci += 1) {
        while (ci < content.len and content[ci] != 10 and content[ci] != '-' and content[ci] != ',') : (ci += 1) {
            if (isReadingStart) {
                curReadRangeStart = curReadRangeStart * 10 + (content[ci] - '0');
            } else {
                curReadRangeEnd = curReadRangeEnd * 10 + (content[ci] - '0');
            }
        }

        if (curReadRangeStart != 0 and curReadRangeEnd != 0) {
            rangesList[rangeInsertIndex] = curReadRangeStart;
            rangesList[rangeInsertIndex + 1] = curReadRangeEnd;

            curReadRangeStart = 0;
            curReadRangeEnd = 0;

            rangeInsertIndex += 2;
        }
        isReadingStart = !isReadingStart;
    }

    var mirrorSeqList: []u64 = try std.heap.page_allocator.alloc(u64, 65535);
    var mirrorSeqInsertIndex: u16 = 0;

    var rangeIndex: u8 = 0;
    while (rangeIndex < rangeInsertIndex) : (rangeIndex += 2) {
        const rangeStart: u64 = rangesList[rangeIndex];
        const rangeEnd: u64 = rangesList[rangeIndex + 1];

        std.debug.print("Calculating for: {} - {}\n", .{rangeStart, rangeEnd});

        for (rangeStart..rangeEnd) |i| {
            if (isRepeatedPattern(i)) {
                mirrorSeqList[mirrorSeqInsertIndex] = i;
                mirrorSeqInsertIndex += 1;
            }
        }
    }

    var sum: u128 = 0;
    for (0..mirrorSeqInsertIndex) |i| {
        std.debug.print("Adding: {}\n", .{mirrorSeqList[i]});
        sum += mirrorSeqList[i];
    }

    std.debug.print("Sum: {}\n", .{sum});
    std.debug.assert(sum == 41294979841);
}

fn isRepeatedPattern(n: u64) bool {
    var tmp = n;
    var digits: u8 = 0;
    while (tmp > 0) : (tmp /= 10) digits += 1;
    if (digits < 2) return false;

    var k: u8 = 1;
    while (k <= digits / 2) : (k += 1) {
        if (digits % k != 0) continue;

        const pow_k = std.math.pow(u64, 10, digits - k);
        const pattern = n / pow_k;

        var remain = n;
        const pow_step = std.math.pow(u64, 10, k);

        var ok = true;
        while (remain > 0) {
            const block = remain % pow_step;
            if (block != pattern) {
                ok = false;
                break;
            }
            remain /= pow_step;
        }

        if (ok) return true;
    }

    return false;
}
