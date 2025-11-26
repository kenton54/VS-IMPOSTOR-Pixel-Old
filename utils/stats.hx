final defaultStats:Map<String, Dynamic> = [
    "totalPlaytime" => 0,
    "storyProgress" => "start",
    "totalNotes" => 0,
    "perfectNotes" => 0,
    "sickNotes" => 0,
    "goodNotes" => 0,
    "badNotes" => 0,
    "shitNotes" => 0,
    "missedNotes" => 0,
    "combosBroken" => 0,
    "attacksDodged" => 0,
    "taskSpeedrunSkeld" => 0.0,
    "taskSpeedrunMira" => 0.0,
    "taskSpeedrunPolus" => 0.0,
    "taskSpeedrunAirship" => 0.0,
	"taskSpeedrunFungle" => 0.0,
    "totalTasks" => 0
];
var impostorStats:Map<String, Dynamic> = [];

public static function setStat(id:String, value:Dynamic)
	impostorStats.set(id, value);

public static function addStatPoints(id:String, points:Int)
    setStat(id, getStatValue(id) + points);

public static function addStatFloat(id:String, value:Float)
	setStat(id, getStatValue(id) + value);

public static function getStats(?def:Bool):Map<String, Dynamic> {
    var map:Map<String, Dynamic> = [];

    if (def) {
        for (stat in defaultStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    } else {
        for (stat in impostorStats.keyValueIterator()) {
            map.set(stat.key, stat.value);
        }
    }

    return map;
}

public static function getStatName(id:String):Null<String> {
    var success:Bool = false;

    function fail() {
		logTraceError('Statistic ID "' + id + '" doesn\'t exists!');
        return null;
    }

	if (!statExists(id))
		return fail();

    for (stat in impostorStats.keys()) {
        if (stat == id) {
            return translate("mainMenu.stats." + stat);
        }
    }

	logTraceColored([{
        text: 'Statistic ID "' + id + '" doesn\'t exists in the save data!', color: getLogColor("yellow")
    }], "warning");

    for (stat in defaultStats.keys()) {
        if (stat == id) {
            return translate("mainMenu.stats." + stat);
        }
    }

	return fail();
}

public static function getStatValue(id:String):Dynamic {
	if (!statExists(id)) {
		logTraceError('Stat ID "' + id + '" doesn\'t exist!');
        return null;
    }

    if (impostorStats.exists(id))
        return impostorStats.get(id);
    else
        return defaultStats.get(id);
}

function statExists(id:String):Bool
	return defaultStats.exists(id) || impostorStats.exists(id);

public static function clearStats()
	impostorStats.clear();