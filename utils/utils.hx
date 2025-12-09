import flixel.sound.FlxSound;
import flixel.util.FlxBaseSignal;
import funkin.backend.MusicBeatTransition;
import funkin.options.Options;
import funkin.savedata.FunkinSave;
import lime.system.JNI; // JNI stands for JavaNativeInterface
import openfl.display.BlendMode;
import openfl.Lib;

public static var playablesList:Map<String, Bool> = ["bf" => true];
public static var skinsList:Map<String, Map<String, Bool>> = [/*character => [skin => bought]*/];

public static var pixelPlayable:String = "bf";

public static var pixelBeans:Int = 0;

public static var isPlayingVersus:Bool = false;

public static var festiveEvent:Null<String> = null;

final defaultTransition:String = "fadeUp";
public static function setTransition(transitionID:String) {
    //trace("Setting transition to: " + (transitionID == "" ? "Default" : transitionID));

    if (transitionID == "")
        MusicBeatTransition.script = "data/transitions/" + defaultTransition;
    else
        MusicBeatTransition.script = "data/transitions/" + transitionID;
}

public static function getBlendMode(blend:String):BlendMode {
    switch(blend) {
        case "add": return BlendMode.ADD;
        case "alpha": return BlendMode.ALPHA;
        case "darken": return BlendMode.DARKEN;
        case "difference": return BlendMode.DIFFERENCE;
        case "erase": return BlendMode.ERASE;
        case "hardlight": return BlendMode.HARDLIGHT;
        case "invert": return BlendMode.INVERT;
        case "layer": return BlendMode.LAYER;
        case "lighten": return BlendMode.LIGHTEN;
        case "multiply": return BlendMode.MULTIPLY;
        case "normal": return BlendMode.NORMAL;
        case "overlay": return BlendMode.OVERLAY;
        case "screen": return BlendMode.SCREEN;
        case "shader": return BlendMode.SHADER;
        case "subtract": return BlendMode.SUBTRACT;
        default: return null;
    }
}

public static function playSound(sound:String, ?volume:Float) {
    volume ??= 1;
    FlxG.sound.play(Paths.sound(sound), volume * Options.volumeSFX);
}

/**
 * Plays a sound that persists between menus.
 * 
 * If you don't understand, the sound won't stop playing when switching states.
 * 
 * @param sound The sound ID, it's actually just the file inside the "sounds/menu" folder (without the extension obviously).
 * @param volume The volume the sound should play at.
 */
public static function playMenuSound(sound:String, ?volume:Float) {
    volume ??= 1;

    var soundPath:String = Paths.sound("menu/" + sound);
    var menuSound:FlxSound = new FlxSound().loadEmbedded(soundPath, false, true);
    menuSound.volume = volume * Options.volumeSFX;
    menuSound.persist = true;
    menuSound.play();
    menuSound.onComplete = function() {
        menuSound.destroy();
    };
}

public static function createMultiLineText(textLines:Array<String>):String {
    var wholeText:String = "";
    var lastLineIndex:Int = textLines.length - 1;

    for (line => text in textLines) {
        wholeText += text;
        if (!(line >= lastLineIndex)) wholeText += '\n';
    }

    return wholeText;
}

// TODO: code this better lol
public static function formatTimeAdvanced(time:Float, format:String):String {
	var days:Int = Std.int(time / 86400); // 24 * 3600
	var hours:Int = Std.int(time / 3600);
	var minutes:Int = Std.int((time % 3600) / 60);
	var seconds:Int = Std.int(time % 60);
	var milliseconds:Float = time % 1;

	var result:String = format;
	if (StringTools.contains(format, "%D")) result = StringTools.replace(result, "%D", CoolUtil.addZeros(Std.string(days), 2));
	if (StringTools.contains(format, "%H")) result = StringTools.replace(result, "%H", CoolUtil.addZeros(Std.string(hours), 2));
	if (StringTools.contains(format, "%M")) result = StringTools.replace(result, "%M", CoolUtil.addZeros(Std.string(minutes), 2));
	if (StringTools.contains(format, "%S")) result = StringTools.replace(result, "%S", CoolUtil.addZeros(Std.string(seconds), 2));
    if (StringTools.contains(format, "%s")) result = StringTools.replace(result, "%s", Std.string(milliseconds).substring(2));

	return result;
}

public static function formatAmongUsDownloadTime(time:Float):String {
    var days:Int = Std.int(time / 86400); // 24 * 3600
	var hours:Int = Std.int(time / 3600);
	var minutes:Int = Std.int((time % 3600) / 60);
	var seconds:Int = Std.int(time % 60);

	var resultString:String = "";
    if (days > 0) resultString += translate("game.tasks.download.daySuffix", [days]) + " ";
    if (hours > 0) resultString += translate("game.tasks.download.hourSuffix", [hours]) + " ";
	if (minutes > 0) resultString += translate("game.tasks.download.minuteSuffix", [minutes]) + " ";
	resultString += translate("game.tasks.download.secondSuffix", [seconds]);
	return resultString;
}

public static function getMonthName(monthId:Int) {
    var monthName:String = switch(monthId) {
        case 0: "january";
		case 1: "february";
		case 2: "march";
		case 3: "april";
		case 4: "may";
		case 5: "june";
		case 6: "july";
		case 7: "august";
		case 8: "september";
		case 9: "october";
		case 10: "november";
		case 11: "december";
    }
	return translate("months." + monthName);
}

public static function getMonthNameShort(monthId:Int) {
	var monthName:String = switch (monthId) {
		case 0: "jans";
		case 1: "febs";
		case 2: "mars";
		case 3: "aprs";
		case 4: "mays";
		case 5: "juns";
		case 6: "juls";
		case 7: "augs";
		case 8: "seps";
		case 9: "octs";
		case 10: "novs";
		case 11: "decs";
	}
	return translate("months." + monthName);
}

// TODO: figure out a cleaner way to execute this.
public static function dispatchSignal(signal:FlxBaseSignal, ?argument1:Dynamic, ?argument2:Dynamic, ?argument3:Dynamic, ?argument4:Dynamic, ?argument5:Dynamic, ?argument6:Dynamic) {
    for (handler in signal.handlers) {
        handler.listener(argument1, argument2, argument3, argument4, argument5, argument6);
    }
}

public static function getPlatform():String {
    #if desktop
    return "desktop";
    #elseif mobile
    return "mobile";
    #elseif web
    return "web";
    #else
    return "unknown";
    #end
}

public static function getTarget():String {
    #if windows
    return "windows";
    #elseif linux
    return "linux";
    #elseif mac
    return "mac";
    #elseif android
    return "android";
    #elseif ios
    return "ios";
    #elseif html5
    return "html5";
    #elseif flash
    return "flash"; // you'll never get this returned
    #elseif switch
    return "switch"; // very unlike you'll get this returned
    #else
    return "unknown";
    #end
}

// this function can only be executed on real mobile targets
public static function createJNIStaticMethod(className:String, methodName:String, signature:String):Null<Dynamic> {
    if (FlxG.onMobile) {
        className = JNI.transformClassName(className);
        return JNI.createStaticMethod(className, methodName, signature);
    }

    return null;
}

public static function saveImpostor() {
	FlxG.save.data.impPixelStorySequence = getStoryProgress();
    FlxG.save.data.impPixelBeans = pixelBeans;
    FlxG.save.data.impPixelStats = getStats();
	FlxG.save.data.impPixelAchievements = achievementsUnlocked;
    FlxG.save.data.impPixelPlayablesUnlocked = playablesList;
    FlxG.save.data.impPixelSkinsUnlocked = skinsList;
    FlxG.save.data.impPixelFlags = getFlags();

	Options.save();
	FlxG.save.flush();
	FunkinSave.flush();

    logTraceColored([{text: "Data saved!", color: getLogColor("green")}], "verbose");
}

public static function eraseImpostorSaveData() {
	resetStoryProgression();
	clearStats();
    playablesList.clear();
    playablesList.set("bf", true);
    skinsList.clear();
    pixelBeans = 0;
    resetFlags();

    FlxG.save.data.impPixelStorySequence = null;
    FlxG.save.data.impPixelBeans = null;
    FlxG.save.data.impPixelStats = null;
	FlxG.save.data.impPixelAchievements = null;
    FlxG.save.data.impPixelPlayablesUnlocked = null;
    FlxG.save.data.impPixelSkinsUnlocked = null;
    FlxG.save.data.impPixelFlags = null;
}