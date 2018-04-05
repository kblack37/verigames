package graph;


/**
	 * A collection of all possible node types in the game, stored as constants because there aren't enumerated types in actionscript 3.
	 * @author Tim Pavlik
	 */
class NodeTypes
{
    public static inline var BALL_SIZE_TEST : String = "BALL_SIZE_TEST";
    public static inline var CONNECT : String = "CONNECT";
    public static inline var END : String = "END";
    public static inline var GET : String = "GET";
    public static inline var INCOMING : String = "INCOMING";
    public static inline var MERGE : String = "MERGE";
    public static inline var OUTGOING : String = "OUTGOING";
    public static inline var SPLIT : String = "SPLIT";
    public static inline var START_LARGE_BALL : String = "START_LARGE_BALL";
    public static inline var START_NO_BALL : String = "START_NO_BALL";
    public static inline var START_PIPE_DEPENDENT_BALL : String = "START_PIPE_DEPENDENT_BALL";
    public static inline var START_SMALL_BALL : String = "START_SMALL_BALL";
    public static inline var SUBBOARD : String = "SUBBOARD";

    public function new()
    {
    }
}

