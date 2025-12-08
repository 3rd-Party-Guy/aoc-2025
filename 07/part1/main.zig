const std = @import("std");

pub fn main() !void {
    const content = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var linesIter = std.mem.tokenizeScalar(u8, content, '\n');
    const lineLength = linesIter.peek().?.len;

    var beamTracker = try std.heap.page_allocator.alloc(bool, lineLength);
    defer std.heap.page_allocator.free(beamTracker);

    const startLine = linesIter.next().?;
    var x: usize = 0;
    for (startLine) |c| {
        if (c == 'S') {
            beamTracker[x] = true;
            break;
        }
        x += 1;
    }

    var totalSplits: usize = 0;
    while (linesIter.next()) |line| {
        x = 0;
        for (line) |c| {
            if (c == '^' and beamTracker[x]) {
                beamTracker[x - 1] = true;
                beamTracker[x + 1] = true;
                beamTracker[x] = false;

                totalSplits += 1;
            }

            x += 1;
        }
    }

    std.debug.print("Total: {}\n", .{totalSplits});
}
