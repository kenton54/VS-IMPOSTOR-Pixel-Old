function create() {
    songUsesLightsSabotage = true;
	customSnowEmitterInit = true;
	hasBlue = true;
}

function postUIOverhaul() {
    camZooming = false;

    camGame.zoom = 0.4;
    camHUD.alpha = 0;

    camFollow.setPosition(132, -2400);
    camGame.snapToTarget();
}

function moogusIntroTween() {
    if (curStage == "Polus Lab (Outside)") emitSnowParticles();
	FlxTween.tween(camHUD, {alpha: 1}, (Conductor.stepCrochet / 1000) * 16);
}

function killCrewmateBesideBF() {
    if (curStage == "Polus Lab (Outside)") {
        dad.playAnim("shoot-front", true);
        boyfriend.playAnim("shock-front", true);
        flash();
    }
}

function killCrewmatePassingBy() {
    if (curStage == "Polus Lab (Outside)") {
        dad.playAnim("shoot-camera", true);
        boyfriend.playAnim("shock-camera", true);
        flash();
    }
}

function lightsOut() {
    sabotageLights();
}

function lightsBack() {
    fixLights();
}