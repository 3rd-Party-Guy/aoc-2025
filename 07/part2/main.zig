const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var linesIter = std.mem.tokenizeScalar(u8, content, '\n');
    const width = linesIter.peek().?.len;

    var curr = try std.heap.page_allocator.alloc(u128, width);
    defer std.heap.page_allocator.free(curr);
    @memset(curr, 0);

    var next = try std.heap.page_allocator.alloc(u128, width);
    defer std.heap.page_allocator.free(next);
    @memset(next, 0);

    const startLine = linesIter.next().?;
    var x: usize = 0;
    for (startLine) |c| {
        if (c == 'S') {
            curr[x] = 1;
            break;
        }
        x += 1;
    }

    while (linesIter.next()) |line| {
        @memset(next, 0);
        x = 0;

        for (line) |c| {
            const n = curr[x];
            if (n != 0) {
                if (c == '^') {
                    next[x - 1] += n;
                    next[x + 1] += n;
                } else {
                    next[x] += n;
                }
            }

            x += 1;
        }

        @memcpy(curr, next);
    }

    var total: u128 = 0;
    for (curr) |v| total += v;
    std.debug.print("Total: {}\n", .{total});
}
