package cgs.math;

import cgs.utils.CgsTuple;

/**
	 * Math utility functions
	 * @author Jack
	 */
class CgsMathUtilities
{
    
    /**
		 * Returns a vector of CgsTuples describing the pairs of factors of n
		 * example:  factorPairs(24) will return {(1,24), (2,12), (3,8), (4,6), (6,4), (8,3), (12,2), (24,1)}
		 * @param	n	- The number to find the factor pairs of. n must be a positive integer
		 * @return	vector containing CgsTuples of those factor pairs
		 */
    public static function factorPairs(n : Int) : Array<CgsTuple>
    {
        var results : Array<CgsTuple> = new Array<CgsTuple>();
        for (i in 1...n + 1)
        {
            if (n % i == 0)
            {
                results.push(new CgsTuple(i, n / i));
            }
        }
        return results;
    }
    
    /**
		 * Returns a vector of all the factors of n
		 * @param	n	- The number to find the factors of.  n must be a positive integer
		 * @return	vector containing the factors of n
		 */
    public static function factors(n : Int) : Array<Int>
    {
        var results : Array<Int> = new Array<Int>();
        for (i in 1...n + 1)
        {
            if (n % i == 0)
            {
                results.push(i);
            }
        }
        return results;
    }

    public function new()
    {
    }
}

