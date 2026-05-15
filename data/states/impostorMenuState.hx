import flixel.effects.FlxFlicker;
import flixel.math.FlxRect;
import flixel.FlxBasic;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.Controls;
import funkin.backend.system.Flags;
import funkin.backend.MusicBeatGroup;
import funkin.editors.character.CharacterSelection;
import funkin.editors.charter.CharterSelection;
import funkin.editors.stage.StageSelection;
import funkin.menus.ModSwitchMenu;
import funkin.options.Options;
import funkin.options.OptionsMenu;
import funkin.options.PlayerSettings;
import impostor.menus.mainmenu.MainMenuButton;
import impostor.menus.mainmenu.MainMenuButton.MainMenuButtonType;
import impostor.menus.mainmenu.ExitPrompt;
import impostor.menus.mainmenu.TopButton;
//import impostor.menus.mainmenu.WindowSubMenuHandler;
//import impostor.menus.mainmenu.WindowSubMenu;
import impostor.utils.FunkinMath;
import impostor.BackButton;
import impostor.StarsBackdrop;
import FunkinGroup;

var deadVersion:Bool = false; //isBelowStoryPoint("menuRevival");

enum SelectionMode {
    MAIN;
    WINDOW;
}

enum MainMenuButtonTriggerType {
	OPEN_WINDOW;
	OPEN_SUBSTATE;
	SWITCH_STATE;
	CUSTOM;
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

var lightBulb:FlxSprite;
var lightGlow:FlxSprite;
var lightBulbOverlay:FlxSprite;

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
		type: MainMenuButtonType.MAIN,
		triggerType: MainMenuButtonTriggerType.OPEN_WINDOW,
		onSelect: function(state:ModState)
		{
			var worldmapImage:String = getImage("bigButtons/worldmap-dead"); // deadVersion ? getImage("bigButtons/worldmap-dead") : getImage("bigButtons/worldmap");
			var worldmapText:String = translate("questionMarks"); // deadVersion ? (isBelowStoryPoint("postLobby") ? translate("questionMarks") : translate("mainMenu.sections.worldmap")) : translate("mainMenu.sections.worldmap");
			var freeplayImage:String = deadVersion ? getImage("bigButtons/freeplay-dead") : getImage("bigButtons/freeplay");
			var freeplayText:String = deadVersion ? translate("questionMarks") : translate("generic.freeplay");
			var tutorialImage:String = deadVersion ? getImage("bigButtons/tutorial-dead") : getImage("bigButtons/tutorial");

			var window:WindowSubMenu = new WindowSubMenu(translate("generic.play"));

			var worldmapButton:WindowButton = new WindowButton(windowArea, windowArea.width / 2, 3 * baseScale, {
				image: worldmapImage,
				width: 56,
				height: 55
			});
			worldmapButton.x -= worldmapButton.width + 0.5 * baseScale;
			worldmapButton.index.set(0, 0);
			worldmapButton.idleColor = deadVersion ? 0xFF313131 : 0xFF0A3C33;
			worldmapButton.hoverColor = deadVersion ? 0xFF484848 : 0xFF10584B;
			worldmapButton.available = false; // !isBelowStoryPoint("postTutorial");
			worldmapButton.addLabel(worldmapText, FlxPoint.get(0, 43.5));
			FunkinMath.objectCenter(worldmapButton.label, worldmapButton.button, FlxAxes.X);
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
			freeplayButton.available = true; // !deadVersion;
			freeplayButton.addLabel(freeplayText, FlxPoint.get(0, 43.5));
			freeplayButton.onSelect = function() {
				disableInput();
				new FlxTimer().start(1, _ -> FlxG.switchState(new FreeplayState()));
			};
			FunkinMath.objectCenter(freeplayButton.label, freeplayButton.button, FlxAxes.X);
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
			FunkinMath.objectCenter(tutorialButton.label, tutorialButton.button, FlxAxes.X);
			window.add(tutorialButton);

			return window;
        }
    },
    {
        name: translate("generic.achievements"),
		available: false,
        icon: getImage("icons/achievements"),
		iconOffsets: [4, 0],
		scale: baseScale,
		type: MainMenuButtonType.MAIN,
		triggerType: MainMenuButtonTriggerType.SWITCH_STATE,
		onSelect: function(state:ModState)
		{
			return new ModState("impostorAchievementsState");
        }
    },
    {
        name: translate("generic.shop"),
		available: false,
		icon: getImage("icons/shop"),
		iconOffsets: [1, 1],
		scale: baseScale,
		type: MainMenuButtonType.MAIN,
		triggerType: MainMenuButtonTriggerType.SWITCH_STATE,
		onSelect: function(state:ModState)
		{
			return new ModState("impostorShopState");
		}
    },
	{
		name: translate("generic.options"),
		available: true,
		icon: getImage("icons/options"),
		scale: baseScale,
		type: MainMenuButtonType.EXTRA,
		triggerType: MainMenuButtonTriggerType.SWITCH_STATE,
		onSelect: function(state:ModState)
		{
			return new OptionsMenu();
        }
	},
	{
		name: translate("generic.extras"),
		available: true,
		icon: getImage("icons/credits"),
		scale: baseScale,
		type: MainMenuButtonType.EXTRA,
		triggerType: MainMenuButtonTriggerType.OPEN_WINDOW,
		onSelect: function(state:ModState)
		{
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

			return window;
        }
	},
	{
		name: translate("generic.mods"),
		available: true,
		scale: baseScale,
		type: MainMenuButtonType.OTHER,
		triggerType: MainMenuButtonTriggerType.OPEN_WINDOW,
		onSelect: function(state:ModState)
		{
            var modsList:Array<String> = ModsFolder.getModsList();
            var window:WindowSubMenu = new WindowSubMenu(translate("generic.mods"));

            var reloadButton:BackButton = new BackButton(106 * baseScale, 58 * baseScale, function() {
				playMenuSound("cancel");
                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.5);
                setTransition("fade");
                ModsFolder.switchMod(ModsFolder.currentModFolder);
            }, baseScale, "menus/mainmenu/reload", false, true);
            reloadButton.scrollFactor.set();

            var unloadButton:BackButton = new BackButton(124 * baseScale, 58 * baseScale, function() {
				playMenuSound("cancel");
                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.5);
                setTransition("fade");
                ModsFolder.switchMod(null);
            }, baseScale, "menus/mainmenu/unload", false, true);
            unloadButton.scrollFactor.set();

            var yPos:Float = 0;
			var i:Int = 0;
            for (modName in modsList) {
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
				i++;
            }

			var lastMember:Int = window.getLength() - 1;

			if (window.members[lastMember].y + window.members[lastMember].height > windowArea.height) {
                window.customUpdate = function(elapsed:Float) {
					var windowCamera:FlxCamera = window._parent.windowCamera;
					windowCamera.minScrollY = 0;
					windowCamera.maxScrollY = window.members[lastMember].y + window.members[lastMember].height;
                    windowCamera.scroll.y += -FlxG.mouse.wheel * elapsed * 2000;

					if (windowCamera.scroll.y < 0)
						windowCamera.scroll.y = 0;

					if (windowCamera.scroll.y > windowCamera.maxScrollY - windowCamera.height)
						windowCamera.scroll.y = windowCamera.maxScrollY - windowCamera.height;
                };
            }

            window.add(reloadButton);
            window.addDeadzone(reloadButton);

            window.add(unloadButton);
            window.addDeadzone(unloadButton);

			return window;
        }
	},
	{
		name: translate("generic.exit"),
		available: true,
		scale: baseScale,
		type: MainMenuButtonType.OTHER,
		triggerType: MainMenuButtonTriggerType.CUSTOM,
        onSelect: function(state:ModState)
		{
			backButton.enabled = false;
			topButtonsGroup.forEach(function(button) button.enabled = false);
            exitPrompt.open();
        }
	}
];

var allButtonsArray:Array<Dynamic> = [];
var mainButtons:FlxGroup;

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
	add(starField);

	var bgLeft:FlxSprite = new FlxSprite().loadGraphic(getImage("bg-left"));
    bgLeft.scale.set(baseScale, baseScale);
    bgLeft.updateHitbox();
	bgLeft.camera = mainCamera;
	add(bgLeft);

	var bgRight:FlxSprite = new FlxSprite(FlxG.width).loadGraphic(getImage("bg-right"));
    bgRight.scale.set(baseScale, baseScale);
    bgRight.updateHitbox();
    bgRight.x -= bgRight.width;
	bgRight.camera = mainCamera;
	add(bgRight);

	var bgDistance:Float = FunkinMath.distanceBetweenFloats(bgLeft.x + bgLeft.width, bgRight.x);
	var bgMiddle:FlxSprite = new FlxSprite(bgLeft.x + bgLeft.width).loadGraphic(getImage("bg-middle"));
	bgMiddle.scale.set(baseScale, baseScale);
    bgMiddle.updateHitbox();
	bgMiddle.setGraphicSize(bgDistance, bgMiddle.height);
	bgMiddle.updateHitbox();
    bgMiddle.camera = mainCamera;
    add(bgMiddle);

	var topLeft:FlxSprite = new FlxSprite(1 * baseScale, 2 * baseScale).loadGraphic(getImage("top-left"));
    topLeft.scale.set(baseScale, baseScale);
    topLeft.updateHitbox();
    topLeft.camera = mainCamera;

	var topRight:FlxSprite = new FlxSprite(FlxG.width - 1 * baseScale, topLeft.y).loadGraphic(getImage("top-right"));
    topRight.scale.set(baseScale, baseScale);
    topRight.updateHitbox();
    topRight.x -= topRight.width;
    topRight.camera = mainCamera;

	var topDistance:Float = FunkinMath.distanceBetweenFloats(topLeft.x + topLeft.width, topRight.x + 1 / gameScale.y);
	var topMiddle:FlxSprite = new FlxSprite(topLeft.x + topLeft.width, topLeft.y).makeGraphic(1, 18, 0xFF282828);

	for (position in [0, 17])
		topMiddle.pixels.setPixel(0, position, 0x111111);

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
	add(topShadowL);

	var topShadowR:FlxSprite = new FlxSprite(topRight.x, (topRight.y + topRight.height) - 2 * baseScale).loadGraphic(getImage("top-shadow"));
    topShadowR.scale.set(baseScale, baseScale);
    topShadowR.updateHitbox();
    topShadowR.blend = getBlendMode("multiply");
    topShadowR.flipX = true;
    topShadowR.camera = mainCamera;
	add(topShadowR);

	var topShadowDistance:Float = FunkinMath.distanceBetweenFloats(topShadowL.x + topShadowL.width, topShadowR.x + 1 / gameScale.y);
    var topShadowM:FlxSprite = new FlxSprite(topShadowL.x + topShadowL.width, topShadowL.y).makeGraphic(Std.int(topShadowDistance), Std.int(4 * baseScale), 0xFF999999);
	topShadowM.blend = getBlendMode("multiply");
	topShadowM.camera = mainCamera;
	add(topShadowM);

	add(topLeft);
	add(topRight);
	add(topMiddle);

	lightBulb = new FlxSprite(topLeft.x + 24 * baseScale, topLeft.y + 4 * baseScale).loadGraphic(getImage("lightBulb"));
	lightBulb.scale.set(baseScale, baseScale);
    lightBulb.updateHitbox();
	lightBulb.camera = mainCamera;
	add(lightBulb);

	lightGlow = new FlxSprite().loadGraphic(getImage("lightGlow"));
    lightGlow.scale.set(1.5, 1.5);
    lightGlow.updateHitbox();
	lightGlow.setPosition(lightBulb.x + (lightBulb.width / 2) - (lightGlow.width / 2), lightBulb.y + (lightBulb.height / 2) - (lightGlow.height / 2));
    lightGlow.blend = getBlendMode("add");
	lightGlow.camera = mainCamera;
	add(lightGlow);

	lightBulbOverlay = new FlxSprite(lightBulb.x, lightBulb.y).loadGraphic(getImage("lightBulbOverlay"));
	lightBulbOverlay.scale.set(baseScale, baseScale);
	lightBulbOverlay.updateHitbox();
	lightBulbOverlay.blend = getBlendMode("multiply");
	lightBulbOverlay.camera = mainCamera;
	add(lightBulbOverlay);

	if (!deadVersion) {
		lightBulb.color = 0xFF43A25A;
        lightGlow.color = 0xFF43A25A;
    } else {
		lightBulb.color = 0xFF333333;
		lightGlow.color = 0xFF333333;
		lightGlow.visible = false;
		lightBulbOverlay.visible = false;
    }

    topButtonsGroup = new FlxSpriteGroup();
	topButtonsGroup.camera = mainCamera;
	add(topButtonsGroup);

	statsButton = new TopButton("stats", topRight.x + topRight.width, topLeft.y + topLeft.height);
    statsButton.scale.set(baseScale, baseScale);
    statsButton.updateHitbox();
    statsButton.x -= statsButton.width + 8 * baseScale;
    statsButton.y -= statsButton.height + 2 * baseScale;
	statsButton.onPress = statsMenu;
    topButtonsGroup.add(statsButton);

    if (!isMobile) {
        if (Options.devMode) {
			var debugButton:TopButton = new TopButton("debug", statsButton.x - statsButton.width - 4 * baseScale, statsButton.y);
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

	var divisionThing:FlxSprite = new FlxSprite(buttonsBack.x + 4 * baseScale, buttonsBack.y + 46 * baseScale).makeGraphic(94, 1, 0xFF5A5B61);

	for (position in [0, 1, 92, 93])
		divisionThing.pixels.setPixel(position, 0, 0x3E4044);

    divisionThing.scale.set(baseScale, baseScale);
    divisionThing.updateHitbox();
	divisionThing.camera = mainCamera;
    add(divisionThing);

    var buttonsXPos:Float = buttonsBack.x + 3 * baseScale * 2;
	var buttonsYPos:Float = buttonsBack.y + 3 * baseScale * 2;

	mainButtons = new FlxGroup(7);
    mainButtons.camera = mainCamera;
	add(mainButtons);

	createMainSectionButtons(buttonsBack.x + 3 * baseScale * 2, buttonsBack.y + 3 * baseScale * 2);

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

    var windowAreaX:Float = windowBorderLeft.x + 8 * baseScale;
	var windowAreaY:Float = windowBorderLeft.y + 8 * baseScale;
	var windowAreaW:Int = Std.int(FlxG.width - windowAreaX);
	var windowAreaH:Int = Std.int(FunkinMath.distanceBetweenFloats(windowAreaY, windowBorderLeft.y + windowBorderLeft.height - 8 * baseScale));
	windowArea = new FlxRect(windowAreaX, windowAreaY, windowAreaW, windowAreaH);

	spaceCamera.setPosition(windowArea.x, windowArea.y);
	spaceCamera.setSize(windowArea.width, windowArea.height);
	//starField.setBounds(FlxG.camera.x, FlxG.camera.y, FlxG.camera.width, FlxG.camera.height);

	spaceGroup = new FlxSpriteGroup();
	add(spaceGroup);

	var windowShine:FlxSprite = new FlxSprite().loadGraphic(getImage("window-shine"));
    windowShine.scale.set(baseScale, baseScale);
    windowShine.updateHitbox();
    windowShine.blend = getBlendMode("add");
    windowShine.alpha = 0.15;
	windowShine.x = windowArea.width * (windowArea.width / 1280) * 0.4;
    windowShine.scrollFactor.set(0, 0);
	windowShine.camera = spaceCamera;
	add(windowShine);

	windowMenu = new WindowSubMenuHandler(spaceCamera);
	add(windowMenu);

	add(windowBorderShadowM);
	add(windowBorderShadowL);
	add(windowBorderMiddle);
	add(windowBorderLeft);

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
	exitPrompt.onClose = enableInput;

	if (globalUsingKeyboard)
	    changeMainEntry(0);
}

function createMainSectionButtons(?x:Float, ?y:Float) {
    var xPos:Float = x ?? 0;
    var yPos:Float = y ?? 0;
	for (i => buttonData in mainSectionButtons) {
        if (i >= 7) return;

		var button:MainMenuButton = new MainMenuButton(i, xPos, yPos, buttonData, mainCamera, baseScale);
		mainButtons.add(button);

        if (i < 5) {
			yPos += button.height + baseScale + 1;
			if (i == 2) yPos += 3 * baseScale;
        }
        else
			xPos += button.width + 2 * baseScale + 1;
    }
}

function postCreate() {
    var backBtnScale:Float = isMobile ? 5 : 3;
    backButton = new BackButton(FlxG.width * 0.92, FlxG.height * 0.95, goBack2Title, backBtnScale);
    backButton.visible = !globalUsingKeyboard;
    backButton.x -= backButton.width;
    backButton.y -= backButton.height;
    backButton.camera = mainCamera;
	backButton.alpha = 0;
    add(backButton);

    backButton.onConfirm.add(disableInput);

	FlxTween.tween(backButton, {alpha: 1}, 1, {startDelay: 0.5, ease: FlxEase.quintOut});

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
var curMainEntry:Int = 0;
var curPointerEntry:Int = 0;
var lastPointerEntry:Int = -1;
function update(elapsed:Float) {
	if (!allowInput) return;

	handleKeyboard(elapsed);
    if (isMobile)
        handleTouch();
    else
        handleMouse();
}

var holdTimer:Float = 0;
final maxHeldTime:Float = 0.5;
var frameDelayer:Int = 0;
final maxFrameDelay:Int = 2;
function handleKeyboard(elapsed:Float) {
    if (FlxG.keys.justPressed.ANY)
		useKeyboard();

	if (exitPrompt.isOpen) {
		if (controls.LEFT_P)
			exitPrompt.pressedLeft();
		if (controls.RIGHT_P)
			exitPrompt.pressedRight();

		if (controls.ACCEPT)
			exitPrompt.pressedConfirm();

		if (controls.BACK)
			exitPrompt.close();

		return;
	}

	if (curSelectionMode == SelectionMode.MAIN) {
		if (controls.UP_P)
			changeMainEntry(-1);
		if (controls.DOWN_P)
			changeMainEntry(1);

		if (controls.UP) {
			if (holdTimer >= maxHeldTime) {
				if (frameDelayer >= maxFrameDelay) {
					changeMainEntry(-1);
					frameDelayer = 0;
				}
				else
					frameDelayer++;
			}
			else
				holdTimer += elapsed;
		}
		else if (controls.DOWN) {
			if (holdTimer >= maxHeldTime) {
				if (frameDelayer >= maxFrameDelay) {
					changeMainEntry(1);
					frameDelayer = 0;
				}
				else
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
			checkMainSelection(curMainEntry);
	}

    if (controls.BACK)
		checkBackAction();
}

function useKeyboard() {
    backButton.visible = false;
    FlxG.mouse.visible = false;
}

function handleMouse() {
	if (pointerDoesAnything()) {
		holdTimer = 0;
		if (curSelectionMode == SelectionMode.MAIN)
			backButton.visible = true;

		FlxG.mouse.visible = true;
    }

	if (!FlxG.mouse.visible || globalUsingKeyboard) return;

	if (exitPrompt.isOpen) {
		exitPrompt.updatePointer();
        return;
    }

	var isOverButton:Bool = false;

	for (button in mainButtons.members) {
		if (FlxG.mouse.overlaps(button, mainCamera) && button.available) {
			button.hover();
			pointerSelection(button.index);
			isOverButton = true;
        }
        else
			button.idle();
    }

    if (isOverButton) {
        setMouseCursor("button");
        if (FlxG.mouse.justReleased)
			checkMainSelection(curPointerEntry);
    }
    else {
		pointerSelection();
		setMouseCursor();
    }
}

function handleTouch() {
	if (pointerDoesAnything()) {
		holdTimer = 0;
		if (curSelectionMode == SelectionMode.MAIN)
			backButton.visible = true;
	}

	if (globalUsingKeyboard) return;

	if (exitPrompt.isOpen) {
		exitPrompt.updatePointer();
		return;
	}

	var isOverButton:Bool = false;

    for (touch in FlxG.touches.list) {
		for (button in mainButtons.members) {
			if (touch.overlaps(button, mainCamera) && button.available) {
				button.hover();
				pointerSelection(button.index);
				isOverButton = true;
			} else
				button.idle();
		}
    }

	if (isOverButton) {
		if (pointerJustReleased())
			checkMainSelection(curPointerEntry);
    }
    else
        pointerSelection();

    // only available on real mobile devices
    #if mobile
    if (FlxG.android.justReleased.BACK)
        goBack2Title();
    #end
}

function changeMainEntry(change:Int) {
	var oldEntry:Int = curMainEntry;
	curMainEntry = FlxMath.wrap(curMainEntry + change, 0, mainButtons.length - 1);

	if (!mainButtons.members[curMainEntry].available) {
        changeMainEntry(change);
        return;
    }

	for (button in mainButtons.members) {
		if (button.index == curMainEntry)
			button.hover();
		else
			button.idle();
	}

	if (curMainEntry != oldEntry)
		playMenuSound("scroll");
}

function pointerSelection(?index:Int) {
	curPointerEntry = index ?? -1;

	if (curPointerEntry != lastPointerEntry) {
		lastPointerEntry = curPointerEntry;

		if (index >= 0)
			playMenuSound("scroll");
    }
}

function checkMainSelection(index:Int) {
	var button:MainMenuButton = mainButtons.members[index];

	if (button.available) {
		playMenuSound("confirm");
		FlxFlicker.flicker(button, 1, 0.05, true, true);
		selectButton(mainSectionButtons[index]);
	}
	else
		playMenuSound("cancel");
}

function selectButton(buttonData:Dynamic) {
	switch (buttonData.triggerType) {
		case MainMenuButtonTriggerType.OPEN_WINDOW:
			openWindowSubMenu(buttonData.onSelect(this));

		case MainMenuButtonTriggerType.OPEN_SUBSTATE:
			disableInput();
			openSubState(buttonData.onSelect(this));

		case MainMenuButtonTriggerType.SWITCH_STATE:
			disableInput();
			new FlxTimer().start(1, _ -> FlxG.switchState(buttonData.onSelect(this)));

		case MainMenuButtonTriggerType.CUSTOM:
			buttonData.onSelect(this);
	}
}

function openWindowSubMenu(subMenu:WindowSubMenu) {
	curSelectionMode = SelectionMode.WINDOW;
    backButton.visible = false;

	windowMenu.open(subMenu);
    //windowMenu.onOpen = enableInput;
	windowMenu.onClose = closeWindowSection;

	FlxG.mouse.visible = !globalUsingKeyboard;
}

function closeWindowSection() {
	if (windowMenu.isOpen)
		windowMenu.close(false);

	backButton.visible = !globalUsingKeyboard;

    enableInput();

	curSelectionMode = SelectionMode.MAIN;
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
	topButtonsGroup.forEach(function(button) button.enabled = true);
	setMouseCursor();
}

function disableInput() {
	allowInput = false;
    backButton.enabled = false;
    windowMenu.enabled = false;
    topButtonsGroup.forEach(function(button) button.enabled = false);
    setMouseCursor();
}

function checkBackAction() {
	if (curSelectionMode == SelectionMode.WINDOW)
		closeWindowSection();
    else
		goBack2Title();
}

function goBack2Title() {
    setTransition("fadeUp");
    FlxG.switchState(new ModState("impostorTitleState"));
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
	var _windowRect:FlxRect;
	var _subMenuRect:FlxRect;

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
		_windowRect = new FlxRect(camera.x, camera.y + _mainRect.height, camera.width, camera.height - _mainRect.height);
		_subMenuRect = new FlxRect(0, _mainRect.height, _mainRect.width, FunkinMath.distanceBetweenFloats(_mainRect.y + _mainRect.height, camera.height));

		windowCamera = new FlxCamera(camera.x, camera.y + _subMenuRect.y, camera.width, _subMenuRect.height);
		windowCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.insert(windowCamera, FlxG.cameras.list.indexOf(this.camera) + 1, false);

		kill();
		isOpen = false;
	}

	override public function update(elapsed:Float) {
		if (!enabled || !isOpen)
			return;

		super.update(elapsed);

		background.update(elapsed);
		lineSprite.update(elapsed);
		titleText.update(elapsed);
		closeButton.update(elapsed);

		if (curSubMenu != null)
			curSubMenu.update(elapsed);
	}

	override public function draw() {
		if (!isOpen)
			return;

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

		windowCamera.scroll.set();
		windowCamera.minScrollX = null;
		windowCamera.minScrollY = null;
		windowCamera.maxScrollX = null;
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

	var controls(get, never):Controls;

	var _parent:WindowSubMenuHandler;

	var _deadzones:Array<FlxObject> = [];

	var _isHovering:Bool = false;

	public function new(name:String) {
		super();

		this.name = name;
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

	/**
	 * this is so hilariously bad
	 */
	var selectedButton:WindowButton = null;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (customUpdate != null && pointerWithinBounds(_parent._windowRect))
			customUpdate(elapsed);

		// i hate doing this
		if (globalUsingKeyboard) {
			if (name == translate('generic.mods')) {
				if (controls.DOWN_P) {
					playMenuSound("scroll");
					_parent._position.y = FlxMath.wrap(_parent._position.y + 1, 0, getLength() - 1);
					updateButtons();
					updateCameraScroll();
				}
				else if (controls.UP_P) {
					playMenuSound("scroll");
					_parent._position.y = FlxMath.wrap(_parent._position.y - 1, 0, getLength() - 1);
					updateButtons();
					updateCameraScroll();
				}

				if (controls.ACCEPT) {
					for (button in members) {
						if (!isButtonDeadzone(button) && button.available && button.isHovered)
							button.checkPosition(0, _parent._position.y);
					}
				}
			}
			else {
				// make the player feel like its controling the menu, but in reality hes not doing anything HAHAHAHAH
				if (controls.LEFT_P || controls.DOWN_P || controls.UP_P || controls.RIGHT_P)
					playMenuSound("scroll");

				if (controls.ACCEPT && selectedButton != null && selectedButton.isHovered)
					selectedButton.checkPosition(selectedButton.index.x, selectedButton.index.y);

				if (selectedButton == null) {
					for (button in members) {
						if (isButtonDeadzone(button))
							continue;

						if (button.available) {
							button.hover();
							selectedButton = button;
						}
					}
				}
			}

			return;
		}

		_isHovering = false;
		_overlapDeadzone = false;
		onlyAvailableButton = null;

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
			}
			else
				button.idle();

			if (_isHovering && pointerJustReleased())
				button.checkPosition(_parent._position.x, _parent._position.y);
		}

		if (!_isHovering) {
			_parent._position.set(-1, -1);
			_parent._lastPosition.set(-1, -1);
		}
	}

	function updateButtons() {
		for (button in members) {
			if (isButtonDeadzone(button))
				continue;

			if (button.available && button.index.y == _parent._position.y) {
				selectedButton = button;
				button.hover();
			}
			else
				button.idle();
		}
	}

	function updateCameraScroll() {
		if (selectedButton != null) {
			_parent.windowCamera.minScrollY = 0;
			_parent.windowCamera.maxScrollY = members[getLength() - 1].y + members[getLength() - 1].height;
			_parent.windowCamera.scroll.y = selectedButton.y + selectedButton.height / 2 - _parent.windowCamera.height / 2;
		}
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

		forEach((spr) -> {
			spr.camera = _parent.windowCamera;
		});
	}

	function isButtonDeadzone(button) {
		for (deadzone in _deadzones)
			if (button == deadzone)
				return true;
		return false;
	}

	function get_controls():Controls {
		return PlayerSettings.solo.controls;
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
		if (!available || !_enabled)
			return;

		isHovered = true;
		if (button.hasAnim("hover"))
			button.playAnim("hover");
		else
			button.alpha = _hoverOpacity;

		playMenuSound("scroll");

		if (label != null)
			label.color = hoverColor;
	}

	public function idle() {
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