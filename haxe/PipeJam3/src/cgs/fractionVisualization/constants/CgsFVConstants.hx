package cgs.fractionVisualization.constants;


/**
	 * ...
	 * @author Rich
	 */
class CgsFVConstants
{
    /**
		 * 
		 * Core Sizing
		 * 
		**/
    
    // Animation Controller
    public static inline var ANIMATION_CONTROLLER_DEFAULT_WIDTH : Float = 800;  // Default width of Animation Controller  
    public static inline var ANIMATION_CONTROLLER_DEFAULT_HEIGHT : Float = 600;  // Default height of Animation Controller  
    
    // Representations
    public static var REPRESENTATION_BASE_UNIT_SIZE : Float = 34 * Math.PI;  // Base width (and height when square) of a unit of a representation  
    public static inline var REPRESENTATION_BASE_UNIT_SEPARATION : Float = 20;  // Separation between units, when applicable (Grid, Pie, etc)  
    public static inline var REPRESENTATION_BASE_UNIT_SCALE : Float = 1;  // Scaling of all other values  
    public static inline var REPRESENTATION_BASE_STROKE_THICKNESS : Float = 2;  // Thickness of a stroke  
    
    // Animations
    public static inline var ANIMATION_WINNING_GLOW_COLOR : Int = 0xFFE600;  // Default color of a winning glow (for comparisons)  
    
    /**
		 * 
		 * Animation Detail Keys
		 * 
		**/
    
    // General Keys
    public static inline var WINNING_GLOW_COLOR : String = "winningGlowColor";  // String code for the color of the winning glow color  
    public static inline var TEXT_COLOR : String = "textColor";  // String code for the color of the text color  
    public static inline var TEXT_GLOW_COLOR : String = "textGlowColor";  // String code for the color of the text glow color  
    public static inline var RESULT_FRACTION_FOREGROUND_COLOR : String = "resultFractionForegroundColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_FRACTION_BACKGROUND_COLOR : String = "resultFractionBackgroundColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_FRACTION_BORDER_COLOR : String = "resultFractionBorderColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_FRACTION_TICK_COLOR : String = "resultFractionTickColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_FRACTION_TEXT_COLOR : String = "resultFractionTextColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_FRACTION_TEXT_GLOW_COLOR : String = "resultFractionTextGlowColor";  // String code for the color of the result fraction, if any  
    public static inline var RESULT_DESTINATION : String = "resultDestination";  // String code for the Point where the result should end up at the end of the animation (if applicable)  
    public static inline var CLONE_VIEWS_KEY : String = "cloneViews";  // String code for the list of cloned views in details  
    public static inline var SPEED_SCALER_KEY : String = "speedScaler";  // String code for the speed scaler of the animation  
    
    // Compare data keys
    public static inline var COMPARE_TYPE_DATA_KEY : String = "comparisonType";  // Type of comparison key  
    public static inline var COMPARISON_BENCHMARK_DATA_KEY : String = "benchmarkFraction";  // Benchmark Fraction data key  
    
    // Compare types
    public static inline var COMPARE_TYPE_GREATER_THAN : String = "compareGreaterThan";  // Greater Than Comparison Type  
    public static inline var COMPARE_TYPE_LESS_THAN : String = "compareLessThan";  // Less Than Comparison Type  
    public static inline var COMPARE_TYPE_CLOSEST_TO_BENCHMARK : String = "compareToBenchmark";  // Compare to Benchmark Comparison Type  
    
    // Split Keys
    public static inline var SPLIT_DESTINATIONS_KEY : String = "split_destinations";
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    // Strip Animations
    public static inline var STRIP_STANDARD_COMPARE_SIZE : String = "StripStandardCompareSize";  // String code for Strip's Standard Compare Size animation  
    public static inline var STRIP_STANDARD_COMPARE_BENCHMARK : String = "StripStandardCompareBenchmark";  // String code for Strip's Standard Compare Benchmark animation  
    public static inline var STRIP_STANDARD_ADD : String = "StripStandardAdd";  // String code for Strip's Standard Add animation  
    public static inline var STRIP_STANDARD_SUBTRACT : String = "StripStandardSubtract";  // String code for Strip's Standard Subtract animation  
    public static inline var STRIP_STANDARD_MULTIPLY : String = "StripStandardMultiply";  // String code for Strip's Standard Multiply animation  
    public static inline var STRIP_SCALING_MULTIPLY : String = "StripScalingMultiply";  // String code for Strip's Scaling Multiply animation  
    public static inline var STRIP_STANDARD_SPLIT : String = "StripStandardSplit";  // String code for Strip's Standard Split animation  
    
    public static var STRIP_ANIMATION_LIST : Array<Dynamic> = [
        STRIP_STANDARD_COMPARE_SIZE, 
        STRIP_STANDARD_COMPARE_BENCHMARK, 
        STRIP_STANDARD_ADD, 
        STRIP_STANDARD_SUBTRACT, 
        STRIP_STANDARD_MULTIPLY, 
        STRIP_SCALING_MULTIPLY, 
        STRIP_STANDARD_SPLIT
    ];
    
    // Pie Animations
    public static inline var PIE_STANDARD_COMPARE_SIZE : String = "PieStandardCompareSize";  // String code for Pie's Standard Compare Size animation  
    public static inline var PIE_STANDARD_COMPARE_BENCHMARK : String = "PieStandardCompareBenchmark";  // String code for Pie's Standard Compare Target animation  
    public static inline var PIE_STANDARD_ADD : String = "PieStandardAdd";  // String code for Pie's Standard Add animation  
    public static inline var PIE_STANDARD_SUBTRACT : String = "PieStandardSubtract";  // String code for Pie's Standard Add animation  
    public static inline var PIE_STANDARD_MULTIPLY : String = "PieStandardMultiply";  // String code for Pie's Standard Multiply animation  
    //public static const PIE_STANDARD_SPLIT:String = "PieStandardSplit";						// String code for Pie's Standard Split animation
    
    public static var PIE_ANIMATION_LIST : Array<Dynamic> = [
        PIE_STANDARD_COMPARE_SIZE, 
        PIE_STANDARD_COMPARE_BENCHMARK, 
        PIE_STANDARD_ADD, 
        PIE_STANDARD_SUBTRACT, 
        PIE_STANDARD_MULTIPLY
    ];
    
    // Grid Animations
    public static inline var GRID_STANDARD_COMPARE_SIZE : String = "GridStandardCompareSize";  // String code for Grid's Standard Compare Size animation  
    public static inline var GRID_STANDARD_COMPARE_BENCHMARK : String = "GridStandardCompareBenchmark";  // String code for Grid's Standard Compare Benchmark animation  
    public static inline var GRID_STANDARD_ADD : String = "GridStandardAdd";  // String code for Grid's Standard Add animation  
    public static inline var GRID_STANDARD_SUBTRACT : String = "GridStandardSubtract";  // String code for Grid's Standard Subtract animation  
    public static inline var GRID_STANDARD_MULTIPLY : String = "GridStandardMultiply";  // String code for Grid's Standard Multiply animation  
    
    public static var GRID_ANIMATION_LIST : Array<Dynamic> = [
        GRID_STANDARD_COMPARE_SIZE, 
        GRID_STANDARD_COMPARE_BENCHMARK, 
        GRID_STANDARD_ADD, 
        GRID_STANDARD_SUBTRACT, 
        GRID_STANDARD_MULTIPLY
    ];
    
    // Numberline Animations
    public static inline var NUMBERLINE_STANDARD_COMPARE_SIZE : String = "NumberlineStandardCompareSize";  // String code for Numberline's Standard Compare Size animation  
    public static inline var NUMBERLINE_STANDARD_COMPARE_BENCHMARK : String = "NumberlineStandardCompareBenchmark";  // String code for Numberline's Standard Compare Benchmark animation  
    public static inline var NUMBERLINE_STANDARD_ADD : String = "NumberlineStandardAdd";  // String code for Numberline's Standard Add animation  
    public static inline var NUMBERLINE_PROCEDURAL_ADD : String = "NumberlineProceduralAdd";  // String code for Numberline's Procedural Add animation  
    public static inline var NUMBERLINE_STANDARD_SUBTRACT : String = "NumberlineStandardSubtract";  // String code for Numberline's Standard Subtract animation  
    public static inline var NUMBERLINE_STANDARD_MULTIPLY : String = "NumberlineStandardMultiply";  // String code for Numberline's Standard Multiply animation  
    
    public static var NUMBERLINE_ANIMATION_LIST : Array<Dynamic> = [
        NUMBERLINE_STANDARD_COMPARE_SIZE, 
        NUMBERLINE_STANDARD_COMPARE_BENCHMARK, 
        NUMBERLINE_STANDARD_ADD, 
        NUMBERLINE_PROCEDURAL_ADD, 
        NUMBERLINE_STANDARD_SUBTRACT, 
        NUMBERLINE_STANDARD_MULTIPLY
    ];
    
    /**
		 * 
		 * Representations
		 * 
		**/
    
    public static inline var STRIP_REPRESENTATION : String = "Strip";  // String code for Strip Representation  
    public static inline var GRID_REPRESENTATION : String = "Grid";  // String code for Grid Representation  
    public static inline var NUMBERLINE_REPRESENTATION : String = "Numberline";  // String code for Numberline Representation  
    public static inline var PIE_REPRESENTATION : String = "Pie";  // String code for Pie Representation  
    public static inline var DISCRETE_REPRESENTATION : String = "Discrete";  // String code for Discrete Representation  
    
    /**
		 * 
		 * Settings
		 * 
		**/
    
    // End Type Settings
    public static inline var END_TYPE_PAUSE : String = "pauseOnEnd";
    public static inline var END_TYPE_LOOP : String = "loopOnEnd";
    public static inline var END_TYPE_REFLECT : String = "reflectOnEnd";
    public static inline var END_TYPE_CLEAR : String = "clearOnEnd";
    
    // Step Settings
    public static inline var STEP_SETTINGS_KEY : String = "AnimationStepSettings";  // Key in animate's details field  
    public static var STEP_SETTINGS_LIST : Array<Dynamic> = [
        STEP_TYPE_POSITION, 
        STEP_TYPE_SHOW_BENCHMARK, 
        STEP_TYPE_ALIGN, 
        STEP_TYPE_COMPARE, 
        STEP_TYPE_CHANGE_DENOMINATOR, 
        STEP_TYPE_DROP, 
        STEP_TYPE_MERGE, 
        STEP_TYPE_FADE, 
        STEP_TYPE_SIMPLIFICATION, 
        STEP_TYPE_TBD
    ];
    
    // Advanced Settings
    public static inline var SHOW_POSITIONING_SETTING_KEY : String = "ShowPositioningSetting";  // Key in animate's details field  
    public static inline var SHOW_EQUATIONS_SETTING_KEY : String = "ShowEquationsSetting";  // Key in animate's details field  
    public static inline var SHOW_NUMBER_GLOW_SETTING_KEY : String = "ShowNumberGlowSetting";  // Key in animate's details field  
    
    /**
		 * 
		 * Steps
		 * 
		**/
    
    // Step Types
    public static inline var STEP_TYPE_POSITION : String = "Position";
    public static inline var STEP_TYPE_SHOW_BENCHMARK : String = "ShowBenchmark";
    public static inline var STEP_TYPE_ALIGN : String = "Align";
    public static inline var STEP_TYPE_COMPARE : String = "Compare";
    public static inline var STEP_TYPE_CHANGE_DENOMINATOR : String = "ChangeDenominator";
    public static inline var STEP_TYPE_DROP : String = "Drop";
    public static inline var STEP_TYPE_MERGE : String = "Merge";
    public static inline var STEP_TYPE_SHOW_RESULT : String = "ShowResult";
    public static inline var STEP_TYPE_FADE : String = "Fade";
    public static inline var STEP_TYPE_SIMPLIFICATION : String = "Simplification";
    public static inline var STEP_TYPE_TBD : String = "TBD";

    public function new()
    {
    }
}

