const rl = @import("raylib");
const mz = @import("maze.zig");
const mazeConfig = @import("maze_config.zig");

const mc: mazeConfig.mazeConfig = .init();

pub fn main() void {
    var maze: [mc.rows][mc.cols]mz.pathBlock = undefined;
    for (&maze, 0..) |*row, i| {
        for (row, 0..) |*pathBlock, j| {
            const x: i32 = mc.startX + @as(i32, @intCast(i)) * mc.dx;
            const y: i32 = mc.startY + @as(i32, @intCast(j)) * mc.dy;

            pathBlock.* = mz.pathBlock.init(x, y, mc.dx, mc.dy, .ray_white);
        }
    }

    const curr: [2]i32 = .{ rl.getRandomValue(0, mc.rows - 1), rl.getRandomValue(0, mc.cols - 1) };
    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].color = .blue;
    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].visited = true;

    var dfs: mz.randDfs = .init(curr);
    var flag: bool = false;

    rl.setTargetFPS(mc.fps);
    rl.initWindow(mc.screenWidth, mc.screenHeigth, "Maze Generator");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        if (!flag) {
            if (rl.isKeyPressed(.space)) {
                flag = true;
            }

            continue;
        }

        dfs.next(&maze);
        for (&maze) |*row| {
            for (row) |*pathBlock| {
                pathBlock.draw();
            }
        }
    }
}
