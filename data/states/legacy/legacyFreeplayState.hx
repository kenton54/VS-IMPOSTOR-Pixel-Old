import flixel.addons.display.FlxBackdrop;
import funkin.backend.MusicBeatGroup;
import impostor.BackButton;
import RimlightShader;

var backGlow:FlxSprite;
var portraits:FunkinSprite;

var rimlightShader:CustomShader;

var scoreText:FunkinText;
var ratingText:FunkinText;

var songCards:FlxGroup;

var curSelect:Int = 0;
var curPage:Int = 0;
var hardcodedListOfSongsLel:Array<Dynamic> = [
    [
        {song: "Sussus Moogus", portrait: "red", color: FlxColor.RED},
		{song: "Sabotage", portrait: "red", color: FlxColor.RED},
		{song: "Meltdown", portrait: "red", color: FlxColor.RED},
		{song: "Sussus Toogus", portrait: "green", color: 0xFF00FF00},
		{song: "Lights Down", portrait: "green", color: 0xFF00FF00},
		{song: "Reactor", portrait: "green", color: 0xFF00FF00},
		{song: "Ejected", portrait: "para", color: 0xFF00FF00},
		{song: "Mando", portrait: "yellow", color: 0xFFFFDA43},
		{song: "Dlow", portrait: "yellow", color: 0xFFFFDA43},
		{song: "Oversight", portrait: "white", color: FlxColor.WHITE},
		{song: "Danger", portrait: "black", color: 0xFFB300FF},
		{song: "Double Kill", portrait: "black", color: 0xFFB300FF},
		{song: "Defeat", portrait: "black", color: 0xFFB300FF},
		{song: "Finale", portrait: "finale", color: 0xFFB300FF},
		{song: "Identity Crisis", portrait: "monotone", color: FlxColor.BLACK},
    ],
	[
		{song: "Ashes", portrait: "maroon", color: 0xFFB50000},
		{song: "Magmatic", portrait: "maroon", color: 0xFFB50000},
		{song: "Boiling Point", portrait: "maroon", color: 0xFFB50000},
		{song: "Delusion", portrait: "grey", color: 0xFF8B9DA8},
		{song: "Blackout", portrait: "grey", color: 0xFF8B9DA8},
		{song: "Neurotic", portrait: "grey", color: 0xFF8B9DA8},
		{song: "Heartbeat", portrait: "pink", color: 0xFFFF00DE},
		{song: "Pinkwave", portrait: "pink", color: 0xFFFF00DE},
		{song: "Pretender", portrait: "pink", color: 0xFFFF00DE},
		{song: "Sauces Moogus", portrait: "chef", color: 0xFFF2721C},
	],
    [
		{song: "O2", portrait: "jorsawsee", color: 0xFF267FE6},
		{song: "Voting Time", portrait: "warchief", color: 0xFF9943C4},
		{song: "Turbulence", portrait: "redmungus", color: FlxColor.RED},
		{song: "Victory", portrait: "warchief", color: 0xFF9943C4},
		{song: "ROOMCODE", portrait: "powers", color: 0xFF50ADEB},
    ],
	[
		{song: "Sussy Bussy", portrait: "tomo", color: 0xFFFF5A86},
		{song: "Rivals", portrait: "tomo", color: 0xFFFF5A86},
		{song: "Chewmate", portrait: "ham", color: 0xFFFF5A86},
		{song: "Tomongus Tuesday", portrait: "tomo", color: 0xFFFF5A86},
	],
	[
		{song: "Christmas", portrait: "loggo", color: 0xFF00FF00},
		{song: "Spookpostor", portrait: "loggo", color: 0xFF00FF00},
	],
	[
		{song: "Titular", portrait: "tit", color: FlxColor.ORANGE},
		{song: "Greatest Plan", portrait: "charles", color: FlxColor.RED},
		{song: "Reinforcements", portrait: "ellie", color: FlxColor.ORANGE},
		{song: "Armed", portrait: "rhm", color: FlxColor.ORANGE},
	],
	[
		{song: "Alpha Moogus", portrait: "oldpostor", color: FlxColor.RED},
		{song: "Actin Sus", portrait: "oldpostor", color: FlxColor.RED},
	],
	[
		{song: "Ow", portrait: "kills", color: 0xFF54A7CA},
		{song: "Who", portrait: "who", color: 0xFF1641F0},
		{song: "Insane Streamer", portrait: "jerma", color: FlxColor.BLACK},
		{song: "Sussus Nuzzus", portrait: "nuzzus", color: FlxColor.BLACK},
		{song: "Idk", portrait: "idk", color: 0xFFFF8CB1},
		{song: "Esculent", portrait: "esculent", color: FlxColor.BLACK},
		{song: "Drippypop", portrait: "pop", color: 0xFFBC6ADF},
		{song: "Crewicide", portrait: "dave", color: FlxColor.BLUE},
		{song: "Monotone Attack", portrait: "monotoner", color: FlxColor.WHITE},
		{song: "Top 10", portrait: "top", color: FlxColor.RED},
	],
	[
		{song: "Chippin", portrait: "chips", color: 0xFFFF3C26},
		{song: "Chipping", portrait: "chips", color: 0xFFFF3C26},
		{song: "Torture", portrait: "torture", color: 0xFFBC6ADF},
	]
];

function create() {
	changeDiscordStatus("In the Menus...?", "Freeplay");

	var stars1:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsBG"));
	stars1.antialiasing = !Options.lowMemoryMode;
	stars1.velocity.x = -10;
	stars1.scrollFactor.set(0, 0);
	add(stars1);

	var stars2:FlxBackdrop = new FlxBackdrop(Paths.image("menus/legacy/starsFG"));
	stars2.antialiasing = !Options.lowMemoryMode;
	stars2.velocity.x = -20;
	stars2.scrollFactor.set(0, 0);
	add(stars2);

	backGlow = new FlxSprite(-11.1, -12.65).loadGraphic(Paths.image("menus/legacy/freeplay/backGlow"));
    backGlow.antialiasing = !Options.lowMemoryMode;
	backGlow.scrollFactor.set(0, 0);
    add(backGlow);

	portraits = new FunkinSprite(304.65, -100).loadSprite(Paths.image("menus/legacy/freeplay/portraits"));
	portraits.addAnim('red', 'Character', 24, true, null, [1]);
	portraits.addAnim('yellow', 'Character', 24, true, null, [2]);
	portraits.addAnim('green', 'Character', 24, true, null, [3]);
	portraits.addAnim('tomo', 'Character', 24, true, null, [4]);
	portraits.addAnim('ham', 'Character', 24, true, null, [5]);
	portraits.addAnim('black', 'Character', 24, true, null, [6]);
	portraits.addAnim('white', 'Character', 24, true, null, [7]);
	portraits.addAnim('para', 'Character', 24, true, null, [8]);
	portraits.addAnim('pink', 'Character', 24, true, null, [9]);
	portraits.addAnim('maroon', 'Character', 24, true, null, [10]);
	portraits.addAnim('grey', 'Character', 24, true, null, [11]);
	portraits.addAnim('chef', 'Character', 24, true, null, [12]);
	portraits.addAnim('tit', 'Character', 24, true, null, [13]);
	portraits.addAnim('ellie', 'Character', 24, true, null, [14]);
	portraits.addAnim('rhm', 'Character', 24, true, null, [15]);
	portraits.addAnim('loggo', 'Character', 24, true, null, [16]);
	portraits.addAnim('clow', 'Character', 24, true, null, [17]);
	portraits.addAnim('ziffy', 'Character', 24, true, null, [18]);
	portraits.addAnim('chips', 'Character', 24, true, null, [19]);
	portraits.addAnim('oldpostor', 'Character', 24, true, null, [20]);
	portraits.addAnim('top', 'Character', 24, true, null, [21]);
	portraits.addAnim('jorsawsee', 'Character', 24, true, null, [22]);
	portraits.addAnim('warchief', 'Character', 24, true, null, [23]);
	portraits.addAnim('redmungus', 'Character', 24, true, null, [24]);
	portraits.addAnim('bananungus', 'Character', 24, true, null, [25]);
	portraits.addAnim('powers', 'Character', 24, true, null, [26]);
	portraits.addAnim('kills', 'Character', 24, true, null, [27]);
	portraits.addAnim('jerma', 'Character', 24, true, null, [28]);
	portraits.addAnim('who', 'Character', 24, true, null, [29]);
	portraits.addAnim('monotone', 'Character', 24, true, null, [30]);
	portraits.addAnim('charles', 'Character', 24, true, null, [31]);
	portraits.addAnim('finale', 'Character', 24, true, null, [32]);
	portraits.addAnim('pop', 'Character', 24, true, null, [33]);
	portraits.addAnim('torture', 'Character', 24, true, null, [34]);
	portraits.addAnim('dave', 'Character', 24, true, null, [35]);
	portraits.addAnim('bpmar', 'Character', 24, true, null, [36]);
	portraits.addAnim('grinch', 'Character', 24, true, null, [37]);
	portraits.addAnim('redmunp', 'Character', 24, true, null, [38]);
	portraits.addAnim('nuzzus', 'Character', 24, true, null, [39]);
	portraits.addAnim('monotoner', 'Character', 24, true, null, [40]);
	portraits.addAnim('idk', 'Character', 24, true, null, [41]);
	portraits.addAnim('esculent', 'Character', 24, true, null, [42]);
	portraits.playAnim('red');
	portraits.color = FlxColor.BLACK;
	portraits.antialiasing = !Options.lowMemoryMode;
	portraits.scrollFactor.set(0, 0);
	add(portraits);

	rimlightShader = new RimlightShader(315, 10, FlxColor.RED, portraits);
	portraits.shader = rimlightShader.shader;

	songCards = new FlxGroup();
    add(songCards);

	createPlaylist(0);

    var upperBar:FlxSprite = new FlxSprite(-2, -1.4).loadGraphic(Paths.image("menus/legacy/freeplay/topBar"));
	upperBar.antialiasing = !Options.lowMemoryMode;
	upperBar.scrollFactor.set(0, 0);
	add(upperBar);

	var backButton:BackButton = new BackButton(12.5, 8.05, function() {
        playMenuSound("cancel");
        FlxG.switchState(new ModState("legacy/legacyMenuState"));
    }, 1, "menus/legacy/menuBack", false, true);
	backButton.antialiasing = !Options.lowMemoryMode;
	backButton.scrollFactor.set(0, 0);
	add(backButton);
}

function createPlaylist(page:Int) {
	songCards.forEach(function(card) card.destroy());
	songCards.clear();

	for (songData in hardcodedListOfSongsLel[page]) {
		var card:FreeplayCard = new FreeplayCard(0, 0, songData.song, songData.portrait, songData.color);
		songCards.add(card);
	}

	changeSelection(0);
}

function update(elapsed:Float) {
	rimlightShader.updateFrame();

    if (controls.BACK) {
		playMenuSound("cancel");
		FlxG.switchState(new ModState("legacy/legacyMenuState"));
    }

    if (controls.DOWN_P || FlxG.mouse.wheel < 0) {
        changeSelection(1);
    }
	if (controls.UP_P || FlxG.mouse.wheel > 0) {
        changeSelection(-1);
    }
    if (controls.LEFT_P)
		changePage(-1);
	if (controls.RIGHT_P)
		changePage(1);

	songCards.forEach(function(card) {
        var scaledY:Float = FlxMath.remapToRange(card.targetY, 0, 1, 0, 1.3);
		var xPos:Float = Math.abs(card.targetY * 70) * -1 + 70;

		card.y = lerp(card.y, (scaledY * 90) + (FlxG.height * 0.45), 0.25);
		card.x = lerp(card.x, xPos, 0.25);

        var alph:Float = 1 + -Math.abs(card.targetY) * 0.25;
		card.alpha = lerp(card.alpha, alph, 0.25);
    });

	if (controls.ACCEPT || pointerOverlaps(songCards.members[curSelect]) && pointerJustReleased()) {
		playMenuSound("lock");
		FlxG.camera.stopShake();
		FlxG.camera.shake(0.004, 0.15);
    }
}

var prevSelect:Int = -1;
function changeSelection(change:Int) {
    curSelect += change;

	if (curSelect > songCards.length - 1) {
		changePage(1, true);
        return;
    } else if (curSelect < 0) {
		changePage(-1, true);
        return;
    }

	if (curSelect != prevSelect) {
		prevSelect = curSelect;
		playMenuSound("scroll");
	}

    var idk:Int = 0;
	songCards.forEach(function(card) {
		card.targetY = idk - curSelect;
        idk++;
    });

	changePortrait();
}

function changePage(change:Int, ?wrap:Bool) {
	curPage = FlxMath.wrap(curPage + change, 0, hardcodedListOfSongsLel.length - 1);

	prevSelect = -1;

    if (change < 0 && wrap)
		curSelect = hardcodedListOfSongsLel[curPage].length - 1;
	else if (change > 0 && wrap)
		curSelect = 0;
    else
		curSelect = CoolUtil.bound(curSelect, 0, hardcodedListOfSongsLel[curPage].length - 1);

	createPlaylist(curPage);
}

var prevPortrait:String = "";
var portTween:FlxTween;
var colorTween:FlxTween;
function changePortrait(?reset:Bool) {
    var curPortrait:String = songCards.members[curSelect].portrait;
	rimlightShader.color = songCards.members[curSelect].cardColor;

	if (curPortrait != prevPortrait || reset) {
		prevPortrait = curPortrait;
		portraits.playAnim(curPortrait);

		if (portTween != null) {
			portTween.cancel();
			colorTween.cancel();
        }

        var defX:Float = portraits.x = 304.65;
		portraits.x += 200;
		portraits.alpha = 0;
		portTween = FlxTween.tween(portraits, {x: defX, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		colorTween = FlxTween.color(backGlow, 0.3, backGlow.color, songCards.members[curSelect].cardColor);
    }
}

function destroy() {
	backGlow.destroy();
	portraits.destroy();

	songCards.destroy();
}

class FreeplayCard extends MusicBeatGroup {
    public var card:FlxSprite;

    public var icon:FlxSprite;

	public var songTxt:FunkinText;

    public var portrait:String;

    public var targetY:Float = 0;

    public var cardColor:FlxColor;

    var shuffleTimer:FlxTimer;

    var songName:String;

    public function new(x:Float, y:Float, song:String, portrait:String, color:FlxColor) {
        super(x, y);

        this.portrait = portrait;
        cardColor = color;
		songName = song;

		card = new FlxSprite().loadGraphic(Paths.image("menus/legacy/freeplay/songPanel"));
		card.antialiasing = !Options.lowMemoryMode;
		card.color = song == "Finale" ? 0xFF4A0000 : 0xFF4A4A4A;
		add(card);

		icon = new FlxSprite(25, 11).loadGraphic(Paths.image("menus/legacy/freeplay/" + (song == "Finale" ? "goldLock" : "lock")));
		icon.antialiasing = !Options.lowMemoryMode;
		add(icon);

		songTxt = new FunkinText(120, 5, 0, songName, 64, true);
		songTxt.font = Paths.font("amatic.ttf");
		songTxt.antialiasing = !Options.lowMemoryMode;
		songTxt.color = song == "Finale" ? FlxColor.RED : FlxColor.WHITE;
		add(songTxt);

		shuffleTimer = new FlxTimer();

		if (song != "Finale") {
			shuffleName();
			shuffleTimer.start(FlxG.random.float(0.1, 0.2), _ -> shuffleName(), 0);
        }
    }

    public function shuffleName() {
        var stringArray:Array<String> = [];
		for (i in 0...songName.length)
            stringArray.push(songName.charAt(i));

		shuffleTable(stringArray);

        var txt:String = "";
		for (char in stringArray)
            txt += char;

		songTxt.text = txt;
    }

    public function destroy() {
        card.destroy();
        icon.destroy();
        songTxt.destroy();
		shuffleTimer.destroy();
    }
}