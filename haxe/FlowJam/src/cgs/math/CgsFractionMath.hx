package cgs.math;


/**
	 * Helpful functions that relate to fractions
	 * 
	 * @author Tamir, Dmitri
	 */
class CgsFractionMath
{
    /**
		 * Values this far away will still be considered equal
		 */
    public static inline var EPSILON : Float = 0.00001;
    
    /**
		 * Computes whether or not the two values are equal.
		 * 
		 * @param f1
		 * @param f2
		 * @return <code>true</code> if the two values are within EPSILON of each other
		 */
    public static function equals(f1 : Float, f2 : Float) : Bool
    {
        return (compare(f1, f2) == 0);
    }
    
    /**
		 * Compares two Numbers
		 * 
		 * @param	f1
		 * @param	f2
		 * @return Number representing comparison result.
		 */
    public static function compare(f1 : Float, f2 : Float) : Float
    {
        var result : Float = f1 - f2;
        if (Math.abs(result) < EPSILON)
        {
            result = 0;
        }
        return (result);
    }
    
    /**
		 * Returns the Greatest Common Divisor of the given values.
		 * 
		 * @param first
		 * @param second
		 * @return The Greatest Common Divisor of the two values
		 */
    public static function gcd(first : Int, second : Int) : Int
    {
        // When finding the gcd of two numbers, negative numbers act as though they're positive
        // Switches first and second to positive to fix infinite loop bug
        first = Std.int(Math.abs(first));
        second = Std.int(Math.abs(second));
        if (first == 0)
        {
            return second;
        }
        
        while (second != 0)
        {
            if (first > second)
            {
                first = as3hx.Compat.parseInt(first - second);
            }
            else
            {
                second = as3hx.Compat.parseInt(second - first);
            }
        }
        return first;
    }
    
    /**
		 * Returns the Least Common Multiple of the given values.
		 * 
		 * @param first
		 * @param second
		 * @return The Least Common Multiple of the two given values
		 */
    public static function lcm(first : Int, second : Int) : Int
    {
        if (first == 0 || second == 0)
        {
            return 0;
        }
        
        return as3hx.Compat.parseInt(Math.abs(first * second) / gcd(first, second));
    }

    public function new()
    {
    }
}
