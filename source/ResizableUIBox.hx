import flixel.group.FlxSpriteGroup;

class ResizableUIBox {
    public var box(default, null):FlxSpriteGroup;

	public var x(default, set):Float;
    public var y(default, set):Float;
    public var width(get, null):Int;
	public var height(get, null):Int;

    public var initialWidth(default, null):Float;
	public var initialHeight(default, null):Float;
    public var style(default, null):String;
    public var scale(default, null):Float;
    public var visible(default, set):Float;

	public function new(x:Float, y:Float, width:Int, height:Int, ?style:String, ?scale:Float, ?backColor:FlxColor) {
        style ??= "simple";
        scale ??= 4;

		initialWidth = width;
		initialHeight = height;
        this.style = style;
        this.scale = scale;

        box = new FlxSpriteGroup();

		var topLeftCorner:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/borders/corner-"+style));
        var startingX:Float = topLeftCorner.width * scale;
        var startingY:Float = topLeftCorner.height * scale;

        var maxWidth:Int = Std.int(FlxG.width - topLeftCorner.width * scale * 2);
        if (width > maxWidth) width = maxWidth;

        var maxHeight:Int = Std.int(FlxG.height - topLeftCorner.height * scale * 2);
        if (height > maxHeight) height = maxHeight;

		backColor ??= FlxColor.BLACK;
		var boxBack:FlxSprite = new FlxSprite(startingX, startingY).makeGraphic(width, height, backColor);
        box.add(boxBack);

        topLeftCorner.setPosition(boxBack.x, boxBack.y);
        topLeftCorner.scale.set(scale, scale);
        topLeftCorner.updateHitbox();
        topLeftCorner.x -= topLeftCorner.width;
        topLeftCorner.y -= topLeftCorner.height;
        box.add(topLeftCorner);

		var topRightCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/corner-"+style));
        topRightCorner.scale.set(scale, scale);
        topRightCorner.updateHitbox();
        topRightCorner.x += boxBack.width;
        topRightCorner.y -= topRightCorner.height;
        topRightCorner.angle = 90;
        box.add(topRightCorner);

		var botLeftCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/corner-"+style));
        botLeftCorner.scale.set(scale, scale);
        botLeftCorner.updateHitbox();
        botLeftCorner.x -= botLeftCorner.width;
        botLeftCorner.y += boxBack.height;
        botLeftCorner.angle = 270;
        box.add(botLeftCorner);

		var botRightCorner:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/corner-"+style));
        botRightCorner.scale.set(scale, scale);
        botRightCorner.updateHitbox();
        botRightCorner.x += boxBack.width;
        botRightCorner.y += boxBack.height;
        botRightCorner.angle = 180;
        box.add(botRightCorner);

        var horizontalDistance:Float = FlxMath.distanceBetween(topLeftCorner, topRightCorner) - topRightCorner.width;
		var topBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/top-"+style));
        var horizontalYScale:Float = topBorder.height * scale;
        topBorder.setGraphicSize(width, horizontalYScale);
        topBorder.updateHitbox();
        topBorder.y -= topBorder.height;
        box.add(topBorder);

		var bottomBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/top-"+style));
        bottomBorder.setGraphicSize(width, horizontalYScale);
        bottomBorder.updateHitbox();
        bottomBorder.y += boxBack.height;
        bottomBorder.flipY = true;
        box.add(bottomBorder);

        var verticalDistance:Float = FlxMath.distanceBetween(topLeftCorner, botLeftCorner) - botLeftCorner.height;
		var leftBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/side-"+style));
        var verticalXScale:Float = leftBorder.width * scale;
        leftBorder.setGraphicSize(verticalXScale, height);
        leftBorder.updateHitbox();
        leftBorder.x -= leftBorder.width;
        box.add(leftBorder);

        var rightBorder:FlxSprite = new FlxSprite(boxBack.x, boxBack.y).loadGraphic(Paths.image("menus/borders/side-"+style));
        rightBorder.setGraphicSize(verticalXScale, height);
        rightBorder.updateHitbox();
        rightBorder.x += boxBack.width;
        rightBorder.flipX = true;
        box.add(rightBorder);

		box.x = x;
		box.y = y;
    }

    public function screenCenter(?axes:FlxAxes) {
        box.screenCenter(axes);
        x = box.x;
        y = box.y;
    }

    public function boundsCenter(x:Float, y:Float, width:Float, height:Float) {
		box.x = x + (width / 2) - (box.width / 2);
		box.y = y + (height / 2) - (box.height / 2);
		this.x = box.x;
		this.y = box.y;
    }

    public function resize(?newWidth:Int, ?newHeight:Int):Float {
        var curHPos:Float = this.x;
        var curVPos:Float = this.y;

        var boxBack:FlxSprite = box.members[0];
        boxBack.setGraphicSize(newWidth, newHeight);

        var topLeftCorner:FlxSprite = box.members[1];
    }

	public function set_x(value:Float):Float {
        x = value;
		box.x = value;
		return value;
    }

	public function set_y(value:Float):Float {
		y = value;
		box.y = value;
		return value;
	}

    public function set_visible(value:Bool):Bool {
        visible = value;
        box.visible = value;
        return value;
    }

    public function get_width():Int
		return box.width;

	public function get_height():Int
		return box.height;

    public function destroy() {
        box.destroy();
    }
}