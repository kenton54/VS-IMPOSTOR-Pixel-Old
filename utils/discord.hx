import funkin.backend.utils.DiscordUtil;

public static function changeDiscordStatus(state:String, ?details:String)
	DiscordUtil.call("changePresence", [state, details]);

public static function changeDiscordMenuStatus(menu:String)
	DiscordUtil.call("onMenuLoaded", [menu]);

public static function changeDiscordEditorTreeStatus(menu:String)
	DiscordUtil.call("onEditorTreeLoaded", [menu]);

public static function setDiscordActivity(activity:String)
	DiscordUtil.call("setActivity", [activity]);

public static function setDiscordLargeImage(key:String, ?text:String)
	DiscordUtil.call("setLargeImage", [key, text]);