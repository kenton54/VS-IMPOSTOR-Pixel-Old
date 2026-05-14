package impostor.menus.mainmenu;

import flixel.math.FlxRect;
import funkin.backend.system.Controls;
import funkin.backend.MusicBeatGroup;
import funkin.options.PlayerSettings;
import FunkinGroup;

class WindowSubMenu extends FunkinGroup {
	public var name(default, null):String;

    var scale:Float;
    var area:FlxRect;

	var controls(get, never):Controls;

	var _parent:WindowSubMenuHandler;

	public function new(name:String, ?scale:Float) {
		super();

		this.name = name;
        this.scale = scale ?? 5;
	}

	function init(parent:WindowSubMenuHandler)
		_parent = parent;

	public function destroy() {
		_parent = null;
	}

    public function create() {}

    public function updateMenu(elapsed:Float) {}

	public function drawMenu() {}

	function get_controls():Controls
        return PlayerSettings.solo.controls;
}

class WindowButton extends MusicBeatGroup {
	public var available(default, set):Bool = true;

	public var button(default, null):FunkinSprite;
	public var label(default, null):FunkinText;

	public var onSelect:Void->Void;

	public var hoverColor:FlxColor = FlxColor.WHITE;
	public var idleColor:FlxColor = FlxColor.BLACK;

	public var hovering(default, set):Bool = false;

	public function new(?x:Float, ?y:Float) {
		super(x, y);

		button = new FunkinSprite();
		add(button);

		label = new FunkinText(0, 0, 0, '', 8, false);
		add(label);
	}

	function set_available(value:Bool):Bool {
		available = value;

		if (available) {
			if (hovering) {
				button.playAnim('hover');
				label.color = hoverColor;
			} else {
				button.playAnim('idle');
				label.color = idleColor;
			}
		} else {
			button.playAnim('locked');
			label.color = FlxColor.BLACK;
		}

		return available;
	}

	function set_hovering(value:Bool):Bool {
		hovering = value && available;

		if (available) {
            if (hovering) {
                button.playAnim('hover');
                label.color = hoverColor;
            }
            else {
                button.playAnim('idle');
                label.color = idleColor;
            }
        }

		return hovering;
	}

	function set_idleColor(value:FlxColor):FlxColor {
		idleColor = value;

		if (!hovering && available)
			label.color = idleColor;

		return idleColor;
	}

	function set_hoverColor(value:FlxColor):FlxColor {
		hoverColor = value;

		if (hovering && available)
			label.color = hoverColor;

		return hoverColor;
	}
}