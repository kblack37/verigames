package graph 
{
	/**
	 * A collection of all possible node types in the game, stored as constants because there aren't enumerated types in actionscript 3.
	 * @author Tim Pavlik
	 */
	public class NodeTypes 
	{
		public static const BALL_SIZE_TEST:String = "BALL_SIZE_TEST";
		public static const CONNECT:String = "CONNECT";
		public static const END:String = "END";
		public static const GET:String = "GET";
		public static const INCOMING:String = "INCOMING";
		public static const MERGE:String = "MERGE";
		public static const OUTGOING:String = "OUTGOING";
		public static const SPLIT:String = "SPLIT";
		public static const START_LARGE_BALL:String = "START_LARGE_BALL";
		public static const START_NO_BALL:String = "START_NO_BALL";
		public static const START_PIPE_DEPENDENT_BALL:String= "START_PIPE_DEPENDENT_BALL";
		public static const START_SMALL_BALL:String = "START_SMALL_BALL";
		public static const SUBBOARD:String = "SUBBOARD";
		
	}

}