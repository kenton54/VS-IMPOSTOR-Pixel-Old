var transOut:Bool = false;

function create(event) {
	event.cancel();

	transOut = event.transOut;

	blackSpr = new FlxSprite(0, event.transOut ? transitionCamera.height : -transitionCamera.height).makeGraphic(1, 1, FlxColor.BLACK);
	blackSpr.scale.set(transitionCamera.width, transitionCamera.height);
	blackSpr.updateHitbox();
	blackSpr.camera = transitionCamera;
	add(blackSpr);

	transitionSprite = new FunkinSprite();
	transitionSprite.loadSprite(Paths.image("menus/transitions/funkinVerLine"));
	transitionSprite.setGraphicSize(transitionCamera.width, transitionCamera.height);
	transitionSprite.updateHitbox();
	transitionSprite.camera = transitionCamera;
	transitionSprite.flipY = true;
	add(transitionSprite);

	var transDur:Float = FlxG.save.data.impPixelFastMenus ? 1 / 3 : 2 / 3;
	transitionCamera.flipY = !event.transOut;
	transitionCamera.scroll.y = -transitionCamera.height;
	transitionTween = FlxTween.tween(transitionCamera, {"scroll.y": transitionCamera.height}, transDur, {
		ease: FlxEase.sineOut,
		onComplete: _ -> {
			finish();
		}
	});
}