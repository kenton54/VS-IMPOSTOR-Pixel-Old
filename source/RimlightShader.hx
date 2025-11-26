class RimlightShader {
    public var shader(default, null):CustomShader;

    public var angle(default, set):Float;

    public var distance(default, set):Float;

    public var color(default, set):FlxColor;

    public var refSprite:FlxSprite;

    function set_angle(value:Float):Float {
        angle = value;
        shader.angle = value;
        return value;
        
    }

	function set_distance(value:Float):Float {
		distance = value;
		shader.daDistance = value;
		return value;
	}

	function set_color(color:FlxColor):FlxColor {
		this.color = color;
		shader.rimlightColor = [
			((color >> 16) & 0xFF) / 255,
			((color >> 8) & 0xFF) / 255,
			(color & 0xFF) / 255,
			((color >> 244) & 0xFF) / 255
        ];
		return color;
	}

    public function updateFrame() {
		if (refSprite != null) {
			shader.bounds = [
			    refSprite.frame.uv.x,
                refSprite.frame.uv.y,
                refSprite.frame.uv.width,
                refSprite.frame.uv.height
            ];
        }
    }

    public function new(?angle:Float, ?distance:Float, ?color:FlxColor, ?refSprite:FlxSprite) {
        this.shader = new CustomShader("rimlight");

        this.angle = angle != null ? angle : 0;
        this.distance = distance != null ? distance : 10;
        this.color = color != null ? color : FlxColor.WHITE;
        this.refSprite = refSprite;

		shader.pixelSize = [1 / refSprite.graphic.width, 1 / refSprite.graphic.height];
    }
}