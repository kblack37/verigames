package utils;

import haxe.Constraints.Function;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
//import starling.display.graphics.Fill;
//import starling.display.graphics.NGon;
//import starling.display.graphics.Stroke;
import starling.events.Event;
import starling.display.Quad;

class XSprite
{
    public static function extractRed(cc : Int) : Int
    {
        return as3hx.Compat.parseInt(as3hx.Compat.parseInt(cc >> 16) & 0xFF);
    }
    
    public static function extractGreen(cc : Int) : Int
    {
        return as3hx.Compat.parseInt(as3hx.Compat.parseInt(cc >> 8) & 0xFF);
    }
    
    public static function extractBlue(cc : Int) : Int
    {
        return as3hx.Compat.parseInt(cc & 0xFF);
    }
    
    private static function toByte(nn : Int) : Int
    {
        return Std.int(Math.max(0, Math.min(255, nn * 255)));
    }
    
    public static function toColor(rr : Int, gg : Int, bb : Int) : Int
    {
        return as3hx.Compat.parseInt((toByte(rr) << 16) | (toByte(gg) << 8) | toByte(bb));
    }
    
    public static function scaleColor(scale : Float, cc : Int) : Int
    {
        return toColor(
                Std.int(scale * extractRed(cc) / 255.0), 
                Std.int(scale * extractGreen(cc) / 255.0), 
                Std.int(scale * extractBlue(cc) / 255.0)
        );
    }
    
    public static function removeAllChildren(doc : DisplayObjectContainer) : Void
    {
        while (doc.numChildren > 0)
        {
            doc.removeChildAt(0);
        }
    }
    
    public static function setupDisplayObject(obj : DisplayObject, x : Float, y : Float, sz : Float) : Void
    {
        obj.x = x;
        obj.y = y;
        obj.scaleX = obj.scaleY = (sz / Math.max(obj.width, obj.height));
    }
    
    public static function eventCallbackWrapper(func : Function, arg : Dynamic) : Function
    {
        return function(ev : Event) : Void
        {
            Reflect.callMethod(null, func, [ev, arg]);
        };
    }
    
    public static function eventCallbackWrapper2(func : Function, arg0 : Dynamic, arg1 : Dynamic) : Function
    {
        return function(ev : Event) : Void
        {
            Reflect.callMethod(null, func, [ev, arg0, arg1]);
        };
    }
    
    public static function setPivotCenter(obj : DisplayObject) : Void
    {
        obj.pivotX = as3hx.Compat.parseInt(obj.width / 2);
        obj.pivotY = as3hx.Compat.parseInt(obj.height / 2);
    }
    
    public static function createPolyLine(x0 : Float, y0 : Float, x1 : Float, y1 : Float, color : Int, thickness : Int, alpha : Float = 1.0) : DisplayObject
    {
		/*
        var stroke : Stroke = new Stroke();
        stroke.addVertex(x0, y0, thickness, color, alpha, color, alpha);
        stroke.addVertex(x1, y1, thickness, color, alpha, color, alpha);
        return stroke; TODO find stroke replacement*/
		return new Quad(x0, x1, color);
    }
    
    public static function createPolyRect(width : Float, height : Float, color : Int, thickness : Int, alpha : Float = 1.0) : DisplayObject
    {
        if (thickness == 0)
        {
			/*
            var fill : Fill = new Fill();
            fill.addVertex(0, 0, color, alpha);
            fill.addVertex(0, height, color, alpha);
            fill.addVertex(width, height, color, alpha);
            fill.addVertex(width, 0, color, alpha);
            return fill;TODO does this work?
			*/
			var quad : Quad = new Quad(width, height, color);
			return quad;
        }
        else
        {
			/*
            var stroke : Stroke = new Stroke();
            stroke.addVertex(0, 0, thickness, color, alpha, color, alpha);
            stroke.addVertex(0, height, thickness, color, alpha, color, alpha);
            stroke.addVertex(width, height, thickness, color, alpha, color, alpha);
            stroke.addVertex(width, 0, thickness, color, alpha, color, alpha);
            stroke.addVertex(0, 0, thickness, color, alpha, color, alpha);
            return stroke;
			*/
			 return new Quad(width, height, color);
        }
    }
    
    public static function createPolyCircle(radius : Float, color : Int, thickness : Int, alpha : Float = 1.0) : DisplayObject
    {
		/*
        var SECTIONS : Int = 16;
        var ii : Int;
        var ang : Float;
        var ngon : NGon;
        
        if (thickness == 0)
        {
            ngon = new NGon(radius, SECTIONS);
        }
        else
        {
            ngon = new NGon(radius + thickness / 2, SECTIONS, radius - (thickness + 1) / 2);
        }
        
        ngon.material.color = color;
        ngon.material.alpha = alpha;
        return ngon;
		TODO find ngon replacement*/
		return new Quad(radius, thickness, color);
    }

    public function new()
    {
    }
}

