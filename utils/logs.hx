import funkin.backend.system.Logs;

public static function logTraceColored(text:Array<LogText>, ?level:String) {
	var fullLog:Array<LogText> = [Logs.getPrefix("VS IMPOSTOR Pixel")];
    if (text.length > 0)
        for (logLine in text)
			fullLog.push(logLine);
	Logs.traceColored(fullLog, getLogLevel(level));
}

public static function logTraceState(state:String, text:Array<LogText>, ?level:String) {
	var fullLog:Array<LogText> = [Logs.getPrefix(state)];
	if (text.length > 0)
		for (logLine in text)
			fullLog.push(logLine);
	Logs.traceColored(fullLog, getLogLevel(level));
}

public static function logTraceError(error:String) {
	logTraceColored([{text: error, color: getLogColor("red")}], "error");
}

public static function logTraceErrorState(state:String, error:String) {
	logTraceState(state, [{text: error, color: getLogColor("red")}], "error");
}

public static function getLogLevel(string:String):Int {
    switch(string) {
        case "info": return 0;
        case "warning": return 1;
        case "error": return 2;
        case "trace": return 3;
        case "verbose": return 4;
        case "success": return 5;
        case "failure": return 6;
        default: return 0;
    }
}

public static function getLogColor(color:String):Int {
    switch(color) {
        case "black": return 0;
        case "darkBlue": return 1;
        case "darkGreen": return 2;
        case "darkCyan": return 3;
        case "darkRed": return 4;
        case "darkMagenta": return 5;
        case "darkYellow": return 6;
        case "lightGray": return 7;
        case "gray": return 8;
        case "blue": return 9;
        case "green": return 10;
        case "cyan": return 11;
        case "red": return 12;
        case "magenta": return 13;
        case "yellow": return 14;
        case "white": return 15;
        default: return -1;
    }
}