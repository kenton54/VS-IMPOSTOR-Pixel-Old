import flixel.addons.display.FlxBackdrop;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.MusicBeatGroup;
import impostor.utils.FunkinMath;
import impostor.BackButton;
import impostor.StarsBackdrop;

var stars:StarsBackdrop;
var topBorder:FlxBackdrop;
var backButton:BackButton;

var arrow:FunkinSprite;

var categoriesGroup:FlxSpriteGroup;
var impostorPixel:BackButton;
var impostorm:BackButton;
var innersloth:BackButton;
var codename:BackButton;
var fridayNightFunkin:BackButton;

var positionOffset:Float = 12;

var minCategoryX:Float = 40;
var minContributorX:Float = minCategoryX + 30;
var creditsGroup:Array<FlxSpriteGroup> = [];
var creditsPanel:CreditsPanel;
var creditsData:Array<Array<Dynamic>> = [
    {
        category: "VS IMPOSTOR Pixel",
		portrait: "pixel-big",
		scale: 2.4,
		about: "It's the mod you're playing right now!\nMade with love and passion by one single developer.",
        contributors: [
            {
                name: "kenton",
                portrait: "",
                jobs: ["director", "programmer", "pixelartist", "artist", "charter", "translator", "advertiser"],
                quote: "I've spent almost 2 years developing this mod from Beta 2.1 to Version 1, I've learn a lot in the process and met a lot of cool people too!\nYes I'm the only one that worked for this mod, and thank you for your patience! And sorry for not delivering something... bigger, specially with the amount of time this mod took to develop.",
				youtube: "https://www.youtube.com/@kenton.54",
				github: "https://github.com/kenton54",
				kofi: "https://ko-fi.com/kenton54",
				twitter: "https://x.com/kenton__54"
            },
			{
                name: "Silte",
                portrait: "",
                jobs: ["musician"],
				quote: "uh hi ehh, how did i get here",
				youtube: "https://www.youtube.com/@SilteTheMusician"
            }
        ]
    },
    {
        category: "MOTORFROG",
		portrait: "motorfrog-big",
		scale: 0.8,
		offset: 8,
		about: "The team that made VS IMPOSTOR.\nGo check them out!",
		website: "https://vsimpostor.com",

		// If anyone asks, this list is from https://vsimpostor.com/#credits
		// If i got someone wrong, its clowfoe's fault :v
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
        category: "Innersloth LLC",
		portrait: "innersloth-big",
		scale: 0.45,
		about: "The creators of Among Us.\nGo support them!",
		website: "https://www.innersloth.com",
		youtube: "https://www.youtube.com/channel/UCKuI2VapWQjkMz2DDrLvLKw",
		discord: "https://discord.com/invite/innersloth",
		twitter: "https://twitter.com/InnerslothDevs",
		tiktok: "https://www.tiktok.com/@amongus"
    },
	{
		category: "Codename Engine",
		portrait: "codename-big",
		scale: 0.7,
		about: "The engine this mod is running on!\nThank you so much CNE Devs for making this amazing engine <3\nI can't recommend you this engine enough! It's so damn good and really powerful.",
		website: "https://codename-engine.com",
		youtube: "https://www.youtube.com/@CodenameEngine",
		twitter: "https://twitter.com/FNFCodenameEG",
		bluesky: "https://bsky.app/profile/codename-engine.com",
		discord: "https://discord.com/servers/codename-engine-860561967383445535/",
		github: "https://github.com/CodenameCrew/CodenameEngine",
		itchio: "https://nex-isdumb.itch.io/codename-engine",
		gamebanana: "https://gamebanana.com/studios/38320",
		kofi: "https://ko-fi.com/codename_engine",
		contributors: [
			{name: "YoshiCrafter29", github: "https://github.com/YoshiCrafter29"},
			{name: "NeeEoo", github: "https://github.com/NeeEoo"},
			{name: "lunarcleint", github: "https://github.com/lunarcleint"},
			{name: "NexIsDumb", github: "https://github.com/NexIsDumb"},
			{name: "Raltyro", github: "https://github.com/Raltyro"},
			{name: "Frakits", github: "https://github.com/Frakits"},
			{name: "SrtHero278", github: "https://github.com/SrtHero278"},
			{name: "FuroYT", github: "https://github.com/FuroYT"},
			{name: "TheZoroForce240", github: "https://github.com/TheZoroForce240"},
			{name: "WizardMantis441", github: "https://github.com/WizardMantis441"},
			{name: "Verwex", github: "https://github.com/Verwex"},
			{name: "SenDoesStuff", github: "https://github.com/SenDoesStuff"},
			{name: "swordcube", github: "https://github.com/swordcube"},
			{name: "chronicsilly", github: "https://github.com/chronicsilly"},
			{name: "WhosGalaxie", github: "https://github.com/WhosGalaxie"},
			{name: "KolzeYT", github: "https://github.com/KolzeYT"},
			{name: "MAJigsaw77", github: "https://github.com/MAJigsaw77"},
			{name: "rodney528", github: "https://github.com/rodney528"},
			{name: "bopcityfan", github: "https://github.com/bopcityfan"},
			{name: "crowplexus", github: "https://github.com/crowplexus"},
			{name: "HeroEyad", github: "https://github.com/HeroEyad"},
			{name: "bctix", github: "https://github.com/bctix"},
			{name: "WhosGalaxie", github: "https://github.com/WhosGalaxie"},
			{name: "mariosbignuts", github: "https://github.com/mariosbignuts"},
			{name: "Sword352", github: "https://github.com/Sword352"},
			{name: "TechnikTil", github: "https://github.com/TechnikTil"},
			{name: "Jamextreme140", github: "https://github.com/Jamextreme140"},
			{name: "Jurtaa", github: "https://github.com/Jurtaa"},
			{name: "theeoo-h", github: "https://github.com/theoo-h"},
			{name: "betpowo", github: "https://github.com/betpowo"},
			{name: "ItsLJcool", github: "https://github.com/ItsLJcool"},
		]
	},
	{
		category: "Friday Night Funkin'",
		portrait: "fnf-big",
		scale: 0.75,
		offset: 10,
		about: "The creators of our beloved rhythm game!",
		website: "https://funkin.me/blog/",
		youtube: "https://www.youtube.com/@FNF_Developers",
		twitter: "https://x.com/FNF_Developers",
		instagram: "https://www.instagram.com/fnf_developers/",
		tiktok: "https://www.tiktok.com/@fnf_developers",
		playstore: "https://play.google.com/store/apps/details?id=me.funkin.fnf",
		appstore: "https://apps.apple.com/us/app/friday-night-funkin-mobile/id6740428530",
		itchio: "https://ninja-muffin24.itch.io/funkin",
		github: "https://github.com/FunkinCrew/Funkin",
		newgrounds: "https://www.newgrounds.com/portal/view/770371",
		kickstarter: "https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game",
		spotify: "https://open.spotify.com/artist/4fqDivs0BnIje4XZ10cF2d",
		appleMusic: "https://music.apple.com/es/artist/funkin-sound-team/1680992035",
		gamebanana: "https://gamebanana.com/games/8694",
		gamejolt: "https://gamejolt.com/games/tag-fnf",

		// taken from the wiki lol (mostly)
		contributors: [
			{
				name: "PhantomArcade",
				jobs: ["director", "artist", "animator", "designer", "writter"],
				youtube: "https://www.youtube.com/PhantomArcade",
				twitch: "https://www.twitch.tv/phantom_arcade",
				twitter: "https://x.com/PhantomArcade3K",
				instagram: "https://www.instagram.com/phantomarcade/",
				newgrounds: "https://phantomarcade.newgrounds.com",
			},
			{
				name: "ninjamuffin99",
				jobs: ["programmer"],
				newgrounds: "https://ninjamuffin99.newgrounds.com",
				twitter: "https://x.com/ninja_muffin99",
				github: "https://github.com/ninjamuffin99"
			},
			{
				name: "evilsk8r",
				jobs: ["artist", "designer"],
				twitter: "https://x.com/evilsk8r",
				newgrounds: "https://evilsk8r.newgrounds.com"
			},
			{
				name: "Kawai Sprite",
				jobs: ["musician"],
				newgrounds: "https://kawaisprite.newgrounds.com",
				appleMusic: "https://music.apple.com/ve/artist/kawai-sprite/1358602718",
				soundcloud: "https://soundcloud.com/kawaispritefak",
				twitter: "https://x.com/kawaisprite",
				spotify: "https://open.spotify.com/artist/19nnKeOt6Vo1g0ijPcFxdu"
			},
			{
				name: "EliteMasterEric",
				jobs: ["programmer"],
				twitter: "https://x.com/EliteMasterEric",
				github: "https://github.com/EliteMasterEric",
				twitch: "https://www.twitch.tv/elitemastereric"
			},
			{
				name: "Saruky",
				jobs: ["musician"],
				youtube: "https://www.youtube.com/@Saruky",
				twitter: "https://x.com/Saruky__",
				spotify: "https://open.spotify.com/artist/3MqkT4MbvBItBby3mUmvIS",
				soundcloud: "https://soundcloud.com/saruky",
				appleMusic: "https://music.apple.com/us/artist/saruky/1586337554"
			},
			{
				name: "brekkits",
				jobs: ["artist", "designer"],
				twitter: "https://x.com/brekkist"
			},
			{
				name: "Hundrec",
				jobs: ["organizer"],
				youtube: 'https://www.youtube.com/@hundrec',
				twitter: "https://x.com/Hundrec",
				github: "https://github.com/Hundrec"
			},
			{
				name: "Abnormal",
				jobs: ["organizer"],
				github: "https://github.com/AbnormalPoof"
			}
		]
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

	creditsPanel = new CreditsPanel(FlxG.width, topBorder.height, 512, FlxG.height - topBorder.height);
	creditsPanel.scrollFactor.set(0, 0);
	creditsPanel.x -= creditsPanel.width;
	add(creditsPanel);

	arrow = new FunkinSprite(8, 0, Paths.image("menus/credits/arrow"));
	arrow.scale.set(4, 4);
	arrow.updateHitbox();
	arrow.scrollFactor.set();
	arrow.screenCenter(FlxAxes.Y);
	arrow.y += topBorder.height / 2;
	add(arrow);

	add(topBorder);

	categoriesGroup = new FlxSpriteGroup();
	categoriesGroup.scrollFactor.set();
	add(categoriesGroup);

	add(backButton);

	impostorPixel = new BackButton(0, 1, () -> setPosition(creditsGroup[0].members[0].y - FlxG.height / 2 - positionOffset), baseScale * 0.8, "menus/credits/pixel", false, true);
	impostorPixel.multiPress = true;

	impostorm = new BackButton(impostorPixel.x + impostorPixel.width + 40, -1, () -> setPosition(creditsGroup[1].members[0].y - FlxG.height / 2 - positionOffset), 0.63, "menus/credits/impostorm", false, true);
	impostorm.multiPress = true;

	innersloth = new BackButton(impostorm.x + impostorm.width + 40, 6, () -> setPosition(creditsGroup[2].members[0].y - FlxG.height / 2 - positionOffset), 0.52, "menus/credits/innersloth", false, true);
	innersloth.multiPress = true;

	codename = new BackButton(innersloth.x + innersloth.width + 40, 0, () -> setPosition(creditsGroup[3].members[0].y - FlxG.height / 2 - positionOffset), 0.6, "menus/credits/codename", false, true);
	codename.multiPress = true;

	fridayNightFunkin = new BackButton(codename.x + codename.width + 40, -1, () -> setPosition(creditsGroup[4].members[0].y - FlxG.height / 2 - positionOffset), 0.55, "menus/credits/fnf", false, true);
	fridayNightFunkin.multiPress = true;

	categoriesGroup.add(impostorPixel);
	categoriesGroup.add(impostorm);
	categoriesGroup.add(innersloth);
	categoriesGroup.add(codename);
	categoriesGroup.add(fridayNightFunkin);

	categoriesGroup.screenCenter(FlxAxes.X);

	FlxG.camera.minScrollY = firstObjectPos - positionOffset;
	lerpScroll = firstObjectPos - positionOffset;
	snapPosition();

	FlxG.camera.maxScrollY = lastObjectPos + FlxG.height / 2 - positionOffset;

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

	if (FlxG.keys.justPressed.HOME)
		setPosition(creditsGroup[0].members[0].y - FlxG.height / 2 - positionOffset);
	if (FlxG.keys.justPressed.END) {
		var group = creditsGroup[creditsGroup.length - 1];
		setPosition(group.members[group.members.length - 1].y - FlxG.height / 2 - positionOffset);
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
			if (credits.category == object.text)
				return credits;
			if (credits.contributors != null) {
				for (contributor in credits.contributors) {
					if (contributor.name == object.text)
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
	var socialsGroup1:FlxSpriteGroup;
	var socialsGroup2:FlxSpriteGroup;
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

		socialsGroup1 = new FlxSpriteGroup();
		add(socialsGroup1);

		socialsGroup2 = new FlxSpriteGroup();
		add(socialsGroup2);
	}

	public function update(elapsed:Float) {
		for (social in socialsGroup1.members) {
			if (social != null && pointerOverlaps(social) && pointerJustPressed())
				social.select();
		}
		for (social in socialsGroup2.members) {
			if (social != null && pointerOverlaps(social) && pointerJustPressed())
				social.select();
		}
	}

	public function updatePanel(data:Array<Dynamic>) {
		if (_lastData == data) return;

		portrait.visible = false;
		quote.visible = false;
		quote.scale.set(1, 1);
		quote.updateHitbox();

		for (sprite in socialsGroup1)
			sprite.destroy();
		socialsGroup1.clear();

		for (sprite in socialsGroup2)
			sprite.destroy();
		socialsGroup2.clear();

		if (data.name == null) {
			if (data.category == null) {
				title.y = this.y + 250;
				title.text = "Hover over an organization/team or contributor to show their information.";
				title.size = 26;
			} else {
				portrait.loadGraphic(Paths.image("menus/credits/" + data.portrait));
				portrait.scale.set(data.scale ?? 1, data.scale ?? 1);
				portrait.updateHitbox();
				portrait.visible = true;
				portrait.y = this.y + 15;
				portrait.y -= data.offset ?? 0;
				portrait.x = this.x + (background.width - portrait.width) / 2;

				var nextPosition:Float = portrait.height + 30;

				title.y = this.y + nextPosition;
				title.text = data.category;
				title.size = 30;

				nextPosition += title.height + 10;

				quote.text = data.about;
				quote.visible = true;
				quote.y = this.y + nextPosition;
				nextPosition += quote.height;

				createSocials(data);

				var quoteHeightlimit:Float = FunkinMath.distanceBetweenFloats(quote.y, socialsGroup1.y) - 10;
				if (quote.height > quoteHeightlimit) {
					quote.scale.y = quoteHeightlimit / quote.height;
					quote.updateHitbox();
				}
			}
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

			createSocials(data);
		}

		_lastData = data;
	}

	function createSocials(data:Array<Dynamic>) {
		socialsGroup1.y = this.y + background.height - 20;
		socialsGroup2.y = socialsGroup1.y;

		var iconXPos:Float = 0;
		var iconScale:Float = 3.2;
		var iconLength:Int = 0;
		var maxIconsRow:Int = 8;
		function addSocial(social:SocialIcon) {
			if (iconLength > maxIconsRow - 1)
				socialsGroup2.add(social);
			else
				socialsGroup1.add(social);
			iconLength++;
		}

		if (data.website != null && data.website != "") {
			var websiteIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "website", data.website);
			addSocial(websiteIcon);
		}
		if (data.youtube != null && data.youtube != "") {
			var youtubeIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "youtube", data.youtube);
			addSocial(youtubeIcon);
		}
		if (data.instagram != null && data.instagram != "") {
			var instagramIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "instagram", data.instagram);
			addSocial(instagramIcon);
		}
		if (data.twitter != null && data.twitter != "") {
			var twitterIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "twitter", data.twitter);
			addSocial(twitterIcon);
		}
		if (data.bluesky != null && data.bluesky != "") {
			var blueskyIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "bluesky", data.bluesky);
			addSocial(blueskyIcon);
		}
		if (data.tiktok != null && data.tiktok != "") {
			var tiktokIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "tiktok", data.tiktok);
			addSocial(tiktokIcon);
		}
		if (data.twitch != null && data.twitch != "") {
			var twitchIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "twitch", data.twitch);
			addSocial(twitchIcon);
		}
		if (data.discord != null && data.discord != "") {
			var discordIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "discord", data.discord);
			addSocial(discordIcon);
		}
		if (data.spotify != null && data.spotify != "") {
			var spotifyIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "spotify", data.spotify);
			addSocial(spotifyIcon);
		}
		if (data.soundcloud != null && data.soundcloud != "") {
			var soundcloudIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "soundcloud", data.soundcloud);
			addSocial(soundcloudIcon);
		}
		if (data.appleMusic != null && data.appleMusic != "") {
			var appleMusicIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "appleMusic", data.appleMusic);
			addSocial(appleMusicIcon);
		}
		if (data.github != null && data.github != "") {
			var githubIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "github", data.github);
			addSocial(githubIcon);
		}
		if (data.playstore != null && data.playstore != "") {
			var playstoreIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "playstore", data.playstore);
			addSocial(playstoreIcon);
		}
		if (data.appstore != null && data.appstore != "") {
			var appstoreIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "appstore", data.appstore);
			addSocial(appstoreIcon);
		}
		if (data.itchio != null && data.itchio != "") {
			var itchioIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "itchio", data.itchio);
			addSocial(itchioIcon);
		}
		if (data.newgrounds != null && data.newgrounds != "") {
			var newgroundsIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "newgrounds", data.newgrounds);
			addSocial(newgroundsIcon);
		}
		if (data.gamebanana != null && data.gamebanana != "") {
			var gamebananaIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "gamebanana", data.gamebanana);
			addSocial(gamebananaIcon);
		}
		if (data.gamejolt != null && data.gamejolt != "") {
			var gamejoltIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "gamejolt", data.gamejolt);
			addSocial(gamejoltIcon);
		}
		if (data.kickstarter != null && data.kickstarter != "") {
			var kickstarterIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "kickstarter", data.kickstarter);
			addSocial(kickstarterIcon);
		}
		if (data.kofi != null && data.kofi != "") {
			var kofiIcon:SocialIcon = new SocialIcon((10 + 16 * iconScale) * (iconLength % maxIconsRow), 0, iconScale, "kofi", data.kofi);
			addSocial(kofiIcon);
		}

		socialsGroup1.x = this.x + (background.width - socialsGroup1.width) / 2;
		socialsGroup1.y -= socialsGroup1.height;

		if (socialsGroup2.members.length > 0) {
			socialsGroup2.x = this.x + (background.width - socialsGroup2.width) / 2;
			socialsGroup2.y = socialsGroup1.y;
			socialsGroup1.y -= socialsGroup2.height + 4;
		}
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