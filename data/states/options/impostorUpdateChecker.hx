import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.github.GitHub;
import funkin.backend.utils.SysZip;
import funkin.backend.system.Main;
import funkin.backend.MusicBeatState;
import haxe.io.Bytes;
import haxe.io.Error;
import haxe.io.Path;
//import haxe.zip.Entry;
import haxe.zip.Reader;
import lime.app.Future;
import lime.system.System as LimeSystem;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import sys.io.FileOutput;
import sys.io.File;
import sys.FileSystem;
import DateTools;
import ResizableUIBox;
import RGBPalette;

var mainTxt:FunkinText;
var topBar:FlxSprite;

var githubSprite:FlxSprite;
var loadingSprite:FunkinSprite;

var scrollBar:FlxSprite;
var scrollHeight:Float = 0;
var isHoldingScrollBar:Bool = false;

var githubReleases:Array<Dynamic> = [];
var thisReleaseIndex:Int = -1;

var checkForDevReleases:Bool = true;

var skipButton:FlxSpriteGroup;
var downloadButton:FlxSpriteGroup;

var downloadSubMenu:FlxSpriteGroup;

var releaseAssets:Array<FlxSpriteGroup> = [];

enum ViewerState {
	UPDATE_FOUND;
	ERROR;
	UP_TO_DATE;
	INSTALLING;
	NONE;
}

enum SelectionState {
	SKIP;
	DOWNLOAD;
	NONE;
}

function getRandomLoadingAnimation():String {
	var listOfAnims:Array<String> = [];
	for (file in Paths.getFolderContent("images/menus/general/loading", false, 1, true))
		CoolUtil.pushOnce(listOfAnims, file);

	return listOfAnims[FlxG.random.int(0, listOfAnims.length - 1)];
}

var githubRequest:Future<Array<Dynamic>> = null;

function create() {
	//if (!FlxG.save.data.impPixelCheckUpdates) {
		MusicBeatState.skipTransOut = true;
		startMod();
		return;
	//}

	changeDiscordStatus("Checking for Updates");

	FlxG.mouse.visible = true;

	FlxG.camera.bgColor = 0xFF0D1117;

	topBar = new FlxSprite().makeGraphic(FlxG.width, FlxG.height / 8, 0xFF010409);
	topBar.scrollFactor.set(0, 0);
	add(topBar);

	var littleLine:FlxSprite = new FlxSprite(0, topBar.height).makeGraphic(topBar.width, 2, 0xFF3D444D);
	littleLine.scrollFactor.set(0, 0);
	add(littleLine);

	githubSprite = new FlxSprite(42, 10).loadGraphic(Paths.image("menus/general/github"), true, 34, 34);
	githubSprite.animation.add("idle", [0]);
	githubSprite.animation.add("hover", [1]);
	githubSprite.scale.set(2, 2);
	githubSprite.updateHitbox();
	githubSprite.scrollFactor.set(0, 0);
	add(githubSprite);

	mainTxt = new FunkinText(0, topBar.height / 2, 1280, translate("update.checking"), 32, false);
	mainTxt.alignment = "center";
	mainTxt.font = Paths.font("pixeloidsans.ttf");
	mainTxt.screenCenter(FlxAxes.X);
	mainTxt.scrollFactor.set(0, 0);
	mainTxt.y -= mainTxt.height / 2;
	add(mainTxt);

	var loadingAnim:String = getRandomLoadingAnimation();
	loadingSprite = new FunkinSprite().loadSprite(Paths.image("menus/general/loading/" + loadingAnim));
	loadingSprite.addAnim("animation", loadingAnim, 24, true);
	loadingSprite.scale.set(4, 4);
	loadingSprite.updateHitbox();
	loadingSprite.screenCenter();
	loadingSprite.y += topBar.height / 2;
	add(loadingSprite);

	scrollHeight = littleLine.y + littleLine.height;
	var scrollBg:FlxSprite = new FlxSprite(FlxG.width, scrollHeight).makeGraphic(10, FlxG.height - scrollHeight, 0xFFFFFFFF);
	scrollBg.scrollFactor.set(0, 0);
	scrollBg.alpha = 0.2;
	scrollBg.x -= scrollBg.width;
	add(scrollBg);

	scrollBar = new FlxSprite(scrollBg.x, scrollBg.y).makeGraphic(10, 1, 0xFFFFFFFF);
	scrollBar.scrollFactor.set(0, 0);
	scrollBar.alpha = 0.3;
	add(scrollBar);

	updateScrollHeight();

	tryGetReleases();
}

function tryGetReleases() {
	viewState = ViewerState.NONE;

	mainTxt.text = translate("update.checking");

	loadingSprite.revive();
	loadingSprite.playAnim("animation");

	if (errorLog != null) errorLog.destroy();
	if (skipButton != null) skipButton.destroy();
	if (downloadButton != null) downloadButton.destroy();

	FlxG.camera.minScrollY = null;
	FlxG.camera.maxScrollY = null;
	updateScrollHeight();

	githubRequest = new Future<Array<Dynamic>>(processReleases, true);

	// for whatever reason, theres a chance the `githubRequest` variable may return null after initialization, if that happens, the state just gets reset.
	// added as a failsafe
	// theres a rare chance this failsafe fails (?????????)
	if (githubRequest == null) {
		setTransition("closingSharpCircle");
		MusicBeatState.skipTransIn = true;
		FlxG.resetState();
	} else {
		githubRequest.onComplete(function(data:Array<Dynamic>) {
			if (data != null && data.length > 0)
				foundUpdate(data);
		});
		githubRequest.onError(retrieveReleasesCheckError);
	}
}

function processReleases():Array<Dynamic> {
	githubReleases = GitHub.getReleases("kenton54", "VS-IMPOSTOR-Pixel", retrieveReleasesCheckError);

	var recentBuild:Int = -1;
	var recentDate:Date = new Date(0, 0, 1, 0, 0, 0);
	if (githubReleases.length > 0) {
		try {
			for (i => release in githubReleases) {
				if (release == null)
					continue;

				if (!checkForDevReleases)
					if (StringTools.startsWith(release.tag_name, "dev"))
						continue;

				// then it checks if the version tag is 3 numbers splitted between dots (for example 1.0.0)
				var invalidVersion:Bool = false;
				var formatRelease:Array<Int> = [];
				try {
					for (version in release.tag_name.split(".")) {
						var intVersion:Int = Std.parseInt(version);
						if (intVersion == null) break;
						formatRelease.push(intVersion);
					}
				} catch (e:Dynamic) {
					throw "Version not valid! error: " + e;
					invalidVersion = true;
				}

				// after checking for normal releases, it checks for dev releases (if the check for them is activated)
				var invalidDevVersion:Bool = false;
				var formatDevRelease:Array<Int> = [];
				if (checkForDevReleases) {
					if (!StringTools.startsWith(release.tag_name, "dev"))
						continue;

					var devVersion:String = StringTools.replace(release.tag_name, "dev", "");
					if (StringTools.contains(devVersion, ".")) {
						try {
							for (version in devVersion.split(".")) {
								var intVersion:Int = Std.parseInt(version);
								formatDevRelease.push(intVersion);
							}
						} catch (e:Dynamic) {
							throw "Developer Version not valid! error: " + e;
							invalidDevVersion = true;
						}
					} else {
						var intVersion:Int = Std.parseInt(devVersion);
						formatDevRelease.push(intVersion);
					}
				}

				if (checkForDevReleases)
					if (invalidVersion && invalidDevVersion)
						continue;
					else if (invalidVersion)
						continue;

				// then it finds the most recent build
				var date:String = release.published_at.substring(0, release.published_at.indexOf("T"));
				var time:String = release.published_at.substring(release.published_at.indexOf("T") + 1, release.published_at.indexOf("Z"));
				var buildDate:Date = Date.fromString(date + " " + time);

				if (buildDate.getTime() > recentDate.getTime())
					recentDate = buildDate;
				else
					continue;

				recentBuild = i;
			}
		} catch(e:Dynamic) {
			retrieveReleasesCheckError(e);
			throw e;
		}
	}

	return githubReleases[recentBuild];
}

var errorLog:FunkinText;

function retrieveReleasesCheckError(error) {
	logTraceErrorState("UpdateChecker", 'An error ocurred while trying to check for a newer update! (Error log: "' + error + '")');

	githubRequest = null;

	// theres a rare case that this throws a error (which shouldnt happen) (funny, an error throwing an error)
	// this line of code helps lower those chances (but it still happens, codename devs fix this if you can istg)
	var daError:Dynamic = error;
	// why do i have to do this :sob: (without this, the engine just creates garbage textures)
	new FlxTimer().start(0.01, _ -> {
		loadingSprite.stopAnim();
		loadingSprite.kill();

		mainTxt.text = translate("update.fail");

		var errorPos:Float = 0;
		errorLog = new FunkinText(0, 0, FlxG.width, translate("update.errorLog", [daError]), 26, false);
		errorLog.alignment = "center";
		errorLog.font = Paths.font("pixeloidsans.ttf");
		errorLog.screenCenter();
		insert(0, errorLog);

		skipButton = new FlxSpriteGroup();
		insert(members.indexOf(errorLog) + 1, skipButton);

		downloadButton = new FlxSpriteGroup();
		insert(members.indexOf(skipButton), downloadButton);

		var skipBack:ResizableUIBox = new ResizableUIBox(0, 0, 280, 50, "githubButton", 2, 0xFF212830);
		skipButton.add(skipBack.box);

		var skipTxt:FunkinText = new FunkinText(0, skipBack.height / 2, skipBack.width, translate("update.continue"), 24, false);
		skipTxt.font = Paths.font("pixeloidsans.ttf");
		skipTxt.alignment = "center";
		skipTxt.y -= skipTxt.height / 2;
		skipButton.add(skipTxt);

		var skipOverlay:ResizableUIBox = new ResizableUIBox(-1, -1, skipBack.initialWidth - 4, skipBack.initialHeight - 4, "githubOverlay", skipBack.scale,
			FlxColor.TRANSPARENT);
		skipOverlay.visible = false;
		skipButton.add(skipOverlay.box);

		var retryBack:ResizableUIBox = new ResizableUIBox(0, 0, skipBack.initialWidth, skipBack.initialHeight, skipBack.style, skipBack.scale, 0xFF212830);
		downloadButton.add(retryBack.box);

		var retryTxt:FunkinText = new FunkinText(0, retryBack.height / 2, retryBack.width, translate("retry"), 24, false);
		retryTxt.font = Paths.font("pixeloidsans.ttf");
		retryTxt.alignment = "center";
		retryTxt.y -= retryTxt.height / 2;
		downloadButton.add(retryTxt);

		var retryOverlay:ResizableUIBox = new ResizableUIBox(-1, -1, retryBack.initialWidth - 4, retryBack.initialHeight - 4, "githubOverlay",
			retryBack.scale, FlxColor.TRANSPARENT);
		retryOverlay.visible = false;
		downloadButton.add(retryOverlay.box);

		skipButton.x = FlxG.width * 0.42;
		skipButton.x -= skipButton.width;
		downloadButton.x = FlxG.width * 0.58;

		var buttonsPos:Float = errorLog.y + errorLog.height + 40;
		skipButton.y = buttonsPos;
		downloadButton.y = buttonsPos;

		updateScrollHeight();
		viewState = ViewerState.ERROR;
	});
}

function updateScrollHeight() {
	var heightMult:Float = 1;

	if (FlxG.camera.maxScrollY != null && FlxG.camera.maxScrollY > FlxG.height)
		heightMult = FlxG.height / (FlxG.camera.maxScrollY);

	scrollBar.setGraphicSize(scrollBar.width, (FlxG.height - scrollHeight)  * heightMult);
	scrollBar.updateHitbox();
}

function updateScrollBarPosition(posMult:Float) {
	scrollBar.y = scrollHeight + (FlxG.height - scrollHeight) * posMult;
	scrollBar.y -= scrollBar.height * posMult;
}

var foundRelease:Array<Dynamic> = [];
function foundUpdate(releaseData:Array<Dynamic>) {
	foundRelease = releaseData;

	if (errorLog != null) errorLog.destroy();
	githubRequest = null;

	var releaseTag:String = StringTools.startsWith(foundRelease.tag_name, "dev") ? foundRelease.tag_name.substring(foundRelease.tag_name.indexOf("dev") + 3, foundRelease.tag_name.length) : foundRelease.tag_name;
	var formatFoundRelease:Array<Int> = [];
	if (StringTools.contains(releaseTag, ".")) {
		for (version in releaseTag.split(".")) {
			var intVersion:Int = Std.parseInt(version);
			if (intVersion == null) break;
			formatFoundRelease.push(intVersion);
		}
	} else
		formatFoundRelease.push(Std.parseInt(releaseTag));

	var thisRelease:String = StringTools.startsWith(MOD_VERSION, "dev") ? MOD_VERSION.substring(MOD_VERSION.indexOf("dev") + 3, MOD_VERSION.length) : MOD_VERSION;
	var formatThisRelease:Array<Int> = [];
	if (StringTools.contains(MOD_VERSION, ".")) {
		for (version in MOD_VERSION.split(".")) {
			var intVersion:Int = Std.parseInt(version);
			if (intVersion == null) break;
			formatThisRelease.push(intVersion);
		}
	} else
		formatThisRelease.push(Std.parseInt(thisRelease));

	// it checks in this order: major > minor > hotfix
	if (formatThisRelease[0] < formatFoundRelease[0])
		createUpdateInfo();
	else if (formatFoundRelease[1] != null && formatThisRelease[1] != null && formatThisRelease[1] < formatFoundRelease[1])
		createUpdateInfo();
	else if (formatFoundRelease[2] != null && formatThisRelease[2] != null && formatThisRelease[2] < formatFoundRelease[2])
		createUpdateInfo();
	else
		clientIsUp2Date();
}

var releaseBody:FunkinText;
function createUpdateInfo() {
	mainTxt.text = translate("update.found", [foundRelease.name]);

	loadingSprite.stopAnim();
	loadingSprite.kill();

	var date:String = foundRelease.published_at.substring(0, foundRelease.published_at.indexOf("T"));
	var time:String = foundRelease.published_at.substring(foundRelease.published_at.indexOf("T") + 1, foundRelease.published_at.indexOf("Z"));
	var releaseDate:Date = Date.fromString(date + " " + time);
	var dateMonth:String = getMonthNameShort(releaseDate.getMonth());
	var extraInfo:String = foundRelease.tag_name + " • " + translate("update.releaseDate", [dateMonth + DateTools.format(releaseDate, " %d, %Y")]);
	var extraTxt:FunkinText = new FunkinText(0, mainTxt.y + mainTxt.height - 8, mainTxt.fieldWidth, extraInfo, 16, false);
	extraTxt.alignment = "center";
	extraTxt.font = Paths.font("pixeloidsans.ttf");
	extraTxt.screenCenter(FlxAxes.X);
	extraTxt.scrollFactor.set(0, 0);
	extraTxt.color = 0xFFAAAAAA;
	insert(members.indexOf(mainTxt) + 1, extraTxt);

	var pis:Float = 100;
	releaseBody = new FunkinText(pis, topBar.height + 20, FlxG.width - pis * 2, "", 12);
	releaseBody.font = Paths.font("pixelarial-bold.ttf");
	releaseBody.borderSize = 2;
	MarkdownUtil.applyMarkdownText(releaseBody, foundRelease.body);
	insert(0, releaseBody);

	var lowestPoint:Float = releaseBody.y + releaseBody.height;

	for (i => assetData in foundRelease.assets) {
		var groupPos:Float = pis + 60;
		var assetGroup:FlxSpriteGroup = new FlxSpriteGroup();
		insert(members.indexOf(releaseBody), assetGroup);
		releaseAssets.push(assetGroup);

		var assetBox:ResizableUIBox = new ResizableUIBox(0, 0, FlxG.width - groupPos * 2, 50, "github", 2, 0xFF0D1117);
		assetGroup.add(assetBox.box);

		var boxSpr:FlxSprite = new FlxSprite(assetBox.box.x + 20, assetBox.box.y + assetBox.box.height / 2).loadGraphic(Paths.image("menus/githubBox"));
		boxSpr.scale.set(2, 2);
		boxSpr.updateHitbox();
		boxSpr.y -= boxSpr.height / 2;
		assetGroup.add(boxSpr);

		var assetName:FunkinText = new FunkinText(boxSpr.x + boxSpr.width + 10, boxSpr.y, 0, assetData.name, 24, false);
		assetName.font = Paths.font("retrogaming.ttf");
		//assetName.color = 0xFF4493F8;
		assetGroup.add(assetName);

		var assetSize:FunkinText = new FunkinText(assetBox.box.x + assetBox.box.width - 20, boxSpr.y, 0, CoolUtil.getSizeString(assetData.size), 24, false);
		assetSize.font = Paths.font("retrogaming.ttf");
		assetSize.color = 0xFF9198A1;
		assetSize.x -= assetSize.width;
		assetGroup.add(assetSize);

		var groupVer:Float = releaseBody.y + releaseBody.height + 20;
		assetGroup.x = groupPos;
		assetGroup.y = groupVer + (4 * i);

		lowestPoint = assetGroup.y + assetGroup.height;
	}

	skipButton = new FlxSpriteGroup();
	insert(members.indexOf(releaseBody) + 1, skipButton);

	downloadButton = new FlxSpriteGroup();
	insert(members.indexOf(skipButton), downloadButton);

	var skipBack:ResizableUIBox = new ResizableUIBox(0, 0, 280, 50, "githubButton", 2, 0xFF212830);
	skipButton.add(skipBack.box);

	var skipTxt:FunkinText = new FunkinText(0, skipBack.height / 2, skipBack.width, translate("update.skip"), 24, false);
	skipTxt.font = Paths.font("pixeloidsans.ttf");
	skipTxt.alignment = "center";
	skipTxt.y -= skipTxt.height / 2;
	skipButton.add(skipTxt);

	var skipOverlay:ResizableUIBox = new ResizableUIBox(-1, -1, skipBack.initialWidth - 4, skipBack.initialHeight - 4, "githubOverlay", skipBack.scale, FlxColor.TRANSPARENT);
	skipOverlay.visible = false;
	skipButton.add(skipOverlay.box);

	var downloadBack:ResizableUIBox = new ResizableUIBox(0, 0, skipBack.initialWidth, skipBack.initialHeight, skipBack.style, skipBack.scale, 0xFF212830);
	downloadButton.add(downloadBack.box);

	var downloadTxt:FunkinText = new FunkinText(0, downloadBack.height / 2, downloadBack.width, translate("update.download"), 24, false);
	downloadTxt.font = Paths.font("pixeloidsans.ttf");
	downloadTxt.alignment = "center";
	downloadTxt.y -= downloadTxt.height / 2;
	downloadButton.add(downloadTxt);

	var downloadOverlay:ResizableUIBox = new ResizableUIBox(-1, -1, downloadBack.initialWidth - 4, downloadBack.initialHeight - 4, "githubOverlay", downloadBack.scale, FlxColor.TRANSPARENT);
	downloadOverlay.visible = false;
	downloadButton.add(downloadOverlay.box);

	skipButton.x = FlxG.width * 0.42;
	skipButton.x -= skipButton.width;
	downloadButton.x = FlxG.width * 0.58;

	var buttonsPos:Float = lowestPoint + 40;
	skipButton.y = buttonsPos;
	downloadButton.y = buttonsPos;

	lowestPoint = skipButton.y + skipButton.height + 20;

	FlxG.camera.minScrollY = 0;
	if (lowestPoint > FlxG.height) FlxG.camera.maxScrollY = lowestPoint + 40;

	updateScrollHeight();
	viewState = ViewerState.UPDATE_FOUND;
}

function clientIsUp2Date() {
	mainTxt.text = translate("update.noUpdates");

	loadingSprite.stopAnim();
	loadingSprite.kill();

	var acceptKey:FlxKey = Reflect.field(Options, "P1_ACCEPT")[0];
	var mobileDetectorLol:String = isMobile ? translate("touch", [translate("screen")]) : translate("click", [translate("mouse")]);
	var daTxt:FunkinText = new FunkinText(0, 0, 1280, createMultiLineText([
		translate("update.up2date"),
		translate("update.continuePlaying", [translate("press", [CoolUtil.keyToString(acceptKey)]) + " " + translate("or") + " " + mobileDetectorLol])
	]), 32, false);
	daTxt.font = Paths.font("pixeloidsans.ttf");
	daTxt.alignment = "center";
	daTxt.screenCenter();
	daTxt.y += topBar.height / 2;
	insert(0, daTxt);

	updateScrollHeight();
	viewState = ViewerState.UP_TO_DATE;
}

function initDownloadOverlay() {
	selecting = SelectionState.NONE;
	skipButton.members[skipButton.length - 1].visible = false;
	downloadButton.members[downloadButton.length - 1].visible = false;

	//MusicBeatState.ALLOW_DEV_RELOAD = false;

	startDownload();

	viewState = ViewerState.INSTALLING;
}

var modFolderDir:String = Path.normalize(LimeSystem.applicationDirectory) + ModsFolder.modsPath.substr(1, ModsFolder.modsPath.length);
var impPixelFolderDir:String = modFolderDir + ModsFolder.currentModFolder;
var downloadDirectory:String = impPixelFolderDir + "/downloads/";
var downloadRef:URLStream;
function startDownload() {
	var assetData:Array<Dynamic> = foundRelease.assets[0];
	var downloadPath:String = downloadDirectory + assetData.name;
	var downloadUrl:String = assetData.browser_download_url;

	var request:URLRequest = new URLRequest();
	request.url = downloadUrl;

	downloadRef = new URLLoader();
	downloadRef.dataFormat = 0;
	downloadRef.addEventListener("open", onDownloadStart);
	downloadRef.addEventListener("cancel", onDownloadCancel);
	downloadRef.addEventListener("progress", onDownloadProgress);
	downloadRef.addEventListener("complete", onDownloadComplete);
	downloadRef.addEventListener("ioError", onDownloadError);
	downloadRef.load(request);
}

function onDownloadStart(event:Event) {
	trace("download start");
	createDownloadSubMenu();
}

function onDownloadCancel(event:Event) {
	trace("download cancelled");
	destroyDownloadSubMenu();
}

var lastByteAmount:Float = 0;
var lastDownloadSpeed:Float = 0;
var lastDownloadTime:Float = 0;
var downloadSpeedTimingUpdate:Float = 0;
function onDownloadProgress(event:ProgressEvent) {
	var percent:Float = event.bytesLoaded / event.bytesTotal;
	progressBar.members[0].value = percent;
	progressTxt.text = Math.round(percent * 100) + "%";

	if (downloadSpeedTimingUpdate >= 1) {
		lastDownloadSpeed = distanceBetweenFloats(lastByteAmount, event.bytesLoaded);
		lastDownloadTime = (event.bytesTotal - event.bytesLoaded) / lastDownloadSpeed;
		downloadSpeedTimingUpdate = 0;
		lastByteAmount = event.bytesLoaded;
	}

	downloadInfoTxt.text = CoolUtil.getSizeString(lastDownloadSpeed) + "/s - " + CoolUtil.getSizeString(event.bytesLoaded) + " / " + CoolUtil.getSizeString(event.bytesTotal);
	downloadEstimatedTimeTxt.text = translate("game.tasks.download.estimatedTime", [formatAmongUsDownloadTime(lastDownloadTime)]);
}

var queuedEnd:Bool = false;
function onDownloadComplete(event:Event) {
	trace("download finish", event);

	progressBar.members[0].value = 1; // sometimes the bar doesn't draw complete properly, due to float quirks

	queuedEnd = true;

	var zipBytes:ByteArray = event.target.data;
	var haxeBytes:Bytes = ByteArray.toBytes(zipBytes);

	if (!FileSystem.exists(downloadDirectory))
		FileSystem.createDirectory(downloadDirectory);

	var filePath:String = downloadDirectory + foundRelease.assets[0].name;
	var zipFile:FileOutput = File.write(filePath, true);
	zipFile.writeBytes(haxeBytes, 0, haxeBytes.length);
	zipFile.close();

	finishInstallation(filePath);
}

function onDownloadError(event:IOErrorEvent) {
	trace("download errored", event.target);

	destroyDownloadSubMenu();
}

var tablet:FlxSprite;
var crewDownload:FunkinSprite;
var serverFolder:FunkinSprite;
var serverTxt:FunkinText;
var destFolder:FunkinSprite;
var destTxt:FunkinText;
var downloadEstimatedTimeTxt:FunkinText;
var downloadInfoTxt:FunkinText;
var progressBar:FlxSpriteGroup;
var progressTxt:FunkinText;
function createDownloadSubMenu() {
	downloadSubMenu = new FlxSpriteGroup();
	downloadSubMenu.scrollFactor.set(0, 0);
	add(downloadSubMenu);

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.alpha = 0.6;
	downloadSubMenu.add(bg);

	tablet = new FlxSprite().loadGraphic(Paths.image("menus/tasks/tablet-download"));
	tablet.scale.set(4, 4);
	tablet.updateHitbox();
	tablet.screenCenter();

	var tabletBg:FlxSprite = new FlxSprite(tablet.x + 15, tablet.y + 15).makeGraphic(tablet.width - 15 * 2, tablet.height - 15 * 2, 0xFF3C6490);
	downloadSubMenu.add(tabletBg);

	var insideScale:Float = 3;

	crewDownload = new FunkinSprite().loadSprite(Paths.image("menus/tasks/crewmate-download"));
	crewDownload.addAnim("image", "walk-image", 24, true);
	crewDownload.addAnim("music", "walk-music", 24, true);
	crewDownload.addAnim("audio", "walk-audio", 24, true);
	crewDownload.addAnim("video", "walk-video", 24, true);
	crewDownload.addAnim("data", "walk-data", 24, true);
	crewDownload.addAnim("language", "walk-language", 24, true);
	crewDownload.addAnim("xml", "walk-xml", 24, true);
	crewDownload.addAnim("json", "walk-json", 24, true);
	crewDownload.addAnim("haxe", "walk-haxe", 24, true);
	crewDownload.addAnim("zip", "walk-zip", 24, true);
	crewDownload.addAnim("aseprite", "walk-aseprite", 24, true);
	crewDownload.playAnim("image");
	crewDownload.scale.set(insideScale - 0.8, insideScale - 0.8);
	crewDownload.updateHitbox();
	crewDownload.moves = true;
	crewDownload.shader = new RGBPalette(FlxColor.WHITE, FlxColor.WHITE, FlxColor.WHITE).shader;
	downloadSubMenu.add(crewDownload);

	serverFolder = new FunkinSprite((tablet.x + 8 * tablet.scale.x) + 12 * tablet.scale.x, (tablet.y + 8 * tablet.scale.y) + 20 * tablet.scale.y).loadSprite(Paths.image("menus/tasks/folder-download"));
	serverFolder.addAnim("filled", "filled", 24, false);
	serverFolder.playAnim("filled", true, "NONE", true);
	serverFolder.animation.finish();
	serverFolder.scale.set(insideScale, insideScale);
	serverFolder.updateHitbox();
	serverFolder.animation.onFinish.add(function(animName:String) {
		if (!serverFolder.animation.curAnim.reversed)
			new FlxTimer().start(1, _ -> serverFolder.playAnim("filled", true, "NONE", true));
	});
	downloadSubMenu.add(serverFolder);

	serverTxt = new FunkinText(serverFolder.x, serverFolder.y + serverFolder.height + 4, serverFolder.width, "github.com", 20, false);
	serverTxt.alignment = "center";
	serverTxt.font = Paths.font("pixeloidsans.ttf");
	downloadSubMenu.add(serverTxt);

	destFolder = new FunkinSprite(serverFolder.x + 124 * tablet.scale.x, serverFolder.y).loadGraphicFromSprite(serverFolder);
	destFolder.removeAnim("filled");
	destFolder.addAnim("empty", "empty", 24, false);
	destFolder.playAnim("empty", true, "NONE", true);
	destFolder.animation.finish();
	destFolder.scale.set(insideScale, insideScale);
	destFolder.updateHitbox();
	destFolder.animation.onFinish.add(function(animName:String) {
		if (!destFolder.animation.curAnim.reversed)
			new FlxTimer().start(1, _ -> destFolder.playAnim("empty", true, "NONE", true));
		else {
			if (isDummyWalking) {
				endWalkCycle();
				if (!queuedEnd) new FlxTimer().start(1, _ -> startWalkCycle());
			}
		}
	});
	downloadSubMenu.add(destFolder);

	destTxt = new FunkinText(destFolder.x, destFolder.y + destFolder.height + 4, destFolder.width, "VS IMPOSTOR Pixel", 20, false);
	destTxt.alignment = "center";
	destTxt.font = Paths.font("pixeloidsans.ttf");
	downloadSubMenu.add(destTxt);

	progressBar = new FlxSpriteGroup(serverTxt.x + serverTxt.width / 4, serverTxt.y + serverTxt.height + 20);
	downloadSubMenu.add(progressBar);

	var theBar:FlxBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, tablet.width - tablet.width / 2, 30);
	theBar.setRange(0, 1);
	theBar.createFilledBar(FlxColor.WHITE, 0xFF238E1C);
	progressBar.add(theBar);

	var barBorder:ResizableUIBox = new ResizableUIBox(-2, -2, theBar.barWidth - theBar.barHeight / 2 - 2, theBar.barHeight - theBar.barHeight / 2 - 2, "black", insideScale, FlxColor.TRANSPARENT);
	progressBar.add(barBorder.box);

	progressTxt = new FunkinText(progressBar.x + progressBar.width, progressBar.y, 240, "0%", 32, false);
	progressTxt.alignment = "center";
	progressTxt.font = Paths.font("pixeloidsans.ttf");
	progressTxt.y -= progressTxt.height / 6;
	downloadSubMenu.add(progressTxt);

	downloadInfoTxt = new FunkinText(progressBar.x, progressBar.y + progressBar.height, progressBar.width, CoolUtil.getSizeString(0) + "/s - " + CoolUtil.getSizeString(0) + " / " + CoolUtil.getSizeString(0), 16, false);
	downloadInfoTxt.alignment = "center";
	downloadInfoTxt.font = Paths.font("pixeloidsans.ttf");
	downloadSubMenu.add(downloadInfoTxt);

	downloadEstimatedTimeTxt = new FunkinText(serverFolder.x + 4 * insideScale, downloadInfoTxt.y + downloadInfoTxt.height + 2 * insideScale, 0, translate("game.tasks.download.estimatedTime", [formatAmongUsDownloadTime(0)]), 28, false);
	downloadEstimatedTimeTxt.font = Paths.font("pixeloidsans.ttf");
	downloadSubMenu.add(downloadEstimatedTimeTxt);

	downloadSubMenu.add(tablet);

	startWalkCycle();
}

var crewmateColors:Array<Array<Int>> = [
	[0xFFE31629, 0xFF52C4FF, 0xFF90003A],
	[0xFF3842AE, 0xFF52C4FF, 0xFF2A1F78],
	[0xFF18683B, 0xFF52C4FF, 0xFF0D412E],
	[0xFFEf69CB, 0xFF52C4FF, 0xFFB74175],
	[0xFFF6CC5A, 0xFF52C4FF, 0xFFD98E25],
	[0xFF352441, 0xFF52C4FF, 0xFF23182F],
	[0xFFD2E5E8, 0xFF52C4FF, 0xFF97ABB5],
	[0xFF461D87, 0xFF52C4FF, 0xFF251161],
	[0xFF5D3E31, 0xFF52C4FF, 0xFF412720],
	[0xFF61C2EF, 0xFF52C4FF, 0xFF3B75C0],
	[0xFF5DD95D, 0xFF52C4FF, 0xFF338C44],
	[0xFF58223C, 0xFF52C4FF, 0xFF41132E],
	[0xFFFFBBD9, 0xFF52C4FF, 0xFFCD7FB4],
	[0xFFF8ECAA, 0xFF52C4FF, 0xFFE2BC69],
	[0xFF67768E, 0xFF52C4FF, 0xFF4C5371],
	[0xFF998877, 0xFF52C4FF, 0xFF6F5B4E],
	[0xFFFF7488, 0xFF52C4FF, 0xFFD94368],
	[0xFF047A49, 0xFF52C4FF, 0xFF00513B],
	[0xFF415D21, 0xFF52C4FF, 0xFF354112],
	[0xFFFFFF00, 0xFF29D496, 0xFFFF0000]
];
var isDummyWalking:Bool = false;
var isDummyNearEnd:Bool = false;
function startWalkCycle() {
	crewDownload.revive();

	function chooseRandomColorPalette():Int {
		var index:Int = FlxG.random.int(0, crewmateColors.length - 1);

		if (index == index.length - 1 && FlxG.random.bool(95))
			return chooseRandomColorPalette(); // reroll lol
		if ((index == index.length - 2 || index == index.length - 3) && FlxG.random.bool(80))
			return chooseRandomColorPalette(); // reroll lol

		return index;
	}

	var animationList:Array<String> = crewDownload.getNameList();
	crewDownload.playAnim(animationList[FlxG.random.int(0, animationList.length - 1)], true);

	var choosenColorArray:Array<Int> = crewmateColors[chooseRandomColorPalette()];
	var easierSetupLol:RGBPalette = new RGBPalette(choosenColorArray[0], choosenColorArray[1], choosenColorArray[2]);
	crewDownload.shader = easierSetupLol.shader;

	crewDownload.setPosition(serverFolder.x + serverFolder.width / 2, serverFolder.y + serverFolder.height);
	crewDownload.x -= crewDownload.width / 2;
	crewDownload.y -= crewDownload.height;
	crewDownload.velocity.x = 160;

	serverFolder.playAnim("filled");

	isDummyWalking = true;
}

function endWalkCycle() {
	crewDownload.velocity.x = 0;

	crewDownload.kill();

	isDummyWalking = false;
	isDummyNearEnd = false;

	if (queuedEnd)
		new FlxTimer().start(0.01, _ -> destroyDownloadSubMenu()); // 10ms cooldown, otherwise game crashes due to flixel signals's shit
}

function destroyDownloadSubMenu() {
	downloadSubMenu.forEach(function(spr) {
		spr.destroy();
	});
	downloadSubMenu.destroy();
}

function finishInstallation(path:String) {
	var zipData:SysZip = null;
	var ignoreRest:Bool = false;

	function analizeFile(file:Dynamic) {
		// is the entry a file or a folder?
		var isDirectory:Bool = false;
		if (StringTools.endsWith(file.fileName, "/"))
			isDirectory = true;

		if (isDirectory && FileSystem.exists(modFolderDir + file.fileName)) {
			FileSystem.createDirectory(modFolderDir + file.fileName);
			return;
		}

		// it checks if the file actually exists
		// if it doesnt, just create it and add it to the mods folders
		if (!FileSystem.exists(modFolderDir + file.fileName)) {
			var extractedFile:FileOutput = File.write(modFolderDir + file.fileName, true);
			extractedFile.writeBytes(haxeBytes, 0, haxeBytes.length);
			extractedFile.close();
		}
		else {

		}
	}

	zipData = ZipUtil.openZip(path);
	var fileSize:Float = 0;
	var dataSize:Float = 0;
	for (entry in zipData.read()) {
		fileSize += entry.fileSize;
		dataSize += entry.dataSize;
	}
}

function cleanup(path:String) {
	try {
		if (FileSystem.exists(path))
			FileSystem.deleteFile(path);
	} catch(e:Dynamic) {}
}

var viewState:ViewerState = ViewerState.NONE;
var scrollAmount:Float = 1000;
var lerpScroll:Float = 0;
var selecting:SelectionState = SelectionState.NONE;
function update(elapsed:Float) {
	if (viewState != ViewerState.INSTALLING) {
		if (pointerOverlaps(githubSprite)) {
			githubSprite.animation.play("hover");
			if (pointerJustPressed())
				CoolUtil.openURL("https://github.com/kenton54/VS-IMPOSTOR-Pixel");
		} else
			githubSprite.animation.play("idle");

		if (viewState == ViewerState.UPDATE_FOUND) {
			if (controls.UP)
				lerpScroll = FlxMath.bound(lerpScroll - (scrollAmount / 2) * elapsed, FlxG.camera.minScrollY, FlxG.camera.maxScrollY - FlxG.height);
			if (controls.DOWN)
				lerpScroll = FlxMath.bound(lerpScroll + (scrollAmount / 2) * elapsed, FlxG.camera.minScrollY, FlxG.camera.maxScrollY - FlxG.height);

			lerpScroll = FlxMath.bound(lerpScroll - FlxG.mouse.wheel * (scrollAmount * 6) * elapsed, FlxG.camera.minScrollY, FlxG.camera.maxScrollY - FlxG.height);

			FlxG.camera.scroll.y = CoolUtil.fpsLerp(FlxG.camera.scroll.y, lerpScroll, 0.25);

			updateScrollBarPosition(FlxG.camera.scroll.y / (FlxG.camera.maxScrollY - FlxG.height));

			if (FlxG.camera.maxScrollY == null || FlxG.camera.scroll.y >= FlxG.camera.maxScrollY - (FlxG.camera.maxScrollY / 16) - FlxG.height) {
				if (globalUsingKeyboard) {
					if (controls.LEFT_P) {
						selecting = SelectionState.SKIP;
						skipButton.members[skipButton.length - 1].visible = true;
						downloadButton.members[downloadButton.length - 1].visible = false;
					}
					if (controls.RIGHT_P) {
						selecting = SelectionState.DOWNLOAD;
						skipButton.members[skipButton.length - 1].visible = false;
						downloadButton.members[downloadButton.length - 1].visible = true;
					}
					if (controls.ACCEPT)
						checkSelection(viewState);

					return;
				}

				if (pointerOverlaps(skipButton)) {
					selecting = SelectionState.SKIP;
					skipButton.members[skipButton.length - 1].visible = true;
					downloadButton.members[downloadButton.length - 1].visible = false;
				} else if (pointerOverlaps(downloadButton)) {
					selecting = SelectionState.DOWNLOAD;
					skipButton.members[skipButton.length - 1].visible = false;
					downloadButton.members[downloadButton.length - 1].visible = true;
				} else {
					selecting = SelectionState.NONE;
					skipButton.members[skipButton.length - 1].visible = false;
					downloadButton.members[downloadButton.length - 1].visible = false;
				}

				if (pointerJustReleased())
					checkSelection(viewState);
			}
		}
		else if (viewState == ViewerState.UP_TO_DATE) {
			if (controls.ACCEPT || pointerJustPressed())
				startMod();
		}
		else if (viewState == ViewerState.ERROR) {
			if (globalUsingKeyboard) {
				if (controls.LEFT_P) {
					selecting = SelectionState.SKIP;
					skipButton.members[skipButton.length - 1].visible = true;
					downloadButton.members[downloadButton.length - 1].visible = false;
				}
				if (controls.RIGHT_P) {
					selecting = SelectionState.DOWNLOAD;
					skipButton.members[skipButton.length - 1].visible = false;
					downloadButton.members[downloadButton.length - 1].visible = true;
				}
				if (controls.ACCEPT)
					checkSelection(viewState);

				return;
			}

			if (pointerOverlaps(skipButton)) {
				selecting = SelectionState.SKIP;
				skipButton.members[skipButton.length - 1].visible = true;
				downloadButton.members[downloadButton.length - 1].visible = false;
			} else if (pointerOverlaps(downloadButton)) {
				selecting = SelectionState.DOWNLOAD;
				skipButton.members[skipButton.length - 1].visible = false;
				downloadButton.members[downloadButton.length - 1].visible = true;
			} else {
				selecting = SelectionState.NONE;
				skipButton.members[skipButton.length - 1].visible = false;
				downloadButton.members[downloadButton.length - 1].visible = false;
			}

			if (pointerJustReleased())
				checkSelection(viewState);
		}
	} else {
		downloadSpeedTimingUpdate += elapsed;

		if (isDummyWalking && !isDummyNearEnd) {
			if (FlxG.overlap(crewDownload, destFolder)) {
				crewDownload.velocity.x = 120;
				isDummyNearEnd = true;

				destFolder.playAnim("empty");
			}
		}
	}
}

function checkSelection(curState:ViewerState) {
	if (curState == ViewerState.ERROR) {
		switch (selecting) {
			case SelectionState.SKIP:
				startMod();
			case SelectionState.DOWNLOAD:
				tryGetReleases();
			case SelectionState.NONE:
				// nothing lol
		}
	}
	else if (curState == ViewerState.UPDATE_FOUND) {
		switch (selecting) {
			case SelectionState.SKIP:
				startMod();
			case SelectionState.DOWNLOAD:
				initDownloadOverlay();
			case SelectionState.NONE:
				// nothing lol
		}
	}
}

function retrieveReleaseInstallError(error) {
	logTraceErrorState("UpdateChecker", 'An error ocurred while trying to install the found update! (Error log: "' + error + '")');
}

function startMod() {
	setTransition("closingSharpCircle");
	FlxG.switchState(new ModState("warnings/impostorWarningState"));
}

function destroy() {
	MusicBeatState.ALLOW_DEV_RELOAD = true;

	FlxG.camera.bgColor = 0xFF000000;

	mainTxt.destroy();
	githubSprite.destroy();
	topBar.destroy();
	if (loadingSprite != null) loadingSprite.destroy();
	scrollBar.destroy();

	if (releaseBody != null) releaseBody.destroy();
	if (downloadSubMenu != null) downloadSubMenu.destroy();

	releases = null;
	githubRequest = null;
}