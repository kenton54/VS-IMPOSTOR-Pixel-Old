import flixel.FlxObject;
import BackButton;

var opponent:Character;

var blackBackground:FunkinSprite;

var retryButton:BackButton;
var exitButton:BackButton;

function create(event) {
    event.cancel();

	blackBackground = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blackBackground.scrollFactor.set();
	blackBackground.zoomFactor = 0;
	blackBackground.alpha = 0;
	add(blackBackground);

	var playStateOpponent = PlayState.instance.dad;
	opponent = new Character(playStateOpponent.x, playStateOpponent.y, playStateOpponent.curCharacter, false);
	opponent.danceOnBeat = false;
	opponent.playAnim('kill', false, "LOCK");
	opponent.shader = playStateOpponent.shader;
	add(opponent);

    var boyfriend = PlayState.instance.boyfriend;
	character = new Character(boyfriend.x, boyfriend.y, boyfriend.curCharacter, true);
	character.danceOnBeat = false;
	character.playAnim('deathStart');
	character.shader = boyfriend.shader;
	add(character);

	var camPos:FlxPoint = FlxPoint.get(character.x + character.width / 2, character.y);
	camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);
	add(camFollow);

	FlxG.camera.target = camFollow;
	FlxG.camera.followLerp = 0.02;

	FlxTween.tween(blackBackground, {alpha: 1}, 1);
	FlxTween.tween(opponent, {alpha: 0}, 1, {startDelay: 1, onComplete: _ -> opponent.destroy()});
}