import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatTransition;
import funkin.savedata.FunkinSave;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.Capabilities;
import openfl.utils.Assets;

// extra variables and function that can be accessed from anywhere in the mod
// ordered by importance
importScript("utils/utils");
importScript("utils/math");
importScript("utils/logs");
importScript("utils/window");
importScript("utils/input");
importScript("utils/discord");
importScript("utils/story");
importScript("utils/stats");
importScript("utils/achievements");
importScript("utils/flags");

public static final MOD_VERSION:String = "dev3";

public static final PIXEL_SAVE_PATH:String = "kenton";
public static final PIXEL_SAVE_NAME:String = "impostorPixel";

public static var modInitialized:Bool = false;

public static var allowAFK:Bool = true;

public static var totalPlaytime:Float = 0;

var mobileUtilsInitiated:Bool = false;

function new() {
	if (modInitialized) return;

	modInitialized = false;

    FlxSprite.defaultAntialiasing = false;

    FlxG.bitmap.clearCache();
	Assets.cache.clear();

    initSaveData();

	window.onResize.add(windowResize);
    Application.current.onExit.add(closeGame);

    Options.antialiasing = false;
    // I have to do this, cuz otherwise it causes crashes (im not kidding)
    /*
    Options.streamedMusic = false;
    Options.streamedVocals = false;*/
    Options.save();

    if (getPlatform() == "mobile")
        initMobile();
    else
        initWindow();

	//resizeGame(1600, 720);

    /*
    if (FlxG.onMobile) {
        //var screenWidth:Float = Capabilities.screenResolutionX;
        //var screenHeight:Float = Capabilities.screenResolutionY;
        //initMobileUtils();
        resizeGame(1560, 720);
    }
    else {}
    */

	//modInitialized = true;
}

function initSaveData() {
    FlxG.save.bind(PIXEL_SAVE_PATH, null);
    FunkinSave.save.bind(PIXEL_SAVE_NAME, PIXEL_SAVE_PATH);

    // Options
    FlxG.save.data.middlescroll ??= FlxG.onMobile ? true : false;
    FlxG.save.data.impPixelTimeBar ??= true;
    FlxG.save.data.impPixelStrumBG ??= 0;
    FlxG.save.data.impPixelFastMenus ??= false;
    FlxG.save.data.hapticsIntensity ??= 0.5;

    // Mod Save Data
    FlxG.save.data.firstTimePlayingImpPixel ??= true;
	FlxG.save.data.seenImpostorStartupWarnings ??= false;
    FlxG.save.data.impPixelCheckUpdates ??= true;
    FlxG.save.data.impPixelStorySequence ??= 0;
    FlxG.save.data.impPixelBeans ??= 0;
    FlxG.save.data.impPixelStats ??= getStats(true);
    FlxG.save.data.impPixelPlayablesUnlocked ??= ["bf" => true];
    FlxG.save.data.impPixelSkinsUnlocked ??= [];
    FlxG.save.data.impPixelFlags ??= getFlags(true);

    initVars();
    initFlags(FlxG.save.data.impPixelFlags);

    logTraceColored([{text: "Save Data loaded!"}], "information");
}

function initVars() {
	setStoryProgression(FlxG.save.data.impPixelStorySequence);
    initStats(FlxG.save.data.impPixelStats);
    playablesList = FlxG.save.data.impPixelPlayablesUnlocked;
    skinsList = FlxG.save.data.impPixelSkinsUnlocked;
    pixelBeans = FlxG.save.data.impPixelBeans;
}

function initFlags(data:Map<String, Dynamic>) {
    weeksCompleted = data.get("weeksCompleted");
    seenCharacters = data.get("seenCharacters");
    unlockedVideos = data.get("unlockedVideos");
}

function initStats(data:Map<String, Dynamic>) {
    for (stat in data.keyValueIterator())
        setStat(stat.key, stat.value);
}

// currently crashes the game on mobile upon execute
function initMobileUtils() {
    if (FlxG.onMobile) {
        #if android
        final initializeHapticsJNI:Null<Dynamic> = createJNIStaticMethod(null, 'initialize', '()V');
        if (initializeHapticsJNI != null) initializeHapticsJNI();
        #end

        mobileUtilsInitiated = true;
    }
    else
        throw "You can only initialize Mobile exclusive utilities on Mobile targets!";
}

// currently crashes the game on mobile upon execute
function destroyMobileUtils() {
    if (FlxG.onMobile) {
        if (!mobileUtilsInitiated) throw "You need to initialize Mobile exclusive utilities first in order to destroy them!";

        #if android
        final disposeHapticsJNI:Null<Dynamic> = createJNIStaticMethod(null, 'dispose', '()V');
        if (disposeHapticsJNI != null) disposeHapticsJNI();
        #end

        mobileUtilsInitiated = false;
    }
}

function initWindow() {
    window.resizable = true;

    window.minWidth = 1280;
    window.minHeight = 720;

    FlxG.mouse.visible = true;

    resizeGame(1280, 720);
}

function initMobile() {
    // TODO: configure mobile
}

function windowResize(newWidth:Int, newHeight:Int) {
	//resizeGame(newWidth, newHeight, false);
}

var _isGameFocused:Bool = true;

function focusLost() {
	_isGameFocused = false;
	_afkTimer = 0;
	//prepareAFKScreen();
}

var afkScreen:Sprite;

function prepareAFKScreen() {
	if (afkScreen != null) return;

	afkScreen = new Sprite();
	afkScreen.visible = false;
	FlxG.addChildBelowMouse(afkScreen);

	var bg = new Bitmap(new BitmapData(FlxG.width, FlxG.height, true, 0xBF000000));
	afkScreen.addChild(bg);

	var afkText = new TextField();
	afkText.width = bg.width;
	afkText.height = bg.height / 4;
	afkText.selectable = false;
	afkText.embedFonts = true;
	afkText.multiline = true;
	afkText.wordWrap = true;
	afkText.antiAliasType = 1;

	var font = Assets.getFont(Paths.font("pixeloidsans.ttf"));

	var mainFormat = new TextFormat(font.fontName, 48, 0xFFFFFFFF);
	mainFormat.align = 0;
	afkText.defaultTextFormat = mainFormat;
	afkText.text = translate("afk-text");

	var firstLength:Int = afkText.text.length;
	var descFormat = new TextFormat(font.fontName, 24, 0xFF7F7F7F);
	descFormat.align = 0;
	afkText.text += '\n' + translate("afk-desc");
	afkText.setTextFormat(descFormat, firstLength, afkText.text.length);

	screenCenter(afkText);
	afkScreen.addChild(afkText);
}

function destroyAFKScreen() {
	FlxG.removeChild(afkScreen);
	afkScreen = null;
}

function focusGained() {
	_isGameFocused = true;
	_afkTimer = 0;
	//destroyAFKScreen();
    /*
    FlxG.cameras.unlock();
	FlxG.sound.resume();

	if (!FlxG.state.exists)
		FlxG.state.revive();
    */
}

public static var globalUsingKeyboard:Bool = false;

var _afkTimer:Float = 0;
var _afkThreshold:Float = Options.lowMemoryMode ? 10 : 60;
function update(elapsed:Float) {
    // just so it updates properly when the option gets changed
	_afkThreshold = Options.lowMemoryMode ? 10 : 60;

    /*
	if (!_isGameFocused && allowAFK) {
		if (_afkTimer >= _afkThreshold) {
			afkScreen.visible = true;
            FlxG.cameras.lock();
            FlxG.sound.pause();

			if (FlxG.state.exists)
                FlxG.state.kill();

            return;
        }
        else
			_afkTimer += elapsed;
    }
    */

	addStatFloat("totalPlaytime", elapsed);

    if (FlxG.keys.justPressed.ANY) globalUsingKeyboard = true;
	if (pointerDoesAnything()) globalUsingKeyboard = false;

	if (FlxG.keys.justPressed.F11 && canFullscreen)
        toggleFullscreen();

    if (FlxG.keys.justPressed.F8)
		testAchievement();

    if (fakeMobile) {
        if (FlxG.keys.justPressed.F8) {
            setTransition("fadeUp");
            FlxG.switchState(new ModState("debug/mobileEmuInitializer"));
        }
    }
}

public static var canFullscreen:Bool = true;

var oldRegion:Array<Int> = [FlxG.stage.stageWidth, FlxG.stage.stageHeight];
function toggleFullscreen() {
	FlxG.fullscreen = !FlxG.fullscreen;

	if (FlxG.fullscreen) {
		oldRegion[0] = FlxG.stage.stageWidth;
		oldRegion[1] = FlxG.stage.stageHeight;
		//resizeGame(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
    } else {
		//resizeGame(1280, 720);
    }

    //MusicBeatState.skipTransIn = true;
    //FlxG.resetState();
}

function postStateSwitch() {
	allowWindowClosure();

    if (fakeMobile) {
        var mobilePreviewTxt:FunkinText = new FunkinText(FlxG.width * 0.02, FlxG.height * 0.98, 0, 'Mobile Preview, menus may look different in the real thing!\nPress F8 to exit the preview', 32, true);
        mobilePreviewTxt.font = Paths.font("pixeloidsans.ttf");
        mobilePreviewTxt.borderSize = 3;
		mobilePreviewTxt.scrollFactor.set(0, 0);
        mobilePreviewTxt.y -= mobilePreviewTxt.height;
        FlxG.state.add(mobilePreviewTxt);
    }
}

function closeGame()
    saveImpostor();

function destroy() {
    Application.current.onExit.remove(closeGame);

	destroyAFKScreen();

	closeGame();

    FlxG.save.bind(Flags.SAVE_PATH, null);
    FunkinSave.save.bind(Flags.SAVE_NAME, Flags.SAVE_PATH);

    Application.current.window.minWidth = null;
    Application.current.window.minHeight = null;

    resizeGame(1280, 720);

    if (fakeMobile || !Application.current.window.maximized)
        resizeWindow(1280, 720);

    isMobile = FlxG.onMobile;
    setMobile(false);

    //destroyMobileUtils();

	FlxG.bitmap.clearCache();
	Assets.cache.clear();

	modInitialized = false;

    FlxSprite.defaultAntialiasing = true;
}