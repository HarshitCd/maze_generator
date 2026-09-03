pub const mazeConfig = struct {
    fps: i32,

    screenWidth: i32,
    screenHeigth: i32,

    rows: i32,
    cols: i32,

    startX: i32,
    startY: i32,
    dx: i32,
    dy: i32,

    pub fn init() @This() {
        const sw: i32 = 800;
        const sh: i32 = 800;

        const rows = (sw - 200) / 150;
        const cols = (sh - 200) / 150;

        return .{
            .fps = 8,
            .screenWidth = sw,
            .screenHeigth = sh,

            .rows = rows,
            .cols = cols,

            .startX = 100,
            .startY = sh - 100,
            .dx = (sw - 200) / rows,
            .dy = (sh - 200) / cols,
        };
    }
};
