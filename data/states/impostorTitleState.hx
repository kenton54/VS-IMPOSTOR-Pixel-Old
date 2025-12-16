import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxGradient;
import funkin.backend.system.Flags;
import funkin.backend.MusicBeatState;
import funkin.options.Options;
import hxvlc.flixel.FlxVideoSprite;
import EReg;
import StarsBackdrop;
import RGBPalette;

enum TitleState {
    INTRO;
    IDLE;
    DEMO;
}

var deadVersion:Bool = false; //isBelowStoryPoint("postWeek1");

var curState:TitleState = TitleState.IDLE;

var stars:StarsBackdrop;

var startSplash:Array<String> = [];
var midSplash:Array<String> = [];
var endSplash:Array<String> = [];
var introGroup:FlxGroup;
var introText:FunkinText;
var introTextEmotes:Array<FlxSprite> = [];

/**
 * This is supposed to only show the colors of the impostors and crewmates currently
 * being displayed besides the title.
 * 
 * But for now, these are here as placeholders.
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
var titleGrp:FlxGroup;
var baseScale:Float = 4 * gameScale.y;

var pressStart:FunkinText;

var demoVideo:FlxVideoSprite;

var fakeBlackTransition:FlxSprite;

var christmasParticles:FlxTypedEmitter;

static var gameStarted:Bool = false;

static var playedIntro:Bool = false;

var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];
var pressTxt = translate("press", [CoolUtil.keyToString(acceptKey)]).toUpperCase();
var clickTxt = translate("click", [translate("mouse")]).toUpperCase();
var touchTxt = translate("touch", [translate("screen")]).toUpperCase();
var playSuffix = translate("title.2playSuffix").toUpperCase();

// for testing purposes
var initialZoom:Float = 1;

function startMod() {
	gameStarted = false;
	playedIntro = false;
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

    changeDiscordMenuStatus("Title Screen");

	stars = new StarsBackdrop(-10, 5);
    stars.scrollFactor = FlxPoint.get(0.25, 0.25);
	add(stars);

	titleGrp = new FlxGroup();
	//titleGrp.visible = !deadVersion;
	add(titleGrp);

	var rgb:RGBPalette = new RGBPalette(titleColors[0][0], titleColors[0][1]);
    titleColor = new FlxSprite().loadGraphic(Paths.image("menus/title/color"));
    titleColor.scale.set(baseScale, baseScale);
    titleColor.updateHitbox();
    titleColor.centerOffsets();
    titleColor.screenCenter(FlxAxes.X);
    titleColor.y = FlxG.height * 0.2;
    titleColor.shader = rgb.shader;
	titleGrp.add(titleColor);

	var titleAnimIndices:Array<Int> = [0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 0];
    titleMain = new FlxSprite().loadGraphic(Paths.image("menus/title/title"), true, 197, 65);
	titleMain.animation.add("anim", titleAnimIndices, 24, false);
    titleMain.scale.set(baseScale, baseScale);
    titleMain.updateHitbox();
    titleMain.centerOffsets();
    titleMain.screenCenter(FlxAxes.X);
    titleMain.y = FlxG.height * 0.2;
	titleGrp.add(titleMain);

	fakeBlackTransition = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height * 4, [0x00000000, 0xFF000000, 0xFF000000]);
	fakeBlackTransition.visible = false;
	add(fakeBlackTransition);

    pressStart = new FunkinText(0, 0, FlxG.width, "", 52);
    pressStart.alignment = "center";
    pressStart.color = FlxColor.TRANSPARENT;
    pressStart.borderColor = FlxColor.WHITE;
    pressStart.borderSize = 6.8;
    pressStart.font = Paths.font("gameboy.ttf");
	pressStart.y = FlxG.height * 0.9 - pressStart.height;
    pressStart.alpha = 0;
	pressStart.scrollFactor.set(0, 0);
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

	demoVideo = new FlxVideoSprite(0, -FlxG.height);
	demoVideo.bitmap.volume = 0;
	demoVideo.bitmap.onEndReached.add(endDemo);
	demoVideo.kill();
	add(demoVideo);

	if (deadVersion) {
		window.title = "...";
		killIntroText();
		showTitle();
	} else {
		window.title = Flags.MOD_NAME;
		allowInput = true;

		if (!playedIntro && (Conductor.curStep <= 3 || Conductor.curStep >= 304)) {
			CoolUtil.playMenuSong();
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
	if (!allowInput) return;

	FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, initialZoom, 0.05);

	if (curState == TitleState.IDLE) {
		if (controls.BACK) {
			if (!canPlayIntro) {
				logTraceColored([{text: "Queued intro repetition!"}], "information");
				prepareIntro();
			}
		}

		if (controls.ACCEPT) {
			pressedWithKeyboard = true;

			if (transitionTimer.active && !deadVersion) {
				transitionTimer.cancel();
				setTransition("fadeUp");
				FlxG.switchState(new MainMenuState());
			} else if (!transitionTimer.active) {
				pressStart.text = pressTxt;
				pressStart.text += deadVersion ? "" : (" " + playSuffix);
				accept();
			}
		}
		if (pointerJustReleased()) {
			pressedWithKeyboard = false;

			if (transitionTimer.active && !deadVersion) {
				transitionTimer.cancel();
				setTransition("fadeUp");
				FlxG.switchState(new MainMenuState());
			} else if (!transitionTimer.active) {
				pressStart.text = isMobile ? touchTxt : clickTxt;
				pressStart.text += deadVersion ? "" : (" " + playSuffix);
				accept();
			}
		}

		if (accepted) return;

		doSecretCodes();
	} else if (curState == TitleState.INTRO) {
		if (controls.ACCEPT || pointerJustReleased())
			skipIntro();
    }
}

var tweenDur:Float = 1.5;
var tweenIn:FlxTween = null;
var tweenOut:FlxTween = null;
var mouseTxt:Bool = false;
function tweenPressStart() {
	pressStart.borderColor = deadVersion ? FlxColor.WHITE : FlxColor.interpolate(0xFF33FFFF, 0xFF4141CF, FlxG.random.float(0, 1));
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

    if (tweenIn != null) tweenIn.cancel();
    if (tweenOut != null) tweenOut.cancel();

	pressStart.alpha = 0;
    tweenIn = FlxTween.tween(pressStart, {alpha: 1}, tweenDur, {ease: FlxEase.quadOut, onComplete: _ -> {
        tweenOut = FlxTween.tween(pressStart, {alpha: 0}, tweenDur, {ease: FlxEase.quadIn, onComplete: tweenPressStart});
    }});
}

function stepHit(curStep:Int) {
	if (accepted) return;

	if (curStep == 0) {
		if (!_isPlayingDemo && !canPlayIntro && !(introGroup.exists && introGroup.active)) {
			triggerDemo();
			return;
		}

		if (!_isPlayingDemo && (!playedIntro || canPlayIntro) && (introGroup.exists && introGroup.active))
			playIntro();
	}

	if (_isPlayingIntro)
		introBeat(curStep);
}

var doCameraBop:Bool = true;
function beatHit(curBeat:Int) {
	if (accepted) return;

	if (curBeat == 76 && canPlayIntro && !canPlayDemos)
		transitionToIntro();

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
	if (FlxG.sound.music == null || curMeasure >= 20 || accepted) return;

	if (!canChangeColor) return;

	var selectedColors:Array<FlxColor> = titleColors[FlxG.random.int(0, titleColors.length - 1)];
	titleColor.shader.r = RGBPalette.convertColorToFloatArray(selectedColors[0]);
	titleColor.shader.g = RGBPalette.convertColorToFloatArray(selectedColors[1]);
	titleColor.shader.b = RGBPalette.convertColorToFloatArray(selectedColors[2]);
}

function transitionToIntro() {
	introGroup.revive();
	introGroup.forEach(function(obj) {
		obj.visible = true;
		FlxTween.tween(obj, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8);
	});
}

var canPlayIntro:Bool = false;
function prepareIntro() {
	canPlayDemos = false;
	gameStarted = false;
	canPlayIntro = true;
}

var _isPlayingIntro:Bool = false;
function playIntro() {
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
			showSplash(startSplash, 1);
		case 12: // beat 3
			showSplash(startSplash, 2);
		case 14:
			showSplash(startSplash, 3);
		case 16: // beat 4
			resetIntroText();
		case 20: // beat 5
			showText("kenton");
		case 24: // beat 6
			showText("and the VS IMPOSTOR Community");
		case 28: // beat 7
			showText("Presents:");
		case 32: // beat 8
			resetIntroText();
		case 36: // beat 9
			showSplash(midSplash, 1);
		case 44: // beat 11
			showSplash(midSplash, 2);
		case 46:
			showSplash(midSplash, 3);
		case 48: // beat 12
			resetIntroText();
		case 52: // beat 13
			showSplash(endSplash, 1);
		case 56: // beat 14
			showSplash(endSplash, 2);
		case 60: // beat 15
			showSplash(endSplash, 3, true);
		case 64: // beat 16
			playedIntro = true;
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
		obj.alpha = 0;
		obj.visible = false;
	});
	introGroup.kill();
}

function endIntro() {
	killIntroText();
	_isPlayingIntro = false;
	canPlayIntro = false;

	doCameraBop = true;
	canChangeColor = true;

	curState = TitleState.IDLE;

	showTitle(true);
	tweenPressStart();
}

function showTitle(?flash:Bool) {
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
	titleGrp.forEach(function(spr) {
        FlxTween.cancelTweensOf(spr, ["scale.x", "scale.y"]);
		spr.scale.set(baseScale, baseScale);
		spr.updateHitbox();

		var beatScale:Float = (baseScale * 1.08);
        var duration:Float = (Conductor.stepCrochet / 1000) * 4;

		spr.scale.set(beatScale, beatScale);
		FlxTween.tween(spr, {"scale.x": baseScale, "scale.y": baseScale}, duration, {ease: FlxEase.quartOut});
    });
}

function doSecretCodes() {}

var _isPlayingDemo:Bool = false;
var canPlayDemos:Bool = false;
function triggerDemo() {
	if (!canPlayDemos) {
		canPlayDemos = true;
		logTraceColored([{text: "Queued demo play!"}], "information");
        return;
    }

	var chosenVideo:Null<String> = null;
	if (watchedVideos.length > 0)
		choosenVideo = watchedVideos[FlxG.random.int(0, watchedVideos.length - 1)];

	if (chosenVideo == null) {
		canPlayDemos = false;
		_isPlayingDemo = false;
		logTraceColored([{text: "User hasn't watched any videos!", color: getLogColor("yellow")}], "warning");
		return;
	}

	curState = TitleState.DEMO;

    if (tweenIn != null) tweenIn.cancel();
    if (tweenOut != null) tweenOut.cancel();

	_isPlayingDemo = true;
	demoVideo.revive();

	fakeBlackTransition.visible = true;
	fakeBlackTransition.flipY = true;
	fakeBlackTransition.y = -FlxG.height - fakeBlackTransition.height;
	FlxTween.tween(stars, {verticalSpeed: 400}, 1, {startDelay: 1.5, ease: FlxEase.quartIn});
	FlxTween.tween(fakeBlackTransition, {y: FlxG.height - fakeBlackTransition.height}, 3, {ease: FlxEase.quadIn});
	FlxTween.tween(FlxG.camera.scroll, {y: -FlxG.height * 2}, 3, {ease: FlxEase.quartIn, onComplete: _ -> {
		if (demoVideo.load(chosenVideo))
			demoVideo.play();
	}});
}

function endDemo() {
	canPlayDemos = false;
	_isPlayingDemo = false;
	demoVideo.kill();

	//fakeBlackTransition.y = FlxG.height - fakeBlackTransition.height * 2;
	FlxTween.tween(stars, {verticalSpeed: 0}, 1, {startDelay: 1.5, ease: FlxEase.quartOut});
	FlxTween.tween(fakeBlackTransition, {y: -FlxG.height - fakeBlackTransition.height}, 3, {ease: FlxEase.quadOut});
	FlxTween.tween(FlxG.camera.scroll, {y: 0}, 3, {ease: FlxEase.quartOut, onComplete: _ -> {
        fakeBlackTransition.visible = false;
		fakeBlackTransition.flipY = false;

        curState = TitleState.IDLE;

		mouseTxt = false;
        tweenPressStart();
	}});
}

var transitionTimer:FlxTimer = new FlxTimer();
function accept() {
	accepted = true;
	doCameraBop = false;
	killIntroText();
	bopTitle();

    if (tweenIn != null && tweenIn.active) tweenIn.cancel();
    if (tweenOut != null && tweenOut.active) tweenOut.cancel();
    FlxTween.cancelTweensOf(pressStart, ["alpha"]);
    pressStart.alpha = 1;
    pressStart.borderColor = FlxColor.WHITE;

    playMenuSound("confirm");
    FlxG.camera.zoom += 0.08;

    var fakePressStart:FunkinText = pressStart.clone();
    fakePressStart.setPosition(pressStart.x, pressStart.y);
	fakePressStart.scrollFactor.copyFrom(pressStart.scrollFactor);
    insert(members.indexOf(pressStart), fakePressStart);
    FlxTween.tween(fakePressStart, {"scale.x": 1.25, "scale.y": 1.25}, 1, {ease: FlxEase.quartOut});
    FlxTween.tween(fakePressStart, {alpha: 0}, 0.5);
    FlxFlicker.flicker(pressStart, 1, 0.05, false, true);

    transitionTimer.start(1, _ -> {
		allowInput = false;
        transitioning = true;

		fakeBlackTransition.visible = true;
		fakeBlackTransition.y = FlxG.height;
		var transOutTimer:Float = deadVersion ? 2 : 1;
		FlxTween.tween(stars, {verticalSpeed: -400}, transOutTimer, {startDelay: 0.5, ease: FlxEase.quartIn});
		FlxTween.tween(fakeBlackTransition, {y: -FlxG.height}, transOutTimer, {ease: FlxEase.quadIn});
		FlxTween.tween(FlxG.camera.scroll, {y: FlxG.height * 2}, transOutTimer, {ease: FlxEase.quartIn});

		new FlxTimer().start(1.01 * transOutTimer, _ -> {
			MusicBeatState.skipTransOut = true;
			setTransition("fadeUpSlow");
            FlxG.switchState(new ModState("impostorMenuState"));
        });
    });
}

function destroy() {
	if (stars != null) {
        stars.destroy();
        stars = null;
    }

    if (tweenIn != null) tweenIn.destroy();
    if (tweenOut != null) tweenOut.destroy();
    transitionTimer.destroy();

	if (titleGrp != null) titleGrp.destroy();
	if (pressStart != null) pressStart.destroy();
	if (introGroup != null) introGroup.destroy();
	if (demoVideo != null) demoVideo.destroy();

	for (emote in introTextEmotes) {
		if (emote != null) {
			remove(emote);
			emote.destroy();
		}
	}
	introTextEmotes = null;
}