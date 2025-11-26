function onEvent(camare) {
    if (camare.event.name == "Camera Fade") {
        var params = {
            color: camare.event.params[0],
            duration: camare.event.params[1],
            fadeFromColor: camare.event.params[2]
        };
        if (params.duration == 0) params.duration = 0.001;
        camGame.fade(params.color, (Conductor.stepCrochet / 1000) * params.duration, params.fadeFromColor, null, true);
    }
}