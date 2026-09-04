const rl = @import("raylib");
const mazeConfig = @import("maze_config.zig");

const mc = mazeConfig.mazeConfig.init();

inline fn castToFloat32(val: i32) f32 {
    return @as(f32, @floatFromInt(val));
}

inline fn castToInt32(val: f32) i32 {
    return @as(i32, @intFromFloat(val));
}

fn randBool() bool {
    if (rl.getRandomValue(0, 100) < 50) {
        return true;
    }

    return false;
}

pub const pathBlock = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    path: [4]bool,
    default_color: rl.Color,
    color: rl.Color,
    thickness: f32,
    visited: bool,

    pub fn init(x: i32, y: i32, width: i32, height: i32, color: rl.Color) @This() {
        return .{
            .x = castToFloat32(x),
            .y = castToFloat32(y),
            .width = castToFloat32(width),
            .height = castToFloat32(height),
            .path = .{ false, false, false, false },
            .default_color = color,
            .color = color,
            .thickness = 2,
            .visited = false,
        };
    }

    pub fn reset(self: *@This()) void {
        self.color = self.default_color;
        self.path = .{ false, false, false, false };
        self.visited = false;
    }

    pub fn randPath(self: *@This()) void {
        self.path = .{ randBool(), randBool(), randBool(), randBool() };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            castToInt32(self.x),
            castToInt32(self.y),
            castToInt32(self.width),
            castToInt32(self.height),
            self.color,
        );

        // Top wall (Index 0: Up / {-1, 0})
        if (!self.path[0]) rl.drawLineEx(.{
            .x = self.x,
            .y = self.y,
        }, .{
            .x = self.x + self.width,
            .y = self.y,
        }, self.thickness, .dark_gray);

        // Right wall (Index 1: Right / {0, 1})
        if (!self.path[1]) rl.drawLineEx(.{
            .x = self.x + self.width,
            .y = self.y,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height,
        }, self.thickness, .dark_gray);

        // Bottom wall (Index 2: Down / {1, 0})
        if (!self.path[2]) rl.drawLineEx(.{
            .x = self.x,
            .y = self.y + self.height,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height,
        }, self.thickness, .dark_gray);

        // Left wall (Index 3: Left / {0, -1})
        if (!self.path[3]) rl.drawLineEx(.{
            .x = self.x,
            .y = self.y,
        }, .{
            .x = self.x,
            .y = self.y + self.height,
        }, self.thickness, .dark_gray);
    }
};

pub const randDfs = struct {
    curr_dist: i32,
    curr: [2]i32,
    dirs: [4][2]i32,

    stack: [mc.rows * mc.cols + 1][2]i32,
    top: usize,

    max_dist: i32,
    max_pos: [2]i32,

    done: bool,

    pub fn init(curr: [2]i32) @This() {
        var stack: [mc.rows * mc.cols + 1][2]i32 = undefined;
        for (&stack) |*row| {
            row.* = .{ -1, -1 };
        }

        var resp: randDfs = .{
            .curr_dist = 0,
            .curr = curr,
            .dirs = .{ .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 } },

            .stack = stack,
            .top = 0,

            .max_dist = 0,
            .max_pos = curr,
            .done = false,
        };

        resp.push(curr);
        return resp;
    }

    fn validDirs(x: i32, y: i32, n: i32, m: i32, dirs: [4][2]i32, maze: *[mc.rows][mc.cols]pathBlock, ans: [:-1]i32) [:-1]i32 {
        var j: usize = 0;
        for (dirs, 0..) |dir, i| {
            const nextX: i32 = x + dir[0];
            const nextY: i32 = y + dir[1];

            if (nextX < 0 or nextX >= n) {
                continue;
            } else if (nextY < 0 or nextY >= m) {
                continue;
            } else if (maze[@as(usize, @intCast(nextX))][@as(usize, @intCast(nextY))].visited) {
                continue;
            }

            ans[j] = @as(i32, @intCast(i));
            j += 1;
        }

        return ans;
    }

    pub fn push(self: *@This(), pos: [2]i32) void {
        self.stack[self.top] = pos;
        self.top += 1;
    }

    pub fn pop(self: *@This()) [2]i32 {
        if (self.top > 0) {
            self.top = self.top - 1;
        } else {
            self.done = true;
        }

        const ans: [2]i32 = self.stack[self.top];
        return ans;
    }

    pub fn next(self: *@This(), maze: *[mc.rows][mc.cols]pathBlock) void {
        var dirs: [4:-1]i32 = [_:-1]i32{ -1, -1, -1, -1 };
        var possibleDirs: [:-1]i32 = dirs[0..];
        possibleDirs = randDfs.validDirs(self.curr[0], self.curr[1], maze.len, maze[0].len, self.dirs, maze, possibleDirs);

        var possibleDirs_len: usize = 0;
        for (possibleDirs) |val| {
            if (val == -1) {
                break;
            }

            possibleDirs_len += 1;
        }

        if (possibleDirs_len > 0) {
            const randPos: i32 = possibleDirs[@as(usize, @intCast(rl.getRandomValue(1, @as(i32, @intCast(possibleDirs_len))) - 1))];
            const dir: [2]i32 = self.dirs[@as(usize, @intCast(randPos))];

            var pb1 = &maze[@as(usize, @intCast(self.curr[0]))][@as(usize, @intCast(self.curr[1]))];

            var j: usize = 0;
            for (self.dirs, 0..) |dir2, i| {
                if (dir[0] == dir2[0] and dir[1] == dir2[1]) {
                    j = i;
                }
            }

            pb1.path[j] = true;
            pb1.color = .ray_white;

            self.curr_dist += 1;
            self.curr[0] += dir[0];
            self.curr[1] += dir[1];
            self.push(self.curr);

            var pb2 = &maze[@as(usize, @intCast(self.curr[0]))][@as(usize, @intCast(self.curr[1]))];

            const revDir: [2]i32 = .{ dir[0] * -1, dir[1] * -1 };
            j = 0;
            for (self.dirs, 0..) |dir2, i| {
                if (revDir[0] == dir2[0] and revDir[1] == dir2[1]) {
                    j = i;
                }
            }

            pb2.path[j] = true;
            pb2.visited = true;

            if (self.curr_dist >= self.max_dist) {
                var pb3 = &maze[@as(usize, @intCast(self.max_pos[0]))][@as(usize, @intCast(self.max_pos[1]))];
                pb3.color = .ray_white;

                self.max_dist = self.curr_dist;
                self.max_pos = self.curr;
            }

            var pb4 = &maze[@as(usize, @intCast(self.max_pos[0]))][@as(usize, @intCast(self.max_pos[1]))];
            pb4.color = .green;
            pb2.color = .blue;
        } else {
            var pb1 = &maze[@as(usize, @intCast(self.curr[0]))][@as(usize, @intCast(self.curr[1]))];
            pb1.color = .ray_white;

            self.curr = self.pop();
            self.curr_dist -= 1;
            var pb2 = &maze[@as(usize, @intCast(self.curr[0]))][@as(usize, @intCast(self.curr[1]))];
            pb2.color = .blue;
        }
    }
};
