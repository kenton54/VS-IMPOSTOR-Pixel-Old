package impostor.menus.mainmenu;

import funkin.backend.MusicBeatGroup;

enum MainMenuButtonType {
	MAIN;
	EXTRA;
	OTHER;
}

class MainMenuButton extends MusicBeatGroup {
	public var index(default, null):Int;

	public var button(default, null):FlxSprite;
	public var label(default, null):FunkinText;
	public var icon(default, null):FlxSprite;

	public var type(default, null):MainMenuButtonType;

	public var available(default, set):Bool;

	public var hovered(default, null):Bool = false;

	var _idleColor:FlxColor;
	var _hoverColor:FlxColor;

	public function new(index:Int, ?x:Float, ?y:Float, data:Dynamic, ?camera:FlxCamera, ?scale:Float) {
		scale ??= 5;
		camera ??= FlxG.camera;

		super(x, y, 3);

		this.index = index;
		this.camera = camera;

		type = data.type;

		var colors:Array<FlxColor> = getSelectionColorsFromType(type);
		_idleColor = colors[0];
		_hoverColor = colors[1];

		var buttonDimentions:Array<Int> = getDimentionsFromType(type);
		button = new FlxSprite().loadGraphic(getImageFromType(type), true, buttonDimentions[0], buttonDimentions[1]);
		button.animation.add('idle', [0], 0);
		button.animation.add('hover', [1], 0);
		button.animation.add('locked', [2], 0);
		button.scale.set(scale, scale);
		button.updateHitbox();
		button.camera = camera;
		add(button);

		var labelPosition:Float = 4 * scale;
		label = new FunkinText(labelPosition, button.height / 2, button.width - labelPosition * 2, data.name, getTextSizeFromType(type), false);
		label.font = Paths.font('pixeloidsans.ttf');
		label.color = _idleColor;
		label.alignment = "right";
		label.y -= label.height / 2;
		label.camera = camera;
		add(label);

		icon = new FlxSprite(8 * scale);

		if (data.icon != null) {
			icon.loadGraphic(data.icon);
			icon.scale.set(scale, scale);
			icon.updateHitbox();

			if (data.iconOffsets != null) {
				icon.x -= data.iconOffsets[0] * scale;
				icon.y += data.iconOffsets[1] * scale;
			}
		}
		else {
			icon.alpha = 0; // for good measure
			icon.visible = false;
		}

		icon.camera = camera;
		add(icon);

		available = data.available;
	}

	public function idle() {
		if (!available) return;

		button.animation.play('idle');
		label.color = _idleColor;

		hovered = false;
	}

	public function hover() {
		if (!available) return;

		button.animation.play('hover');
		label.color = _hoverColor;

		hovered = true;
	}

	function getSelectionColorsFromType(buttonType:MainMenuButtonType):Array<FlxColor> {
		switch (buttonType) {
			case MainMenuButtonType.MAIN: return [0xFF0A3C33, 0xFF105848];
			case MainMenuButtonType.EXTRA: return [0xFFAAE2DC, 0xFFFFFFFF];
			case MainMenuButtonType.OTHER: return [0xFFFFFFFF, 0xFFFFFFFF];
		};
	}

	function getImageFromType(buttonType:MainMenuButtonType):String {
		switch (buttonType) {
			case MainMenuButtonType.MAIN: return Paths.image('menus/mainmenu/mainButton');
			case MainMenuButtonType.EXTRA: return Paths.image('menus/mainmenu/extraButton');
			case MainMenuButtonType.OTHER: return Paths.image('menus/mainmenu/otherButton');
		};
	}

	function getDimentionsFromType(buttonType:MainMenuButtonType):Array<Int> {
		switch (buttonType) {
			case MainMenuButtonType.MAIN: return [90, 12];
			case MainMenuButtonType.EXTRA: return [90, 9];
			case MainMenuButtonType.OTHER: return [44, 6];
		};
	}

	function getTextSizeFromType(buttonType:MainMenuButtonType):Int {
		switch (buttonType) {
			case MainMenuButtonType.MAIN: return 32;
			case MainMenuButtonType.EXTRA: return 25;
			case MainMenuButtonType.OTHER: return 18;
		};
	}

	function set_available(value:Bool):Bool {
		available = value;

		if (!available) {
			button.animation.play('locked');
			label.color = FlxColor.BLACK;
			icon.color = FlxColor.GRAY;

			var grayscaleShader:CustomShader = new CustomShader('grayscale');
			grayscaleShader._amount = 1;

			icon.shader = grayscaleShader;
		}
		else {
			button.animation.play('idle');
			label.color = _idleColor;
			icon.color = FlxColor.WHITE;

			icon.shader = null;
		}

		return value;
	}
}