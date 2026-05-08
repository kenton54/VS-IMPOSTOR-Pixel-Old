package impostor.menus.mainmenu;

class TopButton extends FunkinSprite {
	public var onPress:Void->Void;

	public var enabled:Bool = true;

	public function new(button:String, ?x:Float, ?y:Float) {
		x ??= 0;
		y ??= 0;
		super(x, y);

		loadGraphic(Paths.image("menus/mainmenu/topButtons/" + button + "Button"), true, 14, 14);
		animation.add("idle", [0], 0, false);
		animation.add("press", [1], 0, false);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!enabled) return;

		var overlaps = pointerOverlaps(this, this.camera);

		if (overlaps) {
			if (pointerIsHolding())
				playAnim("press");
			else if (pointerJustReleased())
				press();
        }
        else
			playAnim("idle");
	}

	public function press() {
		playAnim("idle");
		if (onPress != null)
			onPress();
	}
}