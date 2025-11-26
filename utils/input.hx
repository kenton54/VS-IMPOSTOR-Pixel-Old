import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxPointer;
import flixel.input.FlxSwipe;
import flixel.math.FlxRect;
import flixel.FlxObject;
import openfl.ui.Mouse;

// variables for the mobile emulator
public static var isMobile:Bool = FlxG.onMobile;
public static var fakeMobile:Bool = false;

public static final appPackage:String = FlxG.stage.application.meta["package"] ?? FlxG.stage.application.meta["packageName"];
public static final appPackageSlash:String = StringTools.replace(appPackage, ".", "/");

final minSwipeDistance:Float = 20;

public static function setMouseCursor(?value:String) {
    value ??= "arrow";
	Mouse.cursor = value;
}

public static function getMouseCursor():String
	return Mouse.cursor;

public static function setMobile(value:Bool) {
    if (FlxG.onMobile) {
        isMobile = true;
        fakeMobile = false;
    }
    else {
        isMobile = value;
        fakeMobile = value;
    }
}

public static function getPointerPosition():FlxPoint {
    return getPointer().getPosition();
}

public static function pointerOverlaps(object:FlxBasic, ?camera:FlxCamera):Bool {
	if (getPointer() == null) return false;

	return getPointer().overlaps(object, camera);
}

public static function pointerOverlapsComplex(object:FlxObject, ?camera:FlxCamera) {
	if (getPointer() == null) return false;

	return object.overlapsPoint(getPointer().getWorldPosition(camera, object._point), true, camera);
}

public static function pointerWithinBounds(rect:FlxRect):Bool {
    if (getPointer() == null) return false;

	return rect.containsPoint(getPointerPosition());
}

public static function pointerJustMoved():Bool
	return getPointer().justMoved;

public static function pointerJustPressed():Bool
	return getPointer().justPressed;

public static function pointerIsHolding():Bool
	return getPointer().pressed;

public static function pointerJustReleased():Bool
	return getPointer().justReleased;

public static function pointerDoesAnything():Bool
	return pointerJustMoved() || pointerJustPressed() || pointerIsHolding() || pointerJustReleased() || getSwipeAny();

public static function getSwipeLeft():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > 135) && (swipe.degrees < -135) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeRight():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > -45) && (swipe.degrees < 45) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeUp():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > 45) && (swipe.degrees < 135) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeDown():Bool {
    final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
    if (swipe == null) return false;
    return (swipe.degrees > -135) && (swipe.degrees < -45) && (swipe.distance > minSwipeDistance);
}

public static function getSwipeAny():Bool
    return getSwipeLeft() || getSwipeRight() || getSwipeUp() || getSwipeDown();

public static function getPointer():FlxPointer {
    if (FlxG.onMobile) {
        for (touch in FlxG.touches.list) {
            if (touch != null) return touch;
        }

        return FlxG.touches.getFirst();
    }
    else
        return FlxG.mouse;

    return null;
}

// this function can only be executed on real mobile targets
// currently crashes the game on mobile upon execute
public static function vibrateDevice(duration:Float, amplitude:Float) {
    if (FlxG.onMobile) {
        final amplitudeValue:Float = clamp(amplitude * FlxG.save.data.hapticsIntensity, 0, 1);
        final sharpness:Float = 1;

        #if android
        final vibrateJNI:Null<Dynamic> = createJNIStaticMethod(null, 'vibrateOneShot', '(II)V');
        if (vibrateJNI != null) vibrateJNI(Math.floor(duration * 1000), Math.floor(Math.max(1, Math.min(255, amplitudeValue * 255))));
        #elseif ios
        #else
        throw "Unrecognized device in use!";
        #end
    }
    else
		logTraceState("Mobile", [{text: 'The "vibrateDevice" method can only be executed on Mobile targets!'}], "warning");
}