//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine.debug;


class LogColor
{
    public static inline var DEBUG : String = "#DDDDDD";
    public static inline var INFO : String = "#222222";
    public static inline var WARN : String = "#FF6600";
    public static inline var ERROR : String = "#FF0000";
    public static inline var MESSAGE : String = "#000000";
    public static inline var CMD : String = "#00DD00";
    
    public static function getColor(level : String) : String
    {
        switch (level)
        {
            case LogEntry.DEBUG:
                return DEBUG;
            case LogEntry.INFO:
                return INFO;
            case LogEntry.WARNING:
                return WARN;
            case LogEntry.ERROR:
                return ERROR;
            case LogEntry.MESSAGE:
                return MESSAGE;
            case "CMD":
                return CMD;
            default:
                return MESSAGE;
        }
    }

    public function new()
    {
    }
}
