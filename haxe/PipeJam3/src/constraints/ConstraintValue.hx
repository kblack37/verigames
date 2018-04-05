package constraints;

import flash.errors.Error;

class ConstraintValue
{
    public static inline var TYPE_0 : String = "0";
    public static inline var TYPE_1 : String = "1";
    
    public static inline var VERBOSE_TYPE_0 : String = "type:0";
    public static inline var VERBOSE_TYPE_1 : String = "type:1";
    
    public var intVal : Int;
    public var strVal : String;
    public var verboseStrVal : String;
    
    public function new(_val : Int)
    {
        intVal = _val;
        switch (intVal)
        {
            case 0:
                strVal = TYPE_0;
                verboseStrVal = VERBOSE_TYPE_0;
            case 1:
                strVal = TYPE_1;
                verboseStrVal = VERBOSE_TYPE_1;
            default:
                throw new Error("Unexpected Constraint Value: " + intVal);
        }
    }
    
    public function clone() : ConstraintValue
    {
        return new ConstraintValue(intVal);
    }
    
    public function toString() : String
    {
        return verboseStrVal;
    }
    
    public static function fromStr(str : String) : ConstraintValue
    {
        switch (str)
        {
            case TYPE_0:
                return new ConstraintValue(0);
            case TYPE_1:
                return new ConstraintValue(1);
        }
        return null;
    }
    
    public static function fromVerboseStr(verboseStr : String) : ConstraintValue
    {
        switch (verboseStr)
        {
            case VERBOSE_TYPE_0:
                return new ConstraintValue(0);
            case VERBOSE_TYPE_1:
                return new ConstraintValue(1);
        }
        return null;
    }
}

