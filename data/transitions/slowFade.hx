var transOut:Bool = false;

function create(event) {
    event.cancel();

    transOut = event.transOut;

    var transDur:Float = FlxG.save.data.impPixelFastMenus ? 1 : 2;
    transitionCamera.fade(FlxColor.BLACK, transDur, !transOut);
    new FlxTimer().start(transDur, _ -> {
        finish();
    });
}