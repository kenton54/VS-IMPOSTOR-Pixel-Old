import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxGradient;
import funkin.backend.system.Flags;
import funkin.backend.MusicBeatState;
import funkin.options.Options;
import hxvlc.flixel.FlxVideoSprite;
import impostor.shaders.RGBPalette;
import impostor.StarsBackdrop;
import EReg;

enum TitleState {
    INTRO;
    IDLE;
    DEMO;
}

var deadVersion:Bool = false;

var curState:TitleState = TitleState.IDLE;

var stars:StarsBackdrop;

var startSplash:Array<String> = [];
var midSplash:Array<String> = [];
var endSplash:Array<String> = [];
var introGroup:FlxGroup;
var introText:FunkinText;
var introTextEmotes:Array<FlxSprite> = [];

var logoGlow:FlxSprite;
var logoShine:FlxSprite;
var introLogo:FunkinSprite;

var legacyLogo:FlxSprite;

var titleRGB:RGBPalette;
/**
 * This is supposed to only show the colors of the impostors and crewmates currently
 * being displayed besides the title.
 * 
 * But for now, all of them are available.
 */
var titleColors:Array<Array<FlxColor>> = [
	[0xFFE31629, 0xFF90003A],
	[0xFF3842AE, 0xFF2A1F78],
	[0xFF18683B, 0xFF0D412E],
	[0xFFEf69CB, 0xFFB74175],
	[0xFFF6CC5A, 0xFFD98E25],
	[0xFF352441, 0xFF23182F],
	[0xFFD2E5E8, 0xFF97ABB5],
	[0xFF461D87, 0xFF251161],
	[0xFF5D3E31, 0xFF412720],
	[0xFF61C2EF, 0xFF3B75C0],
	[0xFF5DD95D, 0xFF338C44],
	[0xFF58223C, 0xFF41132E],
	[0xFFFFBBD9, 0xFFCD7FB4],
	[0xFFF8ECAA, 0xFFE2BC69],
	[0xFF67768E, 0xFF4C5371],
	[0xFF998877, 0xFF6F5B4E],
	[0xFFFF7488, 0xFFD94368],
];
var titleMain:FlxSprite;
var titleColor:FlxSprite;
var baseScale:Float = 4 * gameScale.y;

var pressStart:FlxBitmapText;

var transitionSprite:FlxSprite;

var christmasParticles:FlxTypedEmitter;

static var gameStarted:Bool = false;

var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];
var pressTxt = translate("press", [CoolUtil.keyToString(acceptKey)]).toUpperCase();
var clickTxt = translate("click", [translate("mouse")]).toUpperCase();
var touchTxt = translate("touch", [translate("screen")]).toUpperCase();
var playSuffix = translate("title.2playSuffix").toUpperCase();

// for testing purposes
var initialZoom:Float = 1;

function startMod() {
	gameStarted = false;
	playedTitleIntro = false;
	MusicBeatState.skipTransOut = true;
	FlxG.switchState(new ModState("intro/impostorIntroState"));
}

function create() {
	MusicBeatState.skipTransIn = true;

	/*
	if (!modInitialized) {
		startMod();
        return;
    }*/

	CoolUtil.playMenuSong();

    changeDiscordMenuStatus("Title Screen");

	stars = new StarsBackdrop(-10, 5);
    stars.scrollFactor = FlxPoint.get(0.25, 0.25);
	add(stars);

	var titleSpriteGroup:FlxSpriteGroup = new FlxSpriteGroup();
	titleSpriteGroup.y = FlxG.height * 0.2;
	//titleSpriteGroup.visible = !deadVersion;
	add(titleSpriteGroup);

	titleRGB = new RGBPalette(titleColors[0][0], titleColors[0][1]);

    titleColor = new FlxSprite().loadGraphic(Paths.image("menus/title/color"));
    titleColor.scale.set(baseScale, baseScale);
    titleColor.updateHitbox();
    titleColor.centerOffsets();
    titleColor.screenCenter(FlxAxes.X);
	titleColor.shader = titleRGB.shader;
	titleSpriteGroup.add(titleColor);

	var titleAnimIndices:Array<Int> = [0, 0, 0, 0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 0];
    titleMain = new FlxSprite().loadGraphic(Paths.image("menus/title/title"), true, 197, 65);
	titleMain.animation.add("anim", titleAnimIndices, 24 /** (Conductor.crochet / 1000) * 4*/, false);
    titleMain.scale.set(baseScale, baseScale);
    titleMain.updateHitbox();
    titleMain.centerOffsets();
    titleMain.screenCenter(FlxAxes.X);
	titleSpriteGroup.add(titleMain);

	transitionSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 2, [0x00000000, 0xFF000000, 0xFF000000]);
	transitionSprite.visible = false;
	add(transitionSprite);

	pressStart = new FlxBitmapText(0, 0, "", FlxBitmapFont.fromMonospace(Paths.font('gameboy.png'), ' !"#%&\'()*+.-,/0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`{|}~', FlxPoint.get(8, 10)));
	pressStart.scrollFactor.set();
	pressStart.scale.set(6, 6);
	pressStart.updateHitbox();
	pressStart.fieldWidth = FlxG.width;
    pressStart.alignment = "center";
	pressStart.letterSpacing = -1;
	pressStart.y = FlxG.height * 0.85 - pressStart.height;
	pressStart.screenCenter(FlxAxes.X);
    pressStart.alpha = 0;
    add(pressStart);

	introGroup = new FlxGroup();
	add(introGroup);

    var introBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	introBG.scrollFactor.set(0, 0);
	introGroup.add(introBG);

	introText = new FunkinText(0, 0, FlxG.width, "", 44, false);
	introText.alignment = "center";
	introText.font = Paths.font("pixeloidsans.ttf");
	introText.scrollFactor.set(0, 0);
	introText.screenCenter(FlxAxes.X);
	introText.y = FlxG.height * 0.35;
	introGroup.add(introText);

	legacyLogo = new FlxSprite().loadGraphic(Paths.image("menus/title/legacyLogo"));
	legacyLogo.scale.set(0.65, 0.65);
	legacyLogo.updateHitbox();
	legacyLogo.screenCenter(FlxAxes.X);
	legacyLogo.y = FlxG.height * 0.88 - legacyLogo.height;
	legacyLogo.alpha = 0;
	introGroup.add(legacyLogo);

	logoGlow = new FlxSprite().loadGraphic(Paths.image('menus/title/logoGlow'));
	logoGlow.alpha = 0;
	introGroup.add(logoGlow);

	logoShine = new FlxSprite().loadGraphic(Paths.image('menus/title/logoShine'));
	logoShine.alpha = 0;
	introGroup.add(logoShine);

	introLogo = new FunkinSprite().loadSprite(Paths.image('menus/title/introLogo'));
	introLogo.addAnim('versus', 'versus', 0, false);
	introLogo.addAnim('impostor', 'impostor', 0, false);
	introLogo.addAnim('pixel', 'pixel', 40, false);
	introLogo.playAnim('versus');
	introLogo.scale.set(baseScale, baseScale);
	introLogo.updateHitbox();
	introLogo.setPosition(titleMain.x, titleMain.y);
	introLogo.alpha = 0;
	introGroup.add(introLogo);

	logoGlow.x = introLogo.x + (introLogo.width - logoGlow.width) / 2;
	logoGlow.y = introLogo.y + (introLogo.height - logoGlow.height) / 2;

	logoShine.x = introLogo.x + (introLogo.width - logoShine.width) / 2;
	logoShine.y = introLogo.y + (introLogo.height - logoShine.height) / 2;

	if (deadVersion) {
		window.title = "...";
		killIntroText();
		showTitle();
	} else {
		allowInput = true;

		if (!playedTitleIntro) {
			introGroup.revive();
			prepareIntro();
			playIntro();
        }
		else {
			endIntro();
		}
	}
}

var allowInput:Bool = false;
var accepted:Bool = false;
var transitioning:Bool = false;
var pressedWithKeyboard:Bool = false;
function update(elapsed:Float) {
	FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, initialZoom, 0.05);

	var pressedEnter:Bool = controls.ACCEPT || pointerJustReleased();

	if (allowInput) {
		switch (curState) {
			case TitleState.INTRO:
				if (pressedEnter)
					skipIntro();

			case TitleState.IDLE:
				if (controls.BACK) {
					if (!canPlayIntro) {
						FlxG.sound.music.time = 0;
						prepareIntro();
						playIntro();
					}
				}

				if (pressedEnter) {
					if (transitionTimer.active)
						transitionToMainMenu(true);
					else
						startTransitionToMainMenu(controls.ACCEPT);
				}
		}
	}
}

var transitionTimer:FlxTimer = new FlxTimer();

function startTransitionToMainMenu(keyboard:Bool) {
	accepted = true;
	playMenuSound("confirm");

	killIntroText();

	stopPressStartTween();

	pressStart.alpha = 1;
	pressStart.text = keyboard ? pressTxt : (FlxG.onMobile ? touchTxt : clickTxt);
	pressStart.text += deadVersion ? "" : (" " + playSuffix);

	doCameraBop = false;

	bopTitle();
	FlxG.camera.zoom += 0.08;

	pressStart.screenCenter(FlxAxes.X);

	var fakePressStart:FlxBitmapText = new FlxBitmapText(0, 0, pressStart.text, pressStart.font);
	fakePressStart.scrollFactor.copyFrom(pressStart.scrollFactor);
	fakePressStart.scale.x = fakePressStart.scale.y = pressStart.scale.x;
	fakePressStart.updateHitbox();
	fakePressStart.y = pressStart.y;
	fakePressStart.screenCenter(FlxAxes.X);
	insert(members.indexOf(pressStart), fakePressStart);

	var scaleTo:Float = pressStart.scale.x * 1.25;
	FlxTween.tween(fakePressStart, {"scale.x": scaleTo, "scale.y": scaleTo}, 1, {ease: FlxEase.quintOut});
	FlxTween.tween(fakePressStart, {alpha: 0}, 0.5);

	FlxFlicker.flicker(pressStart, 1, 0.05, false, true);

	transitionTimer.start(1, _ -> transitionToMainMenu(false));
}

function transitionToMainMenu(forced:Bool) {
	allowInput = false;
	transitioning = true;

	if (forced) {
		transitionTimer.cancel();

		setTransition("fadeUp");
		FlxG.switchState(new ModState("impostorMenuState"));
	}
	else {
		transitionSprite.visible = true;
		transitionSprite.flipY = false;
		transitionSprite.y = FlxG.height;
		var transOutTimer:Float = deadVersion ? 2 : 1;
		FlxTween.tween(transitionSprite, {y: 0}, transOutTimer, {ease: FlxEase.quadIn});
		FlxTween.tween(FlxG.camera.scroll, {y: FlxG.height}, transOutTimer, {ease: FlxEase.quartIn});

		new FlxTimer().start(1.01 * transOutTimer, _ -> {
			MusicBeatState.skipTransOut = true;
			setTransition("fadeUp");
			FlxG.switchState(new ModState("impostorMenuState"));
		});
	}
}

var tweenDur:Float = 1.5;
var tweenIn:FlxTween = null;
var tweenOut:FlxTween = null;
var mouseTxt:Bool = false;
function tweenPressStart() {
    if (isMobile) {
        pressStart.text = touchTxt;
		pressStart.text += deadVersion ? "" : (" " + playSuffix);
    }
    else {
        if (mouseTxt = !mouseTxt)
            pressStart.text = pressTxt;
        else
            pressStart.text = clickTxt;

		pressStart.text += deadVersion ? "" : (" " + playSuffix);
    }

	pressStart.screenCenter(FlxAxes.X);

	stopPressStartTween();

	pressStart.alpha = 0;
    tweenIn = FlxTween.tween(pressStart, {alpha: 1}, tweenDur, {ease: FlxEase.quadOut, onComplete: _ -> {
        tweenOut = FlxTween.tween(pressStart, {alpha: 0}, tweenDur, {ease: FlxEase.quadIn, onComplete: tweenPressStart});
    }});
}

function stopPressStartTween() {
	if (tweenIn != null) tweenIn.cancel();
    if (tweenOut != null) tweenOut.cancel();
}

function stepHit(curStep:Int) {
	if (_isPlayingIntro)
		introBeat(curStep);
}

var doCameraBop:Bool = true;
function beatHit(curBeat:Int) {
	if (accepted) return;

	if (curBeat % 4 == 3) // last beat of a measure
		titleMain.animation.play("anim", true);

	if (!doCameraBop) return;

    bopTitle();

	if (curBeat % 2 == 0)
        FlxG.camera.zoom += 0.01;
}

var canChangeColor:Bool = true;
function measureHit(curMeasure:Int) {
	// measure 20 is when the song ends
	if (FlxG.sound.music == null || accepted) return;

	if (canChangeColor) {
		var selectedColors:Array<FlxColor> = titleColors[FlxG.random.int(0, titleColors.length - 1)];
		titleRGB.red = selectedColors[0];
		titleRGB.green = selectedColors[1];
	}
}

var canPlayIntro:Bool = false;
function prepareIntro() {
	gameStarted = false;
	canPlayIntro = true;

	reviveIntroText();
}

var _isPlayingIntro:Bool = false;
function playIntro() {
	FlxG.camera.stopFX();

	doCameraBop = false;
	canChangeColor = false;

	startSplash = getSplash(Assets.getText(Paths.file("data/titlescreen/startupText.txt")));
	midSplash = getSplash(Assets.getText(Paths.file("data/titlescreen/midText.txt")));
	endSplash = getSplash(Assets.getText(Paths.file("data/titlescreen/endText.txt")));

	curState = TitleState.INTRO;

	_isPlayingIntro = true;
}

function getSplash(fileData:String):Array<String> {
	var splashLines:Array<String> = fileData.split("\n");

	function getRandomLine(splashData:Array<String>):String {
		var splash:String = splashData[FlxG.random.int(0, splashData.length - 1)];

		if (StringTools.startsWith(splash, "{")) {
			var eventCommand:String = splash.substring(1, splash.indexOf("}"));
			var command:Array<String> = eventCommand.split(":");
			if (festiveEvent != null && command[0] == "event" && command[1] == festiveEvent) {
				splash = StringTools.replace(splash, "{" + eventCommand + "}", "");
			} else {
				return getRandomLine(splashData);
			}
		}

		return splash;
	}

	var chosenSplash:String = getRandomLine(splashLines);
	return chosenSplash.split("--");
}

function introBeat(curStep:Int) {
	if (curStep > 64) return;

	switch (curStep) {
		case 4: // beat 1
			showText("kenton", 1);
		case 8: // beat 3
			showText("and the VS IMPOSTOR Pixel Team", 2);
		case 12:
			showText("Presents:", 3);
		case 16: // beat 4
			resetIntroText();
		case 20: // beat 5
			introText.y -= 100;
			showText("A mod based of");
		case 28: // beat 7
			showText("VS IMPOSTOR Legacy");
			legacyLogo.alpha = 1;
		case 32: // beat 8
			introText.y += 100;
			legacyLogo.alpha = 0;
			resetIntroText();
		case 36: // beat 9
			showSplash(midSplash, 1);
		case 44: // beat 11
			showSplash(midSplash, 2);
			showSplash(midSplash, 3);
		case 48: // beat 12
			resetIntroText();
		case 52: // beat 13
			FlxTween.cancelTweensOf(introLogo);
			introLogo.playAnim('versus');
			introLogo.alpha = 1;
			FlxTween.tween(introLogo, {alpha: 0}, (Conductor.stepCrochet / 1000) * 4);
		case 56: // beat 14
			FlxTween.cancelTweensOf(introLogo);
			introLogo.playAnim('impostor');
			introLogo.alpha = 1;
			FlxTween.tween(introLogo, {alpha: 0}, (Conductor.stepCrochet / 1000) * 4);
		case 60: // beat 15
			FlxTween.cancelTweensOf(introLogo);
			introLogo.playAnim('pixel');
			introLogo.alpha = 1;

			FlxG.camera.fade(0x40FFFFFF, (Conductor.stepCrochet / 1000) * 4);
			FlxTween.tween(logoGlow, {alpha: 0.5}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadIn});
			FlxTween.tween(logoShine, {alpha: 0.4}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quartIn});
		case 64: // beat 16
			FlxTween.cancelTweensOf(introLogo);
			FlxTween.cancelTweensOf(logoGlow);
			FlxTween.cancelTweensOf(logoShine);
			introLogo.alpha = logoGlow.alpha = logoShine.alpha = 0;
			playedTitleIntro = true;
            endIntro();
    }
}

function showText(text:String) {
	if (introText.text != "")
		introText.text += "\n" + text;
	else
		introText.text = text;
}

function showSplash(splashArray:Array<String>, index:Int, ?ignoreFormat:Bool) {
	if (index == 1) {
		var splashText:Dynamic = formatCommand(index, splashArray[0]);
		introText.text = splashText;
	}
	if (index == 2) {
		var splashText:Dynamic = formatCommand(index, splashArray[1]);
		introText.text += "\n" + splashText;
	}
	if (index == 3 && splashArray[2] != null) {
		var format:FlxTextFormat = null;
		if (ignoreFormat == null || ignoreFormat != null && !ignoreFormat) {
			format = new FlxTextFormat(FlxColor.GRAY);
			format.format.size = introText.size * 0.6;
		}

		var splashText:Dynamic = formatCommand(index, splashArray[2], format);
		introText.text += "\n" + splashText;

		if (format != null)
			introText.addFormat(format, introText.text.lastIndexOf("\n") + 1, introText.text.length);
	}
}

function formatCommand(line:Int, text:String, ?formatData:FlxTextFormat):Dynamic {
	var formattedText:String = text;

	var ereg = new EReg("{+[a-z:_]+}", "gi");
	ereg.map(formattedText, function(reg:EReg) {
		var command:String = reg.matched(0);
		var formatCommand:String = command.substring(1, command.length - 1);
		if (StringTools.contains(formatCommand, ":")) {
			var splittedCommand:Array<String> = formatCommand.split(":");
			if (splittedCommand[0] == "emote") {
				var emotePath:String = Paths.image("menus/title/emotes/" + splittedCommand[1]);
				var emoteSprite:FlxSprite = new FlxSprite(introText.width / 2, introText.y).loadGraphic(emotePath);
				emoteSprite.scale.set(introText.size / 10, introText.size / 10);
				emoteSprite.updateHitbox();
				emoteSprite.x -= emoteSprite.width / 2;
				emoteSprite.y += line != 1 ? (introText.height - 5) : 0;
				introTextEmotes.push(emoteSprite);
				add(emoteSprite);

				if (formatData != null) {
					var formatSize:Float = formatData.format.size / introText.size;
					emoteSprite.scale.x *= formatSize;
					emoteSprite.scale.y *= formatSize;
					emoteSprite.updateHitbox();
					emoteSprite.x = introText.width / 2 - emoteSprite.width / 2;
					emoteSprite.color = formatData.format.color;
				}

				formattedText = reg.replace(formattedText, " ");
			}
			if (splittedCommand[0] == "input") {
				var controlKey:FlxKey = Reflect.field(Options, "P1_" + splittedCommand[1])[0];
				formattedText = reg.replace(formattedText, CoolUtil.keyToString(controlKey));
			}
		} else {
			if (formatCommand == "blank")
				formattedText = reg.replace(formattedText, " ");
			if (formatCommand == "curPlayable")
				formattedText = reg.replace(formattedText, pixelPlayable);
		}
	});

	ereg = null;

	return formattedText;
}

function resetIntroText() {
	introText.text = "";
	introText.clearFormats();

	for (emote in introTextEmotes) {
		if (emote != null) {
			remove(emote);
			emote.destroy();
		}
	}
	introTextEmotes = [];
}

function skipIntro() {
	if (FlxG.sound.music != null)
		FlxG.sound.music.time = 9412;

	endIntro();
}

function killIntroText() {
	resetIntroText();
	introGroup.forEach(function(obj) {
		FlxTween.cancelTweensOf(obj);
		obj.visible = false;
	});
	introGroup.kill();
}

function reviveIntroText() {
	resetIntroText();
	introGroup.forEach(function(obj) {
		FlxTween.cancelTweensOf(obj);
		obj.visible = true;
	});
	introGroup.revive();
}

function endIntro() {
	killIntroText();
	_isPlayingIntro = false;
	canPlayIntro = false;

	doCameraBop = true;
	canChangeColor = true;

	curState = TitleState.IDLE;

	playedTitleIntro = true;
	showTitle(true);
	tweenPressStart();
}

function showTitle(?flash:Bool) {
	FlxG.camera.stopFX();

	if (flash != null && flash)
        FlxG.camera.flash(FlxColor.WHITE, !gameStarted ? 3 : 1.5);
    else {
		FlxG.camera.fade(0xFF000000, !gameStarted ? 2 : 0.5, true);

		if (deadVersion) {
			new FlxTimer().start(!gameStarted ? 5 : 1, _ -> {
				allowInput = true;
				tweenPressStart();
            });
        }
    }

	gameStarted = true;
}

function bopTitle() {
	FlxTween.cancelTweensOf(titleMain, ["scale.x", "scale.y"]);
	FlxTween.cancelTweensOf(titleColor, ["scale.x", "scale.y"]);

	var beatScale:Float = baseScale * 1.05;
	var duration:Float = (Conductor.stepCrochet / 1000) * 4;

	titleMain.scale.set(beatScale, beatScale);
	titleColor.scale.set(beatScale, beatScale);
	FlxTween.tween(titleMain, {"scale.x": baseScale, "scale.y": baseScale}, duration, {ease: FlxEase.quadOut});
	FlxTween.tween(titleColor, {"scale.x": baseScale, "scale.y": baseScale}, duration, {ease: FlxEase.quadOut});
}

function doSecretCodes() {}

function destroy() {
	stars.destroy();

    stopPressStartTween();
    transitionTimer.destroy();

	for (emote in introTextEmotes) {
		if (emote != null) {
			remove(emote);
			emote.destroy();
		}
	}

	introTextEmotes = null;
}