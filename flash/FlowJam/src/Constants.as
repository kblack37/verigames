package
{
    public class Constants
    {
        public static const GameWidth:int  = 480;
        public static const GameHeight:int = 320;
        
        public static const CenterX:int = GameWidth / 2;
        public static const CenterY:int = GameHeight / 2;
		
		/** [Game Sizes] = GAME_SCALE * [XML Layout Sizes] */
		public static const GAME_SCALE:Number = 10.0;
		
		public static const TOOL_TIP_DELAY_SEC:Number = 1.0;
		public static const NUM_BACKGROUNDS:int = 12;
		
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
    }
}