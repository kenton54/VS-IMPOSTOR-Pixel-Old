import funkin.backend.MusicBeatState;
import hxvlc.flixel.FlxVideo;

var introVideo:FlxVideo;

function create() {
	modInitialized = true;

	changeDiscordStatus("Started Playing");

	FlxG.mouse.visible = false;

	MusicBeatState.skipTransIn = true;

	checkUpdates();
}

function update(elapsed:Float) {
	if (controls.ACCEPT || pointerJustPressed())
		checkUpdates();
}

function checkUpdates() {
	introVideo.stop();
	introVideo.dispose();
	FlxG.removeChild(introVideo);

	MusicBeatState.skipTransOut = true;

	setTransition("closingSharpCircle");
	FlxG.switchState(new ModState("options/impostorUpdateChecker"));
}