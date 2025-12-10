import flixel.addons.display.FlxBackdrop;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.MusicBeatGroup;
import BackButton;
import StarsBackdrop;

var stars:StarsBackdrop;
var topBorder:FlxBackdrop;
var backButton:BackButton;

var impostorPixel:BackButton;
var impostorm:BackButton;
var innersloth:BackButton;

var minCategoryX:Float = 20;
var minContributorX:Float = 50;
var creditsGroup:Array<FlxSpriteGroup> = [];
var creditsPanel:CreditsPanel;
var creditsData:Array<Array<Dynamic>> = [
    {
        category: "VS IMPOSTOR Pixel",
        contributors: [
            {
                name: "kenton",
                portrait: "",
                jobs: ["director", "programmer", "pixelartist", "artist", "charter", "translator", "advertiser"],
                quote: "I've spent almost 2 years developing this mod from Beta 2.1 to Version 1, I've learn a lot in the process and met a lot of cool people too!\nYes I'm the only one that worked for this mod, and thank you for your patience! And sorry for not delivering something... bigger, specially with the amount of time this mod took to develop.",
				youtube: "https://www.youtube.com/@kenton.54",
				github: "https://github.com/kenton54",
				kofi: "https://ko-fi.com/kenton54"
            }
        ]
    },
    {
		// If anyone asks, this list is from https://vsimpostor.com/#credits
        // If i got someone wrong, its clowfoe's fault :v
        category: "IMPOSTORM",
		link: "https://vsimpostor.com",
        contributors: [
            {name: "Clowfoe", youtube: "https://www.youtube.com/@Clowfoe", twitter: "https://twitter.com/Clowfoe", discord: "https://www.discord.gg/clowfoe"},
			{name: "emi3_"},
			{name: "Rareblin", youtube: "https://www.youtube.com/@Rareblin", spotify: "https://open.spotify.com/artist/5b4tXJ3zWEjSZCSJDs20bC", soundcloud: "https://soundcloud.com/rareblin", appleMusic: "https://music.apple.com/us/artist/rareblin/1596839841"},
			{name: "loggo", twitter: "https://twitter.com/loggoman512"},
			{name: "EthanTheDoodler", youtube: "https://www.youtube.com/@EthanTheDoodler", twitter: "https://twitter.com/D00dlerEthan", spotify: "https://open.spotify.com/artist/0hDzmNmk3ruYMmIhcg7EKo", soundcloud: "https://soundcloud.com/ethanthedoodler"},
			{name: "Gonk"},
			{name: "fluffyhairs", youtube: "https://www.youtube.com/@fluffyhairsmusic", twitter: "https://twitter.com/fluffyhairslol", spotify: "https://open.spotify.com/artist/0WrQSlkBH3KOBL9jOctrMs", appleMusic: "https://music.apple.com/us/artist/fluffyhairs/1589613202"},
			{name: "SquidBoy84", twitter: "https://twitter.com/SquidBoy84"},
			{name: "Fabs", twitter: "https://twitter.com/fabsthefabs"},
			{name: "Dazzen"},
			{name: "Malor"},
			{name: "Thales", twitter: "https://twitter.com/MoonlessShift"},
			{name: "NeatoNG", newgrounds: "https://neatong.newgrounds.com/"},
			{name: "MonotoneDoc", twitter: "https://twitter.com/MonotoneDoc"},
			{name: "punkett", youtube: "https://www.youtube.com/@punkett", twitter: "https://twitter.com/_punkett", spotify: "https://open.spotify.com/artist/3SwTlwww12v4tI3dojcSIm", appleMusic: "https://music.apple.com/us/artist/punkett/1652607232"},
			{name: "OrbyyOrbinaut", twitter: "https://twitter.com/OrbyyNew"},
			{name: "Crocidy"},
			{name: "Aqua", twitter: "https://twitter.com/useraqua_"},
			{name: "Offbi"},
			{name: "Ellisbros"},
			{name: "Mayokiddo"},
			{name: "MSG", twitter: "https://twitter.com/MSGTheEpic"},
			{name: "Axor the Axolotl"},
			{name: "Vruzzen", youtube: "https://www.youtube.com/@SkarnaesRa", spotify: "https://open.spotify.com/artist/2aTNuFiuOJHrKOH5NanjtM"},
			{name: "Nii-san", youtube: "https://www.youtube.com/@niisanmusic", twitter: "https://twitter.com/NiisanHP"},
			{name: "Biddle3", youtube: "https://www.youtube.com/@therealb3", soundcloud: "https://soundcloud.com/biddle3", appleMusic: "https://music.apple.com/us/artist/biddle3/1561582913"},
			{name: "Emihead", youtube: "https://www.youtube.com/@emihead", twitter: "https://twitter.com/emihead", spotify: "https://open.spotify.com/artist/23GN3NHNBkFtpTcwVeScw1"},
			{name: "LEX3X"},
			{name: "Spaggy"},
			{name: "Julien", twitter: "https://twitter.com/itjulienn"},
			{name: "amongusfan24", quote: "Cooper\nRest in Peace :(", twitter: "https://twitter.com/amongusfan24"},
			{name: "Keoni"},
			{name: "Keegan", youtube: "https://www.youtube.com/@KeeganKeegan", twitter: "https://twitter.com/__Keegan_", spotify: "https://open.spotify.com/artist/6i10vpPPPjzt5Vozj8nbpg", appleMusic: "https://music.apple.com/us/artist/keegan/1632834207"},
			{name: "GallyCid"},
			{name: "Gibz", twitter: "https://twitter.com/9766Gibz"},
			{name: "Farfoxx"},
			{name: "KlutchDJ"},
			{name: "ZiffyClumper", twitter: "https://twitter.com/ziffymusic"},
			{name: "Saster", youtube: "https://www.youtube.com/@sasterofficial", twitter: "https://twitter.com/sub0ru", spotify: "https://open.spotify.com/artist/2wh9IsIFT6RYQWGS0yzo5S", soundcloud: "https://soundcloud.com/sasterdadudester", appleMusic: "https://music.apple.com/us/artist/saster/1575658159"},
			{name: "Cval"},
			{name: "Rozebud", youtube: "https://www.youtube.com/@Rozebud", twitter: "https://twitter.com/helpme_thebigt", spotify: "https://open.spotify.com/artist/5UwDhbNL98PxS4KOm5rGSf", appleMusic: "https://music.apple.com/us/artist/rozebud/1561593812"},
			{name: "JADS", youtube: "https://www.youtube.com/@JADSCastle", twitter: "https://twitter.com/Aw3somejds", spotify: "https://open.spotify.com/artist/5yiRxiTjuMxOfj5ewY14f8", appleMusic: "https://music.apple.com/us/artist/jads/1651744458"},
			{name: "MashProTato", twitter: "https://twitter.com/MashProTato"},
			{name: "Kai"},
			{name: "Renyar"},
			{name: "Saruky", youtube: "https://www.youtube.com/@Saruky", twitter: "https://x.com/Saruky__", spotify: "https://open.spotify.com/artist/3MqkT4MbvBItBby3mUmvIS", soundcloud: "https://soundcloud.com/saruky", appleMusic: "https://music.apple.com/us/artist/saruky/1586337554"},
			{name: "Moonmistt"},
			{name: "Philiplol"},
			{name: "Doguy"},
			{name: "Lunaxis"},
			{name: "Top 10 Awesome"},
			{name: "Salterino", twitter: "https://twitter.com/Salterin0"},
			{name: "LayLasagna"},
			{name: "Elikapika", twitter: "https://twitter.com/elikapika"},
			{name: "SUSSteve", twitter: "https://twitter.com/Steve06421194"},
			{name: "rai_talu"},
			{name: "DuskieWhy", twitter: "https://twitter.com/DuskieWhy"},
			{name: "KadeDev"}
        ]
    },
    {
        category: "Innersloth",
		link: "https://www.innersloth.com",
    }
];

var baseScale:Float = 4;

function create() {
	changeDiscordMenuStatus("Credits Menu");

    FlxG.mouse.visible = true;

	stars = new StarsBackdrop(-15, 4);
	stars.scrollFactor = FlxPoint.get(0.35, 0.35);
    add(stars);

    topBorder = new FlxBackdrop(Paths.image("menus/general/topBorder"), FlxAxes.X);
    topBorder.scale.set(baseScale, baseScale);
    topBorder.updateHitbox();
	topBorder.scrollFactor.set(0, 0);

    backButton = new BackButton(baseScale, baseScale, () -> {
        setTransition("fade");
        FlxG.switchState(new ModState("impostorMenuState"));
    }, baseScale, "menus/x", false, true);
	backButton.scrollFactor.set(0, 0);

	var groupYPos:Float = topBorder.height;
	for (i => category in creditsData) {
		var categoryGroup:FlxSpriteGroup = new FlxSpriteGroup(0, groupYPos);
		creditsGroup.push(categoryGroup);
		add(categoryGroup);

		var categoryName:FunkinText = new FunkinText(minCategoryX, 0, 0, category.category, 52);
		categoryName.font = Paths.font("pixeloidsans.ttf");
		categoryName.alpha = 0.5;
		categoryGroup.add(categoryName);

		var contributorsY:Float = categoryName.height + 10;
		if (category.contributors != null)
            for (contributor in category.contributors) {
				var contributor:FunkinText = new FunkinText(minContributorX, contributorsY, 0, contributor.name, 40);
				contributor.font = Paths.font("pixeloidsans.ttf");
				contributor.alpha = 0.5;
				categoryGroup.add(contributor);

				contributorsY += contributor.height + 10;
            }

		groupYPos += categoryGroup.height + 80;
	}

	var firstObjectPos:Float = creditsGroup[0].members[0].y - FlxG.height / 2;
	var lastGroup:FlxSpriteGroup = creditsGroup[creditsGroup.length - 1];
	var lastObjectPos:Float = lastGroup.members[lastGroup.members.length - 1].y;

	impostorm = new BackButton(0, -1, () -> setPosition(creditsGroup[1].members[0].y - FlxG.height / 2), 0.63, "menus/credits/impostorm", false, true);
	impostorm.multiPress = true;
	impostorm.scrollFactor.set(0, 0);
	impostorm.screenCenter(FlxAxes.X);

	impostorPixel = new BackButton(impostorm.x - 40, 0, () -> setPosition(creditsGroup[0].members[0].y - FlxG.height / 2), baseScale * 0.8, "menus/credits/pixel", false, true);
	impostorPixel.multiPress = true;
	impostorPixel.scrollFactor.set(0, 0);
	impostorPixel.x -= impostorPixel.width;

	innersloth = new BackButton(impostorm.x + impostorm.width + 40, 6, () -> setPosition(creditsGroup[2].members[0].y - FlxG.height / 2), 0.52, "menus/credits/innersloth", false, true);
	innersloth.multiPress = true;
	innersloth.scrollFactor.set(0, 0);

	creditsPanel = new CreditsPanel(FlxG.width, topBorder.height, 512, FlxG.height - topBorder.height);
	creditsPanel.scrollFactor.set(0, 0);
	creditsPanel.x -= creditsPanel.width;
	add(creditsPanel);

	add(topBorder);
	add(backButton);
	add(impostorPixel);
	add(impostorm);
	add(innersloth);

	FlxG.camera.minScrollY = firstObjectPos;
	lerpScroll = firstObjectPos;
	snapPosition();

	FlxG.camera.maxScrollY = lastObjectPos + FlxG.height / 2;

	stars.setPosition(0, FlxG.camera.minScrollY - FlxG.height / 2);
	stars.setLimits(FlxG.width, FlxG.camera.maxScrollY);

	Framerate.offset.y = topBorder.height * (FlxG.stage.stageHeight / 720);
}

var lerpScroll:Float = 0;
function update(elapsed:Float) {
	if (controls.UP)
		addPosition(-440 * elapsed);
	if (controls.DOWN)
		addPosition(440 * elapsed);

	addPosition(40 * FlxG.mouse.wheel * -1);

	FlxG.camera.scroll.y = CoolUtil.fpsLerp(FlxG.camera.scroll.y, lerpScroll, 0.3);

	for (category in creditsGroup) {
		for (text in category.members) {
			if (isScreenCentered(text)) {
				text.alpha = 1;
            } else {
				text.alpha = 0.5;
            }
        }
    }

	var data:Array<Dynamic> = getContributorData(getSelected());
	creditsPanel.update(elapsed);
	creditsPanel.updatePanel(data);
	if (getSelected() != null) {
		if (controls.ACCEPT || pointerOverlaps(getSelected()) && pointerJustPressed()) {
			var catIndex:Int = 0;
			var isCategory:Bool = false;
			for (category in creditsGroup) {
				if (getSelected() == category.members[0]) {
					isCategory = true;
					break;
				}
				catIndex++;
			}

			if (isCategory) {
				if (creditsData[catIndex].link != null)
					CoolUtil.openURL(creditsData[catIndex].link);
			}
		}
    }

	if (controls.BACK)
        FlxG.switchState(new ModState("impostorMenuState"));
}

function addPosition(pos:Float)
	lerpScroll = CoolUtil.bound(lerpScroll + pos, FlxG.camera.minScrollY, FlxG.camera.maxScrollY - FlxG.height);

function setPosition(pos:Float)
	lerpScroll = CoolUtil.bound(pos, FlxG.camera.minScrollY, FlxG.camera.maxScrollY - FlxG.height);

function snapPosition()
	FlxG.camera.scroll.y = lerpScroll;

var checkPositionThreshold:Float = 5;
function isScreenCentered(object:FunkinText):Bool {
	var cameraPosition:Float = FlxG.camera.scroll.y + FlxG.height / 2 + topBorder.height / 2;
	if (cameraPosition >= object.y - checkPositionThreshold && cameraPosition <= object.y + object.height + checkPositionThreshold)
        return true;

    return false;
}

function getSelected():FunkinText {
	for (category in creditsGroup) {
		for (text in category.members) {
			if (text.alpha == 1)
                return text;
		}
    }
    return null;
}

function getContributorData(object:FunkinText):Array<Dynamic> {
	if (object != null) {
		for (credits in creditsData) {
			if (credits.contributors != null) {
				for (contributor in credits.contributors) {
					if (object.text == contributor.name)
						return contributor;
				}
			}
		}
	}
	return {};
}

function onResize(event) {
    // TODO: replace this with `gameScale.y` when display resolution change is properly added
	Framerate.offset.y = topBorder.height * (event.height / 720);
}

function destroy() {
    stars.destroy();
	backButton.destroy();
	impostorPixel.destroy();
	impostorm.destroy();
	innersloth.destroy();

	FlxG.camera.minScrollY = null;
	FlxG.camera.maxScrollY = null;
}

class CreditsPanel extends MusicBeatGroup {
	var title:FunkinText;
	var portrait:FunkinSprite;
	var quote:FunkinText;
	var socialsGroup:FlxSpriteGroup;
	var background:FlxSprite;

	var _lastData:Array<Dynamic> = [];

	public function new(x:Float, y:Float, width:Int, height:Int) {
		super(x, y);

		background = new FlxSprite().makeGraphic(width, height, FlxColor.WHITE);
		background.alpha = 0.4;
		add(background);

		title = new FunkinText(0, 20, width, "kenton test lol", 40, false);
		title.font = Paths.font("pixeloidsans.ttf");
		title.alignment = "center";
		add(title);

		portrait = new FunkinSprite(background.width / 2, title.y + title.height + 20 - this.y);
		portrait.visible = false;
		add(portrait);

		quote = new FunkinText(0, 0, width, "", 18, false);
		quote.font = Paths.font("pixeloidsans.ttf");
		quote.alignment = "center";
		quote.visible = false;
		add(quote);

		socialsGroup = new FlxSpriteGroup();
		add(socialsGroup);
	}

	public function update(elapsed:Float) {
		for (social in socialsGroup.members) {
			if (social != null && pointerOverlaps(social) && pointerJustPressed())
				social.select();
		}
	}

	public function updatePanel(data:Array<Dynamic>) {
		if (_lastData == data) return;

		portrait.visible = false;
		quote.visible = false;

		for (sprite in socialsGroup)
			sprite.destroy();

		socialsGroup.clear();

		if (data.name == null) {
			title.y = this.y + 250;
			title.text = "Hover over a contributor to show its information.";
			title.size = 26;
		} else {
			title.y = this.y + 20;
			title.text = data.name;
			title.size = 40;

			var nextPosition:Float = title.height + 40;

			if (data.portrait != null && data.portrait != "") {
				portrait.loadGraphic(Paths.image("menus/credits/images/" + data.portrait));
				CoolUtil.setUnstretchedGraphicSize(portrait, 256, 256);
				portrait.visible = true;
				portrait.y = this.y + nextPosition;
				portrait.x = (background.width - portrait.width) / 2;
				nextPosition += portrait.height + 20;
			}
			if (data.quote != null && data.quote != "") {
				quote.text = data.quote;
				quote.visible = true;
				quote.y = this.y + nextPosition;
				nextPosition += quote.height;
			}

			socialsGroup.y = this.y + background.height - 20;

			var iconXPos:Float = 0;
			var iconScale:Float = 3.2;
			var iconLength:Int = 0;
			if (data.youtube != null && data.youtube != "") {
				var youtubeIcon:SocialIcon = new SocialIcon(0, 0, iconScale, "youtube", data.youtube);
				socialsGroup.add(youtubeIcon);
				iconLength++;
			}
			if (data.discord != null && data.discord != "") {
				var discordIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "discord", data.discord);
				socialsGroup.add(discordIcon);
				iconLength++;
			}
			if (data.github != null && data.github != "") {
				var githubIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "github", data.github);
				socialsGroup.add(githubIcon);
				iconLength++;
			}
			if (data.twitter != null && data.twitter != "") {
				var twitterIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "twitter", data.twitter);
				socialsGroup.add(twitterIcon);
				iconLength++;
			}
			if (data.spotify != null && data.spotify != "") {
				var spotifyIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "spotify", data.spotify);
				socialsGroup.add(spotifyIcon);
				iconLength++;
			}
			if (data.soundcloud != null && data.soundcloud != "") {
				var soundcloudIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "soundcloud", data.soundcloud);
				socialsGroup.add(soundcloudIcon);
				iconLength++;
			}
			if (data.appleMusic != null && data.appleMusic != "") {
				var appleMusicIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "appleMusic", data.appleMusic);
				socialsGroup.add(appleMusicIcon);
				iconLength++;
			}
			if (data.kofi != null && data.kofi != "") {
				var kofiIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "kofi", data.kofi);
				socialsGroup.add(kofiIcon);
				iconLength++;
			}
			if (data.newgrounds != null && data.newgrounds != "") {
				var newgroundsIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * iconLength, 0, iconScale, "newgrounds", data.newgrounds);
				socialsGroup.add(newgroundsIcon);
				iconLength++;
			}

			socialsGroup.x = this.x + (background.width - socialsGroup.width) / 2;
			socialsGroup.y -= socialsGroup.height;
		}

		_lastData = data;
	}
}

class SocialIcon extends FunkinSprite {
	public var url:String = "";

	public function new(x:Float, y:Float, scale:Float, icon:String, url:String) {
		super(x, y, Paths.image("menus/credits/socials/" + icon));
		this.url = url;
		this.scale.set(scale, scale);
		this.updateHitbox();
	}

	public function select() {
		CoolUtil.openURL(url);
	}
}