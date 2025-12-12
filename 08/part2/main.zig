const std = @import("std");
const vec3 = @Vector(3, u64);

const Edge = struct {
    idxA: usize,
    idxB: usize,
    dist: u64,
};

const DSU = struct {
    gpa: std.mem.Allocator,
    parent: []u64,
    _parentCount: usize,

    const Self = @This();

    pub fn init(gpa: std.mem.Allocator) Self {
        const parent = gpa.alloc(u64, 4096) catch unreachable;
        for (0..4096) |i| parent[i] = i;

        return Self {
            .gpa = gpa,
            .parent = parent,
            ._parentCount = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.gpa.free(self.parent);
    }

    pub fn find(self: *Self, i: u64) u64 {
        if (self.parent[i] != i) {
            self.parent[i] = self.find(self.parent[i]);
        }

        return self.parent[i];
    }

    pub fn unite(self: *Self, i: u64, j: u64) void {
        const ri = self.find(i);
        const rj = self.find(j);

        if (ri != rj) {
            self.parent[ri] = rj;
        }
    }
};

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const content = try std.fs.cwd().readFileAlloc("input", gpa, .unlimited);
    defer gpa.free(content);

    var points = try gpa.alloc(vec3, 1024);
    defer gpa.free(points);
    var pointsCount: usize = 0;

    var lineIter = std.mem.tokenizeScalar(u8, content, '\n');
    while (lineIter.next()) |line| : (pointsCount += 1) {
        if (pointsCount >= 1024) break;
        points[pointsCount] = strToVec3(line);
    }

    var allEdges = try gpa.alloc(Edge, (1024 * 1024) - 1);
    defer gpa.free(allEdges);
    var edgesCount: usize = 0;

    for (0..pointsCount) |i| {
        for (i+1..pointsCount) |j| {
            allEdges[edgesCount] = Edge {
                .idxA = i,
                .idxB = j,
                .dist = dsq(points[i], points[j]),
            };
            edgesCount += 1;
        }
    }

    std.mem.sort(Edge, allEdges, {}, struct {
        fn less(_: void, a: Edge, b: Edge) bool {
            return a.dist < b.dist;
        }
    }.less);

    var dsu: DSU = DSU.init(gpa);
    defer dsu.deinit();

    var unions: usize = 0;
    var lastEdge: Edge = undefined;

    for (allEdges[0..edgesCount]) |edge| {
        if (dsu.find(edge.idxA) != dsu.find(edge.idxB)) {
            dsu.unite(edge.idxA, edge.idxB);
            lastEdge = edge;
            unions += 1;
            if (unions == pointsCount - 1) break;
        }
    }

    const a = points[lastEdge.idxA][0];
    const b = points[lastEdge.idxB][0];
    const result = a * b;
    std.debug.print("Result: {}\n", .{result});
}

inline fn strToVec3(str: []const u8) vec3 {
    var it = std.mem.splitScalar(u8, str, ',');
    const x = std.fmt.parseInt(u64, it.next() orelse return undefined, 10) catch unreachable;
    const y = std.fmt.parseInt(u64, it.next() orelse return undefined, 10) catch unreachable;
    const z = std.fmt.parseInt(u64, it.next() orelse return undefined, 10) catch unreachable;
    return .{ x, y, z };
}

inline fn dsq(a: vec3, b: vec3) u64 {
    const dx: i64 = @as(i64, @intCast(a[0])) - @as(i64, @intCast(b[0]));
    const dy: i64 = @as(i64, @intCast(a[1])) - @as(i64, @intCast(b[1]));
    const dz: i64 = @as(i64, @intCast(a[2])) - @as(i64, @intCast(b[2]));

    return @intCast(dx*dx + dy*dy + dz*dz);
}
