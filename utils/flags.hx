public static var foundCrew:Array<String> = [/*character name*/];

public static var weeksCompleted:Map<String, String> = [/*week ID => character*/];

public static var seenPlayables:Array<String> = [/*playable*/];

public static var watchedVideos:Array<String> = [/*video path*/];

public static function getFlags(?useDefault:Bool):Map<String, Dynamic> {
    var map:Map<String, Dynamic> = [];

    if (useDefault) {
        map.set("foundCrew", []);
        map.set("weeksCompleted", []);
        map.set("seenPlayables", []);
        map.set("watchedVideos", []);
    }
    else {
        map.set("foundCrew", foundCrew);
        map.set("weeksCompleted", weeksCompleted);
        map.set("seenPlayables", seenPlayables);
        map.set("watchedVideos", watchedVideos);
    }

    return map;
}

public static function resetFlags() {
	  foundCrew = [];
    weeksCompleted.clear();
	  seenPlayables = [];
	  watchedVideos = [];
}