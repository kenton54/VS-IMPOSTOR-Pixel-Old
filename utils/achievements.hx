import flixel.tweens.misc.VarTween;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import openfl.text.TextField;
import openfl.text.TextFormat;

function new() {
	FlxG.save.data.impPixelAchievements ??= [];
	achievementsUnlocked = FlxG.save.data.impPixelAchievements;

	achievements = [
		createAchievement("youThought", AchievementLevel.BRONZE),
		createAchievement("curiosityBenefitedTheInspector", AchievementLevel.GOLD),
		createAchievement("alteredReality", AchievementLevel.SILVER),
		createAchievement("newStoryUnfolds", AchievementLevel.SILVER),
		createAchievement("iNeverWin", AchievementLevel.PLATINUM),
		createAchievement("noFunAllowed", AchievementLevel.BRONZE),
		createAchievement("fashionStealer", AchievementLevel.BRONZE),
		createAchievement("noBeans", AchievementLevel.SILVER),
		createAchievement("relivingNostalgia", AchievementLevel.SILVER),
		createAchievement("debugger", AchievementLevel.BRONZE),
    ];
}

enum AchievementLevel {
	BRONZE;
	SILVER;
	GOLD;
	PLATINUM;
	LOCKED;
}

var achievements:Array<Achievement> = [];

public static var achievementsUnlocked:Array<String> = [];

function createAchievement(id:String, level:AchievementLevel, ?points:Int):Achievement {
	return new Achievement(id, translate("achievements." + id + "-name"), translate("achievements." + id + "-desc"), level, points);
}

function hasAchievement(name:String):Bool {
	for (achievement in achievements) {
		if (achievement.ID == name)
			return true;
	}
	return false;
}

function getAchievement(name:String):Achievement {
	for (achievement in achievements) {
		if (achievement.ID == name)
			return achievement;
	}
	return null;
}

public static function isAchievementUnlocked(name:String):Bool {
    return achievementsUnlocked.contains(name);
}

function getRandomAchievementCuzWhyNotLol():Achievement {
	return achievements[FlxG.random.int(0, achievements.length - 1)];
}

public static function grantAchievement(name:String) {
	if (!hasAchievement(name) || isAchievementUnlocked(name)) return;
	popupAchievement(getAchievement(name));
}

public static function testGrantAchievement() {
	var a = getRandomAchievementCuzWhyNotLol();
	grantAchievement(a.ID);
}

public static function testPopupAchievement() {
	popupAchievement(getRandomAchievementCuzWhyNotLol());
}

var achievementScale:Float = 4.5;
var popUpScale:Float = 1.2;
var activeAchievements:Array<Dynamic> = [];
var activeTweens:Array<Array<FlxTween>> = [];
function popupAchievement(data:Achievement) {
	playMenuSound("hardConfirm");

	if (!achievementsUnlocked.contains(data.ID))
		achievementsUnlocked.push(data.ID);

	var achievementToast:Sprite = new Sprite();
	achievementToast.scaleX = popUpScale;
	achievementToast.scaleY = popUpScale;

	var achWidth:Float = 72 * achievementScale;
	var achHeight:Float = 28 * achievementScale;
	var fullRatio:Float = 32 * achievementScale;
	var achLevel:String = getAchievementLevelString(data.level);

	var achievementPanel:Bitmap = new Bitmap(Assets.getBitmapData(Paths.image("achievements/levels/" + achLevel + "Panel")));
	achievementPanel.scaleX = achievementScale;
	achievementPanel.scaleY = achievementScale;
	achievementPanel.alpha = 0;
	achievementToast.addChild(achievementPanel);

	// calculate the text color based on color brightness
	var achievementColor:FlxColor = getAchievementLevelColor(data.level);
	var redFloat:Float = ((achievementColor >> 16) & 0xFF) / 255;
	var greenFloat:Float = ((achievementColor >> 8) & 0xFF) / 255;
	var blueFloat:Float = (achievementColor & 0xFF) / 255;
	var deltaFloat:Float = (redFloat + greenFloat + blueFloat) / 3;

	var textColor:FlxColor = FlxColor.WHITE;
	if (deltaFloat > 0.5)
		textColor = FlxColor.BLACK;

	var textFormat = new TextFormat(Paths.getFontName(Paths.font("pixeloidsans.ttf")), 26, textColor);
	textFormat.align = 0;

	var achievementText:TextField = new TextField();
	achievementText.width = achievementPanel.width;
	achievementText.selectable = false;
	achievementText.embedFonts = true;
	achievementText.multiline = true;
	achievementText.wordWrap = true;
	achievementText.defaultTextFormat = textFormat;
	achievementText.text = translate("achievements.achievementGet");
	achievementText.height = 26;
	achievementText.alpha = 0;
	achievementText.height = achievementText.textHeight + 6;
	achievementToast.addChild(achievementText);
	objectCenter(achievementText, achievementPanel);

	var achievementLevel:Bitmap = new Bitmap(Assets.getBitmapData(Paths.image("achievements/levels/" + achLevel)));
	achievementLevel.scaleX = achievementScale;
	achievementLevel.scaleY = achievementScale;
	achievementLevel.x = achievementPanel.width;
	achievementToast.addChild(achievementLevel);

	var achievementSprite:Bitmap = new Bitmap(Assets.getBitmapData(Paths.image("achievements/" + data.ID)));
	achievementSprite.scaleX = achievementScale;
	achievementSprite.scaleY = achievementScale;
	achievementSprite.x = achievementLevel.x;
	achievementToast.addChild(achievementSprite);

    var nullSpot:Int = -1;
    var foundAchNull:Bool = false;
	for (i in 0...activeAchievements.length) {
		if (activeAchievements[i] == null) {
			foundAchNull = true;
			nullSpot = i;
            break;
        }
    }

	var magicValueUwU:Int = foundAchNull ? nullSpot : activeAchievements.length;

	achievementToast.x = FlxG.stage.stageWidth - achievementToast.width;
	achievementToast.y = (10 / popUpScale) + ((fullRatio + 1.01 * achievementScale) * magicValueUwU);
	var toastX:Float = FlxG.stage.stageWidth - achievementPanel.width - fullRatio - 20;
	var toastY:Float = 20 + ((fullRatio + 1.01 * achievementScale) * magicValueUwU);

	var colorShit:ColorTransform = new ColorTransform();
	colorShit.color = FlxColor.WHITE;

	achievementToast.transform.colorTransform = colorShit;

	achievementPanel.x += 32;
	achievementText.x += 32;

	var tween1:VarTween = new VarTween({ease: FlxEase.quartOut});
	var tween2:VarTween = new VarTween({ease: FlxEase.quartOut, onUpdate: _ -> {
        achievementToast.transform.colorTransform = colorShit;
    }});
	var tween3:VarTween = new VarTween({startDelay: 0.5, ease: FlxEase.quartOut});
	var tween4:VarTween = new VarTween({startDelay: 0.5, ease: FlxEase.quartOut});
	var tween5:VarTween = new VarTween({startDelay: 2, ease: FlxEase.quartOut});

	tween1.tween(achievementToast, {x: toastX, y: toastY, scaleX: 1, scaleY: 1}, 1);
	tween2.tween(colorShit, {redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1, redOffset: 0, greenOffset: 0, blueOffset: 0}, 1);
	tween3.tween(achievementPanel, {alpha: 1, x: 0}, 0.5);
	tween4.tween(achievementText, {alpha: 1, x: 0}, 0.5);
	tween5.tween(achievementText, {alpha: 0, x: 0}, 0.5);

	var tweenArray:Array<VarTween> = [tween1, tween2, tween3, tween4, tween5];

	FlxG.game.addChild(achievementToast);

	if (foundAchNull) {
		activeAchievements[magicValueUwU] = {
			data: data,
			sprite: achievementToast,
			panel: achievementPanel,
			text: achievementText,
			shownName: false,
			timer: 0
		};
		activeTweens[magicValueUwU] = tweenArray;
    } else {
		activeAchievements.push({
			data: data,
			sprite: achievementToast,
			panel: achievementPanel,
			text: achievementText,
			shownName: false,
			onFinish: false,
			timer: 0
		});
		activeTweens.push(tweenArray);
    }
}

var showAchTimer:Float = 2.5;
var maxTimer:Float = 6;
function update(elapsed:Float) {
	for (i => achievement in activeAchievements) {
		if (achievement == null) continue;

		achievement.timer += elapsed;

		for (tween in activeTweens[i])
			tween.update(elapsed);

		if (achievement.timer >= showAchTimer && !achievement.shownName) {
			if (achievement.text.alpha > 0) continue;

			achievement.shownName = true;

			var tween:VarTween = new VarTween({ease: FlxEase.quartOut});
			tween.tween(achievement.text, {alpha: 1}, 0.5);
			activeTweens[i].push(tween);

			achievement.text.text = achievement.data.name;
			achievement.text.height = achievement.text.textHeight + 6;
			objectCenter(achievement.text, achievement.panel);
		}

		if (achievement.timer >= maxTimer) {
			if (achievement.onFinish && achievement.sprite.alpha <= 0) {
				for (tween in activeTweens[i])
					tween.destroy();

				activeTweens[i] = null;
				dispose(achievement);
			}

			if (!achievement.onFinish) {
				achievement.onFinish = true;
				var lastTween:VarTween = new VarTween();
				lastTween.tween(achievement.sprite, {alpha: 0}, 0.2);
				activeTweens[i].push(lastTween);
			}
        }
    }
}

function dispose(achievement:Array<Dynamic>) {
	FlxG.game.removeChild(achievement.sprite);

	achievement.data = null;
	achievement.text = null;
	achievement.panel = null;
	achievement.sprite = null;

	var index:Int = activeAchievements.indexOf(achievement);
	activeAchievements[index] = null;
	achievement = null;
}

function disposeAll() {
	for (achievement in activeAchievements) {
		if (achievement == null) continue;
		FlxG.game.removeChild(achievement.sprite);

		achievement.text = null;
		achievement.panel = null;
		achievement.sprite = null;

		achievement = null;
    }

	activeAchievements = [];
}

public static function getAchievementLevelString(level:AchievementLevel):String {
    switch(level) {
		case AchievementLevel.BRONZE: return "bronze";
		case AchievementLevel.SILVER: return "silver";
		case AchievementLevel.GOLD: return "gold";
		case AchievementLevel.PLATINUM: return "platinum";
		case AchievementLevel.LOCKED: return "locked";
    }
}

public static function getAchievementLevelColor(level:AchievementLevel):FlxColor {
    switch(level) {
		case AchievementLevel.BRONZE: return 0xFF7A644F;
		case AchievementLevel.SILVER: return 0xFF9E9999;
		case AchievementLevel.GOLD: return 0xFFF8A514;
		case AchievementLevel.PLATINUM: return 0xFFB6C5E4;
		case AchievementLevel.LOCKED: return 0xFF292929;
    }
}

public static function getAchievementLevelPrize(level:AchievementLevel):Int {
    switch(level) {
        case AchievementLevel.BRONZE: return 100;
		case AchievementLevel.SILVER: return 200;
		case AchievementLevel.GOLD: return 500;
		case AchievementLevel.PLATINUM: return 1000;
		case AchievementLevel.LOCKED: return 0; // ur never supposed to get this lol
    }
}

public static function saveAchievements() {
	FlxG.save.data.impPixelAchievements = achievementsUnlocked;
}

function destroy() {
	disposeAll();
	activeAchievements = null;
}

class Achievement {
    public var ID:String;

    public var name:String;

    public var description:String;

    public var level:AchievementLevel;

    public var points:Null<Int>;

    public var progress:Int = 0;

	public function new(id:String, name:String, desc:String, level:AchievementLevel, ?points:Int) {
        this.ID = id;
        this.name = name;
        this.description = desc;
        this.level = level;
        this.points = points;
    }

	public function clone():Achievement {
		return new Achievement(ID, name, description, level, points);
    }
}