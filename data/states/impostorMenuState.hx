import flixel.effects.FlxFlicker;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.FlxBasic;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Flags;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.MusicBeatGroup;
import funkin.editors.character.CharacterSelection;
import funkin.editors.charter.CharterSelection;
import funkin.editors.stage.StageSelection;
import funkin.editors.EditorTreeMenu;
import funkin.menus.credits.CreditsMain;
import funkin.menus.ModSwitchMenu;
import funkin.options.Options;
import funkin.options.OptionsMenu;
import openfl.system.System;
import impostor.BackButton;
import impostor.StarsBackdrop;
import impostor.ResizableUIBox;
import FunkinGroup;

var discordIntegration:Bool = false;

var deadVersion:Bool = false; //isBelowStoryPoint("menuRevival");

enum SelectionMode {
    MAIN;
    WINDOW;
}

enum ButtonType {
	MAIN;
	EXTRAS;
	OTHERS;
}

var curSelectionMode:SelectionMode = SelectionMode.MAIN;

var mainCamera:FlxCamera;
var spaceCamera:FlxCamera;

var exitPrompt:ExitPrompt;

var windowArea:FlxRect;
var windowMenu:WindowSubMenuHandler;
var spaceGroup:FlxSpriteGroup;

var backButton:BackButton;

var topButtonsGroup:FlxSpriteGroup;
var statsButton:TopButton;

var discordAvatar:FlxSprite;
var discordUsername:FunkinText;

var lightThing:FlxSprite;
var lightGlow:FlxSprite;
var lightLight:FlxSprite;

var baseScale:Float = 5 * gameScale.y;

inline function getImage(path:String) {
	return Paths.image("menus/mainmenu/" + path);
}

var mainSectionButtons:Array<Dynamic> = [
    {
        name: translate("generic.play"),
        available: true,
        icon: getImage("icons/play"),
        scale: baseScale,
        type: ButtonType.MAIN,
        onSelect: function() {
			var worldmapImage:String = getImage("bigButtons/worldmap-dead"); //deadVersion ? getImage("bigButtons/worldmap-dead") : getImage("bigButtons/worldmap");
			var worldmapText:String = translate("questionMarks"); //deadVersion ? (isBelowStoryPoint("postLobby") ? translate("questionMarks") : translate("mainMenu.sections.worldmap")) : translate("mainMenu.sections.worldmap");
			var freeplayImage:String = deadVersion ? getImage("bigButtons/freeplay-dead") : getImage("bigButtons/freeplay");
			var freeplayText:String = deadVersion ? translate("questionMarks") : translate("generic.freeplay");
			var tutorialImage:String = deadVersion ? getImage("bigButtons/tutorial-dead") : getImage("bigButtons/tutorial");

			var window:WindowSubMenu = new WindowSubMenu(translate("generic.play"), 2, 1);

			var worldmapButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 3 * baseScale, {
				image: worldmapImage,
                width: 56,
                height: 55
            });
            worldmapButton.x -= worldmapButton.width + 0.5 * baseScale;
            worldmapButton.index.set(0, 0);
			worldmapButton.idleColor = deadVersion ? 0xFF313131 : 0xFF0A3C33;
			worldmapButton.hoverColor = deadVersion ? 0xFF484848 : 0xFF10584B;
			worldmapButton.available = false;//!isBelowStoryPoint("postTutorial");
			worldmapButton.addLabel(worldmapText, FlxPoint.get(0, 43.5));
			objectCenter(worldmapButton.label, worldmapButton.button, FlxAxes.X);
			window.add(worldmapButton);

			var freeplayButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 3 * baseScale, {
				image: freeplayImage,
				width: 56,
				height: 55
			});
			freeplayButton.x += 0.5 * baseScale;
			freeplayButton.index.set(1, 0);
			freeplayButton.idleColor = deadVersion ? 0xFF313131 : 0xFF0A3C33;
			freeplayButton.hoverColor = deadVersion ? 0xFF484848 : 0xFF10584B;
			freeplayButton.available = true; //!deadVersion;
			freeplayButton.addLabel(freeplayText, FlxPoint.get(0, 43.5));
            freeplayButton.onSelect = function() {
                disableInput();
                new FlxTimer().start(1, _ -> FlxG.switchState(new FreeplayState()));
            };
			objectCenter(freeplayButton.label, freeplayButton.button, FlxAxes.X);
			window.add(freeplayButton);

			var tutorialButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 59 * baseScale, {
				image: tutorialImage,
				width: 72,
				height: 12
			});
			tutorialButton.x -= tutorialButton.width / 2;
			tutorialButton.index.set(0, 1);
			tutorialButton.idleColor = deadVersion ? 0xFFD6D6D6 : 0xFFAAE2DC;
			tutorialButton.hoverColor = 0xFFFFFFFF;
			tutorialButton.available = false;
			tutorialButton.addLabel(translate("questionMarks"), FlxPoint.get(0, 1.5));
			objectCenter(tutorialButton.label, tutorialButton.button, FlxAxes.X);
			window.add(tutorialButton);

            openWindowSubMenu(window);
        }
    },
    {
        name: translate("generic.achievements"),
		available: false,
        icon: getImage("icons/achievements"),
		scale: baseScale,
		type: ButtonType.MAIN,
        offset: [4, 0],
        onSelect: function() {
			new FlxTimer().start(0.5, _ -> {
				setTransition("fade");
				FlxG.switchState(new ModState("impostorAchievementsState"));
			});
        }
    },
    {
        name: translate("generic.shop"),
		available: false,
		icon: getImage("icons/shop"),
		scale: baseScale,
		type: ButtonType.MAIN,
		offset: [1, 1],
		onSelect: function() {
			new FlxTimer().start(0.5, _ -> {
				setTransition("fade");
				FlxG.switchState(new ModState("impostorShopState"));
			});
		}
    },
	{
		name: translate("generic.options"),
		available: true,
		icon: getImage("icons/options"),
		scale: baseScale,
		type: ButtonType.EXTRAS,
        onSelect: function() {
			new FlxTimer().start(0.5, _ -> {
				setTransition("fade");
				FlxG.switchState(new OptionsMenu());
			});
			//openSubState(new ModSubState("options/impostorOptionsSubState"));
        }
	},
	{
		name: translate("generic.extras"),
		available: true,
		icon: getImage("icons/credits"),
		scale: baseScale,
		type: ButtonType.EXTRAS,
        onSelect: function() {
			var window:WindowSubMenu = new WindowSubMenu(translate("generic.extras"));

			var creditsButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 8 * baseScale, {
                image: getImage("bigButtons/credits"),
                width: 121,
                height: 35
            });
            creditsButton.x -= creditsButton.width / 2;
			creditsButton.index.set(0, 0);
			creditsButton.idleColor = 0xFF0A3C33;
			creditsButton.hoverColor = 0xFF10584B;
			creditsButton.addLabel(translate("generic.credits"), FlxPoint.get(4, 11), 48, 52);
			creditsButton.available = true;//!deadVersion;
			creditsButton.onSelect = function() {
				disableInput();
				setTransition("fade");
				new FlxTimer().start(0.5, _ -> FlxG.switchState(new ModState("impostorCreditsState")));
			};
			window.add(creditsButton);

			var musicButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 46 * baseScale, {
                image: getImage("bigButtons/musicPlayer"),
                width: 25,
                height: 25
            });
			musicButton.x -= musicButton.width / 2;
			musicButton.x -= musicButton.width + 10 * baseScale;
			musicButton.index.set(0, 1);
			musicButton.idleColor = 0xFFAAE2DC;
			musicButton.available = false;//!deadVersion;
			window.add(musicButton);

			var charsButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 46 * baseScale, {
				image: getImage("bigButtons/characterBio"),
				width: 25,
				height: 25
			});
			charsButton.x -= charsButton.width / 2;
			charsButton.index.set(1, 1);
			charsButton.idleColor = 0xFFAAE2DC;
			charsButton.available = false;
			window.add(charsButton);

			var moviesButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 46 * baseScale, {
				image: getImage("bigButtons/movieTheater"),
				width: 25,
				height: 25
			});
			moviesButton.x -= musicButton.width / 2;
			moviesButton.x += moviesButton.width + 10 * baseScale;
			moviesButton.index.set(2, 1);
			moviesButton.idleColor = 0xFFAAE2DC;
			moviesButton.available = false;//!deadVersion;
			window.add(moviesButton);

			openWindowSubMenu(window);
        }
	},
	{
		name: translate("generic.mods"),
		available: true,
		scale: baseScale,
		type: ButtonType.OTHERS,
        onSelect: function() {
            if (Flags.VERSION == "1.0.1" || Flags.VERSION == "1.0.0") {
				modSubState();
                return;
            }

            var modsList:Array<String> = ModsFolder.getModsList();
            var window:WindowSubMenu = new WindowSubMenu(translate("generic.mods"), 0, modsList.length);

            var reloadButton:BackButton = new BackButton(106 * baseScale, 58 * baseScale, function() {
				playMenuSound("cancel");
                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.5);
                setTransition("fade");
                ModsFolder.switchMod(ModsFolder.currentModFolder);
            }, baseScale, "menus/mainmenu/reload", false, true);
            reloadButton.scrollFactor.set(0, 0);

            var unloadButton:BackButton = new BackButton(124 * baseScale, 58 * baseScale, function() {
				playMenuSound("cancel");
                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.5);
                setTransition("fade");
                ModsFolder.switchMod(null);
            }, baseScale, "menus/mainmenu/unload", false, true);
            unloadButton.scrollFactor.set(0, 0);

            var yPos:Float = 0;
            for (i => modName in modsList) {
                if (modName == ModsFolder.currentModFolder) continue;

				var modButton:WindowButton = new WindowButton(windowArea, 0, yPos, {
                    image: null,
                    width: windowArea.width,
					height: windowArea.height / 8
                });
				modButton.index.set(0, i);
				modButton.idleColor = 0xFFAAAAAA;
			    modButton.hoverColor = 0xFFFFFFFF;
				modButton.addLabel(modName, FlxPoint.get(4, 1.5));
                modButton.onSelect = function() {
                    playMenuSound("confirm");
                    if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.5);
					setTransition("fade");
					ModsFolder.switchMod(modName);
                }
                window.add(modButton);

				yPos += modButton.height;
            }

			if (window.members[window.getLength() - 1].y + window.members[window.getLength() - 1].height > windowArea.height) {
                window.customUpdate = function(elapsed:Float) {
                    var windowCamera:FlxCamera = window._parent.windowCamera;
                    windowCamera.minScrollY = 0;
                    windowCamera.maxScrollY = window.members[window.getLength() - 1].y + window.members[window.getLength() - 1].height;
                    windowCamera.scroll.y += -FlxG.mouse.wheel * elapsed * 2000;
                };
            }

            window.add(reloadButton);
            window.addDeadzone(reloadButton);

            window.add(unloadButton);
            window.addDeadzone(unloadButton);

			openWindowSubMenu(window);
        }
	},
	{
		name: translate("generic.exit"),
		available: true,
		scale: baseScale,
		type: ButtonType.OTHERS,
        onSelect: function() {
            exitPrompt.open();
        }
	}
];

var allButtonsArray:Array<Dynamic> = [];
var mainButtons:FlxGroup;
var buttonsMainGroup:FlxSpriteGroup;
var buttonsLabelGroup:FlxSpriteGroup;
var buttonsIconGroup:FlxSpriteGroup;

function create() {
    changeDiscordMenuStatus("Main Menu");

    subStateClosed.add(onCloseSubstate);

	//setTransition("fadeUp");

    if (FlxG.sound.music == null && !deadVersion) {
        CoolUtil.playMenuSong();
		FlxG.sound.music.volume = Options.volumeMusic;
    }

	spaceCamera = new FlxCamera();
	spaceCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(spaceCamera, false);

    mainCamera = new FlxCamera();
	mainCamera.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(mainCamera, false);

    var starField:StarsBackdrop = new StarsBackdrop(-5, 3);
    starField.scale = FlxPoint.get(1.2, 1.2);
    starField.scrollFactor = FlxPoint.get(0.2, 0.2);
	starField.camera = spaceCamera;
	add(starField);

	var bgLeft:FlxSprite = new FlxSprite().loadGraphic(getImage("bg-left"));
    bgLeft.scale.set(baseScale, baseScale);
    bgLeft.updateHitbox();
	bgLeft.camera = mainCamera;

	var bgRight:FlxSprite = new FlxSprite(FlxG.width).loadGraphic(getImage("bg-right"));
    bgRight.scale.set(baseScale, baseScale);
    bgRight.updateHitbox();
    bgRight.x -= bgRight.width;
	bgRight.camera = mainCamera;

	var bgDistance:Float = distanceBetweenFloats(bgLeft.x + bgLeft.width, bgRight.x);
	var bgMiddle:FlxSprite = new FlxSprite(bgLeft.x + bgLeft.width).loadGraphic(getImage("bg-middle"));
	bgMiddle.scale.set(baseScale, baseScale);
    bgMiddle.updateHitbox();
	bgMiddle.setGraphicSize(bgDistance, bgMiddle.height);
	bgMiddle.updateHitbox();
    bgMiddle.camera = mainCamera;

    add(bgMiddle);
    add(bgLeft);
    add(bgRight);

	var topLeft:FlxSprite = new FlxSprite(1 * baseScale, 2 * baseScale).loadGraphic(getImage("top-left"));
    topLeft.scale.set(baseScale, baseScale);
    topLeft.updateHitbox();
    topLeft.camera = mainCamera;

	var topRight:FlxSprite = new FlxSprite(FlxG.width - 1 * baseScale, topLeft.y).loadGraphic(getImage("top-right"));
    topRight.scale.set(baseScale, baseScale);
    topRight.updateHitbox();
    topRight.x -= topRight.width;
    topRight.camera = mainCamera;

	var topDistance:Float = distanceBetweenFloats(topLeft.x + topLeft.width, topRight.x + 1 / gameScale.y);
	var topMiddle:FlxSprite = new FlxSprite(topLeft.x + topLeft.width, topLeft.y).loadGraphic(getImage("top-middle"));
    topMiddle.scale.set(baseScale, baseScale);
    topMiddle.updateHitbox();
	topMiddle.setGraphicSize(topDistance, topMiddle.height);
	topMiddle.updateHitbox();
    topMiddle.camera = mainCamera;

	var topShadowL:FlxSprite = new FlxSprite(topLeft.x, (topLeft.y + topLeft.height) - 2 * baseScale).loadGraphic(getImage("top-shadow"));
    topShadowL.scale.set(baseScale, baseScale);
    topShadowL.updateHitbox();
    topShadowL.blend = getBlendMode("multiply");
    topShadowL.camera = mainCamera;

	var topShadowR:FlxSprite = new FlxSprite(topRight.x, (topRight.y + topRight.height) - 2 * baseScale).loadGraphic(getImage("top-shadow"));
    topShadowR.scale.set(baseScale, baseScale);
    topShadowR.updateHitbox();
    topShadowR.blend = getBlendMode("multiply");
    topShadowR.flipX = true;
    topShadowR.camera = mainCamera;

	var topShadowDistance:Float = distanceBetweenFloats(topShadowL.x + topShadowL.width, topShadowR.x + 1 / gameScale.y);
    var topShadowM:FlxSprite = new FlxSprite(topShadowL.x + topShadowL.width, topShadowL.y).makeGraphic(Std.int(topShadowDistance), Std.int(4 * baseScale), 0xFF999999);
	topShadowM.blend = getBlendMode("multiply");
	topShadowM.camera = mainCamera;

	lightThing = new FlxSprite(topLeft.x + 24 * baseScale, topLeft.y + 4 * baseScale).loadGraphic(getImage("lightThing"));
    lightThing.scale.set(baseScale, baseScale);
    lightThing.updateHitbox();
	lightThing.camera = mainCamera;

	lightGlow = new FlxSprite().loadGraphic(getImage("lightGlow"));
    lightGlow.scale.set(1.5, 1.5);
    lightGlow.updateHitbox();
    lightGlow.setPosition(lightThing.x + (lightThing.width / 2) - (lightGlow.width / 2), lightThing.y + (lightThing.height / 2) - (lightGlow.height / 2));
    lightGlow.blend = getBlendMode("add");
	lightGlow.camera = mainCamera;

	lightLight = new FlxSprite(lightThing.x, lightThing.y).loadGraphic(getImage("lightLight"));
    lightLight.scale.set(baseScale, baseScale);
    lightLight.updateHitbox();
	lightLight.blend = getBlendMode("add");
	lightLight.camera = mainCamera;

	if (!isMobile && discordIntegration && !deadVersion) {
		discordAvatar = new FlxSprite(lightThing.x + lightThing.width + 6 * baseScale, lightThing.y - 1.5 * baseScale);

        if (DiscordUtil.ready) {
            try {
				discordAvatar.loadGraphic(DiscordUtil.user.getAvatar(64 * gameScale.y));
            }
            catch (e:Dynamic) {
                discordAvatar.loadGraphic(getImage("nullAvatar"));
				discordAvatar.scale.set(gameScale.y, gameScale.y);
                discordAvatar.updateHitbox();
            }
        }
        else {
			discordAvatar.loadGraphic(getImage("nullAvatar"));
			discordAvatar.scale.set(gameScale.y, gameScale.y);
            discordAvatar.updateHitbox();
        }

        discordAvatar.shader = new CustomShader("spriteSphereBounds");
        discordAvatar.shader.uRadius = 0.5;
		discordAvatar.shader.uCenter = [discordAvatar.width / 2 / gameScale.y, discordAvatar.height / 2 / gameScale.y];
		discordAvatar.camera = mainCamera;
    }

	if (isMobile && !deadVersion) {
        lightThing.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
    } else if (discordIntegration && !deadVersion) {
		discordUsername = new FunkinText(0, 0, 0, "", 32 * gameScale.y);
		discordUsername.borderSize = 3.4 * gameScale.y;
        discordUsername.font = Paths.font("pixeloidsans.ttf");

        if (DiscordUtil.ready) {
            lightThing.color = 0xFF43A25A;
            lightGlow.color = 0xFF43A25A;
            discordUsername.text = DiscordUtil.user.globalName;
            discordUsername.color = FlxColor.WHITE;
        } else {
            lightThing.color = 0xFF333333;
            lightGlow.color = 0xFF333333;
            lightGlow.visible = false;
            lightLight.visible = false;
            discordUsername.text = "Disconnected";
            discordUsername.color = FlxColor.GRAY;
        }

        discordUsername.fieldWidth = discordUsername.width + 40;
        discordUsername.alignment = "center";
		discordUsername.setPosition(discordAvatar.x + discordAvatar.width, topLeft.y + 5 * baseScale);
        discordUsername.camera = mainCamera;
    } else if (!deadVersion) {
        lightThing.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
    } else {
		lightThing.color = 0xFF333333;
		lightGlow.color = 0xFF333333;
		lightGlow.visible = false;
		lightLight.visible = false;
    }

    topButtonsGroup = new FlxSpriteGroup();
	topButtonsGroup.camera = mainCamera;

	statsButton = new TopButton("stats", topRight.x + topRight.width, topLeft.y + topLeft.height);
    statsButton.scale.set(baseScale, baseScale);
    statsButton.updateHitbox();
    statsButton.x -= statsButton.width + 8 * baseScale;
    statsButton.y -= statsButton.height + 2 * baseScale;
	statsButton.onPress = statsMenu;
    topButtonsGroup.add(statsButton);

    if (!isMobile) {
		var discordButton:TopButton;
		if (discordIntegration && !deadVersion) {
			discordButton = new TopButton("discord", statsButton.x - statsButton.width - 4 * baseScale, statsButton.y);
			discordButton.scale.set(baseScale, baseScale);
			discordButton.updateHitbox();
			topButtonsGroup.add(discordButton);
		}

        if (Options.devMode) {
			var xPos:Float = (discordButton != null) ? discordButton.x - discordButton.width : statsButton.x - statsButton.width;
			var yPos:Float = (discordButton != null) ? discordButton.y : statsButton.y;
			var debugButton:TopButton = new TopButton("debug", xPos - 4 * baseScale, yPos);
            debugButton.scale.set(baseScale, baseScale);
            debugButton.updateHitbox();
			debugButton.onPress = debugShit;
            topButtonsGroup.add(debugButton);
        }
    }

    var title:FlxSprite = new FlxSprite(3 * baseScale, (topShadowL.y + topShadowL.height) + 2 * baseScale).loadGraphic(getImage("title"));
    title.scale.set(baseScale, baseScale);
    title.updateHitbox();
	title.camera = mainCamera;
	title.visible = !deadVersion;
    add(title);

	var buttonsBack:FlxSprite = new FlxSprite(2 * baseScale, (title.y + title.height) + 2 * baseScale).loadGraphic(getImage("buttonsBack"));
    buttonsBack.scale.set(baseScale, baseScale);
    buttonsBack.updateHitbox();
	buttonsBack.camera = mainCamera;

	var buttonsBackShadow:FlxSprite = new FlxSprite(buttonsBack.x - 1 * baseScale, buttonsBack.y + 3 * baseScale).loadGraphic(getImage("buttonsBack-shadow"));
    buttonsBackShadow.scale.set(baseScale, baseScale);
    buttonsBackShadow.updateHitbox();
	buttonsBackShadow.blend = getBlendMode("multiply");
	buttonsBackShadow.camera = mainCamera;

    add(buttonsBackShadow);
    add(buttonsBack);

	var divisionThing:FlxSprite = new FlxSprite(buttonsBack.x + 4 * baseScale, buttonsBack.y + 46 * baseScale).loadGraphic(getImage("buttonsDivision"));
    divisionThing.scale.set(baseScale, baseScale);
    divisionThing.updateHitbox();
	divisionThing.camera = mainCamera;
    add(divisionThing);

    var buttonsXPos:Float = buttonsBack.x + 3 * baseScale * 2;
	var buttonsYPos:Float = buttonsBack.y + 3 * baseScale * 2;

	mainButtons = new FlxSpriteGroup(buttonsXPos, buttonsYPos);
    mainButtons.camera = mainCamera;
	add(mainButtons);

	createMainSectionButtons();

    var version:FunkinText = new FunkinText(buttonsBack.x, buttonsBack.y + buttonsBack.height + 2 * baseScale, buttonsBack.width, translate("version", [MOD_VERSION]) /*+ '\nCodename Version: ' + Main.releaseVersion*/, 18 * gameScale.y);
    version.font = Paths.font("pixeloidsans.ttf");
    version.alignment = "center";
	version.borderSize = 2.2 * gameScale.y;
    version.color = 0xFFBFBFBF; // lol
	version.camera = mainCamera;
	version.visible = !deadVersion;
    add(version);

    var windowBorderLeft:FlxSprite = new FlxSprite((buttonsBack.x + buttonsBack.width) + 2 * baseScale, (topLeft.y + topLeft.height) + 3 * baseScale).loadGraphic(getImage("windowBorder-left"));
    windowBorderLeft.scale.set(baseScale, baseScale);
    windowBorderLeft.updateHitbox();
	windowBorderLeft.camera = mainCamera;

    var windowBorderDistance:Int = FlxMath.distanceToPoint(windowBorderLeft, FlxPoint.get(FlxG.width, windowBorderLeft.y));
    var windowBorderMiddle:FlxSprite = new FlxSprite(windowBorderLeft.x + windowBorderLeft.width, windowBorderLeft.y).loadGraphic(getImage("windowBorder-middle"));
    windowBorderMiddle.scale.set(windowBorderDistance, baseScale);
    windowBorderMiddle.updateHitbox();
    windowBorderMiddle.camera = mainCamera;

    var windowBorderShadowL:FlxSprite = new FlxSprite(windowBorderLeft.x - 1 * baseScale, windowBorderLeft.y + 5 * baseScale).loadGraphic(getImage("windowBorder-shadow-left"));
    windowBorderShadowL.scale.set(baseScale, baseScale);
    windowBorderShadowL.updateHitbox();
	windowBorderShadowL.blend = getBlendMode("multiply");
    windowBorderShadowL.camera = mainCamera;

    var windowShadowDistance:Int = FlxMath.distanceToPoint(windowBorderShadowL, FlxPoint.get(FlxG.width, windowBorderShadowL.y));
    var windowBorderShadowM:FlxSprite = new FlxSprite(windowBorderShadowL.x + windowBorderShadowL.width, windowBorderShadowL.y).loadGraphic(getImage("windowBorder-shadow-middle"));
    windowBorderShadowM.scale.set(windowShadowDistance, baseScale);
    windowBorderShadowM.updateHitbox();
	windowBorderShadowM.blend = getBlendMode("multiply");
    windowBorderShadowM.camera = mainCamera;

    var spaceHpos:Float = windowBorderLeft.x + 8 * baseScale;
    var spaceVpos:Float = windowBorderLeft.y + 8 * baseScale;
    var spaceWidth:Int = Std.int(FlxG.width - spaceHpos);
    var spaceHeight:Int = Std.int(112 * baseScale - 8 * baseScale * 2);
	windowArea = new FlxRect(spaceHpos, spaceVpos, spaceWidth, spaceHeight);

	spaceCamera.setPosition(windowArea.x, windowArea.y);
	spaceCamera.setSize(windowArea.width, windowArea.height);
	starField.setBounds(spaceCamera.x, spaceCamera.y, spaceCamera.width, spaceCamera.height);

	spaceGroup = new FlxSpriteGroup();
	spaceGroup.camera = spaceCamera;
	add(spaceGroup);

	var windowShine:FlxSprite = new FlxSprite().loadGraphic(getImage("window-shine"));
    windowShine.scale.set(baseScale, baseScale);
    windowShine.updateHitbox();
    windowShine.blend = getBlendMode("add");
    windowShine.alpha = 0.15;
	windowShine.x = windowArea.width * (windowArea.width / 1280) * 0.4;
	windowShine.camera = spaceCamera;
    windowShine.scrollFactor.set(0, 0);
	add(windowShine);

	windowMenu = new WindowSubMenuHandler(spaceCamera);
	add(windowMenu);

	add(windowBorderShadowM);
	add(windowBorderShadowL);
	add(windowBorderMiddle);
	add(windowBorderLeft);

	add(topShadowM);
	add(topShadowL);
	add(topShadowR);
	add(topMiddle);
	add(topLeft);
	add(topRight);
	if (discordAvatar != null) add(discordAvatar);
	if (discordUsername != null) add(discordUsername);
	add(lightGlow);
	add(lightThing);
	add(lightLight);
	add(topButtonsGroup);

	if (deadVersion) {
		var grayShader:CustomShader = new CustomShader("grayscale");
		grayShader._amount = 1;

		bgLeft.shader = grayShader;
		bgRight.shader = grayShader;
		bgMiddle.shader = grayShader;
		buttonsBack.shader = grayShader;
		windowBorderLeft.shader = grayShader;
		windowBorderMiddle.shader = grayShader;
	}

    exitPrompt = new ExitPrompt();
    exitPrompt.onOpen = disableInput;
    exitPrompt.onClose = enableInput;

	if (globalUsingKeyboard)
	    changeMainEntry(0);
}

function createMainSectionButtons(?x:Float, ?y:Float) {
    var xPos:Float = x ?? 0;
    var yPos:Float = y ?? 0;
	for (i => buttonData in mainSectionButtons) {
        if (i >= 7) return;

		var button:MainMenuButton = new MainMenuButton(i, xPos, yPos, buttonData);
		mainButtons.add(button);

        if (deadVersion) {
			button.hideIcon = true;
            button.greyscale = true;
        }

        if (i < 5) {
			yPos += button.height + baseScale + 1;
			if (i == 2) yPos += 3 * baseScale;
        }
        else
			xPos += button.width + 2 * baseScale + 1;
    }
}

function postCreate() {
    var backBtnScale:Float = isMobile ? 4 : 3;
    backButton = new BackButton(FlxG.width * 0.975, FlxG.height, goBack2Title, backBtnScale);
    backButton.visible = !globalUsingKeyboard;
    backButton.x -= backButton.width;
    backButton.y -= backButton.height * 1.1;
    backButton.camera = mainCamera;
    add(backButton);

    backButton.onConfirm.add(disableInput);

	FlxG.mouse.visible = !globalUsingKeyboard;
    if (isMobile) FlxG.mouse.visible = false;
}

function statsMenu() {
	playMenuSound("select", 1);
	openSubState(new ModSubState("impostorStatsMenuSubState"));
}

function modSubState() {
	playMenuSound("select", 1);
	openSubState(new ModSwitchMenu());
}

var debugOptions:Array<Array<Dynamic>> = [
    {
        name: "Chart Editor",
        image: Paths.image("editors/icons/chart"),
		smellect: function() {
			FlxG.switchState(new CharterSelection());
		},
        transition: "right2leftSharpCircle"
    },
    {
        name: "Character Editor",
        image: Paths.image("editors/icons/character"),
		smellect: function() {
			FlxG.switchState(new CharacterSelection());
		},
        transition: "right2leftSharpCircle"
    },
    {
        name: "Stage Editor",
        image: Paths.image("editors/icons/stage"),
        smellect: function() {
			FlxG.switchState(new StageSelection());
        },
        transition: "right2leftSharpCircle"
    }
];
function debugShit() {
	playMenuSound("select", 1);
    var window:WindowSubMenu = new WindowSubMenu("Developer Tools");

    var yPos:Float = 0;
    for (i => debug in debugOptions) {
        var piss:WindowButton = new WindowButton(windowArea, 0, yPos, {
            image: null,
            width: windowArea.width,
            height: windowArea.height / 8
        });
        piss.index.set(0, i);
        piss.idleColor = 0xFFAAAAAA;
        piss.hoverColor = 0xFFFFFFFF;
        piss.addLabel(debug.name, FlxPoint.get(4, 1.5));
		piss.onSelect = function() {
            if (FlxG.sound.music != null) FlxG.sound.music.fadeOut();

            playMenuSound("confirm");

            new FlxTimer().start(1, _ -> {
                // does destroy() even work????
                FlxG.sound.music.destroy();
                FlxG.sound.music = null;
                debug.smellect();
            });
        };
		window.add(piss);

		yPos += piss.height;
    }

    if (window.members[window.getLength() - 1].y + window.members[window.getLength() - 1].height > windowArea.height) {
		window.customUpdate = function(elapsed:Float) {
			var windowCamera:FlxCamera = window._parent.windowCamera;
			windowCamera.minScrollY = 0;
			windowCamera.maxScrollY = window.members[window.getLength() - 1].y + window.members[window.getLength() - 1].height;
			windowCamera.scroll.y += -FlxG.mouse.wheel * elapsed * 2000;
		};
    }

	openWindowSubMenu(window);
}

var allowInput:Bool = true;
function update(elapsed:Float) {
	if (!allowInput) return;

	if (globalUsingKeyboard) {
		handleKeyboard(elapsed);
        return;
    }

	handlePointer();
    if (isMobile)
        handleTouch();
    else
        handleMouse();
}

function postUpdate(elapsed:Float) {
    if (exitPrompt.isOpen)
        handleExitPromptInput();

	if (!isBelowStoryPoint("menuRevival") && foundCrew.length > 0)
        floatSus();
}

// main, window
//var currentSelectionMode:String = "main";

var curMainEntry:Int = 0;
var lastMainEntry:Int = -1;
var curWindowEntry:Array<Int> = [0, 0];
var lastWindowEntry:Array<Int> = [-1, -1];

var holdTimer:Float = 0;
var maxHeldTime:Float = 0.5;
var frameDelayer:Int = 0;
var maxDelay:Int = 2;
function handleKeyboard(elapsed:Float) {
    if (FlxG.keys.justPressed.ANY)
		useKeyboard();

	if (curSelectionMode == SelectionMode.MAIN) {
        if (controls.UP_P)
            changeMainEntry(-1);
        if (controls.DOWN_P)
            changeMainEntry(1);

        if (controls.UP) {
            if (holdTimer >= maxHeldTime) {
                if (frameDelayer >= maxDelay) {
                    changeMainEntry(-1);
                    frameDelayer = 0;
                }
                else {
                    frameDelayer++;
                }
            }
            else
                holdTimer += elapsed;
        }
        else if (controls.DOWN) {
            if (holdTimer >= maxHeldTime)
                if (frameDelayer >= maxDelay) {
                    changeMainEntry(1);
                    frameDelayer = 0;
                }
                else {
                    frameDelayer++;
                }
            else
                holdTimer += elapsed;
        }
        else {
            frameDelayer = 0;
            holdTimer = 0;
        }

        if (controls.SWITCHMOD)
            statsMenu();

        if (controls.ACCEPT)
            selectMain();

        if (controls.BACK)
            goBack2Title();
    }
	else if (curSelectionMode == SelectionMode.WINDOW) {
        /*
        if (controls.UP_P)
            changeWindowEntry(-1, 0);
        if (controls.DOWN_P)
            changeWindowEntry(1, 0);
        if (controls.LEFT_P)
            changeWindowEntry(0, -1);
        if (controls.RIGHT_P)
            changeWindowEntry(0, 1);

        if (controls.ACCEPT)
            checkSelectedWindowEntry();
        */

        if (controls.BACK)
            closeWindowSection();
    }
}

function useKeyboard() {
    backButton.visible = false;
    FlxG.mouse.visible = false;
}

var isOverButton:Bool = false;
function handleMouse() {
	if (pointerDoesAnything())
        FlxG.mouse.visible = true;

    if (!FlxG.mouse.visible) return;
	if (globalUsingKeyboard) return;

    if (isOverButton)
        setMouseCursor("button");
    else
		setMouseCursor();
}

function handleTouch() {
    // only available on real mobile
    if (FlxG.onMobile) {
        if (FlxG.android.justReleased.BACK)
            goBack2Title();
    }
}

function handlePointer() {
	if (pointerDoesAnything()) {
		holdTimer = 0;
		if (curSelectionMode == SelectionMode.MAIN)
			backButton.visible = true;
    }

    isOverButton = false;

	if (curSelectionMode == SelectionMode.MAIN) {
		handleMainButtons();
		//handleTopButtons();
	}
	else if (curSelectionMode == SelectionMode.WINDOW)
		handleWindow();

    /*
    if (isOverButton) {
		if (curSelectionMode == SelectionMode.MAIN) {
			if (pointerJustReleased())
                checkSelectedMainEntry();
        }
		else if (curSelectionMode == SelectionMode.WINDOW) {
			if (pointerJustReleased())
                checkSelectedWindowEntry();
        }
    }
    else {
        lastMainEntry = -1;
        lastWindowEntry[0] = -1;
        lastWindowEntry[1] = -1;
    }
    */
}

function handleMainButtons() {
	if (curSelectionMode != SelectionMode.MAIN) return;

    mainButtons.forEach(function(button) {
		if (button != null && button.enabled)
            button.updateButton();

		if (button.isHovered)
            isOverButton = true;
    });
}

function handleExitPromptInput() {
    if (globalUsingKeyboard) {
        FlxG.mouse.visible = false;

        if (controls.LEFT_P)
            exitPrompt.pressedLeft();
		if (controls.RIGHT_P)
			exitPrompt.pressedRight();

        if (controls.ACCEPT)
			exitPrompt.pressedConfirm();

        return;
    }

	FlxG.mouse.visible = true;
	exitPrompt.updatePointer();
}

function playSoundMain() {
    if (curMainEntry != lastMainEntry) {
        playMenuSound("scroll");
        lastMainEntry = curMainEntry;
    }
}

function playSoundWindow() {
    if (curWindowEntry[0] != lastWindowEntry[0] || curWindowEntry[1] != lastWindowEntry[1]) {
        playMenuSound("scroll");
        lastWindowEntry[0] = curWindowEntry[0];
        lastWindowEntry[1] = curWindowEntry[1];

        //trace("Column Pos: "+curWindowEntry[0],"Row Pos: "+curWindowEntry[1]);
    }
}

function changeMainEntry(change:Int) {
	curMainEntry = FlxMath.wrap(curMainEntry + change, 0, mainButtons.length - 1);

	if (!mainButtons.members[curMainEntry].isAvailable()) {
        changeMainEntry(change);
        return;
    }

    playSoundMain();

	mainButtons.forEach(function(button) {
        button.checkPosition(curMainEntry);
    });
}

function changeWindowEntry(changeColumn:Int, changeRow:Int) {
    curWindowEntry[0] = FlxMath.wrap(curWindowEntry[0] + changeColumn, 0, curWindow.length - 1);
    curWindowEntry[1] = FlxMath.wrap(curWindowEntry[1] + changeRow, 0, curWindow[curWindowEntry[0]].length - 1);

    if (!curWindow[curWindowEntry[0]][curWindowEntry[1]].available) {
        changeWindowEntry(changeColumn, changeRow);
        return;
    }

    playSoundWindow();
}

function selectMain() {
	mainButtons.forEach(function(button) {
		button.checkSelected(curMainEntry);
	});
}

function checkSelectedMainEntry() {
    playMenuSound("confirm");

    disableInput();

    FlxFlicker.flicker(buttonsMainGroup.members[curMainEntry], 1, 0.05, true, true);
    FlxFlicker.flicker(buttonsLabelGroup.members[curMainEntry], 1, 0.05, true, true);
    if (buttonsIconGroup.members[curMainEntry] != null) FlxFlicker.flicker(buttonsIconGroup.members[curMainEntry], 1, 0.05, true, true);
}

function openWindowSubMenu(subMenu:WindowSubMenu) {
	FlxG.inputs.onStateSwitch();
	curSelectionMode = SelectionMode.WINDOW;
    backButton.visible = false;

	windowMenu.open(subMenu);
    //windowMenu.onOpen = enableInput;
	windowMenu.onClose = closeWindowSection;

	FlxG.mouse.visible = !globalUsingKeyboard;
}

function handleWindow() {
	windowMenu.curSubMenu.forEach(function(button) {
		if (button.isHovered)
            isOverButton = true;
    });
}

function closeWindowSection() {
	if (windowMenu.isOpen)
		windowMenu.close(false);

	backButton.visible = !globalUsingKeyboard;

    enableInput();

	FlxG.inputs.onStateSwitch();
	curSelectionMode = SelectionMode.MAIN;
}

function checkSelectedWindowEntry() {
    if (curWindow == null) return;

    disableInput();

    var trans:String = "";
    try {
        trans = curWindow[curWindowEntry[0]][curWindowEntry[1]].transition;
    }
    catch(e:Dynamic) {
        trans = "closingSharpCircle";
    }

    setTransition(trans);
    curWindowChooseBehaviour();
}

function floatSus() {}

function shutdownDiscordRPC() {
    DiscordUtil.shutdown();
    DiscordUtil.ready = false;
    updateDiscordUserStatus(false);
}

var connecting:Bool = false;
function initDiscordRPC() {
    DiscordUtil.currentID = "-1";
    DiscordUtil.init();
    discordUsername.fieldWidth = 0;
    discordUsername.text = "Connecting to Discord...";
    discordUsername.color = FlxColor.GRAY;
    discordUsername.fieldWidth = discordUsername.width + 40;

    connecting = true;
    new FlxTimer().start(5, _ -> {
        connecting = false;
        updateDiscordUserStatus(true);
    });
}

function updateDiscordUserStatus(fetchInfo:Bool) {
    function fail(?error) {
		discordAvatar.loadGraphic(getImage("nullAvatar"));
		discordUsername.fieldWidth = 0;
		discordUsername.text = "Disconnected";
		discordUsername.color = FlxColor.GRAY;
		discordUsername.fieldWidth = discordUsername.width + 40;
		lightThing.color = 0xFF333333;
		lightGlow.color = 0xFF333333;
		lightGlow.visible = false;
		lightLight.visible = false;

        if (error != null)
            logTraceErrorState("Discord", 'Error while trying to fetch Discord User information (Error log: "' + error + '")');
    }

    if (fetchInfo && DiscordUtil.ready) {
        try {
            discordAvatar.loadGraphic(DiscordUtil.user.getAvatar(64));
			discordUsername.fieldWidth = 0;
			discordUsername.text = DiscordUtil.user.globalName;
			discordUsername.color = FlxColor.WHITE;
			discordUsername.fieldWidth = discordUsername.width + 40;
			lightThing.color = 0xFF43A25A;
			lightGlow.color = 0xFF43A25A;
			lightGlow.visible = true;
			lightLight.visible = true;

			changeDiscordMenuStatus("Main Menu");
        }
        catch (e:Dynamic) {
			throw fail(e);
        }
    }
    else
        fail();
}

function onOpenSubState(event) {
    disableInput();
	persistentUpdate = persistentDraw = true;
}

function onCloseSubstate() {
    changeDiscordMenuStatus("Main Menu");
    enableInput();
}

function enableInput() {
	allowInput = true;
    backButton.enabled = true;
	windowMenu.enabled = true;
	setMouseCursor();
	enableMainButton(true);
	topButtonsGroup.forEach(function(button) button.enabled = true);
}

function disableInput() {
	allowInput = false;
    backButton.enabled = false;
    windowMenu.enabled = false;
    setMouseCursor();
    enableMainButton(false);
    topButtonsGroup.forEach(function(button) button.enabled = false);
}

function enableMainButton(enable:Bool) {
    if (curSelectionMode != SelectionMode.MAIN) return;

    if (mainButtons != null) {
		mainButtons.forEach(function(button) {
			button.enabled = enable;
		});
	}
}

function goBack2Title() {
    setTransition("fadeUp");
    FlxG.switchState(new ModState("impostorTitleState"));
}

function destroy() {
    mainButtons.destroy();
    topButtonsGroup.destroy();
    //statsHint.destroy();

    // discord stuff
	if (!isMobile && discordIntegration && !deadVersion) {
        discordAvatar.destroy();
        discordUsername.destroy();
    }

	lightThing.destroy();
	lightGlow.destroy();
	lightLight.destroy();

	windowMenu.destroy();
    backButton.destroy();

	mainCamera.destroy();
	spaceCamera.destroy();
}

enum ButtonState {
    IDLE;
    HOVER;
    SELECTED;
    BLOCKED;
}

class MainMenuButton extends MusicBeatGroup {
	public var button:FunkinSprite;

    public var label:FunkinText;

	public var icon:FunkinSprite;

	public var type(default, null):ButtonType;

	public var onSelect(default, null):Void->Void;

	public var hideIcon(default, set):Bool;

    public var greyscale(default, set):Bool;

    public var enabled:Bool = true;

    public var isHovered(default, null):Bool = false;

	var _position:Int = 0;

	var _available:Bool;

    var _selectColor:FlxColor;

    var _idleColor:FlxColor;

    var _blockedColor:FlxColor = FlxColor.BLACK;

    var _state:ButtonState = ButtonState.IDLE;

    var _flickerTimer:Float = 1;

	public function new(position:Int, x:Float, y:Float, data:Array<Dynamic>) {
        super(x, y);

        _position = position;
        _available = data.available ?? true;
		this.type = data.type ?? ButtonType.MAIN;

        this.onSelect = data.onSelect ?? null;

        var offsets:Array<Int> = data.offset ?? [0, 0];

        switch(this.type) {
			case ButtonType.MAIN:
				createMainButton(data.name, data.icon, data.scale, FlxPoint.get(offsets[0], offsets[1]));
			case ButtonType.EXTRAS:
				createExtrasButton(data.name, data.icon, data.scale, FlxPoint.get(offsets[0], offsets[1]));
			case ButtonType.OTHERS:
				createOthersButton(data.name, data.icon, data.scale, FlxPoint.get(offsets[0], offsets[1]));
        }

		this.greyscale = false;
		this.hideIcon = false;
    }

    public function destroy() {
		button.destroy();
        label.destroy();

        if (icon != null)
            icon.destroy();

		onSelect = null;
    }

    public function isAvailable():Bool
		return _available;

    public function updateButton() {
        if (!enabled || !isAvailable()) return;

		if (_state == ButtonState.BLOCKED || _state == ButtonState.SELECTED) return;

		var overlaps:Bool = pointerOverlaps(this);

		if (overlaps && _state == ButtonState.IDLE)
            hover();

        if (overlaps && _state == ButtonState.HOVER && pointerJustReleased())
            select();

		if (!overlaps && _state != ButtonState.IDLE)
            goIdle();
    }

    public function checkPosition(position:Int) {
        if (!enabled || !isAvailable()) return;

        if (position == _position)
            hover();
        else
            goIdle();
    }

    public function checkSelected(position:Int) {
		if (!enabled || !isAvailable()) return;

		if (position == _position)
			select();
    }

    public function hover() {
        _state = ButtonState.HOVER;
		playMenuSound("scroll");

        isHovered = true;

        button.playAnim("hover");
		label.color = _selectColor;
    }

    public function goIdle() {
		_state = ButtonState.IDLE;

		isHovered = false;

		button.playAnim("idle");
		label.color = _idleColor;
    }

	public function select() {
		_state = ButtonState.SELECTED;
		playMenuSound("confirm");

		isHovered = false;

		if (!hideIcon && icon != null && icon.active && icon.exists)
            FlxFlicker.flicker(icon, _flickerTimer, 0.05, true, true);

		FlxFlicker.flicker(label, _flickerTimer, 0.05, true, true);
		FlxFlicker.flicker(button, _flickerTimer, 0.05, true, true, _ -> {
            _state = ButtonState.HOVER;
        });

		if (onSelect != null)
            onSelect();
    }

	function createMainButton(name:String, iconPath:String, scale:Float, offset:FlxPoint) {
		_idleColor = 0xFF0A3C33;
		_selectColor = 0xFF10584B;

		button = new FunkinSprite().loadGraphic(getImage("mainButton"), true, 90, 12);
		button.animation.add("idle", [0], 0, false);
		button.animation.add("hover", [1], 0, false);
		button.animation.add("blocked", [2], 0, false);
		button.scale.set(scale, scale);
		button.updateHitbox();
		add(button);

		var labelPosition:Float = 4 * scale;
		label = new FunkinText(labelPosition, button.height / 2, button.width - labelPosition * 2, name, 32 * gameScale.y, false);
		label.font = Paths.font("pixeloidsans.ttf");
		label.color = _idleColor;
		label.alignment = "right";
		label.y -= label.height / 2;
		add(label);

		icon = new FunkinSprite(8 * scale).loadGraphic(iconPath);
		icon.scale.set(scale, scale);
		icon.updateHitbox();
		add(icon);

        if (iconPath == null) icon.kill();

        icon.x -= offset.x * scale;
        icon.y += offset.y * scale;

		if (!isAvailable()) {
			button.animation.play("blocked");

			label.color = _blockedColor;

			icon.color = 0xFF888888;
			icon.shader = new CustomShader("grayscale");
			icon.shader._amount = 1;

			_state = ButtonState.BLOCKED;
		}
    }

	function createExtrasButton(name:String, iconPath:String, scale:Float, offset:FlxPoint) {
		_idleColor = 0xFFAAE2DC;
		_selectColor = 0xFFFFFFFF;

		button = new FunkinSprite().loadGraphic(getImage("otherButton"), true, 90, 9);
		button.animation.add("idle", [0], 0, false);
		button.animation.add("hover", [1], 0, false);
		button.animation.add("blocked", [2], 0, false);
		button.scale.set(scale, scale);
		button.updateHitbox();
		add(button);

		var labelPosition:Float = 8 * scale;
		label = new FunkinText(labelPosition, button.height / 2, button.width - labelPosition * 2, name, 25 * gameScale.y, false);
		label.font = Paths.font("pixeloidsans.ttf");
		label.color = _idleColor;
		label.alignment = "right";
		label.y -= label.height / 2;
		add(label);

        if (iconPath != null) {
            icon = new FunkinSprite(6 * scale).loadGraphic(iconPath);
            icon.scale.set(scale, scale);
            icon.updateHitbox();
            add(icon);

            icon.x -= offset.x * scale;
		    icon.y += offset.y * scale;
        }

		if (!isAvailable()) {
			button.animation.play("blocked");

			label.color = _blockedColor;

			icon.color = 0xFF888888;
			icon.shader = new CustomShader("grayscale");
			icon.shader._amount = 1;

			_state = ButtonState.BLOCKED;
		}
    }

	function createOthersButton(name:String, iconPath:String, scale:Float, offset:FlxPoint) {
		_idleColor = 0xFFFFFFFF;
		_selectColor = _idleColor;

		button = new FunkinSprite().loadGraphic(getImage("lonelyButton"), true, 44, 6);
		button.animation.add("idle", [0], 0, false);
		button.animation.add("hover", [1], 0, false);
		button.animation.add("blocked", [2], 0, false);
		button.scale.set(scale, scale);
		button.updateHitbox();
		add(button);

		var labelPosition:Float = 4 * scale;
		label = new FunkinText(labelPosition, button.height / 2, button.width - labelPosition * 2, name, 18 * gameScale.y, false);
		label.font = Paths.font("pixeloidsans.ttf");
		label.color = _idleColor;
		label.alignment = "right";
		label.y -= label.height / 2;
		add(label);

        if (iconPath != null) {
			icon = new FunkinSprite(6 * scale).loadGraphic(iconPath);
			icon.scale.set(scale, scale);
			icon.updateHitbox();
			add(icon);

			icon.x -= offset.x * scale;
			icon.y += offset.y * scale;
        }

		if (!isAvailable()) {
			button.animation.play("blocked");

			label.color = _blockedColor;

			icon.color = 0xFF888888;
			icon.shader = new CustomShader("grayscale");
			icon.shader._amount = 1;

			_state = ButtonState.BLOCKED;
		}
	}

    function set_hideIcon(value:Bool):Bool {
        hideIcon = value;
		if (icon != null) icon.visible = !value;
        return value;
    }

    function set_greyscale(value:Bool):Bool {
        if (_state != ButtonState.BLOCKED) {
            greyscale = value;

            if (greyscale) {
				var gsShader:CustomShader = new CustomShader("grayscale");
				gsShader._amount = 1;

				button.shader = gsShader;
				label.shader = gsShader;

				if (!hideIcon && icon != null && icon.active && icon.exists)
					icon.shader = gsShader;
            }
            else {
                button.shader = null;
				label.shader = null;

                if (!hideIcon && icon != null && icon.active && icon.exists)
					icon.shader = null;
            }

			return greyscale;
        }
        else
            return greyscale = false;
    }
}

class TopButton extends FunkinSprite {
    public var onPress:Void->Void;

	public var enabled:Bool = true;

	public function new(button:String, ?x:Float, ?y:Float) {
        x ??= 0;
        y ??= 0;
        super(x, y);

        loadGraphic(getImage("topButtons/" + button + "Button"), true, 14, 14);
        animation.add("idle", [0], 0, false);
		animation.add("press", [1], 0, false);
    }

    override public function update(elapsed:Float) {
        if (!enabled) return;

		super.update(elapsed);

		var overlaps = pointerOverlaps(this);

		if (overlaps && pointerIsHolding())
            playAnim("press");

		if (overlaps && pointerJustReleased())
            press();

		if (!overlaps)
            playAnim("idle");
    }

    public function press() {
		playAnim("idle");
        if (onPress != null) onPress();
    }
}

enum SelectingPromtOption {
	NONE;
	YES;
	NO;
}

class ExitPrompt {
    public var isOpen(default, null):Bool = false;

    public var onOpen:Void->Void;

    public var onClose:Void->Void;

    var prompt:FlxSpriteGroup;

	var bg:FlxSprite;
	var promptBackground:ResizableUIBox;
	var promptText:FunkinText;
	var no:FunkinText;
	var yes:FunkinText;

    public function new() {}

    public function open() {
		if (prompt != null || isOpen) return;

		playMenuSound("cancel");

        prompt = new FlxSpriteGroup();
        prompt.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
        FlxG.state.add(prompt);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		prompt.add(bg);

		promptBackground = new ResizableUIBox(0, 0, 640, 180);
		promptBackground.screenCenter();
		prompt.add(promptBackground.box);

		var limits:Float = 4 * 4;
		promptText = new FunkinText(promptBackground.x + limits, promptBackground.y + promptBackground.height / 8, promptBackground.width - limits * 2, translate("mainMenu.exitPrompt"), 32, false);
		promptText.font = Paths.font("pixeloidsans.ttf");
		promptText.alignment = "center";
		prompt.add(promptText);

		no = new FunkinText(promptText.x + promptText.width / 6, promptText.y + promptBackground.height / 2, 100, translate("no"), 40, false);
		no.font = Paths.font("pixeloidsans.ttf");
		no.alignment = "center";
		no.alpha = 0.5;
		prompt.add(no);

		yes = new FunkinText(promptText.x + promptText.width / 2 + promptText.width / 6, no.y, 100, translate("yes"), 40, false);
		yes.font = Paths.font("pixeloidsans.ttf");
		yes.alignment = "center";
		yes.alpha = 0.5;
		prompt.add(yes);

        if (onOpen != null)
            onOpen();

		isOpen = true;
    }

    public function close() {
		if (prompt == null || !isOpen) return;

		playMenuSound("cancel");

		bg.destroy();
		promptBackground.destroy();
		promptText.destroy();
		no.destroy();
		yes.destroy();
        prompt.destroy();
        prompt = null;

        curSelection = SelectingPromtOption.NONE;
        _isHoveringSmth = false;

        if (onClose != null)
            onClose();

		isOpen = false;
    }

	var curSelection:SelectingPromtOption = SelectingPromtOption.NONE;
    public function pressedLeft() {
		if (curSelection == SelectingPromtOption.NO) return;

		playMenuSound("scroll");
		curSelection = SelectingPromtOption.NO;
		updateSelection();
    }

	public function pressedRight() {
        if (curSelection == SelectingPromtOption.YES) return;

		playMenuSound("scroll");
		curSelection = SelectingPromtOption.YES;
		updateSelection();
	}

	public function pressedConfirm()
        checkSelection();

	var _isHoveringSmth:Bool = false;
    public function updatePointer() {
		if (prompt == null && !isOpen) return;

		if (pointerOverlaps(no)) {
			if (!_isHoveringSmth) {
				_isHoveringSmth = true;
				playMenuSound("scroll");
				curSelection = SelectingPromtOption.NO;
				updateSelection();
			}
		}
        else if (pointerOverlaps(yes)) {
			if (!_isHoveringSmth) {
				_isHoveringSmth = true;
				playMenuSound("scroll");
				curSelection = SelectingPromtOption.YES;
				updateSelection();
			}
		}
        else {
			_isHoveringSmth = false;
			curSelection = SelectingPromtOption.NONE;
			updateSelection();
		}

		if (pointerJustReleased())
			checkSelection();
    }

	function updateSelection() {
		no.alpha = 0.5;
		yes.alpha = 0.5;

		if (curSelection == SelectingPromtOption.YES)
			yes.alpha = 1;
		if (curSelection == SelectingPromtOption.NO)
			no.alpha = 1;
	}

	function checkSelection() {
        switch(curSelection) {
            case SelectingPromtOption.YES:
                accept();
            case SelectingPromtOption.NO:
                decline();
        }
    }

	function accept() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut();

        playMenuSound("confirm");

		FlxG.cameras.list[FlxG.cameras.list.length - 1].fade();

		new FlxTimer().start(1.05, _ -> System.exit(0));
	}

	function decline()
        close();
}

class WindowSubMenuHandler extends FlxBasic {
    public var isOpen(default, null):Bool;

    public var titleText(default, null):FunkinText;

	public var closeButton(default, null):BackButton;

	public var curSubMenu(default, null):WindowSubMenu;

    public var enabled:Bool = true;

    public var onOpen:Void->Void;

    public var onClose:Void->Void;

    public var windowCamera:FlxCamera;

    var lineSprite:FlxSprite;

    var background:FlxSprite;

    var _mainRect:FlxRect;
	var _cameraRect:FlxRect;
    var _windowRect:FlxRect;
    var _subMenuRect:FlxRect;

    var _layout:Array<Int> = [];
    var _layoutWidth:Int = 0;
	var _layoutHeight:Int = 0;
	var _lastPosition:FlxPoint;
    var _position:FlxPoint;

    public function new(camera:FlxCamera) {
        super(0, 0);

        this.camera = camera;

		_position = FlxPoint.get();
		_lastPosition = FlxPoint.get(-1, -1);

		background = new FlxSprite().makeGraphic(camera.width, camera.height, 0xFF505050);
		background.alpha = 0.7;
        background.scrollFactor.set(0, 0);
        background.camera = this.camera;

		closeButton = new BackButton(baseScale, baseScale, close, baseScale, "menus/x", false, true);
		closeButton.scrollFactor.set(0, 0);
		closeButton.camera = this.camera;

		lineSprite = new FlxSprite(0, closeButton.y + closeButton.height + baseScale).makeGraphic(background.width, baseScale, FlxColor.WHITE);
		lineSprite.scrollFactor.set(0, 0);
		lineSprite.camera = this.camera;

		var titlePos:Float = 2 * baseScale;
		titleText = new FunkinText(titlePos, lineSprite.y / 2, background.width - titlePos * 2, "", 56 * gameScale.y, false);
		titleText.font = Paths.font("pixeloidsans.ttf");
		titleText.alignment = "right";
		titleText.scrollFactor.set(0, 0);
		titleText.y -= titleText.height / 2;
        titleText.camera = this.camera;

		_mainRect = new FlxRect(0, 0, camera.width, lineSprite.y + lineSprite.height);
		closeButton.clipRect = _mainRect;
		lineSprite.clipRect = _mainRect;
		titleText.clipRect = _mainRect;

		_cameraRect = new FlxRect(camera.x, camera.y, camera.width, camera.height);
        _windowRect = new FlxRect(camera.x, camera.y + _mainRect.height, camera.width, camera.height - _mainRect.height);

		_subMenuRect = new FlxRect(0, _mainRect.height, _mainRect.width, distanceBetweenFloats(_mainRect.y + _mainRect.height, camera.height));

        windowCamera = new FlxCamera(camera.x, camera.y + _subMenuRect.y, camera.width, _subMenuRect.height);
        windowCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.insert(windowCamera, FlxG.cameras.list.indexOf(this.camera) + 1, false);

        kill();
		isOpen = false;
    }

    override public function update(elapsed:Float) {
		if (!enabled || !isOpen) return;

        super.update(elapsed);

		background.update(elapsed);
		lineSprite.update(elapsed);
		titleText.update(elapsed);
		closeButton.update(elapsed);

		if (curSubMenu != null)
            curSubMenu.update(elapsed);
    }

	override public function draw() {
		if (!isOpen) return;

		super.draw();

        background.draw();
        lineSprite.draw();
        titleText.draw();
        closeButton.draw();

        if (curSubMenu != null)
            curSubMenu.draw();
	}

    public function open(subMenu:WindowSubMenu) {
		isOpen = true;

        if (curSubMenu != null) {
            curSubMenu.destroy();
            curSubMenu = null;
        }

		revive();

        if (subMenu != null) {
            curSubMenu = subMenu;
            curSubMenu.init(this);
            curSubMenu.camera = windowCamera;
			titleText.text = curSubMenu.name;
        }

        if (onOpen != null)
            onOpen();
    }

    public function close(?trigger:Bool) {
        isOpen = false;

        if (curSubMenu != null) {
            curSubMenu.destroy();
            curSubMenu = null;
        }

        windowCamera.scroll.set(0, 0);
        windowCamera.minScrollY = null;
        windowCamera.maxScrollY = null;

        kill();

        playMenuSound("cancel");

        trigger ??= true;
		if (onClose != null && trigger)
            onClose();
    }

    override public function revive() {
		background.revive();
		closeButton.revive();
		lineSprite.revive();
		titleText.revive();

		closeButton.reset();

        super.revive();
    }

    override public function kill() {
        background.kill();
		closeButton.kill();
		lineSprite.kill();
		titleText.kill();

        super.kill();
    }

    override public function destroy() {
        super.destroy();

		background.destroy();
		closeButton.destroy();
		lineSprite.destroy();
		titleText.destroy();

		if (curSubMenu != null)
			curSubMenu.destroy();
    }
}

class WindowSubMenu extends FunkinGroup {
    public var name:String;

    public var customUpdate:Float->Void;

	var _parent:WindowSubMenuHandler;

	var _deadzones:Array<FlxObject> = [];

    var _layoutWidth:Int = 0;
	var _layoutHeight:Int = 0;

	var _isHovering:Bool = false;

    public function new(name:String, ?width:Int, ?height:Int) {
        super();

        this.name = name;

        width ??= 0;
        height ??= 0;
		_layoutWidth = width;
		_layoutHeight = height;
    }

    public function addDeadzone(object:FlxObject) {
		CoolUtil.pushOnce(_deadzones, object);
    }

    override public function destroy() {
        super.destroy();
        _parent = null;
        _deadzones = [];
        customUpdate = null;
    }

	override public function update(elapsed:Float) {
		super.update(elapsed);

        if (customUpdate != null && pointerWithinBounds(_parent._windowRect))
            customUpdate(elapsed);

        if (globalUsingKeyboard) return;

        _isHovering = false;
        _overlapDeadzone = false;

        for (deadzone in _deadzones) {
            if (pointerOverlapsComplex(deadzone, _parent.windowCamera))
                _overlapDeadzone = true;
        }

        for (button in members) {
            if (isButtonDeadzone(button))
                continue;

			if (pointerOverlapsComplex(button, _parent.windowCamera) && button.available && !_overlapDeadzone) {
				_isHovering = true;
				_parent._position.copyFrom(button.index);
				if (_parent._position.x != _parent._lastPosition.x || _parent._position.y != _parent._lastPosition.y) {
					_parent._lastPosition.copyFrom(_parent._position);
					button.hover();
                }
            } else {
                button.goIdle();
            }

			if (_isHovering && pointerJustReleased())
				button.checkPosition(_parent._position.x, _parent._position.y);
        }

		if (!_isHovering) {
			_parent._position.set(-1, -1);
			_parent._lastPosition.set(-1, -1);
        }
	}

	override public function draw() {
        super.draw();
    }

    public function getLength():Int {
        var length:Int = 0;
        for (member in members) {
            if (!isButtonDeadzone(member))
                length++;
        }

        return length;
    }

	function init(parent:WindowSubMenuHandler) {
        if (parent == null)
			throw 'A "WindowSubMenuHandler" parent must be set!';

		_parent = parent;
		_parent._layoutWidth = this._layoutWidth;
		_parent._layoutHeight = this._layoutHeight;

        forEach((spr) -> {
            spr.camera = _parent.windowCamera;
        });
    }

    function isButtonDeadzone(button) {
        for (deadzone in _deadzones)
            if (button == deadzone) return true;
        return false;
    }
}

class WindowButton extends MusicBeatGroup {
    public var button(default, null):FunkinSprite;

    public var label(default, null):FunkinText;

    public var icon(default, null):FunkinSprite;

    public var onSelect:Void->Void;

    public var available(default, set):Bool = true;

    public var isHovered(default, null):Bool = false;

    public var hoverColor:FlxColor = FlxColor.WHITE;

    public var idleColor:FlxColor = FlxColor.BLACK;

    public var index:FlxPoint;

	var _enabled:Bool = true;

    var _idleOpacity:Float = 0.1;
	var _hoverOpacity:Float = 0.45;

    public function new(area:FlxRect, x:Float = 0, y:Float = 0, graphicData:{var image:Null<String>; var width:String; var height:String;}) {
		super(x, y);

		index = FlxPoint.get(-1, -1);

		button = new FunkinSprite();
        if (graphicData.image == null) {
			button.makeGraphic(graphicData.width, graphicData.height, FlxColor.WHITE);
			button.alpha = _idleOpacity;
        } else {
			button.loadGraphic(graphicData.image, true, graphicData.width, graphicData.height);
			button.animation.add("idle", [0], 0, false);
			button.animation.add("hover", [1], 0, false);
			button.animation.add("blocked", [2], 0, false);
			button.scale.set(baseScale, baseScale);
			button.updateHitbox();
        }
        add(button);
    }

    public function destroy() {
        button.destroy();
        if (label != null)
            label.destroy();

        onSelect = null;
    }

    var labelPosition:FlxPoint = FlxPoint.get();
    public function addLabel(label:String, ?position:FlxPoint, ?size:Float, ?limit:Float) {
        if (position == null)
			position = FlxPoint.get();

		labelPosition.copyFrom(position);

        size ??= 32;
        limit ??= 0;
		label = new FunkinText(labelPosition.x * baseScale, labelPosition.y * baseScale, 0, label, size * gameScale.y, false);
		label.font = Paths.font("pixeloidsans.ttf");
		label.color = available ? idleColor : FlxColor.BLACK;
		if ((labelPosition.x * baseScale + label.width) > (button.width - limit * baseScale)) {
			label.scale.x = (button.width - (labelPosition.x * baseScale * 1.5) - limit * baseScale) / (label.width + labelPosition.x * baseScale);
            label.updateHitbox();
        }
		if (label.y + label.height > button.height)
			label.y = button.height - label.height;

        add(label);
    }

    public function alignLabel(alignment:String) {
        if (alignment == "left") {
			label.x = button.x + labelPosition.x * baseScale;
        } else if (alignment == "right") {
			label.x = (button.x + button.width) - (labelPosition.x * baseScale) - label.width;
        }
    }

    public function hover() {
		if (!available || !_enabled) return;

		isHovered = true;
		if (button.hasAnim("hover"))
            button.playAnim("hover");
        else
			button.alpha = _hoverOpacity;

        playMenuSound("scroll");

		if (label != null)
			label.color = hoverColor;
    }

    public function goIdle() {
		if (!available || !_enabled)
			return;

		isHovered = false;
		if (button.hasAnim("idle"))
			button.playAnim("idle");
		else
			button.alpha = _idleOpacity;

		if (label != null)
			label.color = idleColor;
    }

    public function checkPosition(x:Int, y:Int) {
        if (x == index.x && y == index.y) {
            _enabled = false;

			playMenuSound("confirm");
            isHovered = false;

			if (label != null)
				FlxFlicker.flicker(label, 1, 0.05, true, true);

			FlxFlicker.flicker(button, 1, 0.05, true, true, _ -> {
                _enabled = true;
            });

            if (onSelect != null)
				onSelect();
        }
    }

    function set_available(value:Bool):Bool {
        available = value;

        if (!available) {
			button.playAnim("blocked");
            if (label != null)
				label.color = FlxColor.BLACK;
        } else {
			button.playAnim("idle");
			if (label != null)
				label.color = idleColor;
        }

		return available;
    }
}