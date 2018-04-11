package cgs.fractionVisualization.constants;


/**
	 * ...
	 * @author Rich
	 */
class StripConstants
{
    
    /**
		 * 
		 * Sizing
		 * 
		**/
    
    public static var BASE_UNIT_WIDTH : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SIZE;  // The length of one unit  
    public static var BASE_UNIT_HEIGHT : Float = BASE_UNIT_WIDTH * (35 / 100);  // The height of one unit  
    public static var BASE_SCALE : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SCALE;  // The base scale of a strip  
    
    public static var BACKBONE_BORDER_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // The thickness of the border around the backbone  
    public static inline var FILL_ALPHA : Float = 0.5;  // Default Fill Alpha  
    public static inline var FILL_ALPHA_COLORED : Float = 0.75;  // Colored Fill Alpha  
    public static var TICK_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // Thickness of ticks  
    public static inline var TICK_EXTENSION_DISTANCE : Float = 10;  // Extra distance ticks extend out from the Strip  
    public static inline var WINNING_GLOW_THICKNESS : Int = 15;  // Thickness of the glow around a winning Strip  
    
    public static inline var NUMBER_DISPLAY_MARGIN_INTEGER : Float = 25;  // Margin between the border and the number display if the number display is an integer  
    public static inline var NUMBER_DISPLAY_MARGIN_FRACTION : Float = 35;  // Margin between the border and the number display if the number display is a fraction  
    
    /**
		 * 
		 * Animation General
		 * 
		**/
    
    public static inline var ANIMATION_MARGIN_VERTICAL_SMALL : Float = 10;  // Margin between two strips when displayed one above the other  
    public static inline var ANIMATION_MARGIN_VERTICAL_NORMAL : Float = 50;  // Margin between two strips when displayed one above the other  
    public static inline var ANIMATION_MARGIN_HORIZONTAL_NORMAL : Float = 50;  // Margin between two strips when displayed beside each other  
    public static inline var ANIMATION_MARGIN_HORIZONTAL_SMALL : Float = 20;  // Margin between two strips when displayed beside each other  
    
    public static inline var ANIMATION_MARGIN_EQUATION : Float = 100;  // Distance between a strip and an equation  
    public static inline var ANIMATION_MARGIN_MARKER : Float = 100;  // Distance between a strip and a marker (ie. benchmark dashes)  
    public static inline var ANIMATION_MARGIN_TEXT : Float = 130;  // Distance between a strip and text (ie. result text)  
    
    public static inline var SEGMENT_MARGIN_HORIZONTAL_SMALL : Float = 4;  // Margin between two strips segments when displayed next to each other  
    public static inline var SEGMENT_MARGIN_HORIZONTAL_MEDIUM : Float = 20;  // Margin between two strips segments when displayed next to each other  
    
    public static inline var PULSE_SCALE_GENERAL : Float = 1.25;  // The scale of the pulse emphasis used by the strip, in general  
    public static inline var PULSE_SCALE_GENERAL_LARGE : Float = 1.5;  // The scale of the pulse emphasis used by the strip, in general  
    public static inline var PULSE_SCALE_SEGMENT : Float = 1.25;  // The scale of the pulse emphasis used by the strip segment  
    
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
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM_PER_TICK_MIN : Float = .2;  // The minimum duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX : Float = 1;  // The maximum duration of the tween for changing the denominator of the first segment (set of ticks)  
    public static inline var TIME_ADD_DURATION_EXTENSION : Float = 1;  // The duration of the tween for extending the first fraction (if necessary)  
    public static inline var TIME_ADD_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_ADD_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_ADD_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the simplifying the result  
    public static inline var TIME_ADD_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_ADD_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_ADD_DELAY_AFTER_EXTENSION : Float = .5;  // The amount of delay once the first fraction has been extended  
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
    public static inline var TIME_COMPARE_SIZE_DURATION_COMPARE : Float = 1;  // The duration of the compare  
    public static inline var TIME_COMPARE_SIZE_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_SIZE_DURATION_FADE : Float = 1;  // The duration of the tween for fading out  
    public static inline var TIME_COMPARE_SIZE_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the compare is complete  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the comparison and result are faded out  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Compare Target
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_TARGET_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK : Float = 1;  // The duration of the tween to show the benchmark value  
    public static inline var TIME_COMPARE_TARGET_DURATION_COMPARE : Float = 1;  // The duration of the comparison  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_TARGET_DURATION_FADE : Float = 1;  // The duration of the tween for fading out  
    public static inline var TIME_COMPARE_TARGET_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    
    // Delays
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK : Float = .5;  // The amount of delay once the benchmark value is shown  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the comparison  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the comparison and result are faded out  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    
    /**
		 * 
		 * Multiply
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_MULT_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_MULT_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_MULT_DURATION_CHANGE_DENOM_PER_TICK_MIN : Float = .2;  // The minimum duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_MULT_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX : Float = 1;  // The maximum duration of the tween for changing the denominator of the first segment (set of ticks)  
    public static inline var TIME_MULT_DURATION_DROP_PULSE_PER_TICK : Float = .25;  // The duration of the tween for pulsing a single tick during the drop animation  
    public static inline var TIME_MULT_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_DURATION_MERGE : Float = 1;  // The duration of the merging of the fraction  
    public static inline var TIME_MULT_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delay
    public static inline var TIME_MULT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_MULT_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_MULT_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    public static inline var TIME_MULT_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_MULT_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Multiply - Scaling
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_SCALING_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_SCALING_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_MULT_SCALING_DURATION_SCALE : Float = 1;  // The duration of the tween for squishing/stretching the second fraction (if necessary)  
    public static inline var TIME_MULT_SCALING_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_MULT_SCALING_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_MULT_SCALING_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX : Float = 1;  // The maximum duration of the tween for changing the denominator of the first segment (set of ticks)  
    public static inline var TIME_MULT_SCALING_DURATION_CHANGE_DENOM_OTHER_SEGMENT_MAX : Float = 1;  // The maximum duration of the tween for changing the denominator of the other segments (set of ticks)  
    public static inline var TIME_MULT_SCALING_DURATION_EXTENSION : Float = 1;  // The duration of the tween for extending the first fraction (if necessary)  
    public static inline var TIME_MULT_SCALING_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_MULT_SCALING_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_SCALING_DURATION_MERGE : Float = 1;  // The duration of the tween for merging the result  
    public static inline var TIME_MULT_SCALING_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_MULT_SCALING_DURATION_REDUCTION : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_MULT_SCALING_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_SCALING_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_SCALING_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delay
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_SCALE : Float = .4;  // The amount of delay once the ticks have been updated  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_EXTENSION : Float = .5;  // The amount of delay once the first fraction has been extended  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have merged  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result has been shown  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_REDUCTION : Float = .5;  // The amount of delay once the first fraction has been reduced  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have faded out  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_MULT_SCALING_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    /**
		 * 
		 * Split
		 * 
		**/
    
    // Times
    public static inline var TIME_SPLIT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving the values to their destinations  
    
    // Delays
    public static inline var TIME_SPLIT_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_SPLIT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the results are in position  
    
    /**
		 * 
		 * Subtraction
		 * 
		**/
    
    // Times
    public static inline var TIME_SUB_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for changing the denominator  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM_PER_TICK_MIN : Float = .2;  // The minimum duration of the tween for changing the denominator of a single tick  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX : Float = 1;  // The maximum duration of the tween for changing the denominator of the first segment (set of ticks)  
    public static inline var TIME_SUB_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_SUB_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_DURATION_MERGE : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_DURATION_REDUCTION : Float = 1;  // The duration of the tween for reducing the result fraction (if necessary)  
    public static inline var TIME_SUB_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_SUB_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_SUB_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_SUB_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_SUB_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_DELAY_AFTER_REDUCTION : Float = .5;  // The amount of delay once the result fraction has been reduced  
    public static inline var TIME_SUB_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have faded out  
    public static inline var TIME_SUB_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have been simplified  
    public static inline var TIME_SUB_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  

    public function new()
    {
    }
}

