package impostor.menus.mainmenu;

enum SelectingPromtOption {
	NONE;
	YES;
	NO;
}

class ExitPrompt {
	public var isOpen(default, null):Bool = false;

	public var onOpen:Void->Void;

	public var onClose:Void->Void;

	var prompt:FlxSpriteGroup;

	var bg:FlxSprite;
	var promptBackground:ResizableUIBox;
	var promptText:FunkinText;
	var no:FunkinText;
	var yes:FunkinText;

	var promptCam:FlxCamera;

	public function new() {}

	public function open() {
		if (prompt != null || isOpen)
			return;

		playMenuSound("cancel");

		promptCam = new FlxCamera();
		promptCam.bgColor = 0x0;
		FlxG.cameras.add(promptCam, false);

		prompt = new FlxSpriteGroup();
		prompt.camera = promptCam;
		FlxG.state.add(prompt);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		prompt.add(bg);

		promptBackground = new ResizableUIBox(0, 0, 640, 180);
		promptBackground.screenCenter();
		prompt.add(promptBackground.box);

		var limits:Float = 4 * 4;
		promptText = new FunkinText(promptBackground.x + limits, promptBackground.y + promptBackground.height / 8, promptBackground.width - limits * 2,
			translate("mainMenu.exitPrompt"), 32, false);
		promptText.font = Paths.font("pixeloidsans.ttf");
		promptText.alignment = "center";
		prompt.add(promptText);

		no = new FunkinText(promptText.x + promptText.width / 6, promptText.y + promptBackground.height / 2, 100, translate("no"), 40, false);
		no.font = Paths.font("pixeloidsans.ttf");
		no.alignment = "center";
		no.alpha = 0.5;
		prompt.add(no);

		yes = new FunkinText(promptText.x + promptText.width / 2 + promptText.width / 6, no.y, 100, translate("yes"), 40, false);
		yes.font = Paths.font("pixeloidsans.ttf");
		yes.alignment = "center";
		yes.alpha = 0.5;
		prompt.add(yes);

		if (onOpen != null)
			onOpen();

		isOpen = true;
	}

	public function close() {
		if (prompt == null || !isOpen)
			return;

		playMenuSound("cancel");

		FlxG.cameras.remove(promptCam);

		bg.destroy();
		promptBackground.destroy();
		promptText.destroy();
		no.destroy();
		yes.destroy();
		prompt.destroy();
		prompt = null;

		curSelection = SelectingPromtOption.NONE;
		_isHoveringSmth = false;

		if (onClose != null)
			onClose();

		isOpen = false;
	}

	var curSelection:SelectingPromtOption = SelectingPromtOption.NONE;

	public function pressedLeft() {
		if (curSelection == SelectingPromtOption.NO)
			return;

		playMenuSound("scroll");
		curSelection = SelectingPromtOption.NO;
		updateSelection();
	}

	public function pressedRight() {
		if (curSelection == SelectingPromtOption.YES)
			return;

		playMenuSound("scroll");
		curSelection = SelectingPromtOption.YES;
		updateSelection();
	}

	public function pressedConfirm()
		checkSelection();

	var _isHoveringSmth:Bool = false;

	public function updatePointer() {
		if (prompt == null && !isOpen)
			return;

		if (pointerOverlaps(no, promptCam)) {
			if (!_isHoveringSmth) {
				_isHoveringSmth = true;
				playMenuSound("scroll");
				curSelection = SelectingPromtOption.NO;
				updateSelection();
				setMouseCursor("button");
			}
		} else if (pointerOverlaps(yes, promptCam)) {
			if (!_isHoveringSmth) {
				_isHoveringSmth = true;
				playMenuSound("scroll");
				curSelection = SelectingPromtOption.YES;
				updateSelection();
				setMouseCursor("button");
			}
		} else {
			_isHoveringSmth = false;
			curSelection = SelectingPromtOption.NONE;
			updateSelection();
			setMouseCursor();
		}

		if (pointerJustReleased())
			checkSelection();
	}

	function updateSelection() {
		no.alpha = 0.5;
		yes.alpha = 0.5;

		if (curSelection == SelectingPromtOption.YES)
			yes.alpha = 1;
		if (curSelection == SelectingPromtOption.NO)
			no.alpha = 1;
	}

	function checkSelection() {
		switch (curSelection) {
			case SelectingPromtOption.YES:
				accept();
			case SelectingPromtOption.NO:
				decline();
		}
	}

	function accept() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut();

		playMenuSound("confirm");

		FlxG.cameras.list[FlxG.cameras.list.length - 1].fade();

		new FlxTimer().start(1.05, _ -> System.exit(0));
	}

	function decline()
		close();
}