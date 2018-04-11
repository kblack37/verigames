package cgs.math;


/**
	 * A fraction of 2 integers (non-zero denominator), can be set to auto-simplify.
	 * 
	 * @author
	 */
class CgsFraction
{
    public var autoSimplify(get, set) : Bool;
    public var denominator(get, set) : Int;
    public var numerator(get, set) : Int;
    public var value(get, never) : Float;
    public var isSimplified(get, never) : Bool;

    public static inline var ADD_OPERATOR : String = "add";
    public static inline var DIVIDE_OPERATOR : String = "div";
    public static inline var MULTIPLY_OPERATOR : String = "mul";
    public static inline var SUBTRACT_OPERATOR : String = "sub";
    
    // State
    private var m_numerator : Int;
    private var m_denominator : Int;
    private var m_autoSimplify : Bool;
    
    public function new(startNumerator : Float = 0, startDenominator : Float = 0)
    {
        // Auto-init this CgsFraction if both the startNumerator and startDenominator are valid
        if (startDenominator != 0)
        {
            init(Std.int(startNumerator), Std.int(startDenominator));
        }
    }
    
    /**
		 * Initializes the fraction object with numberator and denominator, currently if denominator
		 * is 0, it is treated as if it is a 1
		 * 
		 * @param	numerator the numerator of the fraction.
		 * @param	denominator the denominator of the fraction.
		 */
    public function init(numerator : Int, denominator : Int) : Void
    {
        //Should we throw exception here?
        if (denominator == 0)
        {
            trace("Attempted to init fraction with denominator 0.  Denominator set to 1.");
            denominator = 1;
        }
        
        m_autoSimplify = false;
        m_denominator = denominator;
        m_numerator = numerator;
    }
    
    /**
		 * Initializes a fraction that is represented by the number given (i.e. .25 becomes 1/4)
		 * Algorithm originates from: http://homepage.smc.edu/kennedy_john/DEC2FRAC.PDF
		 * 
		 * @param	value the value of the fraction desired in decimal form
		 */
    public function initFromValue(value : Float) : Void
    {
        var sign : Int = 1;
        if (value < 0)
        {
            sign = -1;
        }
        value = Math.abs(value);
        var z : Float = value;
        var previousDenominator : Float = 0;
        var fractionDenominator : Float = 1;
        var fractionNumerator : Int = Math.round(value * fractionDenominator);
        var error : Float = Math.abs(value - fractionNumerator / fractionDenominator);
        
        while (error > CgsFractionMath.EPSILON)
        {
            z = 1.0 / (z - integerPart(z));
            var scratchValue : Int = as3hx.Compat.parseInt(fractionDenominator);
            fractionDenominator = fractionDenominator * integerPart(z) + previousDenominator;
            previousDenominator = scratchValue;
            fractionNumerator = Math.round(value * fractionDenominator);
            error = Math.abs(value - fractionNumerator / fractionDenominator);
        }
        fractionNumerator = as3hx.Compat.parseInt(fractionNumerator * sign);
        //trace("Fraction::initFromValue: ", value, fractionNumerator, fractionDenominator, fractionNumerator / fractionDenominator);
        m_autoSimplify = false;
        m_denominator = as3hx.Compat.parseInt(fractionDenominator);
        m_numerator = fractionNumerator;
    }
    
    /**
		 * Returns the integer part of a Number (i.e. 3.75 returns 3, -2.15 return -2)
		 * 
		 * @param	value
		 * @return
		 */
    private function integerPart(value : Float) : Int
    {
        return ((value < 0) ? Math.ceil(value) : Math.floor(value));
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns whether or not this Fraction is set to automatically simplify.
		 * 
		 * @return
		 */
    private function get_autoSimplify() : Bool
    {
        return m_autoSimplify;
    }
    
    /**
		 * Sets whether or not this Fraction is set to automatically simplify.
		 * 
		 * @return
		 */
    private function set_autoSimplify(autoSimplify : Bool) : Bool
    {
        m_autoSimplify = autoSimplify;
        simplifyAutomatically();
        return autoSimplify;
    }
    
    /**
		 * Returns the denominator of this Fraction.
		 * 
		 * @return
		 */
    private function get_denominator() : Int
    {
        return m_denominator;
    }
    
    /**
		 * Sets the denominator of this Fraction to be the given denom.
		 * 
		 * @return
		 */
    private function set_denominator(denom : Int) : Int
    {
        if (denom != 0)
        {
            m_denominator = denom;
        }
        return denom;
    }
    
    /**
		 * Returns the numerator of this Fraction.
		 * 
		 * @return
		 */
    private function get_numerator() : Int
    {
        return m_numerator;
    }
    
    /**
		 * Sets the numerator of this Fraction to be the given num.
		 * 
		 * @return
		 */
    private function set_numerator(num : Int) : Int
    {
        m_numerator = num;
        return num;
    }
    
    /**
		 * Returns the decimal value of this Fraction.
		 * 
		 * @return
		 */
    private function get_value() : Float
    {
        var value : Float = m_numerator / m_denominator;
        return value;
    }
    
    /**
		 * 
		 * Clone
		 * 
		**/
    
    /**
		 * Creates a clone of this Fraction.
		 * 
		 * @return
		 */
    public function clone() : CgsFraction
    {
        var fraction : CgsFraction = new CgsFraction();
        fraction.init(m_numerator, m_denominator);
        fraction.autoSimplify = autoSimplify;
        return fraction;
    }
    
    /**
		 * 
		 * Operations
		 * 
		**/
    
    /**
		 * Adds the other fraction to this fraction, updating this fraction. Simplifies it if autoSimplify is true.
		 * 
		 * @param	other the fraction to add
		 */
    public function add(other : CgsFraction) : Void
    {
        var newDenom : Int = CgsFractionMath.lcm(this.denominator, other.denominator);
        var newNumer : Int = as3hx.Compat.parseInt(this.numerator * (newDenom / this.denominator) + other.numerator * (newDenom / other.denominator));
        m_denominator = newDenom;
        m_numerator = newNumer;
        simplifyAutomatically();
    }
    
    /**
		 * Divides the other fraction from this fraction, updating the fraction and simplifying it if autoSimplify is true.
		 * 
		 * @param	other the fraction to divide by
		 */
    public function divide(other : CgsFraction) : Void
    {
        m_numerator = as3hx.Compat.parseInt(m_numerator * other.denominator);
        m_denominator = as3hx.Compat.parseInt(m_denominator * other.numerator);
        simplifyAutomatically();
    }
    
    /**
		 * Multiplies the other fraction to this fraction, updating the fraction and simplifying it if autoSimplify is true.
		 * 
		 * @param	other the fraction to multiply
		 */
    public function multiply(other : CgsFraction) : Void
    {
        m_numerator = as3hx.Compat.parseInt(m_numerator * other.numerator);
        m_denominator = as3hx.Compat.parseInt(m_denominator * other.denominator);
        simplifyAutomatically();
    }
    
    /**
		 * Negates this fraction (numerator *= -1)
		 */
    public function negate() : Void
    {
        m_numerator *= -1;
    }
    
    /**
		 * Subtracts the other fraction from this fraction, updating the fraction and simplifying it if autoSimplify is true.
		 * 
		 * @param	other the fraction to subtract from this one
		 */
    public function subtract(other : CgsFraction) : Void
    {
        var newDenom : Int = CgsFractionMath.lcm(this.denominator, other.denominator);
        var newNumer : Int = as3hx.Compat.parseInt(this.numerator * (newDenom / this.denominator) - other.numerator * (newDenom / other.denominator));
        m_denominator = newDenom;
        m_numerator = newNumer;
        simplifyAutomatically();
    }
    
    /**
		 * 
		 * Operations - Static
		 * 
		**/
    
    /**
		 * Add f1 and f2 and return the resulting unsimplified fraction
		 * 
		 * @param f1
		 * @param f2
		 * @return f1 + f2
		 */
    public static function fAdd(f1 : CgsFraction, f2 : CgsFraction) : CgsFraction
    {
        var result : CgsFraction = f1.clone();
        result.add(f2);
        
        return result;
    }
    
    /**
		 * Divide f1 by f2 and return the resulting unsimplified fraction
		 * 
		 * @param f1
		 * @param f2
		 * @return f1 / f2
		 */
    public static function fDivide(f1 : CgsFraction, f2 : CgsFraction) : CgsFraction
    {
        var result : CgsFraction = f1.clone();
        result.divide(f2);
        
        return result;
    }
    
    /**
		 * Multiply f1 and f2 and return the resulting unsimplified fraction
		 * 
		 * @param f1
		 * @param f2
		 * @return f1 * f2
		 */
    public static function fMultiply(f1 : CgsFraction, f2 : CgsFraction) : CgsFraction
    {
        var result : CgsFraction = f1.clone();
        result.multiply(f2);
        
        return result;
    }
    
    /**
		 * Subtract f2 from f1 and return the resulting unsimplified fraction
		 * 
		 * @param f1
		 * @param f2
		 * @return f1 - f2
		 */
    public static function fSubtract(f1 : CgsFraction, f2 : CgsFraction) : CgsFraction
    {
        var result : CgsFraction = f1.clone();
        result.subtract(f2);
        
        return result;
    }
    
    /**
		 * 
		 * Simplify
		 * 
		**/
    
    /**
		 * Checks whether the fraction is in simplified form
		 * 
		 * @return <code>true</code> if the fraction is simplified, <code>false</code> if it is not
		 */
    private function get_isSimplified() : Bool
    {
        var gcd : Int = CgsFractionMath.gcd(m_numerator, m_denominator);
        return (gcd == 1);
    }
    
    /**
		 * Simplifies this fraction
		 */
    public function simplify() : Void
    {
        var gcd : Int = CgsFractionMath.gcd(m_numerator, m_denominator);
        if (gcd != 0)
        {
            m_numerator = as3hx.Compat.parseInt(m_numerator / gcd);
            m_denominator = as3hx.Compat.parseInt(m_denominator / gcd);
        }
    }
    
    /**
		 * This is used internally to simplify the fraction if m_autoSimplify is true
		 */
    private function simplifyAutomatically() : Void
    {
        if (m_autoSimplify)
        {
            simplify();
        }
    }
    
    /**
		 * 
		 * Everything Else
		 * 
		**/
    
    /**
		 * Compares this Fraction with another Object
		 * Returns True if other object is a CardGameObject and other object has the same label
		 * Returns False otherwise
		 * 
		 * @param	obj
		 * 			Object to perform comparison with
		 * @return
		 * 			Comparison result
		 */
    public function equals(obj : Dynamic) : Bool
    {
        if (Std.is(obj, CgsFraction))
        {
            var other : CgsFraction = try cast(obj, CgsFraction) catch(e:Dynamic) null;
            
            // Ignore autosimplify flag!
            return (this.m_numerator == other.m_numerator && this.m_denominator == other.m_denominator);
        }
        
        return false;
    }
    
    /**
		 * Returns the String representation of this Fraction instance.
		 * 
		 * @return
		 */
    public function toString() : String
    {
        var s : String = "";
        
        s += Std.string(m_numerator) + "/" + Std.string(m_denominator);
        
        return s;
    }
    
    /**
		 * 
		 * Utilities
		 * 
		**/
    
    /**
		 * Returns the base number of units of the given fraction.
		 * For example, 9/4 has 3 units. 
		 * @param	aFraction
		 * @return
		 */
    public static function computeNumBaseUnits(aFraction : CgsFraction) : Int
    {
        return Std.int(Math.max(Math.ceil(Math.abs(aFraction.value)), 1));
    }
}
