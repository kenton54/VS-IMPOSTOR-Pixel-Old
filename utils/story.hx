var storyStates:Array<String> = [
	"start",
	"deadMenu",
	"postTutorial",
	"enteringLobby",
	"postLobby",
	"postWeek1",
	"menuRevival",
	// "postWeek3",
	"postWeek4",
	"postBlack1",
	"ominousPart1",
	"ominousPart2",
	"ominousFinal",
	"endgame"
];

var storySequence:Int = 0;

public static function getStoryProgress():Int
	return storySequence;

public static function advanceStory()
	storySequence++;

public static function isBelowStoryPoint(stateID:String):Bool {
	if (!storyStates.contains(stateID)) {
        logTraceError('The story state ID "' + stateID + '" doesn\'t exists!');
		return false;
    }

	return getStoryProgress() < storyStates.indexOf(stateID);
}

public static function setStoryProgression(value:Int)
	storySequence = value;

public static function resetStoryProgression()
	storySequence = 0;