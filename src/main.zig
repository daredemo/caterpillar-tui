const std = @import("std");

const CStuff = @import("tui").CStuff;

const Term = @import("tui").Term;

const Border = @import("tui").Border.Border;
const BorderStyle = @import("tui").Border.BorderStyle;
const Panel = @import("tui").Panel.Panel;
const Layout = @import("tui").Panel.Layout;
const RenderText = @import("tui").Panel.RenderText;
const RenderArray = @import("tui").Panel.RenderTextArray;
const Location = @import("tui").Location.Location;
const Face = @import("tui").Location.Face;
const FaceE = @import("tui").Location.FaceE;

const TextLine = @import("tui").TextLine.TextLine;
const RGB = @import("tui").Color.RGB;
const ColorStyle = @import("tui").Color.ColorStyle;
const ColorF = @import("tui").Color.ColorF;
const ColorB = @import("tui").Color.ColorB;
const ColorModes = @import("tui").Color.ColorModes;
const ColorBU = @import("tui").Color.ColorBU;
const ColorFU = @import("tui").Color.ColorFU;
const TitlePosition = @import("tui").Panel.PositionTB;
const StrAU = @import("tui").StringStuff.Alignment;

const BuffWriter = @import(
    "tui",
).BuffWriter.SimpleBufferedWriter;

const rand = std.crypto.random;

const HEIGHT: i32 = 15;
const WIDTH: i32 = 30;

pub fn main() !void {
    var buf_writer = BuffWriter{};
    var score: *u32 = undefined;
    defer _ = std.io.getStdOut().writer().print("Your score: {}\n", .{score.*}) catch unreachable;
    defer _ = buf_writer.flush() catch unreachable;
    CStuff.handleSigwinch(0);
    CStuff.setSignal();
    _ = Term.saveTerminalState(&buf_writer);
    defer {
        _ = Term.restoreTerminalState(&buf_writer);
    }
    const old_terminal = CStuff.saveTerminalSettings();
    var new_terminal = CStuff.saveTerminalSettings();
    defer CStuff.restoreTerminalSettings(old_terminal);
    CStuff.disableEchoAndCanonicalMode(&new_terminal);
    Term.disableCursor(&buf_writer);
    defer Term.enableCursor(&buf_writer);
    defer Term.setColorB(
        &buf_writer,
        ColorB.initName(ColorBU.Reset),
    );
    defer Term.setColorStyle(
        &buf_writer,
        ColorStyle{
            .bg = null,
            .fg = null,
            .modes = ColorModes{ .Reset = true },
        },
    );
    Term.clearScreen(&buf_writer);
    _ = buf_writer.flush() catch unreachable;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    // PANEL: ROOT
    const panel_root = Panel.initRoot(
        "FULL",
        &CStuff.win_width,
        &CStuff.win_height,
        Layout.Horizontal,
        &allocator,
        &buf_writer,
    ).setBorder(null);
    defer _ = allocator.destroy(panel_root);
    defer _ = panel_root.deinit(&allocator);
    // PANELS
    const panel_main = Panel.init(
        "CATERPILLAR",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_main);
    defer _ = panel_main.deinit(&allocator);
    const panel_game = Panel.init(
        null,
        panel_main,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_game);
    defer _ = panel_game.deinit(&allocator);
    const panel_score = Panel.init(
        "© 2024 René",
        panel_main,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_score);
    defer _ = panel_score.deinit(&allocator);
    const panel_info = Panel.init(
        null,
        panel_main,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_info);
    defer _ = panel_info.deinit(&allocator);
    const border_0 = Border.init(&allocator).setBorderStyle(
        BorderStyle.LightRound,
    );
    const border_1 = Border.init(&allocator).setBorderStyle(
        BorderStyle.LightRound,
    );
    const border_2 = Border.init(&allocator).setBorderStyle(
        BorderStyle.Double,
    );
    defer _ = allocator.destroy(border_0);
    defer _ = allocator.destroy(border_1);
    defer _ = allocator.destroy(border_2);
    _ = border_0.setColor(
        ColorStyle.init(
            null,
            ColorF.initName(ColorFU.Blue),
            ColorModes{
                .Bold = true,
            },
        ),
    );
    _ = border_1.setColor(
        ColorStyle.init(
            null,
            ColorF.initName(ColorFU.Blue),
            ColorModes{
                .Italic = true,
            },
        ),
    );
    _ = border_2.setColor(
        ColorStyle.init(
            null,
            ColorF.initName(ColorFU.Blue),
            null,
        ),
    );
    _ = panel_main.setBorder(border_0.*).titleLocation(
        StrAU.Center,
        TitlePosition.Top,
    );
    _ = panel_game.setBorder(border_2.*).setMinHeight(HEIGHT + 2);
    _ = panel_score.setBorder(border_1.*).titleLocation(
        StrAU.Right,
        TitlePosition.Bottom,
    ).setMinHeight(3);
    // PANEL: VOID LEFT OF MAIN
    const panel_void_l = Panel.init(
        "VOID L",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_void_l);
    defer panel_void_l.deinit(&allocator);
    // PANEL: VOID RIGHT OF MAIN
    const panel_void_r = Panel.init(
        "VOID R",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_void_r);
    defer panel_void_r.deinit(&allocator);
    _ = panel_void_l.setBorder(null);
    _ = panel_void_r.setBorder(null);
    _ = panel_main.appendChild(
        panel_game,
        HEIGHT + 2,
        null,
    );
    _ = panel_main.appendChild(
        panel_score,
        3,
        null,
    );
    _ = panel_main.appendChild(
        panel_info,
        null,
        1.0,
    );
    _ = panel_root.appendChild(
        panel_void_l,
        null,
        1.0,
    );
    _ = panel_root.appendChild(
        panel_main,
        WIDTH * 2 + 4,
        null,
    );
    _ = panel_root.appendChild(
        panel_void_r,
        null,
        1.0,
    );
    // THE APP
    var the_app = TheApp.init(
        panel_root,
        &allocator,
        &buf_writer,
    );
    score = &the_app.score;
    defer _ = the_app.deinit() catch unreachable;
    var thread_heartbeat = try std.Thread.spawn(
        .{},
        doAppHeartBeatThread,
        .{
            &the_app,
        },
    );
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(
        .{},
        doAppInputThread,
        .{
            &the_app,
        },
    );
    defer thread_inputs.join();
    _ = buf_writer.flush() catch unreachable;
}

const TheApp = struct {
    app_mutex: std.Thread.Mutex = .{},
    app_running: bool = true,
    app_heart: bool = true,
    app_width: i32 = undefined,
    app_height: i32 = undefined,
    app_allocator: *std.mem.Allocator = undefined,
    jaw: Face = undefined,
    jaw_new: Face = undefined,
    food: Location = undefined,
    score: u32 = undefined,
    larva: std.ArrayList(Location) = undefined,
    writer: *BuffWriter = undefined,
    panel_root: *Panel = undefined,
    // reader: ChRead.CharReader = undefined,
    // panel_void_l: *Panel = undefined,
    // panel_void_r: *Panel = undefined,
    // panel_main: *Panel = undefined,

    pub fn init(
        panel_root: *Panel,
        the_allocator: *std.mem.Allocator,
        writer: *BuffWriter,
    ) TheApp {
        var app = TheApp{
            .writer = writer,
            .app_running = true,
            .app_heart = true,
            .app_allocator = the_allocator,
            .panel_root = panel_root,
            .jaw = Face{},
            .jaw_new = Face{},
            .larva = std.ArrayList(
                Location,
            ).init(
                the_allocator.*,
            ),
        };
        app.app_width = CStuff.win_width;
        app.app_height = CStuff.win_height;
        return app;
    }

    pub fn deinit(self: *TheApp) !void {
        //     // _ = self;
        //     // _ = try self.app_allocator.destroy(panel);
        //     _ = self.app_allocator.destroy(self.panel_void_r);
        //     _ = self.app_allocator.destroy(self.panel_main);
        //     _ = self.app_allocator.destroy(self.panel_void_l);
        _ = self.app_allocator.destroy(&self.larva);
    }

    pub fn getInputs(self: *TheApp) !void {
        var has_esc = false;
        var has_special = false;
        var poller = std.io.poll(
            self.app_allocator.*,
            enum { stdin },
            .{
                .stdin = std.io.getStdIn(),
            },
        );
        defer poller.deinit();
        const timeout = std.time.ns_per_s / 1000;
        var buf: [1024]u8 = [1]u8{0} ** 1024;

        while (true) {
            {
                self.app_mutex.lock();
                defer self.app_mutex.unlock();
                if (!(self.app_running)) break;
            }
            const ready = poller.pollTimeout(
                timeout,
            ) catch unreachable;
            if (ready) {
                const n = poller.fifo(
                    .stdin,
                ).read(
                    &buf,
                );
                for (0..n) |index| {
                    const c = buf[index];
                    switch (c) {
                        'p' => { // TODO: PAUSE
                            has_esc = false;
                            has_special = false;
                        },
                        'q', 'Q' => { // QUIT
                            has_esc = false;
                            has_special = false;
                            _ = Term.eraseCES(self.writer);
                            self.app_mutex.lock();
                            defer self.app_mutex.unlock();
                            self.app_running = false;
                            break;
                        },
                        '[' => {
                            if (has_esc) has_special = true;
                        },
                        'A' => { // ARROW UP
                            if (has_special) {
                                self.jaw_new.face = FaceE.Up;
                            } else {
                                has_esc = false;
                            }
                        },
                        'B' => { // ARROW DOWN
                            if (has_special) {
                                self.jaw_new.face = FaceE.Down;
                            } else {
                                has_esc = false;
                            }
                        },
                        'C' => { // ARROW RIGHT
                            if (has_special) {
                                self.jaw_new.face = FaceE.Right;
                            } else {
                                has_esc = false;
                            }
                        },
                        'D' => { // ARROW LEFT
                            if (has_special) {
                                self.jaw_new.face = FaceE.Left;
                            } else {
                                has_esc = false;
                            }
                        },
                        27 => {
                            has_esc = true;
                            has_special = false;
                        },
                        else => {
                            has_esc = false;
                            has_special = false;
                        },
                    }
                }
            }
        }
    }

    pub fn getHeartBeat(self: *TheApp) !void {
        var counter: u8 = 0;
        var buf: [6]u8 = [1]u8{0} ** 6;
        _ = self.larva.append(Location{
            .x = 15,
            .y = 8,
        }) catch unreachable;
        self.food = self.randomFood();
        var tl_food = TextLine.init(
            self.writer,
            "  ",
        );
        var tl_head = TextLine.init(
            self.writer,
            "  ",
        );
        var tl_body = TextLine.init(
            self.writer,
            "  ",
        );
        var tl_score = TextLine.init(
            self.writer,
            "0",
        );
        var tl_info = TextLine.init(
            self.writer,
            "right: ⇦, left: ⇨, up: ⇧, down: ⇩, quit: q",
        );
        const color_food_b = RGB.init(
            255,
            191,
            0,
        );
        const color_head_b = RGB.init(
            211,
            33,
            45,
        );
        const color_body_b = RGB.init(
            0,
            201,
            87,
        );
        var larva_head = self.larva.items[0];
        const larva_rel = locToRel(larva_head);
        var food_rel = locToRel(Location{
            .x = self.food.x,
            .y = self.food.y,
        });
        _ = tl_score.relativeXY(2, 1);
        _ = tl_info.relativeXY(1, 1);
        _ = tl_food.bg(
            ColorB.initRGB(color_food_b),
        ).relativeXY(
            food_rel.x,
            food_rel.y,
        );
        _ = tl_head.bg(
            ColorB.initRGB(color_head_b),
        ).relativeXY(
            larva_rel.x,
            larva_rel.y,
        );
        _ = tl_body.bg(ColorB.initRGB(color_body_b));
        const panel_void_l = self.panel_root.child_head.?;
        const panel_main = panel_void_l.sibling_next.?;
        const panel_game = panel_main.child_head.?;
        const panel_score = panel_game.sibling_next.?;
        const panel_info = panel_score.sibling_next.?;
        var rt_food = RenderText{
            .parent = panel_game,
            .text = &tl_food,
        };
        var ra_body = RenderArray{
            .delta_x = 1,
            .delta_y = 1,
            .multi_x = 2,
            .coordinates = &self.larva,
            .text = &tl_body,
            .text_first = &tl_head,
            .parent = panel_game,
        };
        var rt_score = RenderText{
            .parent = panel_score,
            .text = &tl_score,
        };
        var rt_info = RenderText{
            .parent = panel_info,
            .text = &tl_info,
        };
        _ = panel_score.appendText(&rt_score);
        _ = panel_game.appendText(&rt_food);
        _ = panel_game.appendArray(&ra_body);
        _ = panel_info.appendText(&rt_info);
        _ = self.panel_root.draw();
        _ = self.writer.flush() catch unreachable;
        while (true) {
            {
                self.app_mutex.lock();
                defer self.app_mutex.unlock();
                if (!self.app_running) break;
            }
            _ = self.panel_root.update();
            _ = std.time.sleep(std.time.ns_per_s / 55);
            defer counter = (counter + 1) % 10;
            if (counter == 0) {
                self.app_heart = !self.app_heart;
                self.app_mutex.lock();
                defer self.app_mutex.unlock();
                if (self.jaw_new.face != self.jaw.opposite()) {
                    self.jaw.face = self.jaw_new.face;
                }
                larva_head = self.larva.items[0];
                const larva_move = larva_head.moveTo(self.jaw.face);
                if (larva_move.inBounds(WIDTH, HEIGHT)) {
                    for (self.larva.items, 1..) |item, index| {
                        if (item.equal(larva_move)) {
                            if (index != self.larva.items.len) {
                                self.app_running = false;
                                break;
                            }
                        }
                    }
                    self.larva.insert(
                        0,
                        larva_move,
                    ) catch unreachable;
                    if (larva_move.equal(self.food)) {
                        self.score += 1;
                        const str_score = std.fmt.bufPrint(
                            &buf,
                            "{d}",
                            .{self.score},
                        ) catch unreachable;
                        _ = tl_score.textLine(str_score);
                        self.food = self.randomFood();
                        food_rel = locToRel(self.food);
                        _ = tl_food.relativeXY(
                            food_rel.x,
                            food_rel.y,
                        );
                    } else {
                        _ = self.larva.pop();
                    }
                } else {
                    self.app_running = false;
                }
                // TODO:Should I have a heart?
                // if (self.app_heart) {
                //     // _ = tl_heart.textLine("♥");
                // } else {
                //     // _ = tl_heart.textLine(" ");
                // }
                _ = self.writer.flush() catch unreachable;
            }
            if (counter == 0) {
                self.app_width = CStuff.win_width;
                self.app_height = CStuff.win_height;
                _ = self.panel_root.draw();
            } else if ( //
            (self.app_width != CStuff.win_width) or //
                (self.app_height != CStuff.win_height))
            {
                self.app_width = CStuff.win_width;
                self.app_height = CStuff.win_height;
                _ = self.panel_root.draw();
            }
            _ = self.writer.flush() catch unreachable;
        }
    }

    pub fn randomFood(self: *TheApp) Location {
        var f = Location{};
        while (true) {
            const x = rand.uintLessThan(u8, WIDTH);
            const y = rand.uintLessThan(u8, HEIGHT);
            f = Location{
                .x = @as(i32, x),
                .y = @as(i32, y),
            };
            var is_done = true;
            for (self.larva.items) |item| {
                if (item.equal(f)) {
                    is_done = false;
                    break;
                }
            }
            if (is_done == true) {
                break;
            }
        }
        return f;
    }
};

/// Convert location to relative location in coordinate
/// system as defined in this game/app
pub fn locToRel(loc: Location) Location {
    return Location{
        .x = 1 + 2 * loc.x,
        .y = 1 + loc.y,
    };
}

/// Thread to get user input
pub fn doAppInputThread(arg: *TheApp) !void {
    try arg.getInputs();
}

/// Thread to update game state, rendering, etc
pub fn doAppHeartBeatThread(arg: *TheApp) !void {
    try arg.getHeartBeat();
}
