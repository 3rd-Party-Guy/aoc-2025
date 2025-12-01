const std = @import("std");

pub fn main() !void {
    const content: []u8 = try std.fs.cwd().readFileAlloc("input", std.heap.page_allocator, .unlimited);
    defer std.heap.page_allocator.free(content);

    var idx: u8 = 50;
    var hits: u16 = 0;

    var i: usize = 0;
    while (i < content.len) {
        const dir = content[i];
        i += 1;

        var amount: u16 = 0;
        while (i < content.len and content[i] >= '0' and content[i] <= '9') : (i += 1) {
            amount = amount * 10 + (content[i] - '0');
        }

        const delta: i32 = if (dir == 'R') @intCast(amount) else - @as(i32, @intCast(amount));

        idx = @intCast(@mod(@as(i32, idx) + delta, 100));

        if (idx == 0) hits += 1;

        while (i < content.len and content[i] == '\n') i += 1;
    }

    std.debug.print("Hits: {}\n", .{hits});
}
