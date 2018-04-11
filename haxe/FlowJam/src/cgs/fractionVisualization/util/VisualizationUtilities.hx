package cgs.fractionVisualization.util;

import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.math.CgsFraction;
import cgs.math.CgsMathUtilities;
import cgs.utils.CgsTuple;

/**
	 * ...
	 * @author Jack
	 */
class VisualizationUtilities
{
    /**
		 * 
		 * Colors
		 * 
		**/
    
    /**
		 * Creates and returns an 3-part array that describes the colors to be used in a gradient matrix
		 * based on the given base color and modification factors.
		 * @param	baseColor
		 * @param	lightenFactor
		 * @param	darkenFactor
		 * @return
		 */
    public static function computeColorArray(baseColor : Int, factorOne : Float, factorThree : Float) : Array<UInt>
    {
        var result : Array<UInt> = new Array<UInt>();
        result.push(shadeColor(baseColor, factorOne));
        result.push(baseColor);
        result.push(shadeColor(baseColor, factorThree));
        return result;
    }
    
    /**
		 * Change the shade of the color by the provided factor
		 * @param	color
		 * @param	colorFactor
		 * @return
		 */
    public static function shadeColor(color : Int, colorFactor : Float) : Int
    {
        // Get Components
        var blue : Int = 0xff & color;
        var green : Int = as3hx.Compat.parseInt(0xff00 & color) >> 8;
        var red : Int = as3hx.Compat.parseInt(0xff0000 & color) >> 16;
        
        // Make each component darker
        var newBlue : Int = as3hx.Compat.parseInt(blue * colorFactor);
        var newGreen : Int = as3hx.Compat.parseInt(green * colorFactor);
        var newRed : Int = as3hx.Compat.parseInt(red * colorFactor);
        
        // Make sure no components overflowed
        if (newBlue < 0)
        {
            newBlue = 0;
        }
        if (newGreen < 0)
        {
            newGreen = 0;
        }
        if (newRed < 0)
        {
            newRed = 0;
        }
        if (newBlue > 255)
        {
            newBlue = 255;
        }
        if (newGreen > 255)
        {
            newGreen = 255;
        }
        if (newRed > 255)
        {
            newRed = 255;
        }
        
        // Compose back into single value and return
        return as3hx.Compat.parseInt((newRed << 16) | (newGreen << 8) | newBlue);
    }
    
    /**
		 * 
		 * Subsets of fractions
		 * 
		**/
    
    /**
		 * Reutrns the numerator of the given fraction at the given unit index.
		 * For example, consider the Grid representation and consider each Grid square as a separate fraction.
		 * This funciton will return the numerator value of the Grid square at the given unit index (if 0, then the first square; if 1, then the second; and so on).
		 * @param	aFraction - The fraction you want the numerator subset of
		 * @param	unitIndex - The unit you want the subset of
		 * @return
		 */
    public static function getNumeratorSubsetOfFraction(aFraction : CgsFraction, unitIndex : Int = 0) : Int
    {
        // Remove the first unitIndex whole units, return what is left over (but no more than a whole unit).
        return Std.int(Math.min(aFraction.numerator - unitIndex * aFraction.denominator, aFraction.denominator));
    }
    
    /**
		 * 
		 * Grid Dimensions
		 * 
		**/
    
    /**
		 * Determines the ideal grid dimentions (rows and columns) given a fraction
		 * @param	fraction - the fraction to use
		 * @return	CgsTuple - the (rows, columns) of the idea grid
		 */
    public static function determineIdealGrid(fraction : CgsFraction) : CgsTuple
    {
        var factorPairs : Array<CgsTuple> = CgsMathUtilities.factorPairs(fraction.denominator);
        var bestPair : CgsTuple = factorPairs[0];
        var num : Int = fraction.numerator;
        if (num == 0)
        {
            num = fraction.denominator;
        }
        for (i in 0...factorPairs.length)
        {
            if (num % factorPairs[i].first == 0 && Math.abs(bestPair.first - bestPair.second) > Math.abs(factorPairs[i].first - factorPairs[i].second))
            {
                bestPair = factorPairs[i];
            }
        }
        return bestPair;
    }
    
    /**
		 * Determine the number of rows and columns in a grid with val spaces in order to minimize the difference between the number of rows and columns
		 * @param	val - The number of spaces in the grid
		 * @return	CgsTupe - the (rows, columns) of the best grid
		 */
    public static function determineSquareGrid(val : Float) : CgsTuple
    {
        var frac : CgsFraction = new CgsFraction();
        frac.init(Std.int(val), Std.int(val));
        return determineIdealGrid(frac);
    }
    
    /**
		 * Determines which fraction, first or second, is closest to the goal of the compare type.
		 * @param	comparisonType
		 * @param	first
		 * @param	second
		 * @param	data
		 * @return
		 */
    public static function compareByComparisonType(comparisonType : String, first : CgsFraction, second : CgsFraction, data : Dynamic = null) : Float
    {
        var result : Float = 0;
        
        // Compute which is closest to the target, based on the target
        if (comparisonType == CgsFVConstants.COMPARE_TYPE_GREATER_THAN)
        {
            result = first.value - second.value;
        }
        else
        {
            if (comparisonType == CgsFVConstants.COMPARE_TYPE_LESS_THAN)
            {
                result = second.value - first.value;
            }
            else
            {
                if (comparisonType == CgsFVConstants.COMPARE_TYPE_CLOSEST_TO_BENCHMARK)
                {
                    var targetFraction : CgsFraction = Reflect.field(data, Std.string(CgsFVConstants.COMPARISON_BENCHMARK_DATA_KEY));
                    var targetValue : Float = targetFraction.value;
                    var firstDiff : Float = Math.abs(targetValue - first.value);
                    var secondDiff : Float = Math.abs(targetValue - second.value);
                    result = secondDiff - firstDiff;
                    if (Math.abs(result) < (1 / 100000000))
                    {
                        result = 0;
                    }
                }
            }
        }
        
        return result;
    }

    public function new()
    {
    }
}

