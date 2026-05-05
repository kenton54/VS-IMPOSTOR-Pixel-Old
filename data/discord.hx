import flixel.util.FlxStringUtil;
import funkin.backend.utils.DiscordUtil;
import hxdiscord_rpc.Types as DiscordTypes;

function new() {}

var curActivity:ActivityType = ActivityType.Playing;
var curLargeImageKey:String = "mainnew";
var curLargeImageText:String = "VS IMPOSTOR Pixel";

function onDiscordPresenceUpdate(event) {
	var presence = event.presence;

	presence.button1Label = "Play the Mod";
	presence.button1Url = "https://gamebanana.com/mods/506768";

	presence.activityType = curActivity;

	presence.largeImageKey = curLargeImageKey;
	presence.largeImageText = curLargeImageText;
}

function changePresence(state:String, ?details:String) {
	DiscordUtil.changePresenceSince(state, details);
}

function onMenuLoaded(name:String) {
    DiscordUtil.changePresenceSince("Navigating Menus", name);
}

function onPlayStateUpdate() {
	DiscordUtil.changeSongPresence(
		PlayState.instance.detailsText,
		(isPlayingVersus ? "1v1 Versus: " : "Playing: ") + PlayState.SONG.meta.displayName + " [" + FlxStringUtil.toTitleCase(PlayState.difficulty) + "]",
		PlayState.instance.inst
	);
}

function onGameOver() {
	DiscordUtil.changePresence('Game Over', PlayState.SONG.meta.displayName + " [" + FlxStringUtil.toTitleCase(PlayState.difficulty) + "]");
}

function onEditorTreeLoaded(name:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Choosing a Character", null);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Choosing a Chart", null);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Choosing a Stage", null);
		case "Week Selector":
			DiscordUtil.changePresenceSince("Choosing a Week", null);
	}
}

function onEditorLoaded(name:String, editingThing:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Editing a Character", editingThing);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Editing a Chart", editingThing);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Editing a Stage", editingThing);
	}
}

function setLargeImage(key:String, ?text:String) {
	curLargeImageKey = key;
	if (text != null) curLargeImageText = text;
}

function setActivity(activity:String)
	curActivity = getActivityFromString(activity.toLowerCase());

function getActivityFromString(activity:String):ActivityType {
	switch(activity) {
		case "playing":
			return ActivityType.Playing;
		case "competing":
			return ActivityType.Competing;
		case "watching":
			return ActivityType.Watching;
		case "listening":
			return ActivityType.Listening;
		default:
			return ActivityType.Playing;
	}
}

/*
function destroy() {
	if (DiscordUtil.ready) {
		DiscordUtil.user.handle = null;
		DiscordUtil.user.userId = null;
		DiscordUtil.user.username = null;
		DiscordUtil.user.discriminator = null;
		DiscordUtil.user.avatar = null;
		DiscordUtil.user.globalName = null;
		DiscordUtil.user.bot = null;
		DiscordUtil.user.flags = null;
		DiscordUtil.user.premiumType = null;
	}
}
*/