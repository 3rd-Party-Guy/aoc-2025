const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var problems: [][]u16 = try std.heap.page_allocator.alloc([]u16, 2048);
    for (problems) |*p| {
        p.* = try std.heap.page_allocator.alloc(u16, 512);
        @memset(p.*, 0);
    }
    var problemSizes: []u16 = try std.heap.page_allocator.alloc(u16, 2048);
    @memset(problemSizes, 0);

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var y: usize = 0;
    var total: u512 = 0;

    while (lines.next()) |line| {
        var elements = std.mem.tokenizeScalar(u8, line, ' ');
        var x: usize = 0;

        while (elements.next()) |element| {
            if (isOperation(element[0])) {
                var res: usize = problems[x][0];

                for (1..problemSizes[x]) |yLocal| {
                    if (element[0] == '*') {
                        res *= problems[x][yLocal];
                    } else {
                        res += problems[x][yLocal];
                    }
                }

                total += res;
            } else {
                var num: u16 = 0;
                for (element) |e| {
                    num = num * 10 + (e - '0');
                }

                problems[x][y] = num;
                problemSizes[x] = @intCast(y + 1);
            }

            x += 1;
        }

        y += 1;
    }

    std.debug.print("Total: {}\n", .{total});
}

inline fn isOperation(c: u16) bool {
    return (c == '+' or c == '*');
}
