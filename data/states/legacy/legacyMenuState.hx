import flixel.addons.display.FlxBackdrop;
import funkin.backend.MusicBeatGroup;
import funkin.backend.MusicBeatState;

var stars1:FlxBackdrop;
var stars2:FlxBackdrop;
var logo:FunkinSprite;

var menuItems:FlxGroup;
var otherItems:FlxGroup;
var mainStuff:Array<String> = ["legacy.storyMode", "generic.freeplay", "legacy.gallery", "generic.credits"];
var otherStuff:Array<String> = ["Options", "Shop", "Innersloth"];
var scaryGlow:FlxSprite;

var errorVignette:FlxSprite;

function create() {
    if (FlxG.sound.music == null)
        CoolUtil.playMusic(Paths.music("ominousMenu"), true);

	changeDiscordStatus("In the Menus...?",  "Main Menu");

	stars1 = new FlxBackdrop(Paths.image("menus/legacy/starsBG"));
	stars1.antialiasing = !Options.lowMemoryMode;
	stars1.velocity.x = -10;
	add(stars1);

	stars2 = new FlxBackdrop(Paths.image("menus/legacy/starsFG"));
	stars2.antialiasing = !Options.lowMemoryMode;
	stars2.velocity.x = -20;
	add(stars2);

	var vignette:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/legacy/mainmenu/vignette"));
	vignette.antialiasing = !Options.lowMemoryMode;
	add(vignette);

	logo = new FunkinSprite();
	logo.frames = Paths.getFrames("menus/legacy/title/logoBumpin");
	logo.addAnim("bop", "logo bumpin", 24, false);
	logo.playAnim("bop");
	logo.antialiasing = !Options.lowMemoryMode;
    logo.scale.set(0.65, 0.65);
	logo.screenCenter();
	logo.shader = new CustomShader("grayscale");
	logo.shader._amount = 1.0;
	logo.y -= 160;
	add(logo);

	scaryGlow = new FlxSprite(370, 448).loadGraphic(Paths.image("menus/legacy/mainmenu/buttonglow"));
	scaryGlow.scale.set(0.5, 0.5);
	scaryGlow.updateHitbox();
	scaryGlow.antialiasing = !Options.lowMemoryMode;
	add(scaryGlow);

	menuItems = new FlxGroup();
	add(menuItems);

	for (i in 0...mainStuff.length) {
        var xPos:Float = i % 2 == 0 ? 400 : 633;
		var button:MenuButton = new MenuButton(i, mainStuff[i], (i < 2 ? "main" : "mini"), xPos, 0);
		button.antialiasing = !Options.lowMemoryMode;
		menuItems.add(button);

        switch(i) {
            case 0, 1: button.y = 475;
            case 2, 3: button.y = 580;
        }
    }

	otherItems = new FlxGroup();
    add(otherItems);

	for (i in 0...otherStuff.length) {
		var button:FunkinSprite = new FunkinSprite(0, 640).loadSprite(Paths.image("menus/legacy/mainmenu/extraButtons"));
		button.addAnim("idle", otherStuff[i] + " Button", 0, false);
		button.addAnim("hover", otherStuff[i] + " Select", 0, false);
		button.playAnim("idle");
		button.antialiasing = !Options.lowMemoryMode;
		button.scale.set(0.5, 0.5);
        button.updateHitbox();
		button.ID = mainStuff.length + i;
		otherItems.add(button);

        switch(i) {
            case 0: button.x = 455;
            case 1: button.x = 590;
            case 2: button.x = 725;
        }
    }

	var fakeVersion:FunkinText = new FunkinText(12, FlxG.height - 44, 0, "VS Impostor v4.1.0?", 16, false);
	fakeVersion.antialiasing = !Options.lowMemoryMode;
	add(fakeVersion);

	var funkinVersion:FunkinText = new FunkinText(12, FlxG.height - 24, 0, "Friday Night Funkin' v0.2.7", 16, false);
	funkinVersion.antialiasing = !Options.lowMemoryMode;
	add(funkinVersion);

	errorVignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
	errorVignette.color = FlxColor.RED;
    errorVignette.alpha = 0;
	add(errorVignette);
}

var curSelect:Int = -1;
var selectSmth:Bool = false;
var pressed:Bool = false;
var doGlow:Bool = true;
var _glowTimer:Float = 0;
function update(elapsed:Float) {
	_glowTimer += elapsed;
	if (doGlow) scaryGlow.alpha = Math.abs(FlxMath.fastSin(_glowTimer));

	if (pressed) return;

	curSelect = -1;
	selectSmth = false;

	menuItems.forEach(function(item) {
        if (pointerOverlaps(item)) {
			selectSmth = true;
            item.hover();
			curSelect = item.index;
        } else {
			item.idle();
        }

		if (selectSmth && pointerJustPressed()) {
			pressed = true;
			checkSelection(curSelect);
        }
    });

	otherItems.forEach(function(item) {
		if (pointerOverlaps(item)) {
			selectSmth = true;
			item.color = FlxColor.RED;
			curSelect = item.ID;
		} else {
			item.color = FlxColor.WHITE;
		}

		if (selectSmth && pointerJustPressed()) {
			checkSelection(curSelect);
		}
    });
    if (controls.BACK)
		FlxG.switchState(new ModState("legacy/legacyTitleState"));
}

function checkSelection(selection:Int) {
    function errorThingLol() {
		playMenuSound("lock");

		FlxG.camera.stopShake();
		FlxG.camera.shake(0.004, 0.15);

		FlxTween.cancelTweensOf(errorVignette);
		errorVignette.alpha = 0.6;
		FlxTween.tween(errorVignette, {alpha: 0}, 0.25);

		pressed = false;
    }

    switch(selection) {
        case 0: selectThing(new ModState("legacy/legacyStoryState"));
        case 1: selectThing(new ModState("legacy/legacyFreeplayState"));
		case 2: errorThingLol();
        case 3: errorThingLol();
        case 4:
			playMenuSound("confirm");
            openSubState(new ModSubState("options/impostorOptionsSubState", [true]));
			persistentUpdate = false;
            persistentDraw = true;
		case 5: errorThingLol();
		case 6:
			playMenuSound("confirm");
			CoolUtil.openURL("https://www.innersloth.com/");
    }
}

function selectThing(newState:MusicBeatState) {
	playMenuSound("confirm");
	pressed = true;
	doGlow = false;

	FlxTween.tween(stars2, {y: stars2.y + 500}, 0.7, {ease: FlxEase.quadInOut});
	FlxTween.tween(stars1, {y: stars1.y + 500}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.2});
	FlxTween.tween(scaryGlow, {alpha: 0}, 0.7, {ease: FlxEase.quadOut});
	menuItems.forEach(function(item) {
        FlxTween.tween(item, {alpha: 0}, 0.7, {ease: FlxEase.quadOut});
    });
	otherItems.forEach(function(item) {
		FlxTween.tween(item, {alpha: 0}, 0.7, {ease: FlxEase.quadOut});
	});
    FlxG.camera.fade(FlxColor.BLACK, 0.7);

    new FlxTimer().start(1, _ -> FlxG.switchState(newState));
}

function destroy() {
	stars1.destroy();
	stars2.destroy();
	logo.destroy();

	menuItems.destroy();
	scaryGlow.destroy();

	errorVignette.destroy();
}

class MenuButton extends MusicBeatGroup {
    public var index:Int;

    public var button:FunkinSprite;

    public var label:FunkinText;

	public function new(index:Int, labelID:String, style:String, ?x:Float, ?y:Float) {
        super(x, y);

        this.index = index;

        var width:Float = 441;
		var height:Float = style == "mini" ? 114 : 182;

		button = new FunkinSprite().loadGraphic(Paths.image("menus/legacy/mainmenu/" + style + "Button"), true, width, height);
		button.animation.add("idle", [0], 0, false);
		button.animation.add("hover", [1], 0, false);
		button.playAnim("idle");
		button.scale.set(0.5, 0.5);
		button.updateHitbox();

		var size:Float = style == "mini" ? 40 : 52;
		label = new FunkinText(0, 0, 0, translate(labelID), size, false);
		label.font = Paths.font("amatic.ttf");
		objectCenter(label, button);

		add(button);
        add(label);
    }

    public function hover() {
        //button.playAnim("hover");
		button.color = FlxColor.RED;
    }

	public function idle() {
		//button.playAnim("idle");
		button.color = FlxColor.WHITE;
	}

    override public function destroy() {
        super.destroy();
		button.destroy();
        label.destroy();
    }
}