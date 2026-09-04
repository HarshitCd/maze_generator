const rl = @import("raylib");
const mz = @import("maze.zig");
const mazeConfig = @import("maze_config.zig");

const mc: mazeConfig.mazeConfig = .init();

const state = enum {
    Home,
    Generate,
    Play,
};

pub fn main() void {
    var s: state = .Home;
    var maze: [mc.rows][mc.cols]mz.pathBlock = undefined;
    for (&maze, 0..) |*row, i| {
        for (row, 0..) |*pathBlock, j| {
            const x: i32 = mc.startX + @as(i32, @intCast(i)) * mc.dx;
            const y: i32 = mc.startY + @as(i32, @intCast(j)) * mc.dy;

            pathBlock.* = mz.pathBlock.init(x, y, mc.dx, mc.dy, .ray_white);
        }
    }

    var curr: [2]i32 = .{ rl.getRandomValue(0, mc.rows - 1), rl.getRandomValue(0, mc.cols - 1) };
    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].color = .blue;
    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].visited = true;

    var dfs: mz.randDfs = .init(curr);
    var play = mz.play.init();

    rl.setTargetFPS(mc.fps);
    rl.initWindow(mc.screenWidth, mc.screenHeigth, "Maze Generator");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        switch (s) {
            .Home => {
                if (rl.isKeyPressed(.space)) {
                    for (&maze) |*row| {
                        for (row) |*pathBlock| {
                            pathBlock.reset();
                        }
                    }

                    curr = .{ rl.getRandomValue(0, mc.rows - 1), rl.getRandomValue(0, mc.cols - 1) };
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].color = .blue;
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].visited = true;

                    dfs = mz.randDfs.init(curr);

                    s = .Generate;
                }

                var measure_text: i32 = rl.measureText(mc.appName, 50);
                const middle: i32 = 2;
                var posX: i32 = @divTrunc(rl.getScreenWidth(), middle) - @divTrunc(measure_text, middle);
                var posY: i32 = @divTrunc(rl.getScreenHeight(), middle) - @divTrunc(50, middle) - 50;

                rl.drawText(mc.appName, posX, posY, 50, .black);

                const actionText: [:0]const u8 = "[space] - to start generation, [esc] - to quit";
                measure_text = rl.measureText(actionText, 20);
                posX = @divTrunc(rl.getScreenWidth(), middle) - @divTrunc(measure_text, middle);
                posY = @divTrunc(rl.getScreenHeight(), middle) - @divTrunc(20, middle);

                rl.drawText(
                    actionText,
                    posX,
                    posY,
                    20,
                    .gray,
                );
            },
            .Generate => {
                const actionText1: [:0]const u8 = "[r] - new generation, [q] - go to home";

                const measure_text: i32 = rl.measureText(actionText1, 18);
                const middle: i32 = 2;
                const posX: i32 = @divTrunc(rl.getScreenWidth(), middle) - @divTrunc(measure_text, middle);
                const posY: i32 = rl.getScreenHeight() - 75 - @divTrunc(18, middle);

                rl.drawText(actionText1, posX, posY, 18, .gray);

                if (!dfs.done) {
                    dfs.next(&maze);
                } else {
                    s = .Play;
                    play.set(dfs.curr, dfs.max_pos);
                }

                for (&maze) |*row| {
                    for (row) |*pathBlock| {
                        pathBlock.draw();
                    }
                }

                if (rl.isKeyPressed(.r)) {
                    for (&maze) |*row| {
                        for (row) |*pathBlock| {
                            pathBlock.reset();
                        }
                    }

                    curr = .{ rl.getRandomValue(0, mc.rows - 1), rl.getRandomValue(0, mc.cols - 1) };
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].color = .blue;
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].visited = true;

                    dfs = mz.randDfs.init(curr);
                }

                if (rl.isKeyPressed(.q)) {
                    s = .Home;
                }
            },
            .Play => {
                const actionText1: [:0]const u8 = "[r] - new generation, [q] - go to home, [arrows] - to move";

                var measure_text: i32 = rl.measureText(actionText1, 18);
                const middle: i32 = 2;
                var posX: i32 = @divTrunc(rl.getScreenWidth(), middle) - @divTrunc(measure_text, middle);
                var posY: i32 = rl.getScreenHeight() - 75 - @divTrunc(18, middle);

                rl.drawText(actionText1, posX, posY, 18, .gray);
                for (&maze) |*row| {
                    for (row) |*pathBlock| {
                        pathBlock.draw();
                    }
                }

                if (rl.isKeyPressed(.r)) {
                    s = .Generate;
                    for (&maze) |*row| {
                        for (row) |*pathBlock| {
                            pathBlock.reset();
                        }
                    }

                    curr = .{ rl.getRandomValue(0, mc.rows - 1), rl.getRandomValue(0, mc.cols - 1) };
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].color = .blue;
                    maze[@as(usize, @intCast(curr[0]))][@as(usize, @intCast(curr[1]))].visited = true;

                    dfs = mz.randDfs.init(curr);
                }

                if (rl.isKeyPressed(.q)) {
                    s = .Home;
                }

                if (!play.done) {
                    if (rl.isKeyPressed(.up)) {
                        play.move(0, &maze);
                    }
                    if (rl.isKeyPressed(.right)) {
                        play.move(1, &maze);
                    }
                    if (rl.isKeyPressed(.down)) {
                        play.move(2, &maze);
                    }
                    if (rl.isKeyPressed(.left)) {
                        play.move(3, &maze);
                    }
                } else {
                    const doneText: [:0]const u8 = "Maze Solved!";

                    measure_text = rl.measureText(doneText, 50);
                    posX = @divTrunc(rl.getScreenWidth(), middle) - @divTrunc(measure_text, middle);
                    posY = 30;

                    rl.drawText(doneText, posX, posY, 50, .green);
                }
            },
        }
    }
}
