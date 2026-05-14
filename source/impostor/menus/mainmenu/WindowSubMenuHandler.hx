package impostor.menus.mainmenu;

import flixel.math.FlxRect;

class WindowSubMenuHandler extends FlxBasic {
	public var isOpen(default, null):Bool;

	public var titleText(default, null):FunkinText;

	public var closeButton(default, null):BackButton;

	public var curSubMenu(default, null):WindowSubMenu;

	public var enabled:Bool = true;

	public var onOpen:Void->Void;

	public var onClose:Void->Void;

	public var windowCamera(default, null):FlxCamera;

	var background:FlxSprite;
	var line:FlxSprite;

	var _mainRect:FlxRect;
	var _subMenuRect:FlxRect;

	public function new(camera:FlxCamera, ?scale:Float) {
		scale ??= 5;

		super();

		this.camera = camera;

		background = new FlxSprite().makeGraphic(camera.width, camera.height, 0xFF505050);
		background.scrollFactor.set();
		background.alpha = 0.7;
		background.camera = this.camera;

		closeButton = new BackButton(scale, scale, () -> {
            playMenuSound("cancel");
            close(true);
		}, scale, "menus/x", false, true);
		closeButton.scrollFactor.set();
		closeButton.camera = this.camera;

		line = new FlxSprite(0, closeButton.y + closeButton.height + scale).makeGraphic(background.width, scale, FlxColor.WHITE);
		line.scrollFactor.set();
		line.camera = this.camera;

		var titlePos:Float = 2 * scale;
		titleText = new FunkinText(titlePos, line.y / 2, background.width - titlePos * 2, "", 56 * gameScale.y, false);
		titleText.font = Paths.font("pixeloidsans.ttf");
		titleText.alignment = "right";
		titleText.scrollFactor.set();
		titleText.y -= titleText.height / 2;
		titleText.camera = this.camera;

		_mainRect = new FlxRect(0, 0, camera.width, line.y + line.height);
		_subMenuRect = new FlxRect(0, _mainRect.height, _mainRect.width, FunkinMath.distanceBetweenFloats(_mainRect.y + _mainRect.height, camera.height));

		windowCamera = new FlxCamera(camera.x, camera.y + _subMenuRect.y, camera.width, _subMenuRect.height);
		windowCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.insert(windowCamera, FlxG.cameras.list.indexOf(this.camera) + 1, false);

		kill();
		isOpen = false;
	}

	override public function update(elapsed:Float) {
		if (!enabled || !isOpen) return;

		super.update(elapsed);

		background.update(elapsed);
		line.update(elapsed);
		titleText.update(elapsed);
		closeButton.update(elapsed);

		curSubMenu?.update(elapsed);
		curSubMenu?.updateMenu(elapsed);
	}

	override public function draw() {
		if (!isOpen) return;

		super.draw();

		background.draw();
		line.draw();
		titleText.draw();
		closeButton.draw();

		curSubMenu?.draw();
		curSubMenu?.drawMenu();
	}

	public function open(subMenu:WindowSubMenu) {
		if (subMenu == null) return;

		curSubMenu?.destroy();

		revive();

        curSubMenu = subMenu;
        curSubMenu.camera = windowCamera;
		curSubMenu.area = _subMenuRect;
        curSubMenu.init(this);
        curSubMenu.create();
        titleText.text = curSubMenu.name;

		isOpen = true;

		if (onOpen != null)
			onOpen();
	}

	public function close(?trigger:Bool) {
		if (!isOpen) return;

		trigger ??= false;

		if (curSubMenu != null) {
			curSubMenu.destroy();
			curSubMenu = null;
		}

		windowCamera.scroll.set();
		windowCamera.minScrollX = null;
		windowCamera.minScrollY = null;
		windowCamera.maxScrollX = null;
		windowCamera.maxScrollY = null;

		playMenuSound("cancel");

		isOpen = false;

		if (onClose != null && trigger)
			onClose();

		kill();
	}

	override public function revive() {
		background.revive();
		closeButton.revive();
		line.revive();
		titleText.revive();

		closeButton.reset();

		super.revive();
	}

	override public function kill() {
		background.kill();
		closeButton.kill();
		line.kill();
		titleText.kill();

		super.kill();
	}

	override public function destroy() {
		super.destroy();

		background.destroy();
		closeButton.destroy();
		line.destroy();
		titleText.destroy();

		curSubMenu?.destroy();
	}
}