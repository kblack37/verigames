
class Constants
{
    public static inline var GameWidth : Int = 480;
    public static inline var GameHeight : Int = 320;
    
    public static var CenterX : Int = Std.int(GameWidth / 2);
    public static var CenterY : Int = Std.int(GameHeight / 2);
    
    /** [Game Sizes] = GAME_SCALE * [XML Layout Sizes] */
    public static inline var GAME_SCALE : Float = 10.0;
    
    public static inline var TOOL_TIP_DELAY_SEC : Float = 1.0;
    public static inline var NUM_BACKGROUNDS : Int = 12;
    
    public static inline var XML_ANNOT_IN : String = "__IN__";
    public static inline var XML_ANNOT_OUT : String = "__OUT__";
    public static inline var XML_ANNOT_COPY : String = "CPY";
    public static inline var XML_ANNOT_EXT : String = "EXT__";
    public static inline var XML_ANNOT_EXT_IN : String = "__XIN__";
    public static inline var XML_ANNOT_EXT_OUT : String = "__XOUT__";
    public static inline var XML_ANNOT_NEG : String = "NEG_";
    public static inline var XML_ANNOT_VARIDSET : String = "_varIDset";
    
    public static inline var CACHE_MUTE_MUSIC : String = "muteMusic";
    public static inline var CACHE_MUTE_SFX : String = "muteSfx";

    public function new()
    {
    }
}
