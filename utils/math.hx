import flixel.FlxObject;
import openfl.display.DisplayObject;

public static function lerp(value1:Float, value2:Float, ratio:Float, ?fpsSensitive:Bool):Float {
    if (fpsSensitive == null) fpsSensitive = false;

    if (fpsSensitive)
        return FlxMath.lerp(value1, value2, ratio);
    else
        return CoolUtil.fpsLerp(value1, value2, ratio);
}

public static function distanceBetweenFloats(floatA:Float, floatB:Float):Float
    return floatB - floatA;

public static function distanceBetweenPoints(pointA:FlxPoint, pointB:FlxPoint):Float {
	var dx:Float = pointB.x - pointA.x;
	var dy:Float = pointB.y - pointA.y;
    return FlxMath.vectorLength(dx, dy);
}

/**
 * Centers the `DisplayObject` object on the screen.
 * 
 * `FlxObject`s already have this function built into them.
 * 
 * @param object The `DisplayObject` to center.
 */
public static function screenCenter(object:DisplayObject, ?axes:FlxAxes) {
	if (axes == FlxAxes.X || axes == null)
		object.x = (FlxG.stage.stageWidth - object.width) / 2;

	if (axes == FlxAxes.Y || axes == null)
		object.y = (FlxG.stage.stageHeight - object.height) / 2;
}

/**
 * Centers the first object to the second object's bounds.
 * @param object1 Can be either a `FlxObject` or a `DisplayObject`.
 * @param object2 Can be either a `FlxObject` or a `DisplayObject`.
 */
public static function objectCenter(object1:Dynamic, object2:Dynamic, ?axes:FlxAxes) {
	if (axes == FlxAxes.X || axes == null)
		object1.x = object2.x + (object2.width - object1.width) / 2;

	if (axes == FlxAxes.Y || axes == null)
		object1.y = object2.y + (object2.height - object1.height) / 2;
}

/**
 * Centers the object to a specified bound.
 * @param object Can be either a `FlxObject` or a `DisplayObject`.
 * @param bounds Can be either a `FlxRect` or a `Rectangle`.
 */
public static function boundsCenter(object:Dynamic, bounds:Dynamic, ?axes:FlxAxes) {
	if (axes == FlxAxes.X || axes == null)
		object.x = bounds.x + (bounds.width - object.width) / 2;

	if (axes == FlxAxes.Y || axes == null)
		object.y = bounds.y + (bounds.height - object.height) / 2;
}

public static function shuffleTable(table:Array<Dynamic>) {
    var maxIndex = table.length - 1;
	for (i in 0...maxIndex) {
		var j = FlxG.random.int(i, maxIndex);
        var tmp = table[i];
        table[i] = table[j];
        table[j] = tmp;
    }
}

public static function clamp(value:Float, min:Float, max:Float):Float {
    return Math.max(min, Math.min(max, value));
}