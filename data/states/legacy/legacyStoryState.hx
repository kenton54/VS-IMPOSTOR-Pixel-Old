import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera.FlxCameraFollowStyle;
import funkin.savedata.FunkinSave;
import BackButton;

var chromaAbbr:CustomShader;

var camSpace:FlxCamera;
var camUI:FlxCamera;

var ship:FunkinSprite;
var weekCircles:FlxGroup;
var weekLines:FlxGroup;

var curWeek:Int = 0;
var idkAtThisPointMan:Array<FlxPoint> = [];

var scoreText:FunkinText;
var weekName:FunkinText;
var weekNumber:FunkinText;
var songList:FunkinText;
var weekIcon:FunkinSprite;
var weekLossIcon:FunkinSprite;

var ominousVignette:FlxSprite;

var hardcodedWeekDataLel:Array<Dynamic> = [
	{/* nothing */},
	{number: "Week 1", name: "Polus Problems", icon: "impostor", songs: ["Sussus Moogus", "Sabotage", "Meltdown"]},
	{number: "Week 2", name: "Mira Mania", icon: "crewmate", songs: ["Sussus Toogus", "Lights Down", "Reactor", "Ejected"]},
	{number: "Week 3", name: "Airship Atrocities", icon: "yellow", songs: ["Mando", "Dlow", "Oversight", "Danger", "Double Kill"]},
	{number: "FINALE", icon: "finale"},
	{number: "Week 5", name: "Magmatic Monstrosity", icon: "maroon", songs: ["Ashes", "Magmatic", "Boiling Point"]},
	{number: "Week 6", name: "Deadly Delusion", icon: "gray", songs: ["Delusion", "Blackout", "Neurotic"]},
	{number: "Week 7", name: "Humane Heartbeat", icon: "pink", songs: ["Heartbeat", "Pinkwave", "Pretender"]},
	{number: "Week J", name: "Jorsawsee's Jams", icon: "jorsawsee", songs: ["O2", "Voting Time", "Turbulence", "Victory"]},
	{number: "Henry", name: "Battling the Boyfriend", icon: "henry", songs: ["Titular", "Greatest Plan", "Reinforcements", "Armed"]},
	{number: "Tomongus", name: "Rousy Rival", icon: "tomongus", songs: ["Sussy Bussy", "Rivals", "Chewmate"]},
	{number: "Boo!", name: "Loggo's Halloween", icon: "fella", songs: ["Christmas", "Spookpostor"]},
];

function create() {
	changeDiscordStatus("In the Menus...?", "Story Mode");

	camSpace = new FlxCamera(0, 100);
	camSpace.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(camSpace, false);

	camUI = new FlxCamera();
	camUI.bgColor = FlxColor.TRANSPARENT;
	FlxG.cameras.add(camUI, false);

	chromaAbbr = new CustomShader("chromaticAbberation");
	chromaAbbr.amount = 0;
	camSpace.addShader(chromaAbbr);

	camSpace.zoom = 0.7;

	var stars1:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsBG"));
	stars1.setPosition(111.3, 67.95);
	stars1.antialiasing = !Options.lowMemoryMode;
	stars1.velocity.x = -10;
	stars1.camera = camSpace;
	add(stars1);

	var stars2:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsFG"));
	stars2.setPosition(54.3, 59.45);
	stars2.antialiasing = !Options.lowMemoryMode;
	stars2.velocity.x = -20;
	stars2.camera = camSpace;
	add(stars2);

	var ominousAura:FlxSprite = new FlxSprite(710, -500).loadGraphic(Paths.image("menus/legacy/story/finaleAura"));
	ominousAura.scale.set(2.5, 2.5);
	ominousAura.antialiasing = !Options.lowMemoryMode;
	ominousAura.camera = camSpace;
	add(ominousAura);

	weekCircles = new FlxGroup();
	add(weekCircles);

	weekLines = new FlxGroup();
	add(weekLines);

	ship = new FunkinSprite().loadSprite(Paths.image("menus/legacy/story/ship"));
	ship.antialiasing = !Options.lowMemoryMode;
	ship.offset.set(48, 24);
	ship.camera = camSpace;
	ship.angle = 90;
    add(ship);

    // wtf is this code...........
    for (i in 0...12) {
        var weekCircle:FlxSprite = new FlxSprite(0, 50).loadGraphic(Paths.image("menus/legacy/story/circle"));
		weekCircle.antialiasing = !Options.lowMemoryMode;
		weekCircle.camera = camSpace;

        if (i == 5) {
			weekCircle.y += 400;
        }
		if (i == 6) {
			weekCircle.x = -400;
			weekCircle.y += 400;
		}
		if (i == 7) {
			weekCircle.x = -800;
			weekCircle.y += 400;
		}
		if (i == 8) {
			weekCircle.x = 0;
			weekCircle.y -= 400;
		}
		if (i == 9) {
			weekCircle.x = 1200;
			weekCircle.y += 400;
		}
		if (i == 10) {
			weekCircle.x = 800;
			weekCircle.y += 400;
		}
		if (i == 11) {
			weekCircle.x = 800;
			weekCircle.y -= 400;
		}

        if (i < 5) {
			weekCircle.x = i * 400;

            if (i < 4) {
				var wkL1:FlxSprite = new FlxSprite(weekCircle.x + 95, 72).loadGraphic(Paths.image("menus/legacy/story/line"));
				wkL1.antialiasing = !Options.lowMemoryMode;
				wkL1.camera = camSpace;
				weekLines.add(wkL1);

				var wkL2:FlxSprite = new FlxSprite(weekCircle.x + 195, 72).loadGraphic(Paths.image("menus/legacy/story/line"));
				wkL2.antialiasing = !Options.lowMemoryMode;
				wkL2.camera = camSpace;
				weekLines.add(wkL2);

				var wkL3:FlxSprite = new FlxSprite(weekCircle.x + 295, 72).loadGraphic(Paths.image("menus/legacy/story/line"));
				wkL3.antialiasing = !Options.lowMemoryMode;
				wkL3.camera = camSpace;
				weekLines.add(wkL3);

				if (i == 3) {
					wkL1.color = 0xFFFFBFBF;
					wkL2.color = 0xFFFF8080;
					wkL3.color = 0xFFFF4040;
				}
            }
        }

        if (i == 4) {
			var wkL1:FlxSprite = new FlxSprite(-4, 165).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			wkL1.angle = 90;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(-4, 265).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			wkL2.angle = 90;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(-4, 365).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			wkL3.angle = 90;
			weekLines.add(wkL3);

			weekCircle.color = FlxColor.RED;
        }

        if (i > 4 && i < 7) {
			var wkL1:FlxSprite = new FlxSprite(weekCircle.x - 95, 472).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(weekCircle.x - 195, 472).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(weekCircle.x - 295, 472).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			weekLines.add(wkL3);
        }

        if (i == 8) {
			var wkL1:FlxSprite = new FlxSprite(-4, -27).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			wkL1.angle = 90;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(-4, -127).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			wkL2.angle = 90;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(-4, -227).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			wkL3.angle = 90;
			weekLines.add(wkL3);
        }

		if (i == 9) {
			var wkL1:FlxSprite = new FlxSprite(1197, 165).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			wkL1.angle = 90;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(1197, 265).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			wkL2.angle = 90;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(1197, 365).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			wkL3.angle = 90;
			weekLines.add(wkL3);
		}

		if (i == 10) {
			var wkL1:FlxSprite = new FlxSprite(797, 165).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			wkL1.angle = 90;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(797, 265).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			wkL2.angle = 90;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(797, 365).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			wkL3.angle = 90;
			weekLines.add(wkL3);
		}

		if (i == 11) {
			var wkL1:FlxSprite = new FlxSprite(797, -27).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL1.antialiasing = !Options.lowMemoryMode;
			wkL1.camera = camSpace;
			wkL1.angle = 90;
			weekLines.add(wkL1);

			var wkL2:FlxSprite = new FlxSprite(797, -127).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL2.antialiasing = !Options.lowMemoryMode;
			wkL2.camera = camSpace;
			wkL2.angle = 90;
			weekLines.add(wkL2);

			var wkL3:FlxSprite = new FlxSprite(797, -227).loadGraphic(Paths.image("menus/legacy/story/line"));
			wkL3.antialiasing = !Options.lowMemoryMode;
			wkL3.camera = camSpace;
			wkL3.angle = 90;
			weekLines.add(wkL3);
		}

		weekCircles.add(weekCircle);
		idkAtThisPointMan.push(FlxPoint.get(weekCircle.x, weekCircle.y - 50));
    }

	var border:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image("menus/legacy/story/border"));
	border.antialiasing = !Options.lowMemoryMode;
	border.camera = camUI;
	add(border);

	scoreText = new FunkinText(80, 170, 0, translate("legacy.highscore", [0]).toUpperCase(), 54);
	scoreText.font = Paths.font("amatic.ttf");
	scoreText.borderSize = 2;
	scoreText.camera = camUI;
	add(scoreText);

	weekIcon = new FunkinSprite(FlxG.width / 2.4 - 115, 55);
	weekIcon.camera = camUI;
	weekIcon.color = FlxColor.BLACK;
	add(weekIcon);

	weekLossIcon = new FunkinSprite(FlxG.width / 2.4 + 200, 55);
	weekLossIcon.camera = camUI;
	weekLossIcon.color = FlxColor.BLACK;
	add(weekLossIcon);

	setIcon("impostor");

	weekNumber = new FunkinText(FlxG.width / 2.4 - 10, 40, 0, "", 111);
	weekNumber.font = Paths.font("amatic.ttf");
	//weekNumber.alignment = "center";
	weekNumber.borderSize = 2.6;
	weekNumber.camera = camUI;
	add(weekNumber);

	weekName = new FunkinText(FlxG.width / 2.6, weekNumber.y + 115, 0, "", 64);
	weekName.font = Paths.font("amatic.ttf");
	//weekName.alignment = "center";
	weekName.borderSize = 2.2;
	weekName.camera = camUI;
	add(weekName);

	songList = new FunkinText(FlxG.width * 0.75, 55, 0, "", 32);
	songList.font = Paths.font("amatic.ttf");
	songList.alignment = "center";
	songList.camera = camUI;
	add(songList);

	var backButton:BackButton = new BackButton(85, 65, function() {
		if (!urDoomed) FlxG.switchState(new ModState("legacy/legacyMenuState"));
    }, 1, "menus/legacy/menuBack", false, true);
	backButton.antialiasing = !Options.lowMemoryMode;
	backButton.camera = camUI;
	add(backButton);

	ominousVignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
	ominousVignette.color = FlxColor.BLACK;
	ominousVignette.alpha = 0;
	ominousVignette.camera = camUI;
	add(ominousVignette);

	camSpace.follow(ship, FlxCameraFollowStyle.LOCKON, 1);

	scoreShuffleTimer.start(0.1, _ -> scoreShuffle(), 0);

	changeWeek(0);
}

var canMove:Bool = true;
var selected:Bool = false;
var urDoomed:Bool = false;
function update(elapsed:Float) {
	ship.x = lerp(ship.x, idkAtThisPointMan[curWeek].x, 0.15);
	ship.y = lerp(ship.y, idkAtThisPointMan[curWeek].y, 0.15);

	ominousVignette.alpha = 1 / (FlxMath.distanceToPoint(ship, FlxPoint.get(1631, 0)) / 100);
	chromaAbbr.amount = -3 / (FlxMath.distanceToPoint(ship, FlxPoint.get(1631, 0)) / 100);
	camSpace.shake(0.8 / FlxMath.distanceToPoint(ship, FlxPoint.get(1631, 0)) / 2, 0.05);
	camUI.shake(0.5 / FlxMath.distanceToPoint(ship, FlxPoint.get(1631, 0)) / 2, 0.05);
	shakeWindow(1.2 / FlxMath.distanceToPoint(ship, FlxPoint.get(1631, 0)) / 2, 0.05);

	if (!selected) {
		if (canMove) {
			switch (curWeek) {
				case 0:
					if (controls.RIGHT_P) {
						changeWeek(1);
						ship.angle = 90;
					} else if (controls.DOWN_P) {
						changeWeek(5);
						ship.angle = 180;
					} else if (controls.UP_P) {
						changeWeek(8);
						ship.angle = 0;
					}

				case 1:
					if (controls.LEFT_P) {
						changeWeek(-1);
						ship.angle = -90;
					} else if (controls.RIGHT_P) {
						changeWeek(1);
						ship.angle = 90;
					}

				case 2:
					if (controls.LEFT_P) {
						changeWeek(-1);
						ship.angle = -90;
					} else if (controls.RIGHT_P) {
						changeWeek(1);
						ship.angle = 90;
					} else if (controls.UP_P) {
						changeWeek(9);
						ship.angle = 0;
					} else if (controls.DOWN_P) {
						changeWeek(8);
						ship.angle = 180;
					}

				case 3:
					if (controls.LEFT_P) {
						changeWeek(-1);
						ship.angle = -90;
					} else if (controls.RIGHT_P) {
						changeWeek(1);
						ship.angle = 90;
					} else if (controls.DOWN_P) {
						changeWeek(6);
						ship.angle = 180;
					}

				case 4:
					canMove = false;
					urDoomed = true;

				case 5:
					if (controls.LEFT_P) {
						changeWeek(1);
						ship.angle = -90;
					} else if (controls.UP_P) {
						changeWeek(-5);
						ship.angle = 0;
					}

				case 6:
					if (controls.LEFT_P) {
						changeWeek(1);
						ship.angle = -90;
					} else if (controls.RIGHT_P) {
						changeWeek(-1);
						ship.angle = 90;
					}

				case 7:
					if (controls.RIGHT_P) {
						changeWeek(-1);
						ship.angle = 90;
					}

				case 8:
					if (controls.DOWN_P) {
						changeWeek(-8);
						ship.angle = 180;
					}

				case 9:
					if (controls.UP_P) {
						changeWeek(-6);
						ship.angle = 0;
					}

				case 10:
					if (controls.UP_P) {
						changeWeek(-8);
						ship.angle = 0;
					}

				case 11:
					if (controls.DOWN_P) {
						changeWeek(-9);
						ship.angle = 180;
					}
			}
        }
    }

	if (controls.BACK && !urDoomed)
		FlxG.switchState(new ModState("legacy/legacyMenuState"));
}

function changeWeek(change:Int) {
    curWeek += change;

    playMenuSound("scroll");

	if (curWeek >= -1 && curWeek < 5) {
		if (curWeek >= 5) curWeek = 0;
		if (curWeek < 0) curWeek = 4;
    }

	canMove = false;

	if (curWeek == 0) {
		scoreText.visible = false;
		weekNumber.visible = false;
		weekName.visible = false;
		songList.visible = false;
		weekIcon.visible = false;
		weekLossIcon.visible = false;
    } else {
		scoreText.visible = true;
		weekNumber.visible = true;
		weekName.visible = true;
		songList.visible = true;
		weekIcon.visible = true;
		weekLossIcon.visible = true;
    }

	if (curWeek == 4) {
		scoreShuffleTimer.cancel();

		weekNumber.text = hardcodedWeekDataLel[curWeek].number.toUpperCase();
		weekNumber.font = Paths.font("arial.ttf");
		weekNumber.color = FlxColor.RED;
		weekNumber.borderSize = 6;
		weekNumber.size = 140;
		weekNumber.letterSpacing = 15;
		weekNumber.x = (FlxG.width - weekNumber.width) / 2;
		weekNumber.y += 10;

		weekName.visible = false;
		songList.visible = false;
		weekLossIcon.visible = false;
		setIcon("black-finale");
		weekIcon.color = FlxColor.WHITE;
		weekIcon.scale.set(1.2, 1.2);
		weekIcon.updateHitbox();
		objectCenter(weekIcon, weekNumber);

		var weekData:Array<Dynamic> = FunkinSave.getWeekHighscore("finalePrologue", "hard");
		scoreText.text = translate("legacy.highscore", [weekData.score]);

		preventWindowClosure();
		urDoomed = true;

		return;
    }

	if (curWeek != 0) {
		weekNumber.text = hardcodedWeekDataLel[curWeek].number.toUpperCase();
		weekName.text = hardcodedWeekDataLel[curWeek].name.toUpperCase();
		weekNumber.x = (FlxG.width - weekNumber.width) / 2;
		weekName.x = (FlxG.width - weekName.width) / 2;
		setIcon(hardcodedWeekDataLel[curWeek].icon);

		weekIcon.y = 55;
		weekLossIcon.y = 55;

		switch(curWeek) {
			case 4:
				weekLossIcon.x = FlxG.width / 2.4 + 180;
			case 5:
				weekIcon.x = FlxG.width / 2.4 - 135;
				weekLossIcon.x = FlxG.width / 2.4 + 220;
				weekIcon.y = 45;
				weekLossIcon.y = 45;
			case 6:
				weekIcon.x = FlxG.width / 2.4 - 135;
				weekLossIcon.x = FlxG.width / 2.4 + 220;
				weekIcon.y = 45;
				weekLossIcon.y = 45;
			case 7:
				weekIcon.x = FlxG.width / 2.4 - 135;
				weekLossIcon.x = FlxG.width / 2.4 + 220;
				weekIcon.y = 40;
				weekLossIcon.y = 40;
			case 9:
				weekIcon.x = FlxG.width / 2.4 - 115;
				weekLossIcon.x = FlxG.width / 2.4 + 180;
				weekIcon.y = 40;
				weekLossIcon.y = 40;
			case 10:
				weekIcon.x = FlxG.width / 2.4 - 205;
				weekLossIcon.x = FlxG.width / 2.4 + 270;
			case 11:
				weekIcon.x = FlxG.width / 2.4 - 115;
				weekLossIcon.x = FlxG.width / 2.4 + 170;
				weekIcon.y = 45;
				weekLossIcon.y = 45;
			default:
				weekIcon.x = FlxG.width / 2.4 - 115;
				weekLossIcon.x = FlxG.width / 2.4 + 200;
		}

		var songs = hardcodedWeekDataLel[curWeek].songs;
		songList.text = "";
		for (i in 0...songs.length) {
			songList.text += songs[i] + (i == songs.length - 1 ? "" : "\n");
		}
		songList.text = songList.text.toUpperCase();

		switch (songs.length) {
			case 2:
				songList.size = 50;
				songList.borderSize = 1.8;
				songList.y = 75;
			case 3:
				songList.size = 40;
				songList.borderSize = 1.6;
				songList.y = 62;
			case 4:
				songList.size = 34;
				songList.borderSize = 1.5;
				songList.y = 55;
			case 5:
				songList.size = 26;
				songList.borderSize = 1.3;
				songList.y = 58;
			default:
				songList.size = 32;
				songList.borderSize = 1;
				songList.y = 55;
		}

		songList.x = (FlxG.width - songList.width) / 2 + 400;
	}

    new FlxTimer().start(0.08, _ -> canMove = true);
}

var scoreShuffleTimer:FlxTimer = new FlxTimer();
function scoreShuffle() {
	var numbers:Array<Int> = [];
	for (i in 0...8)
		numbers.push(FlxG.random.int(0, 9));

	var numberStr:String = "";
	for (num in numbers) numberStr += num;
	scoreText.text = translate("legacy.highscore", [numberStr]);
}

function setIcon(newIcon:String) {
	weekIcon.loadGraphic(Paths.image("menus/legacy/story/icons/icon-" + newIcon), true, 150, 150);
	weekIcon.animation.add("neutral", [0], 0, false);
	weekIcon.playAnim("neutral");

	weekLossIcon.loadGraphic(Paths.image("menus/legacy/story/icons/icon-" + newIcon), true, 150, 150);
	weekLossIcon.animation.add("loss", [1], 0, false);
	weekLossIcon.playAnim("loss");
}

function destroy() {
	camSpace.destroy();
	camUI.destroy();

    ship.destroy();
	weekCircles.destroy();
	weekLines.destroy();

	scoreShuffleTimer.destroy();
	stopWindowShake();
}