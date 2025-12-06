const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var linesIter = std.mem.tokenizeScalar(u8, content, '\n');
    var lines = try std.heap.page_allocator.alloc([]const u8, 4096);
    defer std.heap.page_allocator.free(lines); 
    var linesCount: usize = 0;

    while (linesIter.next()) |line| {
        lines[linesCount] = line;
        linesCount += 1;
    }

    const bottomLine = lines[linesCount-1];
    const bodyLines = lines[0..linesCount-1];

    var total: u512 = 0;
    var column: isize = @intCast(bottomLine.len-1);

    var numbers = try std.heap.page_allocator.alloc(u512, 4096);
    @memset(numbers, 0);
    defer std.heap.page_allocator.free(numbers);
    var numbersCount: usize = 0;

    while (column >= 0) : (column -= 1) {
        var cVal: u512 = 0;
        for (bodyLines) |ln| {
            const idx: usize = @intCast(column);
            const c = if (idx < ln.len) ln[@intCast(idx)] else ' ';
            if (c == ' ') continue;
            cVal = cVal * 10 + (c - '0');
        }

        numbers[numbersCount] = cVal;
        numbersCount += 1;

        const op = bottomLine[@intCast(column)];
        if (op == ' ') continue;

        var result: u512 = if (op == '+') 0 else 1;
        for (0..numbersCount) |nc| {
            const vVal = numbers[nc];
            if (op == '+') result += vVal else result *= vVal;
        }

        total += result;
        numbersCount = 0;
        column -= 1;
    }

    std.debug.print("Total: {}\n", .{total});
}
