const std = @import("std");

const rlzb = @import("rlzb");
const rl = rlzb.raylib;
const rg = rlzb.raygui;

pub fn main() !void {
    rl.InitWindow(400, 200, "raygui - controls test suite");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var showMessageBox = false;

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        const style = rg.GuiGetStyle(
            rg.GuiControl.DEFAULT.toCInt(),
            rg.GuiDefaultProperty.BACKGROUND_COLOR.toCInt(),
        );
        rl.ClearBackground(rl.GetColor(@bitCast(style)));

        if (rg.GuiButton(rl.Rectangle.init(24, 24, 120, 30), "#191#Show Message") > 0)
            showMessageBox = true;

        if (showMessageBox) {
            const bounds = rl.Rectangle.init(85, 70, 250, 100);
            const result = rg.GuiMessageBox(bounds, "#191#Message Box", "Hi! This is a message!", "Nice;Cool");
            if (result >= 0) showMessageBox = false;
        }

        rl.EndDrawing();
    }

    return;
}
