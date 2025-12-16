import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;
import funkin.backend.MusicBeatState;
import funkin.options.Options;

enum SelectingOption {
	YES;
	NO;
	NONE;
}

var curSelection:SelectingOption = SelectingOption.NONE;

var curWaningIndex:Int = 0;
var allWarnings:Array<Array<Dynamic>> = [
	{
		warning: translate("options.warnings.bloodAndGore-name"),
		text: createMultiLineText([
			translate("options.warnings.bloodAndGore-text1"),
			translate("options.warnings.bloodAndGore-text2")
		]),
		image: Paths.image("menus/warning/blood"),
		selectYes: function() {
			Options.naughtyness = false;
		},
		selectNo: null
	},
	{
		warning: translate("options.warnings.flashingLights-name"),
		text: createMultiLineText([
			translate("options.warnings.flashingLights-text1"),
			translate("options.warnings.flashingLights-text2")
		]),
		image: Paths.image("menus/warning/flash"),
		selectYes: function() {
			Options.flashingMenu = false;
		},
		selectNo: null
	}
];

var bg:FlxSprite;
var warnTape:FlxBackdrop;
var backGradient:FlxSprite;

var particlesEmitter:FlxTypedEmitter;
var line:FlxSprite;
var topTxt:FlxSprite;
var warnSprite:FlxSprite;
var warningCount:FunkinText;
var no:FunkinText;
var yes:FunkinText;
var scale:Float = 5;

var skippedCreate:Bool = false;
function create() {
	if (FlxG.save.data.seenImpostorStartupWarnings) {
		skippedCreate = true;
		MusicBeatState.skipTransOut = true;
		checkNextState();
        return;
    }

	MusicBeatState.skipTransIn = true;

	changeDiscordStatus("Warning Screen");

	add(bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

	warnTape = new FlxBackdrop(Paths.image("menus/warning/warningTape"), FlxAxes.X);
	warnTape.scale.set(scale, scale);
	warnTape.updateHitbox();
	warnTape.y = FlxG.height;
	warnTape.y -= warnTape.height + 2 * scale;
	warnTape.velocity.x = -32;

	line = new FlxSprite(0, FlxG.height * 0.45).makeGraphic(FlxG.width, 45 * scale, FlxColor.WHITE);
	line.y -= line.height;

	backGradient = FlxGradient.createGradientFlxSprite(FlxG.width, line.height * 4, [0xFF000000, 0xFF5B0000, 0xFF5B0000, 0xFF000000]);
	backGradient.y = line.y + line.height / 2;
	backGradient.y -= backGradient.height / 2;
	add(backGradient);

	var maxScale:Float = 20;
	var particleLaunchArea:Float = backGradient.height / 2;
	particlesEmitter = new FlxTypedEmitter(FlxG.width + maxScale * scale * 2, backGradient.y - line.height / 2);
	particlesEmitter.loadParticles(Paths.image("menus/warning/fade"), 100);
	particlesEmitter.launchAngle.set(180);
	particlesEmitter.angle.set(90);
	particlesEmitter.speed.set(4000);
	particlesEmitter.scale.set(2, maxScale / 4, 8, maxScale);
	particlesEmitter.height = backGradient.height;
	particlesEmitter.blend = getBlendMode("add");
	particlesEmitter.alpha.set(0.1, 0.5);
	particlesEmitter.start(false, 0.005);
	add(particlesEmitter);

	topTxt = new FunkinText(line.x, line.y, line.width, "", 42);
	topTxt.alignment = "center";
	topTxt.font = Paths.font("pixeloidsans.ttf");
	topTxt.color = FlxColor.RED;
	topTxt.borderColor = 0xFF500000;
	topTxt.borderSize = 5;
	topTxt.textField.__textFormat.leading = -10;
	topTxt.scale.y = line.height / topTxt.height;
	topTxt.updateHitbox();

	add(warnTape);
	add(line);
	add(topTxt);

	warnSprite = new FlxSprite();
	warnSprite.scale.set(6, 6);
	warnSprite.updateHitbox();
	warnSprite.kill();
	add(warnSprite);

	warningCount = new FunkinText(0, warnTape.y + warnTape.height / 2, FlxG.width, (curWaningIndex + 1) + "/" + allWarnings.length, 32, true);
	warningCount.alignment = "center";
	warningCount.font = Paths.font("pixeloidsans.ttf");
	warningCount.borderSize = 3;
	add(warningCount);

	no = new FunkinText(FlxG.width * 0.25, FlxG.width * 0.65, 240, translate("no").toUpperCase(), 80, true);
	no.alignment = "center";
	no.font = Paths.font("pixeloidsans.ttf");
    no.color = FlxColor.RED;
	no.borderColor = 0xFF260000;
	no.borderSize = 9;
	no.x -= no.width / 2;
	no.y -= no.height / 2;
	add(no);

	yes = new FunkinText(FlxG.width * 0.75, FlxG.width * 0.65, 240, translate("yes").toUpperCase(), 80, true);
	yes.alignment = "center";
	yes.font = Paths.font("pixeloidsans.ttf");
    yes.color = FlxColor.LIME;
	yes.borderColor = 0xFF002600;
	yes.borderSize = 9;
	yes.x -= yes.width / 2;
	yes.y -= yes.height / 2;
	add(yes);

    createNewWarning();
}

function createNewWarning() {
	playSound("sabotage");

	isHoveringSmth = false;
	curSelection = SelectingOption.NONE;

	warningCount.text = (curWaningIndex + 1) + "/" + allWarnings.length;

	topTxt.scale.set(1, 1);
	topTxt.updateHitbox();
	var warningStuff:Map<String, Dynamic> = allWarnings[curWaningIndex];
	topTxt.text = translate("options.warnings.warning").toUpperCase() + " - " + warningStuff.warning.toUpperCase() + '\n' + warningStuff.text;
	topTxt.scale.y = line.height / topTxt.height;
	topTxt.updateHitbox();

	warnSprite.revive();
	warnSprite.loadGraphic(warningStuff.image);
	warnSprite.updateHitbox();
	warnSprite.setPosition(FlxG.width / 2 - warnSprite.width / 2, warnTape.y - warnSprite.height);

	no.kill();
    yes.kill();

	new FlxTimer().start(1.25, _ -> {
		no.revive();
		yes.revive();
		FlxG.mouse.visible = true;
		allowSelection = true;
		updateSelection();
	});
}

var isHoveringSmth:Bool = false;
var allowSelection:Bool = false;

function update(elapsed:Float) {
	if (!allowSelection)
		return;

	if (globalUsingKeyboard) {
        FlxG.mouse.visible = false;

		if (controls.LEFT_P) {
			playMenuSound("scroll");
			curSelection = SelectingOption.NO;
			updateSelection();
		}
		if (controls.RIGHT_P) {
			playMenuSound("scroll");
			curSelection = SelectingOption.YES;
			updateSelection();
		}
		if (controls.ACCEPT)
			checkSelection();

        return;
	}

	FlxG.mouse.visible = true;

	if (pointerOverlaps(no)) {
        if (!isHoveringSmth) {
            isHoveringSmth = true;
			playMenuSound("scroll");
			curSelection = SelectingOption.NO;
            updateSelection();
        }
    }
	else if (pointerOverlaps(yes)) {
        if (!isHoveringSmth) {
            isHoveringSmth = true;
			playMenuSound("scroll");
			curSelection = SelectingOption.YES;
            updateSelection();
        }
    }
    else {
		isHoveringSmth = false;
		curSelection = SelectingOption.NONE;
		updateSelection();
    }

	if (pointerJustReleased())
        checkSelection();
}

function updateSelection() {
	yes.scale.set(1, 1);
	yes.updateHitbox();
	yes.alpha = 0.5;

	no.scale.set(1, 1);
	no.updateHitbox();
	no.alpha = 0.5;

	if (curSelection == SelectingOption.YES) {
		yes.scale.set(1.25, 1.25);
		yes.updateHitbox();
		yes.alpha = 1;
	}
	if (curSelection == SelectingOption.NO) {
		no.scale.set(1.25, 1.25);
		no.updateHitbox();
		no.alpha = 1;
	}

	yes.x = FlxG.width * 0.75 - yes.width / 2;
	yes.y = FlxG.height * 0.65 - yes.height / 2;

	no.x = FlxG.width * 0.25 - no.width / 2;
	no.y = FlxG.height * 0.65 - no.height / 2;
}

function checkSelection() {
	if (curSelection == SelectingOption.NONE)
        return;

	allowSelection = false;

	var curWarning:Map<String, Dynamic> = allWarnings[curWaningIndex];
	if (curSelection == SelectingOption.YES) {
		if (curWarning.selectYes != null) {
			var func:Void = curWarning.selectYes;
            func();
        }
    }
    else {
		if (curWarning.selectNo != null) {
			var func:Void = curWarning.selectNo;
			func();
		}
    }

	if (curWaningIndex >= allWarnings.length - 1) {
		playMenuSound("ok");

        saveImpostor();

        setTransition("slowFade");
		checkNextState();
		persistentUpdate = persistentDraw = true;
    }
    else {
		topTxt.text = "";
		warnSprite.kill();
		curWaningIndex++;
		createNewWarning();
    }

	curSelection == SelectingOption.NONE;
	updateSelection();
}

function checkNextState() {
	FlxG.save.data.seenImpostorStartupWarnings = true;

	if (isBelowStoryPoint("deadMenu"))
		FlxG.switchState(new ModState("legacy/legacyTitleState"));
	else
		FlxG.switchState(new ModState("impostorTitleState"));
}

function destroy() {
	if (skippedCreate) return;

	bg.destroy();
	warnTape.destroy();
	backGradient.destroy();
	particlesEmitter.destroy();
	line.destroy();
	topTxt.destroy();
	warnSprite.destroy();
	warningCount.destroy();
	no.destroy();
    yes.destroy();
}