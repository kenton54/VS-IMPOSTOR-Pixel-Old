import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.util.FlxGradient;
import funkin.options.Options;
import impostor.ImpostorCharacter;
import StarsBackdrop;

public var songUsesLightsSabotage:Bool = false;
public var customSnowEmitterInit:Bool = false;
public var makeCrowdAppear:Bool = false;
public var hasBlue:Bool = false;

public var darkDadChar:ImpostorCharacter;
public var darkBoyfriendChar:ImpostorCharacter;
public var darkGfChar:ImpostorCharacter;

public var snowParticles:FlxTypedEmitter;

var stars:StarsBackdrop;

var skyGradient:FlxSprite;

var polusShader:CustomShader;

function create() {
	polusShader = new CustomShader("adjustColor");
	polusShader.brightness = -12.0;
	polusShader.hue = -18.0;
	polusShader.contrast = -30.0;
	polusShader.saturation = -6.0;

    skyGradient = FlxGradient.createGradientFlxSprite(FlxG.width * 4, FlxG.height * 3, [0x0023193B, 0x8023193B, 0xFF755387]);
    skyGradient.setPosition(-1400, -1200);
    skyGradient.scrollFactor.set(0.1, 0.1);
    insert(0, skyGradient);

	stars = new StarsBackdrop(-10, 3);
    stars.scrollFactor = FlxPoint.get(0.05, 0.05);
    insert(0, stars);

    snowParticles = new FlxTypedEmitter(-1600, -800, 180);
    snowParticles.makeParticles(5, 5, FlxColor.WHITE, 100);
    snowParticles.launchAngle.set(120, 60);
    snowParticles.speed.set(100, 250, 200, 800);
    snowParticles.scale.set(1, 1, 3, 3);
    snowParticles.lifespan.set(1800, 1800);
    snowParticles.keepScaleRatio = true;
    snowParticles.width = FlxG.width * 2.5;
    snowParticles.camera = camGame;
    add(snowParticles);

	if (!Options.naughtyness) {
        var x:Float = 6;
        var y:Float = 14;

		deadBanana.x += x * deadBanana.scale.x + 2;
		deadBanana.y -= y * deadBanana.scale.x;
		deadBanana.loadSprite(Paths.image("stages/polus1/dead-banana-sentitive"));
		deadBanana.addAnim("idle", "idle normal", 0);

		deadBanana_dark.x += x * deadBanana_dark.scale.x + 2;
		deadBanana_dark.y -= y * deadBanana.scale.x;
		deadBanana_dark.loadSprite(Paths.image("stages/polus1/dead-banana-sentitive"));
		deadBanana_dark.addAnim("idle", "idle dark", 0);
    }

	deadBanana.shader = polusShader;
}

function postCreate() {
	if (!customSnowEmitterInit)
		emitSnowParticles();

	if (!hasBlue) {
        remove(blue);
        remove(blue_dark);
        blue.destroy();
        blue_dark.destroy();
    }
    else
		blue.shader = polusShader;
}

public function emitSnowParticles() {
	if (snowParticles != null) snowParticles.start(false, 0.08);
}

function onCharacterSetup(character:ImpostorCharacter) {
    character.shader = polusShader;
}

function postCharacterSetup() {
    if (!songUsesLightsSabotage) return;

	darkDadChar = new ImpostorCharacter(dad.x, dad.y, dad.curCharacter + "-lightsOut", false);
    darkDadChar.visible = false;
    dad.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
        darkDadChar.playAnim(name, force, "LOCK", reverse, frame);
    });

	darkBoyfriendChar = new ImpostorCharacter(boyfriend.x, boyfriend.y, boyfriend.curCharacter + "-lightsOut", true);
    darkBoyfriendChar.visible = false;
    boyfriend.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
        darkBoyfriendChar.playAnim(name, force, "LOCK", reverse, frame);
    });

	darkGfChar = new ImpostorCharacter(gf.x, gf.y, gf.curCharacter + "-lightsOut", false);
    darkGfChar.visible = false;
    gf.onPlayAnim.add(function(name:String, force:Bool, context:Dynamic, reverse:Bool, frame:Int) {
        darkGfChar.playAnim(name, force, "LOCK", reverse, frame);
    });

    insert(members.indexOf(dad) + 1, darkDadChar);
    insert(members.indexOf(boyfriend) + 1, darkBoyfriendChar);
    insert(members.indexOf(gf) + 1, darkGfChar);
}

public function flash() {
    medbay_normal.setColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
    labWall_normal.setColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
    labEntrance_normal.setColorTransform(1, 1, 1, 1, 255, 255, 255, 1);
    ground_normal.setColorTransform(1, 1, 1, 1, 255, 255, 255, 1);

    gf.playAnim("shock", true);

    // 2 frames of a 24 animation framerate
    new FlxTimer().start(2 / 24, _ -> {
        medbay_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        labWall_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        labEntrance_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
        ground_normal.setColorTransform(1, 1, 1, 1, 0, 0, 0, 1);
    });
}

var lightsSabotaged:Bool = false;

public function sabotageLights() {
    if (!songUsesLightsSabotage) return;

    camGame.flash();
    medbay_dark.visible = true;
    labWall_dark.visible = true;
    labEntrance_dark.visible = true;
    ground_dark.visible = true;
	deadBanana_dark.visible = true;
    if (blue_dark != null) blue_dark.visible = true;

    darkDadChar.visible = true;
    darkBoyfriendChar.visible = true;
    darkGfChar.visible = true;

    lightsSabotaged = true;
}

public function fixLights() {
    if (!songUsesLightsSabotage) return;
    if (!lightsSabotaged) return;

    FlxTween.cancelTweensOf(medbay_dark, ["alpha"]);
    FlxTween.cancelTweensOf(labWall_dark, ["alpha"]);
    FlxTween.cancelTweensOf(labEntrance_dark, ["alpha"]);
    FlxTween.cancelTweensOf(ground_dark, ["alpha"]);
    FlxTween.cancelTweensOf(deadBanana_dark, ["alpha"]);
	if (blue_dark != null) FlxTween.cancelTweensOf(blue_dark, ["alpha"]);
    FlxTween.cancelTweensOf(darkDadChar, ["alpha"]);
    FlxTween.cancelTweensOf(darkBoyfriendChar, ["alpha"]);
    FlxTween.cancelTweensOf(darkGfChar, ["alpha"]);
    FlxTween.tween(medbay_dark, {alpha: 0}, 1, {onComplete: _ -> {
        medbay_dark.visible = false;
    }});
    FlxTween.tween(labWall_dark, {alpha: 0}, 1, {onComplete: _ -> {
        labWall_dark.visible = false;
    }});
    FlxTween.tween(labEntrance_dark, {alpha: 0}, 1, {onComplete: _ -> {
        labEntrance_dark.visible = false;
    }});
    FlxTween.tween(ground_dark, {alpha: 0}, 1, {onComplete: _ -> {
        ground_dark.visible = false;
    }});
    FlxTween.tween(deadBanana_dark, {alpha: 0}, 1, {onComplete: _ -> {
        deadBanana_dark.visible = false;
    }});
	if (blue_dark != null)
        FlxTween.tween(blue_dark, {alpha: 0}, 1, {onComplete: _ -> {
			blue_dark.visible = false;
        }});
    FlxTween.tween(darkDadChar, {alpha: 0}, 1, {onComplete: _ -> {
        darkDadChar.visible = false;
    }});
    FlxTween.tween(darkBoyfriendChar, {alpha: 0}, 1, {onComplete: _ -> {
        darkBoyfriendChar.visible = false;
    }});
    FlxTween.tween(darkGfChar, {alpha: 0}, 1, {onComplete: _ -> {
        darkGfChar.visible = false;
    }});

    lightsSabotaged = false;
}

function update(elapsed:Float) {
    if (songUsesLightsSabotage) {
        darkBoyfriendChar.lastHit = boyfriend.lastHit;
        darkDadChar.lastHit = dad.lastHit;
    }
}