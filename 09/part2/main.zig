const std = @import("std");

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const content = try std.fs.cwd().readFileAlloc("input", gpa, .unlimited);
    defer gpa.free(content);

    const xP = try gpa.alloc(u32, 512);
    const yP = try gpa.alloc(u32, 512);
    const minXForY = try gpa.alloc(u32, 512*512*512);
    const maxXForY = try gpa.alloc(u32, 512*512*512);

    @memset(xP, 0);
    @memset(yP, 0);
    @memset(minXForY, std.math.maxInt(u32));
    @memset(maxXForY, 0);

    defer gpa.free(xP);
    defer gpa.free(yP);
    defer gpa.free(minXForY);
    defer gpa.free(maxXForY);

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

    for (0..pointCount) |i| {
        for (i+1..pointCount) |j| {
            if (yP[i] == yP[j]) {
                minXForY[yP[i]] = @min(xP[i], xP[j]);
                maxXForY[yP[i]] = @max(xP[i], xP[j]);
            }
        }
    }

    for (0..pointCount) |i| {
        for (i+1..pointCount) |j| {
            if (xP[i] == xP[j]) {
                for (@min(yP[i], yP[j])..@max(yP[i], yP[j])) |y| {
                    minXForY[y] = @min(minXForY[y], xP[i], xP[j]);
                    maxXForY[y] = @max(maxXForY[y], xP[i], xP[j]);
                }
            }
        }
    }

    var largestArea: u64 = 0;
    for (0..pointCount) |i| {
        for (i+1..pointCount) |j| {
            const xi: i64 = xP[i];
            const xj: i64 = xP[j];
            const yi: i64 = yP[i];
            const yj: i64 = yP[j];

            const minX: u32 = @intCast(@min(xi, xj));
            const maxX: u32 = @intCast(@max(xi, xj));
            const minY: usize = @intCast(@min(yi, yj));
            const maxY: usize = @intCast(@max(yi, yj));
            var isValid: bool = true;
            for (minY..maxY) |y| {
                if (minX < minXForY[y] or maxX > maxXForY[y]) isValid = false;
            }
            if (!isValid) continue;

            const distX: u64 = @intCast(@abs(xi - xj) + 1);
            const distY: u64 = @intCast(@abs(yi - yj) + 1);

            const area: u64 = distX * distY;

            if (area > largestArea) {
                largestArea = area;
            }
        }
    }
    std.debug.print("Result: {}\n", .{largestArea});
}
