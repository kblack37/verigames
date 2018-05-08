package utils;

import flash.geom.Point;

/**
	 * My own extended string class
	 * @author pavlik
	 */
@:final class XString
{
    /**
		 * Converts a string into a boolean by looking at the contents of the string.
		 * @param s String to convert to Boolean: "false" (any case or combination upper/lowercase), "0", "f", "F", "null" (any case) or empty string ("") return false, everything else returns true
		 * @return The bool represented by the string. Default to true, although "null" and empty string return false
		 */
    public static function stringToBool(st : String) : Bool
    {
        if (st == null)
        {
            return false;
        }
        var lcst : String = st.toLowerCase();
        switch (lcst)
        {
            case "false", "0", "", "null", "f":
                return false;
        }
        return true;
    }
    
    public static function leftPad(str : Dynamic, len : Int, padChar : String = " ") : String
    {
        var ret : String = Std.string(str);
        
        while (ret.length < len)
        {
            ret = padChar + ret;
        }
        
        return ret;
    }
    
    private static function stripParens(a : String) : String
    {
        if ((a.charAt(0) == "(") || (a.charAt(0) == "["))
        {
            a = a.substring(1, a.length);
        }
        if ((a.charAt(a.length - 1) == ")") || (a.charAt(a.length - 1) == "]"))
        {
            a = a.substring(0, a.length - 1);
        }
        return a;
    }
    
    public static function stringToPointVector(str : String) : Array<Point>
    {
        var fullString : String = str;
        
        // array of points
        var vec : Array<Point> = new Array<Point>();
        var pointsArray : Array<Dynamic> = stripParens(str).split("),(");
        for (j in 0...pointsArray.length)
        {
            var coords : Array<Dynamic> = pointsArray[j].split(",");
            if (Math.isNaN(coords[0]) || Math.isNaN(coords[1]))
            {
                continue;
            }
            vec.push(new Point(coords[0], coords[1]));
        }
        return vec;
    }
    
    public static function pointVectorToString(vec : Array<Point>) : String
    {
        var new_string : String = "";
        var i : Int = 0;
        for (pt in vec)
        {
            new_string += "(" + floatFixedDigits(pt.x, 1) + "," + floatFixedDigits(pt.y, 1) + ")";
            if (i + 1 < vec.length)
            {
                new_string += ",";
            }
            i++;
        }
        return new_string;
    }
	
	public static function floatFixedDigits(val : Float, n : Int) : String {
		var floatSplit : Array<String> = Std.string(val).split(".");
		return floatSplit[0] + floatSplit[1].substr(0, n);
	}
}

