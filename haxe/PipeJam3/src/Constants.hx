
class Constants
{
    public static inline var GameWidth : Float = 480;
    public static inline var GameHeight : Float = 320;
    
    public static var CenterX : Float = GameWidth / 2;
    public static var CenterY : Float = GameHeight / 2;
    
    public static inline var RightPanelWidth : Int = 100;
    
    /** [Game Sizes] = GAME_SCALE * [XML Layout Sizes] */
    public static inline var GAME_SCALE : Float = 10.0;
    
    public static inline var TOOL_TIP_DELAY_SEC : Float = 1.0;
    public static inline var NUM_BACKGROUNDS : Int = 12;
    public static inline var SKIN_DIAMETER : Float = 20;
    
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
    
    public static inline var GOLD : Int = 0xFFEC00;
    public static inline var BROWN : Int = 0x624202;
    
    public static inline var NARROW_BLUE : Int = 0x6cb0cf;
    public static inline var NARROW_GRAY : Int = 0xa4a4a4;
    public static inline var WIDE_BLUE : Int = 0x5876a6;
    public static inline var WIDE_GRAY : Int = 0x727272;
    
    //Nine slice
    public static inline var TOP_LEFT : String = "TopLeft";
    public static inline var TOP : String = "Top";
    public static inline var TOP_RIGHT : String = "TopRight";
    public static inline var LEFT : String = "Left";
    public static inline var CENTER : String = "Center";
    public static inline var RIGHT : String = "Right";
    public static inline var BOTTOM_LEFT : String = "BottomLeft";
    public static inline var BOTTOM : String = "Bottom";
    public static inline var BOTTOM_RIGHT : String = "BottomRight";
    
    public static inline var HINT_LOC : String = "HintLoc";
    
    public static inline var START_BUSY_ANIMATION : String = "startBusyAnimation";
    public static inline var STOP_BUSY_ANIMATION : String = "stopBusyAnimation";
}
