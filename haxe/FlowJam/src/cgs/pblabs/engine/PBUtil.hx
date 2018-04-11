/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine;

import cgs.pblabs.engine.debug.Logger;
import cgs.utils.Error;
import flash.display.DisplayObject;
import flash.geom.Matrix;

/**
 * Contains math related utility methods.
 */
class PBUtil
{
    public static inline var FLIP_HORIZONTAL : String = "flipHorizontal";
    public static inline var FLIP_VERTICAL : String = "flipVertical";
    
    /**
     * Two times PI. 
     */
    public static var TWO_PI : Float = 2.0 * Math.PI;
    
    /**
     * Converts an angle in radians to an angle in degrees.
     * 
     * @param radians The angle to convert.
     * 
     * @return The converted value.
     */
    public static function getDegreesFromRadians(radians : Float) : Float
    {
        return radians * 180 / Math.PI;
    }
    
    /**
     * Converts an angle in degrees to an angle in radians.
     * 
     * @param degrees The angle to convert.
     * 
     * @return The converted value.
     */
    public static function getRadiansFromDegrees(degrees : Float) : Float
    {
        return degrees * Math.PI / 180;
    }
    
    /**
     * Keep a number between a min and a max.
     */
    public static function clamp(v : Float, min : Float = 0, max : Float = 1) : Float
    {
        if (v < min)
        {
            return min;
        }
        if (v > max)
        {
            return max;
        }
        return v;
    }
    
    /**
		 * Clones an array.
		 * @param array Array to clone.
		 * @return a cloned array.
		 */
    public static function cloneArray(array : Array<Dynamic>) : Array<Dynamic>
    {
        var newArray : Array<Dynamic> = [];
        
        for (item in array)
        {
            newArray.push(item);
        }
        
        return newArray;
    }
    
    /**
     * Take a radian measure and make sure it is between -pi..pi.
     */
    public static function unwrapRadian(r : Float) : Float
    {
        r = r % Math.PI;
        if (r > Math.PI)
        {
            r -= TWO_PI;
        }
        if (r < -Math.PI)
        {
            r += TWO_PI;
        }
        return r;
    }
    
    /**
     * Take a degree measure and make sure it is between 0..360.
     */
    public static function unwrapDegrees(r : Float) : Float
    {
        r = r % 360;
        if (r > 180)
        {
            r -= 360;
        }
        if (r < -180)
        {
            r += 360;
        }
        return r;
    }
    
    /**
     * Return the shortest distance to get from from to to, in radians.
     */
    public static function getRadianShortDelta(from : Float, to : Float) : Float
    {
        // Unwrap both from and to.
        from = unwrapRadian(from);
        to = unwrapRadian(to);
        
        // Calc delta.
        var delta : Float = to - from;
        
        // Make sure delta is shortest path around circle.
        if (delta > Math.PI)
        {
            delta -= Math.PI * 2;
        }
        if (delta < -Math.PI)
        {
            delta += Math.PI * 2;
        }
        
        // Done
        return delta;
    }
    
    /**
     * Return the shortest distance to get from from to to, in degrees.
     */
    public static function getDegreesShortDelta(from : Float, to : Float) : Float
    {
        // Unwrap both from and to.
        from = unwrapDegrees(from);
        to = unwrapDegrees(to);
        
        // Calc delta.
        var delta : Float = to - from;
        
        // Make sure delta is shortest path around circle.
        if (delta > 180)
        {
            delta -= 360;
        }
        if (delta < -180)
        {
            delta += 360;
        }
        
        // Done
        return delta;
    }
    
    /**
     * Get number of bits required to encode values from 0..max.
     *
     * @param max The maximum value to be able to be encoded.
     * @return Bitcount required to encode max value.
     */
    public static function getBitCountForRange(max : Int) : Int
    {
        // TODO: Make this use bits and be fast.
        return Math.ceil(Math.log(max) / Math.log(2.0));
    }
    
    /**
     * Pick an integer in a range, with a bias factor (from -1 to 1) to skew towards
     * low or high end of range.
     *  
     * @param min Minimum value to choose from, inclusive.
     * @param max Maximum value to choose from, inclusive.
     * @param bias -1 skews totally towards min, 1 totally towards max.
     * @return A random integer between min/max with appropriate bias.
     * 
     */
    public static function pickWithBias(min : Int, max : Int, bias : Float = 0) : Int
    {
        return clamp(((Math.random() + bias) * (max - min)) + min, min, max);
    }
    
    /**
     * Assigns parameters from source to destination by name.
     * 
     * <p>This allows duck typing - you can accept a generic object
     * (giving you nice {foo:bar} syntax) and cast to a typed object for
     * easier internal processing and validation.</p>
     * 
     * @param source Object to read fields from.
     * @param dest Object to assign fields to.
     * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
     * 
     */
    public static function duckAssign(source : Dynamic, destination : Dynamic, abortOnMismatch : Bool = false) : Void
    {
        for (field in Reflect.fields(source))
        {
            try
            {
                // Try to assign.
                Reflect.setField(destination, field, Reflect.field(source, field));
            }
            catch (e)
            {
                // Abort or continue, depending on user settings.
                if (!abortOnMismatch)
                {
                    continue;
                }
                throw new Error("Field '" + field + "' in source was not present in destination.");
            }
        }
    }
    
    /**
     * Calculate length of a vector. 
     */
    public static function xyLength(x : Float, y : Float) : Float
    {
        return Math.sqrt((x * x) + (y * y));
    }
    
    /**
		 * Replaces instances of less then, greater then, ampersand, single and double quotes.
		 * @param str String to escape.
		 * @return A string that can be used in an htmlText property.
		 */
    public static function escapeHTMLText(str : String) : String
    {
        var chars : Array<Dynamic> = 
        [
        {
            char : "&",
            repl : "|amp|"
        }, 
        {
            char : "<",
            repl : "&lt;"
        }, 
        {
            char : ">",
            repl : "&gt;"
        }, 
        {
            char : "\'",
            repl : "&apos;"
        }, 
        {
            char : "\"",
            repl : "&quot;"
        }, 
        {
            char : "|amp|",
            repl : "&amp;"
        }
    ];
        
        for (i in 0...chars.length)
        {
            while (str.indexOf(chars[i].char) != -1)
            {
                str = str.replace(chars[i].char, chars[i].repl);
            }
        }
        
        return str;
    }
    
    /**
     * Determine the file extension of a file. 
     * @param file A path to a file.
     * @return The file extension.
     * 
     */
    public static function getFileExtension(file : String) : String
    {
        var extensionIndex : Float = file.lastIndexOf(".");
        if (extensionIndex == -1)
        {
            //No extension
            return "";
        }
        else
        {
            return file.substr(extensionIndex + 1, file.length);
        }
    }
    
    /**
		 * Method for flipping a DisplayObject 
		 * @param obj DisplayObject to flip
		 * @param orientation Which orientation to use: PBUtil.FLIP_HORIZONTAL or PBUtil.FLIP_VERTICAL
		 * 
		 */
    public static function flipDisplayObject(obj : DisplayObject, orientation : String) : Void
    {
        var m : Matrix = obj.transform.matrix;
        
        switch (orientation)
        {
            case FLIP_HORIZONTAL:
                m.a = -1;
                m.tx = obj.width + obj.x;
            case FLIP_VERTICAL:
                m.d = -1;
                m.ty = obj.height + obj.y;
        }
        
        obj.transform.matrix = m;
    }
    
    /**
     * Log an object to the console. Based on http://dev.base86.com/solo/47/actionscript_3_equivalent_of_phps_printr.html 
     * @param thisObject Object to display for logging.
     * @param obj Object to dump.
     */
    public static function dumpObjectToLogger(thisObject : Dynamic, obj : Dynamic, level : Int = 0, output : String = "") : String
    {
        var tabs : String = "";
        for (i in 0...level)
        {
            tabs += "\t";
        }
        
        for (child in Reflect.fields(obj))
        {
            output += tabs + "[" + child + "] => " + Reflect.field(obj, child);
            
            var childOutput : String = dumpObjectToLogger(thisObject, Reflect.field(obj, child), level + 1);
            if (childOutput != "")
            {
                output += " {\n" + childOutput + tabs + "}";
            }
            
            output += "\n";
        }
        
        if (level == 0)
        {
            Logger.print(thisObject, output);
            return "";
        }
        
        return output;
    }

    public function new()
    {
    }
}
