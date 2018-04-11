package cgs.utils;


/**
	 * A simple tuple class.
	 * Contains two data values, first and second
	 * No type checking is done on these
	 * @author Jack
	 */
class CgsTuple
{
    public var first : Dynamic;
    public var second : Dynamic;
    
    public function new(f : Dynamic, s : Dynamic)
    {
        first = f;
        second = s;
    }
}

