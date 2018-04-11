package cgs.fractionVisualization.constants;


/**
	 * ...
	 * @author Rich
	 */
class NumberlineConstants
{
    
    /**
		 * 
		 * Sizing
		 * 
		**/
    
    public static var BASE_UNIT_WIDTH : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SIZE;  // The length of one unit  
    public static inline var BASE_UNIT_HEIGHT : Float = 4;  // The height of one unit  
    public static var BASE_SCALE : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SCALE;  // The base scale of a numberline  
    
    public static var BACKBONE_BORDER_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // The thickness of the border around the backbone  
    public static var SEGMENT_RADIUS : Float = BASE_UNIT_WIDTH / 16;  // The radius of the circle indicating the value  
    public static inline var FILL_ALPHA : Float = 0.5;  // Default Fill Alpha  
    public static var SEGMENT_STROKE_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // Thickness of stroke around the dot  
    public static inline var TICK_THICKNESS : Float = 3;  // Thickness of ticks  
    public static inline var TICK_EXTENSION_DISTANCE : Float = 5;  // Extra distance ticks extend out from the Numberline  
    public static var COMPARE_LINE_THICKNESS : Float = BASE_UNIT_HEIGHT;  // Thickness of compare lines  
    
    public static inline var NUMBER_DISPLAY_MARGIN_GLOW : Float = 10;  // Margin between the endges of the numberline and the border of the glow ellipse  
    public static inline var NUMBER_DISPLAY_MARGIN_INTEGER : Float = 25;  // Margin between the border and the number display if the number display is an integer  
    public static inline var NUMBER_DISPLAY_MARGIN_FRACTION : Float = 35;  // Margin between the border and the number display if the number display is a fraction  
    
    /**
		 * 
		 * Animation General
		 * 
		**/
    
    public static inline var ANIMATION_MARGIN_VERTICAL_SMALL : Float = 10;  // Margin between two numberlines when displayed one above the other  
    public static inline var ANIMATION_MARGIN_VERTICAL_NORMAL : Float = 50;  // Margin between two numberlines when displayed one above the other  
    public static inline var ANIMATION_MARGIN_HORIZONTAL_SMALL : Float = 20;  // Margin between two strips when displayed beside each other  
    
    public static inline var ANIMATION_MARGIN_EQUATION : Float = 100;  // Distance between a numberline and an equation  
    public static inline var ANIMATION_MARGIN_MARKER : Float = 100;  // Distance between a numberline and a marker (ie. benchmark dashes)  
    public static inline var ANIMATION_MARGIN_TEXT : Float = 100;  // Distance between a numberline and text (ie. result text)  
    public static inline var ANIMATION_MARGIN_TEXT_LARGE : Float = 120;  // Distance between a numberline and text (ie. result text)  
    
    public static inline var PULSE_SCALE_GENERAL : Float = 1.25;  // The scale of the pulse emphasis used by the Numberline, in general  
    public static inline var PULSE_SCALE_GENERAL_LARGE : Float = 1.5;  // The scale of the pulse emphasis used by the Numberline, in general  
    public static inline var PULSE_SCALE_SEGMENT : Float = 1.5;  // The scale of the pulse emphasis used by the Numberline segment  
    
    public static inline var TIME_DURATION_UNIT_FILL : Float = 2;  // The duration of the tween for a unit fill  
    public static inline var TIME_DURATION_MAX_FILL : Float = 4;  // The maximum duration of the tween for a fill  
    
    /**
		 * 
		 * Addition
		 * 
		**/
    // TODO: Breakout conceptual and procedural timings, if we keep them
    
    // Times
    public static inline var TIME_ADD_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_DURATION_ALIGN : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_ADD_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    //public static const TIME_ADD_DURATION_SIMPLIFICATION:Number = 1;		// The duration of the fading out of the second view
    public static inline var TIME_ADD_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_ADD_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_DELAY_AFTER_ALIGN : Float = .5;  // The amount of delay once the second fraction is aligned to the first fraction  
    public static inline var TIME_ADD_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_ADD_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    //public static const TIME_ADD_DELAY_AFTER_SIMPLIFICATION:Number = .5;	// The amount of delay once the fractions have been simplified
    public static inline var TIME_ADD_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Addition - Procedural
		 * 
		**/
    // TODO: Breakout conceptual and procedural timings, if we keep them
    
    // Times
    public static inline var TIME_ADD_PROCEDURAL_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_ALIGN : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_ADD_PROCEDURAL_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the change denominator is complete  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_ALIGN : Float = .5;  // The amount of delay once the second fraction is aligned to the first fraction  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have faded out  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_ADD_PROCEDURAL_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Compare Size
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_SIZE_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_SIZE_DURATION_COMPARE : Float = 1;  // The duration of the compare  
    public static inline var TIME_COMPARE_SIZE_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_SIZE_DURATION_FADE : Float = 1;  // The duration of the fading out tween  
    public static inline var TIME_COMPARE_SIZE_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the comparison is complete  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the dashed lines are faded out  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Compare Target
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_TARGET_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK : Float = 1;  // The duration of the tween to show the benchmark value  
    public static inline var TIME_COMPARE_TARGET_DURATION_COMPARE : Float = 1;  // The duration of the compare  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_TARGET_DURATION_FADE : Float = 1;  // The duration of the fading out tween  
    public static inline var TIME_COMPARE_TARGET_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK : Float = .5;  // The amount of delay once the benchmark value is shown  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the lines are compared  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the dashed lines are faded out  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Multiply
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_DURATION_SCALE : Float = 1;  // The duration of the tween for squishing/stretching the second fraction (if necessary)  
    public static inline var TIME_MULT_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_MULT_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delay
    public static inline var TIME_MULT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_DELAY_AFTER_SCALE : Float = .4;  // The amount of delay once the ticks have been updated  
    public static inline var TIME_MULT_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    public static inline var TIME_MULT_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_MULT_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Subtraction
		 * 
		**/
    
    // Times
    public static inline var TIME_SUB_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_SUB_DURATION_ALIGN : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_SUB_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    //public static const TIME_SUB_DURATION_SIMPLIFICATION:Number = 1;		// The duration of the fading out of the second view
    public static inline var TIME_SUB_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_SUB_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_DELAY_AFTER_ALIGN : Float = .5;  // The amount of delay once the second fraction is aligned to the first fraction  
    public static inline var TIME_SUB_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    //public static const TIME_SUB_DELAY_AFTER_SIMPLIFICATION:Number = .5;	// The amount of delay once the fractions have been simplified
    public static inline var TIME_SUB_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  

    public function new()
    {
    }
}

