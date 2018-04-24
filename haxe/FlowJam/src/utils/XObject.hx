package utils;

import flash.geom.Point;

/**
	 * My own extended Object class
	 * @author pavlik
	 */
@:final class XObject
{
    /**
		 * Take an input JSON compatible object and return clone of it
		 * @param	obj: Object to clone
		 * @return Cloned obj
		 */
    public static function clone(obj : Dynamic) : Dynamic
    {
        var cloneStr : String = haxe.Json.stringify(obj);
        var clone : Dynamic = haxe.Json.parse(cloneStr);
        return clone;
    }
    
    public static function clonePointArray(arrToClone : Array<Dynamic>) : Array<Dynamic>
    {
        var newArray : Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...arrToClone.length)
        {
            var pt : Point = try cast(arrToClone[i], Point) catch(e:Dynamic) null;
            newArray.push(pt.clone());
        }
        return newArray;
    }
}

