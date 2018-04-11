package cgs.fractionVisualization.constants;


/**
	 * ...
	 * @author Rich
	 */
class GridConstants
{
    
    /**
		 * 
		 * Representation State Keys
		 * 
		**/
    
    public static inline var LOGIC_GRID_KEY : String = "logicGrid";  // String code for accessing the logic grid  
    public static inline var NUM_ROWS_KEY : String = "numRows";  // String code for accessing the number of rows in one unit of this grid  
    public static inline var NUM_COLUMNS_KEY : String = "numColumns";  // String code for accessing the number of columns in one unit of this grid  
    public static inline var SPLIT_COLUMN_BEFORE_ROW_KEY : String = "splitColumnBeforeRow";  // String code for accessing whether the Grid should be split column before row, or the opposite  
    public static inline var FILL_COLUMN_BEFORE_ROW_KEY : String = "fillColumnBeforeRow";  // String code for accessing whether the Grid should be fill column before row, or the opposite  
    public static inline var IS_ELONGATED_STRIP : String = "isElongatedStrip";  // String code for accessing whether the Grid should be in elongated strip  
    public static inline var MAX_ROWS_TO_FILL : String = "maxRowsToFill";  // String code for accessing the maximum number of rows the Grid should be filling  
    public static inline var MAX_COLUMNS_TO_FILL : String = "maxColumnsToFill";  // String code for accessing the maximum number of columns the Grid should be filling  
    //public static const FILL_IN_REVERSE:String = "fillInRevers";						// String code for accessing whether the Grid should fill in reverse (from bottom right)
    
    /**
		 * 
		 * Sizing
		 * 
		**/
    
    public static var BASE_UNIT_WIDTH : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SIZE;  // The length of one unit  
    public static var BASE_UNIT_HEIGHT : Float = BASE_UNIT_WIDTH;  // The height of one unit  
    public static var BASE_UNIT_SEPARATION : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SEPARATION;  // The space between Grids in a representation  
    public static var BASE_SCALE : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SCALE;  // The base scale of a grid  
    
    public static var BACKBONE_BORDER_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // The thickness of the border around the backbone  
    public static inline var FILL_ALPHA : Float = 0.5;  // Default Fill Alpha  
    public static inline var FILL_ALPHA_COLORED : Float = 0.75;  // Colored Fill Alpha  
    public static var TICK_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // Thickness of ticks  
    public static inline var TICK_EXTENSION_DISTANCE : Float = 10;  // Extra distance ticks extend out from the Grid  
    public static inline var WINNING_GLOW_THICKNESS : Int = 15;  // Thickness of the glow around a winning Grid  
    
    public static inline var MULTIPLICATION_TABLE_BORDER_THICKNESS : Float = 2;  // The thickness of the multiplication table border  
    public static inline var MULTIPLICATION_TABLE_BORDER_COLOR : Int = 0x000000;  // The color of the multiplication table border  
    public static inline var NUMBER_DISPLAY_MARGIN_INTEGER : Float = 25;  // Margin between the border and the number display if the number display is an integer  
    public static inline var NUMBER_DISPLAY_MARGIN_FRACTION : Float = 35;  // Margin between the border and the number display if the number display is a fraction  
    
    /**
		 * 
		 * Animation General
		 * 
		**/
    
    public static inline var ANIMATION_MARGIN_VERTICAL_SMALL : Float = 20;  // Margin between two grids when displayed one above the other  
    public static inline var ANIMATION_MARGIN_VERTICAL_NORMAL : Float = 50;  // Margin between two grids when displayed one above the other  
    public static inline var ANIMATION_MARGIN_HORIZONTAL_NORMAL : Float = 50;  // Margin between two grids when displayed one above the other  
    public static inline var ANIMATION_MARGIN_HORIZONTAL_SMALL : Float = 20;  // Margin between two grids when displayed one above the other  
    
    public static inline var ANIMATION_MARGIN_EQUATION : Float = 100;  // Distance between a grid and an equation  
    public static inline var ANIMATION_MARGIN_MARKER : Float = 100;  // Distance between a grid and a marker (ie. benchmark dashes)  
    public static inline var ANIMATION_MARGIN_TEXT : Float = 100;  // Distance between a grid and text (ie. result text)  
    
    public static inline var PULSE_SCALE_GENERAL : Float = 1.25;  // The scale of the pulse emphasis used by the grid, in general  
    public static inline var PULSE_SCALE_GENERAL_LARGE : Float = 1.5;  // The scale of the pulse emphasis used by the grid, in general  
    public static inline var PULSE_SCALE_SEGMENT : Float = 1.25;  // The scale of the pulse emphasis used by the grid segment  
    
    public static inline var TIME_DURATION_UNIT_FILL : Float = 2;  // The duration of the tween for a unit fill  
    public static inline var TIME_DURATION_MAX_FILL : Float = 4;  // The maximum duration of the tween for a fill  
    
    /**
		 * 
		 * Addition
		 * 
		**/
    
    // Times
    public static inline var TIME_ADD_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_ADD_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_DURATION_DROP_PER_BLOCK : Float = .35;  // The duration of the tween for moving a single block while dropping blocks  
    public static inline var TIME_ADD_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_ADD_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the simplifying the result  
    public static inline var TIME_ADD_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_ADD_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_ADD_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_ADD_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    public static inline var TIME_ADD_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_ADD_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Compare Size
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_SIZE_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_SIZE_DURATION_COMPARE : Float = 1;  // The duration of the tween for comparing the fills  
    public static inline var TIME_COMPARE_SIZE_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_SIZE_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_COMPARE_SIZE_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the fills are compared  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Compare Target
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_TARGET_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK : Float = 1;  // The duration of the tween to show the benchmark value  
    public static inline var TIME_COMPARE_TARGET_DURATION_COMPARE : Float = 1;  // The duration of the tween for comparing the fills  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_TARGET_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_COMPARE_TARGET_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK : Float = .5;  // The amount of delay once the benchmark value is shown  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the fills are compared  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Multiply
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_DURATION_MERGE : Float = 1;  // The duration of the tween for merging the result  
    public static inline var TIME_MULT_DURATION_MERGE_PER_BLOCK : Float = .25;  // The duration of the tween for moving a single block while merging for Grid  
    public static inline var TIME_MULT_DURATION_MERGE_BLOCKS_MAX : Float = 5;  // The maximum duration of the tween for merging for Grid  
    public static inline var TIME_MULT_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the simplification (if any)  
    public static inline var TIME_MULT_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delay
    public static inline var TIME_MULT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have merged  
    public static inline var TIME_MULT_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_MULT_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the simplification (if any) is complete  
    public static inline var TIME_MULT_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Subtraction
		 * 
		**/
    
    // Times
    public static inline var TIME_SUB_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_SUB_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_DURATION_DROP_PER_BLOCK : Float = .35;  // The duration of the tween for moving a single block while dropping blocks  
    public static inline var TIME_SUB_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_SUB_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the simplification of the result  
    public static inline var TIME_SUB_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_SUB_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_SUB_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    public static inline var TIME_SUB_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_SUB_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  

    public function new()
    {
    }
}

