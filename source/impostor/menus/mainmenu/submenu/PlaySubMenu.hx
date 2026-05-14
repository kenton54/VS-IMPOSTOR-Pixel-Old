package impostor.menus.mainmenu.submenu;

import impostor.menus.mainmenu.WindowSubMenu.WindowButton;

class PlaySubMenu extends WindowSubMenu {
	var worldmapButton:WindowButton;
	var freeplayButton:WindowButton;
	var tutorialButton:WindowButton;

	var selectingFreeplay:Bool = false;
	var selectingTutorial:Bool = false;

	public function new(?scale:Float) {
		super(translate("generic.play"), scale);
	}

	override function create() {
		super.create();

		worldmapButton = new WindowButton(this.area.width / 2, 3 * this.scale);
		createBigButton(worldmapButton, Paths.image('menus/mainmenu/bigButtons/worldmap-dead'), translate('questionMarks'));
		worldmapButton.x -= Math.round(worldmapButton.width + 0.5 * this.scale);
		worldmapButton.available = false;
		add(worldmapButton);

		freeplayButton = new WindowButton(this.area.width / 2, 3 * this.scale);
		createBigButton(freeplayButton, Paths.image('menus/mainmenu/bigButtons/freeplay'), translate('generic.freeplay'));
		freeplayButton.x += Math.round(0.5 * this.scale);
		freeplayButton.available = true;
		add(freeplayButton);

		tutorialButton = new WindowButton(this.area.width / 2, worldmapButton.y + worldmapButton.height + this.scale);
		tutorialButton.idleColor = 0xFFAAE2DC;
		tutorialButton.hoverColor = 0xFFFFFFFF;

		tutorialButton.button.loadGraphic(Paths.image('menus/mainmenu/bigButtons/tutorial-dead'), true, 72, 12);
		tutorialButton.button.animation.add('idle', [0], 0, false);
		tutorialButton.button.animation.add('hover', [1], 0, false);
		tutorialButton.button.animation.add('locked', [2], 0, false);
		tutorialButton.button.playAnim('idle');
		tutorialButton.button.scale.set(this.scale);
		tutorialButton.button.updateHitbox();

		tutorialButton.label.text = translate('questionMarks');
		tutorialButton.label.font = Paths.font('pixeloidsans.ttf');
		tutorialButton.label.y = tutorialButton.y + 2 * this.scale;
		tutorialButton.label.fieldWidth = tutorialButton.button.width;
		tutorialButton.label.size = 28;
		tutorialButton.label.alignment = "center";

		tutorialButton.x -= tutorialButton.width / 2;
		tutorialButton.available = false;
		add(tutorialButton);

		changeSelection(false, false);
	}

	function createBigButton(group:WindowButton, image:String, text:String) {
		group.idleColor = 0xFF0A3C33;
		group.hoverColor = 0xFF10584B;

		group.button.loadGraphic(image, true, 56, 55);
		group.button.animation.add('idle', [0], 0, false);
		group.button.animation.add('hover', [1], 0, false);
		group.button.animation.add('locked', [2], 0, false);
		group.button.playAnim('idle');
		group.button.scale.set(this.scale);
		group.button.updateHitbox();

		group.label.text = text;
		group.label.font = Paths.font('pixeloidsans.ttf');
		group.label.y = group.y + 44 * this.scale;
		group.label.fieldWidth = group.button.width;
		group.label.size = 30;
		group.label.alignment = "center";
	}

	override public function updateMenu(elapsed:Float) {
		if (controls.LEFT_P || controls.RIGHT_P) {
			changeSelection(true, false);
		}
		if (controls.UP_P || controls.DOWN_P) {
			changeSelection(false, true);
		}

		super.updateMenu(elapsed);
	}

	function changeSelection(changeFreeplay:Bool, changeTutorial:Bool) {
		if (changeFreeplay)
			selectingFreeplay = true;

		if (changeTutorial)
			selectingTutorial = false;

		updateButtons();

		if (changeFreeplay || changeTutorial)
			playMenuSound("scroll");
	}

	function updateButtons() {
        if (selectingTutorial) {
            worldmapButton.hovering = freeplayButton.hovering = false;
            tutorialButton.hovering = true;
        }
        else {
            worldmapButton.hovering = !selectingFreeplay;
            freeplayButton.hovering = selectingFreeplay;
            tutorialButton.hovering = false;
        }
	}
}