package cgs.internationalization;
import cgs.utils.Error;


/**
	 * Class for holding various runtime checks functions.
	 */
class Checks
{
    /**
		 * Assert that a program invariant holds true.
		 * An assertion failure indicates a program bug.
		 */
    public static function assert(condition : Bool) : Void
    {
        assertWithMessage(condition, "[no info]");
    }
    
    /**
		 * Assert that a program invariant holds true.
		 * An assertion failure indicates a program bug.
		 * Also give some message realted to the assertion.
		 */
    public static function assertWithMessage(condition : Bool, msg : String) : Void
    {
        if (!condition)
        {
            throw new Error("Assertion failed: " + msg);
        }
    }
    
    /**
		 * Perform a check.
		 * A failure indicates an unexpected or unhandled problem with inputs.
		 */
    public static function errorCheck(condition : Bool, msg : String) : Void
    {
        if (!condition)
        {
            throw new Error("Error: " + msg);
        }
    }

    public function new()
    {
    }
}

