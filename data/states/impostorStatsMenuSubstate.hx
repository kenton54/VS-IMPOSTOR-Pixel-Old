import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxStringUtil;
import impostor.ResizableUIBox;

// the only reason these are here is becuz maps fuck up the order
var statsList:Array<String> = [
	"totalPlaytime",
    //"storyProgress",
    "totalNotes",
    "perfectNotes",
    "sickNotes",
    "goodNotes",
    "badNotes",
    "shitNotes",
    "missedNotes",
    "combosBroken"/*,
    "attacksDodged",
    "taskSpeedrunSkeld",
    "taskSpeedrunMira",
    "taskSpeedrunPolus",
    "taskSpeedrunAirship",
	"taskSpeedrunFungle",
    "totalTasks"*/
];

var statsCam:FlxCamera;

var buttonsBack:ResizableUIBox;
var closeButton:FlxSprite;
var statsTitle:FunkinText;
var statsNameText:FunkinText;
var statsValueText:FunkinText;

function create() {
    changeDiscordMenuStatus("Viewing his Stats");

    statsCam = new FlxCamera();
    statsCam.bgColor = 0x88000000;
    FlxG.cameras.add(statsCam, false);

    var scale:Float = 4;
	buttonsBack = new ResizableUIBox(0, 0, 680, 640, "fancy", scale);
    buttonsBack.screenCenter();
    buttonsBack.box.camera = statsCam;
    add(buttonsBack.box);

    statsTitle = new FunkinText(buttonsBack.x, buttonsBack.y, buttonsBack.width, translate("mainMenu.stats.title"), 48, false);
    statsTitle.font = Paths.font("pixeloidsans.ttf");
    statsTitle.alignment = "center";
    statsTitle.camera = statsCam;
    statsTitle.y += 8 * scale;
    add(statsTitle);

	var borders:Float = 8 * scale;
	statsNameText = new FunkinText(statsTitle.x + borders, statsTitle.y + statsTitle.height + 3 * scale, statsTitle.fieldWidth - borders * 2, "", 22, false);
	statsNameText.font = Paths.font("retrogaming.ttf");
	statsNameText.textField.__textFormat.leading = -6;
	statsNameText.color = FlxColor.WHITE;
	statsNameText.camera = statsCam;
	add(statsNameText);

	statsValueText = new FunkinText(statsNameText.x, statsNameText.y, statsNameText.fieldWidth, "", 22, false);
	statsValueText.font = statsNameText.font;
	statsValueText.textField.__textFormat.leading = -6;
	statsValueText.alignment = "right";
	statsValueText.color = FlxColor.WHITE;
	statsValueText.camera = statsCam;
	add(statsValueText);

    for (i => stat in statsList) {
		statsNameText.text += (statsNameText.text.length > 0 ? "\n" : "") + getStatName(stat);

        var value:Dynamic = getStatValue(stat);
        var strValue:String = Std.string(value);
		if (StringTools.contains(stat.toLowerCase(), "playtime")) strValue = formatTimeAdvanced(value, "%H:%M:%S");
        if (StringTools.contains(stat.toLowerCase(), "storyprogress")) strValue = '"' + value + '"';
		if (StringTools.contains(stat.toLowerCase(), "speedrun")) strValue = FlxStringUtil.formatTime(value, true);
		statsValueText.text += (statsValueText.text.length > 0 ? "\n" : "") + strValue;

		if (i % 2 == 1) {
			var format:FlxTextFormat = new FlxTextFormat(0xFF999999);
			statsNameText.addFormat(format, statsNameText.text.lastIndexOf("\n"), statsNameText.text.length);
			statsValueText.addFormat(format, statsValueText.text.lastIndexOf("\n"), statsValueText.text.length);
        }
    }

    closeButton = new FlxSprite(buttonsBack.x, buttonsBack.y).loadGraphic(Paths.image("menus/x"));
    closeButton.scale.set(scale, scale);
    closeButton.updateHitbox();
    closeButton.x -= closeButton.width + 2 * scale;
    closeButton.camera = statsCam;
    add(closeButton);
}

function postCreate() {
    if (!isMobile) FlxG.mouse.visible = true;
}

function update(elapsed:Float) {
    updateTimer();

    if (controls.BACK || pointerOverlaps(closeButton) && pointerJustPressed()) {
        playMenuSound("cancel");
        close();
    }
}

function updateTimer() {
	var originalText:String = statsValueText.text;
	var oldTimerTxt:String = originalText.split('\n')[0];
	var newTimerTxt:String = formatTimeAdvanced(getStatValue('totalPlaytime'), "%H:%M:%S");

	if (newTimerTxt != oldTimerTxt)
		statsValueText.text = StringTools.replace(originalText, oldTimerTxt, newTimerTxt);
}

function destroy() {
    statsTitle.destroy();
	statsNameText.destroy();
	statsValueText.destroy();
    buttonsBack.destroy();
    closeButton.destroy();

    FlxG.cameras.remove(statsCam);
    statsCam.destroy();
}