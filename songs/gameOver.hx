import impostor.ImpostorCharacter;

var fixThisShit:Bool = false;

function onGameOver(event) {
	event.cancel();

	if (fixThisShit) return;

	inst.stop();
	vocals.stop();
	for (s in strumLines.members) if (s.vocals != null) s.vocals.stop();

	camGame.visible = false;
	camHUD.visible = false;
	camExtra.visible = false;

	persistentUpdate = false;
	persistentDraw = false;
	paused = true;

	openSubState(new ModSubState('game/gameOverScreen'));

	fixThisShit = true;
}

function onPostGameOver(event) {
	/*
	persistentDraw = true;

	FlxG.camera.stopFX();
	FlxTween.cancelTweensOf(FlxG.camera);

	var camPos:CamPosData = getCharactersCamPos(strumLines.members[1].characters);
	camFollow.setPosition(camPos.pos.x, camPos.pos.y);
	FlxG.camera.snapToTarget();
	FlxG.camera.zoom = 0.8;
	*/
}