import lime.app.Event;
import lime.graphics.Image;
import openfl.system.Capabilities;

function new() {
	window.onClose.add(windowCloseEvent);
}

//public static var screenPosition(default, set):FlxPoint = FlxPoint.get();
public static var gameScale(default, null):FlxPoint = FlxPoint.get();
public static var gameRatio(default, null):Int = 0;

public static function setWindowPosition(?x:Float, ?y:Float) {
	if (x != null) {
		var horPosPercent:Float = CoolUtil.bound(x / Capabilities.screenResolutionX, 0, 1);
		x = CoolUtil.bound(x, 0, Capabilities.screenResolutionX);
		window.x = x - (FlxG.stage.stageWidth * horPosPercent);
	}
	if (y != null) {
		var verPosPercent:Float = CoolUtil.bound(y / Capabilities.screenResolutionY, 0, 1);
		y = CoolUtil.bound(y, 0, Capabilities.screenResolutionY);
		window.y = y - (FlxG.stage.stageHeight * verPosPercent);
	}
}

public static function setWindowIcon(image:String) {
	window.setIcon(Image.fromFile(Assets.getPath(Paths.image(image))));
}

/**
 * Centers the application's window on the display resolution of the monitor.
 */
public static function centerWindow(?axes:FlxAxes) {
	if (axes == FlxAxes.X || axes == null)
		window.x = (Capabilities.screenResolutionX - FlxG.stage.stageWidth) / 2;

	if (axes == FlxAxes.Y || axes == null)
		window.y = (Capabilities.screenResolutionY - FlxG.stage.stageHeight) / 2;
}

public static function updateResize(width:Int, height:Int) {
    gameRatio = width / height;
	gameScale.x = width / 1280;
	gameScale.y = height / 720;
}

public static function resizeGame(width:Int, height:Int, ?updateWindow:Bool) {
	FlxG.initialWidth = width;
	FlxG.initialHeight = height;
	FlxG.width = width;
	FlxG.height = height;

	FlxG.scaleMode.onMeasure(width, height);

	updateResize(width, height);

	updateWindow ??= true;
	if (updateWindow) resizeWindow(width, height);
}

public static function resizeWindow(width:Int, height:Int) {
	FlxG.resizeWindow(width, height);
	centerWindow();
}

var shakingWindow:Bool = false;
var shakeDuration:Float = 0;
var shakeIntensity:Float = 0;
var initialWindowPos:FlxPoint = FlxPoint.get();

public static function shakeWindow(intensity:Float, duration:Float) {
	if (shakingWindow) return;

	shakeDuration = duration;
	shakeIntensity = intensity;

	initialWindowPos.set(window.x, window.y);

	shakingWindow = true;
}

public static function stopWindowShake() {
	window.x = initialWindowPos.x;
	window.y = initialWindowPos.y;

	shakeDuration = 0;
	shakeIntensity = 0;
	shakingWindow = false;
}

function update(elapsed:Float) {
	if (shakingWindow) {
		if (shakeDuration > 0) {
			window.x = initialWindowPos.x + FlxG.random.float(-shakeIntensity * FlxG.stage.stageWidth, shakeIntensity * FlxG.stage.stageWidth);
			window.y = initialWindowPos.y + FlxG.random.float(-shakeIntensity * FlxG.stage.stageHeight, shakeIntensity * FlxG.stage.stageHeight);

			shakeDuration -= elapsed;
		} else {
			window.x = initialWindowPos.x;
			window.y = initialWindowPos.y;

			shakeDuration = 0;
			shakeIntensity = 0;
			shakingWindow = false;
		}
	}
}

var allowGameClose:Bool = true;

public static function preventWindowClosure() {
	allowGameClose = false;
}

public static function allowWindowClosure() {
	allowGameClose = true;
}

function windowCloseEvent() {
	if (!allowGameClose)
		window.onClose.cancel();
}

function destroy() {
	window.onClose.remove(windowCloseEvent);
}