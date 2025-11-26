import funkin.menus.ModSwitchMenu;

var bg:FlxSprite;
var thisguy:FlxSprite;

var optionGroup:FlxGroup;
var options:Array<Array<Dynamic>> = [
    {
        id: "start",
		onSelect: () -> letTheGamesBegin()
    },
    {
        id: "options",
		onSelect: () -> openOptions()
    },
    {
        id: "mods",
		onSelect: () -> changeMod()
    }
];

function create() {
	window.title = "...";

	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF381645);
	bg.alpha = 0;
	add(bg);

	thisguy = new FlxSprite().loadGraphic(Paths.image("menus/ominous/black-visor"));
	thisguy.alpha = 0.025;
	thisguy.screenCenter();
	add(thisguy);

	optionGroup = new FlxGroup();
	add(optionGroup);

    var idk:Float = 32;
    var textSize:Float = 64;
	for (i => option in options) {
		var optTxt:FunkinText = new FunkinText(0, (FlxG.height / 2 - options.length * idk) + (textSize * (1.15 * i)), 0, translate("generic." + option.id), textSize, false);
		optTxt.screenCenter(FlxAxes.X);
		optTxt.alpha = 0.4;
		optionGroup.add(optTxt);
    }

    new FlxTimer().start(1, _ -> {
		doSelection = true;
		changeOption(0);
    });
}

var curOption:Int = 0;
var lastOption:Int = 0;
var doSelection:Bool = false;
function update(elapsed:Float) {
	if (!doSelection) return;

	if (globalUsingKeyboard) {
		FlxG.mouse.visible = false;

		if (controls.UP_P)
			changeOption(-1);
		if (controls.DOWN_P)
			changeOption(1);

		if (controls.ACCEPT) {
			if (options[curOption] != null && options[curOption].onSelect != null) {
				var func:Void = options[curOption].onSelect;
				func();
            }
        }

        return;
    }

	FlxG.mouse.visible = true;
	curOption = -1;

    var i:Int = 0;
	optionGroup.forEach(function(spr) {
		if (pointerOverlaps(spr)) {
			curOption = i;
			spr.alpha = 1;
			if (curOption != lastOption) {
				lastOption = i;
				playMenuSound("scroll");
            }
        }
        else
			spr.alpha = 0.4;

		i++;
	});

	if (pointerJustReleased()) {
		if (options[curOption] != null && options[curOption].onSelect != null) {
			var func:Void = options[curOption].onSelect;
			func();
		}
    }
}

function changeOption(change:Int) {
    if (change != 0) playMenuSound("scroll");

	lastOption = 0;
	curOption = FlxMath.wrap(curOption + change, 0, options.length - 1);

    var i:Int = 0;
	optionGroup.forEach(function(spr) {
        if (i == curOption)
            spr.alpha = 1;
        else
            spr.alpha = 0.4;

        i++;
    });
}

function openOptions() {
	openSubState(new ModSubState("options/impostorOptionsSubState"));
	persistentUpdate = !(persistentDraw = true);
}

function changeMod() {
	new FlxTimer().start(0.02, _ -> {
		openSubState(new ModSwitchMenu());
		persistentUpdate = !(persistentDraw = true);
	});
}

function letTheGamesBegin() {
	doSelection = false;
	playMenuSound("cancel");

	optionGroup.forEach(function(spr) {
        FlxTween.tween(spr, {alpha: 0});
    });

	FlxTween.tween(bg, {alpha: 0.45}, 5);
	FlxTween.tween(thisguy, {alpha: 0.5}, 5);
}

function destroy() {
	bg.destroy();
	thisguy.destroy();
}