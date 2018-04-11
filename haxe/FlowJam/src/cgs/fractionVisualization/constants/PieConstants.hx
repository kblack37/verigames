package cgs.fractionVisualization.constants;

import openfl.geom.Point;

/**
	 * ...
	 * @author Mike (modified from Rich's LineConstants)
	 */
class PieConstants
{
    
    /**
		 * 
		 * Sizing
		 * 
		**/
    
    
    public static var BASE_UNIT_DIAMETER : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SIZE;  // The diameter of one unit  
    public static var BASE_UNIT_SEPARATION : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SEPARATION;  // Separation between pies in a represenation  
    public static var BASE_SCALE : Float = CgsFVConstants.REPRESENTATION_BASE_UNIT_SCALE;  // The base scale of a numberline  
    
    public static var BACKBONE_BORDER_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // The thickness of the border around the backbone  
    public static inline var FILL_ALPHA : Float = 0.5;  // Default Fill Alpha  
    public static inline var FILL_ALPHA_COLORED : Float = 0.75;  // Colored Fill Alpha  
    public static var TICK_THICKNESS : Float = CgsFVConstants.REPRESENTATION_BASE_STROKE_THICKNESS;  // Thickness of ticks  
    public static inline var TICK_EXTENSION_DISTANCE : Float = 5;  // Extra distance ticks extend out from the Numberline  
    public static inline var WINNING_GLOW_THICKNESS : Int = 15;  // Thickness of the glow around a winning Strip  
    
    
    public static inline var NUMBER_DISPLAY_MARGIN_INTEGER : Float = 25;  // Margin between the border and the number display if the number display is an integer  
    public static inline var NUMBER_DISPLAY_MARGIN_FRACTION : Float = 35;  // Margin between the border and the number display if the number display is a fraction  
    
    // Pie Spacing
    public static inline var LEFT_FRACTION_OFFSET : Float = 20;  // Distance to left of pie that fraction is written  
    public static inline var COMPARISON_MARGIN : Float = 28;  // Margin between two pies being compared  
    public static inline var MULTIPLY_TOP_FROM_CENTER_Y : Float = 100;  // Distance from center that Y position is  
    public static inline var MULTIPLY_X_POSITION : Float = 0;  // X coordinator for positioning step  
    public static inline var MULTIPLY_RESULT_Y_POSITION : Float = 100;  // Y coordinator for result  
    public static inline var TIME_MULTIPLY_TOP_FROM_CENTER : Float = 1;  // Time from Center to Top (leftover, should be changed to one below)  
    public static var MULTIPLY_EXPLOSION_FACTOR : Float = 1 / 2;  // Distance to move sectors away from center (relative to size)  
    public static inline var MULTIPLY_EXPLOSION_BOUNCE_FACTOR : Float = 1.5;  // Sectors move out this much extra before returning to distance defined by explosion factor  
    
    public static var COMPARE_RESULT_LOCATION : Point = new Point(0, 30);  // Center pie.  Others adjusted based on this location  
    public static var COMPARE_TARGET_RESULT_LOCATION : Point = new Point(0, 30);  // Center pie.  Others adjusted based on this location  
    
    /**
		 * 
		 * Animation General
		 * 
		**/
    
    public static inline var ANIMATION_MARGIN_VERTICAL_SMALL : Float = 10;  // Margin between two numberlines when displayed one above the other  
    public static inline var ANIMATION_MARGIN_VERTICAL_NORMAL : Float = 45;  // Margin between two numberlines when displayed one above the other  
    
    public static inline var ANIMATION_MARGIN_EQUATION : Float = 100;  // Distance between a numberline and an equation  
    public static inline var ANIMATION_MARGIN_MARKER : Float = 100;  // Distance between a numberline and a marker (ie. benchmark dashes)  
    public static inline var ANIMATION_MARGIN_TEXT : Float = 100;  // Distance between a numberline and text (ie. result text)  
    public static inline var ANIMATION_MARGIN_TEXT_LARGE : Float = 120;  // Distance between a numberline and text (ie. result text)  
    
    public static inline var PULSE_SCALE_GENERAL : Float = 1.25;  // The scale of the pulse emphasis used by the Numberline, in general  
    public static inline var PULSE_SCALE_GENERAL_LARGE : Float = 1.5;  // The scale of the pulse emphasis used by the Numberline, in general  
    public static inline var PULSE_SCALE_SEGMENT : Float = 1.5;  // The scale of the pulse emphasis used by the Numberline segment  
    
    public static inline var TIME_DURATION_UNIT_FILL : Float = 2;  // The duration of the tween for a unit fill  
    public static inline var TIME_DURATION_MAX_FILL : Float = 4;  // The maximum duration of the tween for a fill  
    
    public static inline var TIME_DURATION_ABSOLUTE_MINIMUM : Float = 0.2;  // The absolute minimum used when calculating brevity  
    
    /**
		 * 
		 * Addition
		 * 
		**/
    
    // Times
    public static inline var TIME_ADD_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for updating the ticks of the first segment of a Strip  
    public static inline var TIME_ADD_DURATION_CHANGE_DENOM_TICKS_MAX : Float = 1;  // The duration of the tween for updating the ticks of the first segment of a Strip  
    public static inline var TIME_ADD_DURATION_ALIGN : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_ADD_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to show parts on the result  
    public static inline var TIME_ADD_DURATION_EXTENSION : Float = 1;  // The duration of the tween for extending the first fraction (if necessary)  
    public static inline var TIME_ADD_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_ADD_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_ADD_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_DURATION_MAX_DROP_SECTORS : Float = 3;  // The maximum duration of the droping of the fraction  
    public static inline var TIME_ADD_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_ADD_DURATION_FADE : Float = 1;  // The duration of the merging of the fractions  
    public static inline var TIME_ADD_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the simplifying the result  
    public static inline var TIME_ADD_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_ADD_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_DELAY_AFTER_ALIGN : Float = .5;  // The amount of delay once the second fraction is aligned to the first fraction  
    public static inline var TIME_ADD_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result has been shown  
    public static inline var TIME_ADD_DELAY_AFTER_EXTENSION : Float = .5;  // The amount of delay once the first fraction has been extended  
    public static inline var TIME_ADD_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_ADD_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_ADD_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    public static inline var TIME_ADD_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_ADD_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_ADD_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    /**
		 * 
		 * Addition - In Place
		 * 
		**/
    
    // Times
    public static inline var TIME_ADD_IN_PLACE_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_ADD_IN_PLACE_DURATION_EXTENSION : Float = 1;  // The duration of the tween for extending the first fraction (if necessary)  
    public static inline var TIME_ADD_IN_PLACE_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_ADD_IN_PLACE_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_ADD_IN_PLACE_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_ADD_IN_PLACE_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_ADD_IN_PLACE_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    
    // Delays
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_EXTENSION : Float = .5;  // The amount of delay once the first fraction has been extended  
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_ADD_IN_PLACE_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    
    /**
		 * 
		 * Compare Size
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_SIZE_FILL_UNIT_DURATION : Float = 2;  // Time for filling the pie  
    public static inline var TIME_COMPARE_SIZE_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_SIZE_DURATION_COMPARE : Float = 1;  // The duration of the compare  
    public static inline var TIME_COMPARE_SIZE_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_COMPARE_SIZE_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_SIZE_DURATION_FADE : Float = 1;  // The duration of the fading out tween  
    public static inline var TIME_COMPARE_SIZE_DURATION_REPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    public static inline var TIME_COMPARE_SIZE_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_FILL : Float = .5;  // The amount of delay after fill - likely deprecated soon  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the comparison is complete  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_EMPHASIS : Float = .5;  // The amount of delay once the emphasis is complete  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the dashed lines are faded out  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_REPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    public static inline var TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    public static var COMPARE_GLOW_AREA_BLUR : Point = new Point(30, 30);  // The amount of Blur for winner glow  
    public static inline var COMPARE_PULSE_SCALE : Float = 1.25;  // The amount of to scale for pulse compare.  Keep small  
    public static var COMPARE_SIZE_CENTER : Point = new Point(0, 30);  // Adjust to offset location of EVERYTHING.  
    
    /**
		 * 
		 * Compare Target
		 * 
		**/
    
    // Times
    public static inline var TIME_COMPARE_TARGET_FILL_UNIT_DURATION : Float = 2;  // Time for filling the pie  
    public static inline var TIME_COMPARE_TARGET_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the center position  
    public static inline var TIME_COMPARE_TARGET_DURATION_COMPARE : Float = 1;  // The duration of the compare  
    public static inline var TIME_COMPARE_TARGET_DURATION_PAUSE_BEFORE_ROTATE : Float = 0.5;  // The duration of the pause before rotating the alignment of over/under benchmark  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK : Float = 1;  // The duration of the tween to show the benchmark value  
    public static inline var TIME_COMPARE_TARGET_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_COMPARE_TARGET_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_COMPARE_TARGET_DURATION_FADE : Float = 1;  // The duration of the fading out tween  
    public static inline var TIME_COMPARE_TARGET_DURATION_REPOSITION : Float = 1;  // The duration of the tween for moving to the start position  
    public static inline var TIME_COMPARE_TARGET_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    // Delays
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the fractions are in position  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK : Float = .5;  // The amount of delay once the benchmark value is shown  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_FILL : Float = .5;  // The amount of delay once the fills are complete  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE : Float = .5;  // The amount of delay once the compare is complete  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_EMPHASIS : Float = .5;  // The amount of delay once the emphasis is complete  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result text has been displayed  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the dashed lines are faded out  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_REPOSITION : Float = .5;  // The amount of delay once the fractions are back at the starting position  
    public static inline var TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    // Misc
    public static inline var COMPARE_FILL_ALPHA : Float = 0.8;  // The alpha on the overlays brought together  
    public static inline var COMPARE_GLOW_AREA_SCALING : Float = 1.2;  // Relative size of glowing rectangle to original size  
    public static inline var COMPARE_TARGET_BENCHMARK_LINE_SCALING : Float = 1.2;  // Relative size of benchmark line to original size  
    public static inline var COMPARE_TARGET_MOVING_BENCHMARK_MARGIN : Float = 10;  // Additional pixels to add to spacing that is distance from edge of circle  
    
    /**
		 * 
		 * Multiply
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_MULT_DURATION_SCALE : Float = 1;  // The duration of the tween for squishing/stretching the second fraction (if necessary)  
    public static inline var TIME_MULT_DURATION_EXTENSION : Float = 1;  // The duration of the tween for extending the first fraction (if necessary)  
    public static inline var TIME_MULT_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_MULT_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_DURATION_FADE_ORIGINALS : Float = 1;  // The duration of the fading out the second fraction  
    public static inline var TIME_MULT_DURATION_MERGE : Float = 1;  // The duration of the tween for merging the result  
    public static inline var TIME_MULT_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_MULT_DURATION_REDUCTION : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_MULT_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    
    
    public static inline var TIME_MULT_DURATION_NORMAL_SINGLE_ORGANIZE : Float = 0.5;  // Normal time for separating original denominators from the center  
    public static inline var TIME_MULT_DURATION_MAX_ALL_ORGANIZE : Float = 4;  // Maximum time for separating original denominators from the center  
    public static inline var TIME_MULT_DURATION_NORMAL_SINGLE_PARTITION : Float = 0.5;  // Normal time for pulsing a partitioned piece  
    public static inline var TIME_MULT_DURATION_MAX_ALL_PARTITION : Float = 4;  // Maximum time for pulsing all partitioned pieces  
    public static inline var TIME_MULT_DURATION_NORMAL_SINGLE_GETPARTS : Float = 0.5;  // Normal time for moving parts into the column/row area  
    public static inline var TIME_MULT_DURATION_MAX_ALL_GETPARTS : Float = 4;  // Maximum time for moving parts into the column/row area  
    public static inline var TIME_MULT_DURATION_NORMAL_SINGLE_REASSEMBLE : Float = 0.5;  // Normal time for reassembling into the final fraction  
    public static inline var TIME_MULT_DURATION_MAX_ALL_REASSEMBLE : Float = 4;  // Maximum time for reassembling into the final fraction  
    
    public static inline var TIME_MULT_DURATION_PULSE_STATIONARY_NUMBER : Float = 0.25;  // Duration for numerator or denominator of second fraction to be pulsed  
    // The backbone fade, tick fade, and explode constants all parts of the same step
    // Currently they happen simulatenously
    public static inline var TIME_MULT_START_BACKBONE_FADE : Float = 0;
    public static inline var TIME_MULT_START_TICK_FADE : Float = 0;
    public static inline var TIME_MULT_DURATION_BACKBONE_FADE : Float = 0.5;
    public static inline var TIME_MULT_DURATION_TICK_FADE : Float = 0.5;
    public static inline var TIME_MULT_START_EXPLODE_OUT : Float = 0;
    public static inline var TIME_MULT_DURATION_EXPLODE_OUT : Float = 0.5;
    public static inline var TIME_MULT_DURATION_EXPLODE_BACK : Float = 0.25;
    
    // Delay
    public static inline var TIME_MULT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_MULT_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the denominator has been changed  
    public static inline var TIME_MULT_DELAY_AFTER_SCALE : Float = .4;  // The amount of delay once the ticks have been updated  
    public static inline var TIME_MULT_DELAY_AFTER_EXTENSION : Float = .5;  // The amount of delay once the first fraction has been extended  
    public static inline var TIME_MULT_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_DELAY_AFTER_FADE_ORIGINALS : Float = .5;  // The amount of delay once the second fraction has been faded out  
    public static inline var TIME_MULT_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have merged  
    public static inline var TIME_MULT_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result has been shown  
    public static inline var TIME_MULT_DELAY_AFTER_REDUCTION : Float = .5;  // The amount of delay once the first fraction has been reduced  
    public static inline var TIME_MULT_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_MULT_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_MULT_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    
    public static inline var TIME_MULT_DELAY_AFTER_GETPARTS : Float = .5;  // The amount of delay once the parts have been moved to the column/row area  
    public static inline var TIME_MULT_DELAY_AFTER_ANSWER : Float = .5;  // The amount of delay after answer  
    
    public static inline var MULT_ADDIITIONAL_SPACING_FOR_PULSED_NUMBERS : Float = 10;  // Additional spacing needed for number not to be overlapping with sector  
    public static var MULT_PULSED_NUMBER_OFFSET : Point = new Point(-10, -20);  // Adjustment of location for pulsed number  
    
    /**
		 * 
		 * Multiply - With Result
		 * 
		**/
    
    // Times
    public static inline var TIME_MULT_WITH_RESULT_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_SCALE : Float = 1;  // The duration of the tween for squishing/stretching the second fraction (if necessary)  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to fade in the result  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_MULT_WITH_RESULT_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    
    // Delay
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_SCALE : Float = .4;  // The amount of delay once the ticks have been updated  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result has been shown  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_MULT_WITH_RESULT_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    
    /**
		 * 
		 * Subtraction
		 * 
		**/
    
    // Times
    public static inline var TIME_SUB_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM_PER_TICK : Float = .25;  // The duration of the tween for updating the ticks of the first segment of a Strip  
    public static inline var TIME_SUB_DURATION_CHANGE_DENOM_TICKS_MAX : Float = 1;  // The duration of the tween for updating the ticks of the first segment of a Strip  
    public static inline var TIME_SUB_DURATION_ALIGN : Float = 1;  // The duration of the tween for align the second fraction to the first  
    public static inline var TIME_SUB_DURATION_SHOW_RESULT : Float = 1;  // The duration of the tween to show parts on the result  
    public static inline var TIME_SUB_DURATION_MAX_DROP_SECTORS : Float = 3;  // The maximum duration of the droping of the fraction  
    
    public static inline var TIME_SUB_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_SUB_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_SUB_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_DURATION_REDUCTION : Float = 1;  // The duration of the tween for reducing the result fraction (if necessary)  
    public static inline var TIME_SUB_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_SUB_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_SUB_DURATION_UNPOSITION : Float = 1;  // The duration of the tween for moving to the final position  
    public static inline var TIME_SUB_DURATION_MERGE : Float = 1;  // The duration of the merging of the fractions  
    
    // Delays
    public static inline var TIME_SUB_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_DELAY_AFTER_CHANGE_DENOM : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_DELAY_AFTER_ALIGN : Float = .5;  // The amount of delay once the second fraction is aligned to the first fraction  
    public static inline var TIME_SUB_DELAY_AFTER_SHOW_RESULT : Float = .5;  // The amount of delay once the result has been shown  
    
    public static inline var TIME_SUB_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_SUB_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_DELAY_AFTER_REDUCTION : Float = .5;  // The amount of delay once the result fraction has been reduced  
    public static inline var TIME_SUB_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_SUB_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_SUB_DELAY_AFTER_UNPOSITION : Float = .5;  // The amount of delay once in the final position  
    public static inline var TIME_SUB_DELAY_AFTER_MERGE : Float = .5;  // The amount of delay once the fractions have been merged  
    
    
    public static inline var SUB_SCALE_NULLIFY_WHOLE : Float = 1.01;  // The amount of scale for the nullification step, for whole circles - looks gigantic if same as partial  
    public static inline var SUB_SCALE_NULLIFY_PARTIAL : Float = 1.05;  // The amount of scale for the nullification step  
    public static inline var TIME_SUB_DELAY_NULLIFY : Float = 0.1;  // The amount of delay for first item to allow for chase effect	- Deprecated?  
    
    
    
    /**
		 * 
		 * Subtraction - In Place
		 * 
		**/
    
    // Times
    public static inline var TIME_SUB_IN_PLACE_DURATION_POSITION : Float = 1;  // The duration of the tween for moving to the new position  
    public static inline var TIME_SUB_IN_PLACE_DURATION_SHOW_EQUATION : Float = 1;  // The duration of the tween to show parts on the equation  
    public static inline var TIME_SUB_IN_PLACE_DURATION_EMPHASIS : Float = 1;  // The duration of the emphasis  
    public static inline var TIME_SUB_IN_PLACE_DURATION_DROP : Float = 1;  // The duration of the droping of the fraction  
    public static inline var TIME_SUB_IN_PLACE_DURATION_REDUCTION : Float = 1;  // The duration of the tween for reducing the result fraction (if necessary)  
    public static inline var TIME_SUB_IN_PLACE_DURATION_FADE : Float = 1;  // The duration of the fading out of the second view  
    public static inline var TIME_SUB_IN_PLACE_DURATION_SIMPLIFICATION : Float = 1;  // The duration of the fading out of the second view  
    
    // Delays
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_POSITION : Float = .5;  // The amount of delay once the second fraction is in position  
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_SHOW_EQUATION : Float = .5;  // The amount of delay once the equation has been shown  
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_DROP : Float = .5;  // The amount of delay once the second fraction's value has been dropped  
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_REDUCTION : Float = .5;  // The amount of delay once the result fraction has been reduced  
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_FADE : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  
    public static inline var TIME_SUB_IN_PLACE_DELAY_AFTER_SIMPLIFICATION : Float = .5;  // The amount of delay once the fractions have repositioned/faded out  

    public function new()
    {
    }
}

