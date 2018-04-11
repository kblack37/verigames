package cgs.utils;

class MathUtils 
{

/**
 * Some handy math functions, and inlinable constants.
 */
    public static inline var E = 2.718281828459045;
    public static inline var LN2 = 0.6931471805599453;
    public static inline var LN10 = 2.302585092994046;
    public static inline var LOG2E = 1.4426950408889634;
    public static inline var LOG10E = 0.43429448190325176;
    public static inline var PI = 3.141592653589793;
    public static inline var SQRT1_2 = 0.7071067811865476;
    public static inline var SQRT2 = 1.4142135623730951;

    // Haxe doesn't specify the size of an int or float, in practice it's 32 bits
    /** The lowest integer value in Flash and JS. */
    public static inline var INT_MIN :Int = -2147483648;

    /** The highest integer value in Flash and JS. */
    public static inline var INT_MAX :Int = 2147483647;

    /** The lowest float value in Flash and JS. */
    public static inline var FLOAT_MIN = -1.79769313486231e+308;

    /** The highest float value in Flash and JS. */
    public static inline var FLOAT_MAX = 1.79769313486231e+308;

    /** Converts an angle in degrees to radians. */
    inline public static function toRadians (degrees :Float) :Float
    {
        return degrees * PI/180;
    }

    /** Converts an angle in radians to degrees. */
    inline public static function toDegrees (radians :Float) :Float
    {
        return radians * 180/PI;
    }

    public static function sign (value :Float) :Int
    {
        return if (value < 0) -1
            else if (value > 0) 1
            else 0;
    }
	
	public static function toFixed(n:Float, prec:Int)
	{
	  n = Math.round(n * Math.pow(10, prec));
	  var str = ''+n;
	  var len = str.length;
	  if(len <= prec){
		while(len < prec){
		  str = '0'+str;
		  len++;
		}
		return '0.'+str;
	  }
	  else{
		return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
	  }
	}	
}	