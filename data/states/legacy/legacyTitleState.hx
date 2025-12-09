import flixel.addons.display.FlxBackdrop;
import funkin.backend.MusicBeatState;

var logo:FunkinSprite;
var pressTxt:FunkinSprite;

function create() {
	MusicBeatState.skipTransIn = true;
    setTransition("fadeLegacy");

	FlxG.mouse.visible = true;

    window.title = "VS IMPOSTOR: V4";
    setWindowIcon("app/legacy64");

	setDiscordLargeImage("legacy", "VS IMPOSTOR v4...?");
	changeDiscordStatus("In the Menus...?", "Title Screen");

	var stars1:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsBG"));
	stars1.antialiasing = !Options.lowMemoryMode;
    add(stars1);

	var stars2:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsFG"));
	stars2.antialiasing = !Options.lowMemoryMode;
    add(stars2);

	logo = new FunkinSprite(0, -35);
    logo.frames = Paths.getFrames("menus/legacy/title/logoBumpin");
	logo.addAnim("bop", "logo bumpin", 24, true);
	logo.playAnim("bop");
	logo.antialiasing = !Options.lowMemoryMode;
	logo.screenCenter(FlxAxes.X);
	logo.shader = new CustomShader("grayscale");
	logo.shader._amount = 1.0;
	add(logo);

	pressTxt = new FunkinSprite(300, FlxG.height * 0.855);
	pressTxt.frames = Paths.getFrames("menus/legacy/title/startText");
	pressTxt.addAnim("idle", "EnterIdle");
	pressTxt.addAnim("press", "EnterStart");
	pressTxt.playAnim("idle");
	pressTxt.antialiasing = !Options.lowMemoryMode;
	pressTxt.y -= 88;
	add(pressTxt);

    FlxG.camera.flash(FlxColor.WHITE, 4);
}

var transitioning:Bool = false;
function update(elapsed:Float) {
	var pressed:Bool = controls.ACCEPT || pointerJustPressed();

    if (!transitioning && pressed) {
		transitioning = true;
        playMenuSound("confirm");
		FlxG.camera.flash(FlxColor.WHITE, 1);

		pressTxt.playAnim("press");
		pressTxt.offset.set(278, 2);

        new FlxTimer().start(1, _ -> {
            FlxG.switchState(new ModState("legacy/legacyMenuState"));
        });
    }
}

function destroy() {
    logo.destroy();
    pressTxt.destroy();
}