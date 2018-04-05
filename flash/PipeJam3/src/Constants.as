package
{
    public class Constants
    {
		public static const GameWidth:int  = 480;
        public static const GameHeight:int = 320;
		
        public static const CenterX:int = GameWidth / 2;
        public static const CenterY:int = GameHeight / 2;
		
		public static const RightPanelWidth:int = 100;
		
		/** [Game Sizes] = GAME_SCALE * [XML Layout Sizes] */
		public static const GAME_SCALE:Number = 10.0;
		
		public static const TOOL_TIP_DELAY_SEC:Number = 1.0;
		public static const NUM_BACKGROUNDS:int = 12;
		public static const SKIN_DIAMETER:Number = 20;
		
		public static const XML_ANNOT_IN:String = "__IN__";
		public static const XML_ANNOT_OUT:String = "__OUT__";
		public static const XML_ANNOT_COPY:String = "CPY";
		public static const XML_ANNOT_EXT:String = "EXT__";
		public static const XML_ANNOT_EXT_IN:String = "__XIN__";
		public static const XML_ANNOT_EXT_OUT:String = "__XOUT__";
		public static const XML_ANNOT_NEG:String = "NEG_";
		public static const XML_ANNOT_VARIDSET:String = "_varIDset";
		
		public static const CACHE_MUTE_MUSIC:String = "muteMusic";
		public static const CACHE_MUTE_SFX:String = "muteSfx";
		
		public static const GOLD:uint = 0xFFEC00;
		public static const BROWN:uint = 0x624202;
		
		public static const NARROW_BLUE:uint = 0x6cb0cf;
		public static const NARROW_GRAY:uint = 0xa4a4a4;
		public static const WIDE_BLUE:uint = 0x5876a6;
		public static const WIDE_GRAY:uint = 0x727272;
		
		//Nine slice
		public static const TOP_LEFT:String = "TopLeft";
		public static const TOP:String = "Top";
		public static const TOP_RIGHT:String = "TopRight";
		public static const LEFT:String = "Left";
		public static const CENTER:String = "Center";
		public static const RIGHT:String = "Right";
		public static const BOTTOM_LEFT:String = "BottomLeft";
		public static const BOTTOM:String = "Bottom";
		public static const BOTTOM_RIGHT:String = "BottomRight";
		
		public static const HINT_LOC:String = "HintLoc";
		
		public static const START_BUSY_ANIMATION:String = "startBusyAnimation";
		public static const STOP_BUSY_ANIMATION:String = "stopBusyAnimation";
    }
}