package cgs.fractionVisualization.constants;


/**
	 * ...
	 * @author Rich
	 */
class GenConstants
{
    
    /**
		 * 
		 * Representation State Keys
		 * 
		**/
    
    public static inline var VALUE_IS_ABOVE_KEY : String = "valueIsAbove";
    
    /**
		 * 
		 * Sizing, Coloring, Gradients, etc
		 * 
		**/
    
    // Default Colors
    public static inline var DEFAULT_FOREGROUND_COLOR : Int = 0x7143d4;  // Default Foreground Color  
    public static inline var DEFAULT_BACKGROUND_COLOR : Int = 0x7a7a7a;  // Default Background Color  
    public static inline var DEFAULT_BORDER_COLOR : Int = 0x2e2e2e;  // Default color of a border  
    public static inline var DEFAULT_TICK_COLOR : Int = 0x2e2e2e;  // Default color of a tick  
    public static inline var DEFAULT_FILL_COLOR : Int = 0xffffff;  // Default Fill Color  
    public static inline var DEFAULT_FILL_ALPHA : Float = 0.5;  // Default Fill Alpha  
    public static inline var DEFAULT_TEXT_COLOR : Int = 0x000000;  // Default Text Color  
    public static inline var DEFAULT_TEXT_GLOW_COLOR : Int = 0xffffff;  // Default Text Glow Color  
    
    // Dashed line sizing
    public static inline var DASHED_LINE_THICKNESS : Float = 2;  // Dashed Line thickness (ie. benchmark line)  
    public static inline var DASHED_LINE_COLOR : Int = 0x000000;  // Dashed Line color (ie. benchmark line)  
    public static inline var DASHED_LINE_DASH_LENGTH : Float = 10;  // The length of each dash in a dashed line  
    public static inline var DASHED_LINE_DASH_SPACING : Float = 6;  // The spacing between two dashes in a dashed line  
    
    // Lighten and Darken Factors
    public static inline var LIGHTEN_FOREGROUND_FACTOR : Float = 1.5;
    public static inline var DARKEN_FOREGROUND_FACTOR : Float = .8;
    public static inline var LIGHTEN_BACKGROUND_FACTOR : Float = 1.5;
    public static inline var DARKEN_BACKGROUND_FACTOR : Float = .65;
    
    // Gradient control points for strip/grid (maybe others?) block rendering
    public static inline var INNER_POINT : Int = 30;
    public static inline var MIDDLE_POINT : Int = 175;
    public static inline var OUTER_POINT : Int = 255;
    
    // Number Renderer Sizing
    public static inline var DEFAULT_NUMBER_RENDERER_FONT_SIZE : Float = 26;
    public static inline var DEFAULT_TEXT_FONT_SIZE : Float = 26;
    
    /**
		 * 
		 * Steps
		 * 
		**/
    
    // Step Names
    public static inline var STEP_NAME_POSITION : String = "Position";
    public static inline var STEP_NAME_SHOW_BENCHMARK : String = "Show Benchmark";
    public static inline var STEP_NAME_ALIGN : String = "Align";
    public static inline var STEP_NAME_COMPARE : String = "Compare";
    public static inline var STEP_NAME_CHANGE_DENOMINATOR : String = "Change Denominator";
    public static inline var STEP_NAME_CHANGE_DENOMINATORS : String = "Change Denominators";
    public static inline var STEP_NAME_CHANGE_FIRST_DENOMINATOR : String = "Change First Denominator";
    public static inline var STEP_NAME_CHANGE_SECOND_DENOMINATOR : String = "Change Second Denominator";
    public static inline var STEP_NAME_CONSOLIDATE_DENOMINATORS : String = "Consolidate Denominators";
    public static inline var STEP_NAME_DROP : String = "Drop";
    public static inline var STEP_NAME_MERGE : String = "Merge";
    public static inline var STEP_NAME_SHOW_RESULT : String = "Show Result";
    public static inline var STEP_NAME_FADE_OUT : String = "Fade Out";
    public static inline var STEP_NAME_SIMPLIFICATION : String = "Simplification";
    public static inline var STEP_NAME_UNPOSITION : String = "Final Position";

    public function new()
    {
    }
}

