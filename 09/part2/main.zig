const std = @import("std");

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const content = try std.fs.cwd().readFileAlloc("test", gpa, .unlimited);
    defer gpa.free(content);

    const xP = try gpa.alloc(u32, 512);
    const yP = try gpa.alloc(u32, 512);
    defer gpa.free(xP);
    defer gpa.free(yP);

    var pointCount: usize = 0;

    var lineIter = std.mem.tokenizeScalar(u8, content, '\n');
    while (lineIter.next()) |line| {
        var newX: u32 = 0;
        var newY: u32 = 0;

        var i: usize = 0;
        while (line[i] != ',') {
            newX = newX * 10 + line[i] - '0';
            i += 1;
        }
        i += 1;

        while (i < line.len and line[i] != '\n') {
            newY = newY * 10 + line[i] - '0';
            i += 1;
        }

        xP[pointCount] = newX;
        yP[pointCount] = newY;
        pointCount += 1;
    }

    var maxX: u32 = 0;
    var maxY: u32 = 0;
    for (xP[0..pointCount]) |x| {
        if (x > maxX) maxX = x;
    }
    for (yP[0..pointCount]) |y| {
        if (y > maxY) maxY = y;
    }

    std.debug.print("Max X: {}\n", .{maxX});
    std.debug.print("Max Y: {}\n", .{maxY});

    var allowed = try gpa.alloc(bool, (maxX + 1) * (maxY + 1));
    defer gpa.free(allowed);
    @memset(allowed, false);

    for (0..pointCount) |i| {
        allowed[idx(xP[i], yP[i], maxX)] = true;
    }

    for (0..pointCount) |i| {
        for (i+1..pointCount) |j| {
            const xi: i64 = xP[i];
            const xj: i64 = xP[j];
            const yi: i64 = yP[i];
            const yj: i64 = yP[j];

            if (xi == xj) {
                const ya = @min(yi, yj);
                const yb = @max(yi, yj);
                for (ya..yb+1) |y| {
                    allowed[idx(xi, y, maxX)] = true;
                }
            } else {
                const xa = @min(xi, xj);
                const xb = @max(xi, xj);
                for (xa..xb+1) |x| {
                    allowed[idx(x, yi, maxX)] = true;
                }
            }
        }
    }


}

fn flood(x: usize, y: usize, maxX: usize) usize {

}

inline fn idx(x: usize, y: usize, maxX: usize) usize {
    return y * (maxX + 1) + x;
}
