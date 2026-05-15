import funkin.backend.MusicBeatState;
import funkin.editors.charter.Charter;
import impostor.BackButton;

var camGameOver:FlxCamera;

var blackBackground:FunkinSprite;

var retryButton:BackButton;
var exitButton:BackButton;

final baseScale:Float = 4;

function create() {
	camGameOver = new FlxCamera();
	camGameOver.bgColor = 0x0;
	FlxG.cameras.add(camGameOver, false);

	playSound("gameOverSFX");

	retryButton = new BackButton(FlxG.width, FlxG.height, () -> {
		MusicBeatState.skipTransIn = true;
		FlxG.resetState();
	}, baseScale, "menus/retry", false, true);
	retryButton.x -= retryButton.width + baseScale;
	retryButton.y -= retryButton.height + baseScale;
	retryButton.camera = camGameOver;
	retryButton.visible = false;
	add(retryButton);

	exitButton = new BackButton(baseScale, FlxG.height, () -> {
		if (PlayState.chartingMode) {
			setTransition("closingSharpCircle");
			MusicBeatState.skipTransIn = true;
			FlxG.switchState(new Charter(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.variation, false));
		}
		else
			FlxG.switchState(new FreeplayState());
	}, baseScale, "menus/quit", false, true);
	exitButton.y -= exitButton.height + baseScale;
	exitButton.camera = camGameOver;
	exitButton.visible = false;
	add(exitButton);
}

var waitTimer:Float = 0;

function update(elapsed:Float) {
	if (waitTimer < 1)
		waitTimer += elapsed;
	else {
		retryButton.visible = true;
		exitButton.visible = true;
	}
}