package utilities;

import haxe.Constraints.Function;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.ColorTransform;

class XSprite
{
    /**
		 * Tiles one sprite onto another according to the dimensions given (no scaling)
		 * @param	ontoSprite Sprite to tile onto.
		 * @param	tileData BitmapData to use for tiling.
		 * @param	startX Starting x coordinate to tile.
		 * @param	startY Starting y coordinate to tile.
		 * @param	widthToTile Overall width of the area to tile.
		 * @param	heightToTile Overall height of the area to tile.
		 * @param	randomizeOffsets Set to true to start at a random X,Y offset in the top left corner, set to false to begin at 0,0
		 */
    public static function tileToSprite(ontoSprite : Sprite, tileData : BitmapData, startX : Float, startY : Float, widthToTile : Float, heightToTile : Float, randomizeOffsets : Bool = false) : Void
    {
        var curX : Float = Math.floor(startX / tileData.width) * tileData.width;
        var curY : Float = Math.floor(startY / tileData.height) * tileData.height;
        if (randomizeOffsets)
        {
            curX += Math.floor(-tileData.width * Math.random());
            curY += Math.floor(-tileData.height * Math.random());
        }
        
        var origX : Float = curX;
        var origY : Float = curY;
        while (curX - startX < Math.max(tileData.width, widthToTile) + 10)
        {
            while (curY - startY < Math.max(tileData.height, heightToTile) + 10)
            {
                var bmp : Bitmap = new Bitmap(tileData);
                bmp.x = curX;
                bmp.y = curY;
                ontoSprite.addChild(bmp);
                
                curY += tileData.height - 1;
            }
            curX += tileData.width - 1;
            curY = origY;
        }
    }
    
    /**
		 * Scales r-g-b channels by 'scale' factor, having the r-g-b proportions saved
		 * @param   color:uint      color to be scaled (i.e. lighten or darken)
		 * @param   scale:Number    the scale factor (values -1 to 1) -1 = absolute dark; 1 = absolute light;
		 * @return  uint            scaled color
		 */
    public static function scaleColor(color : Int, scale : Float) : Int
    {
        var r : Int = as3hx.Compat.parseInt(color & 0xFF0000) >> 16;
        var g : Int = as3hx.Compat.parseInt(color & 0x00FF00) >> 8;
        var b : Int = color & 0x0000FF;
        r += as3hx.Compat.parseInt((255 * scale) * (r / (r + g + b)));r = ((r > 255)) ? 255 : r;r = ((r < 0)) ? 0 : r;
        g += as3hx.Compat.parseInt((255 * scale) * (g / (r + g + b)));g = ((g > 255)) ? 255 : g;g = ((g < 0)) ? 0 : g;
        b += as3hx.Compat.parseInt((255 * scale) * (b / (r + g + b)));b = ((b > 255)) ? 255 : b;b = ((b < 0)) ? 0 : b;
        return as3hx.Compat.parseInt((as3hx.Compat.parseInt(r << 16) & 0xff0000) + (as3hx.Compat.parseInt(g << 8) & 0x00ff00) + (b & 0x0000ff));
    }
    
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
    
    public static function applyColorTransform(obj : DisplayObject, color : Int) : Void
    {
        var trans : ColorTransform = obj.transform.colorTransform;
        trans.redMultiplier = extractRed(color) / 255.0;
        trans.greenMultiplier = extractGreen(color) / 255.0;
        trans.blueMultiplier = extractBlue(color) / 255.0;
        obj.transform.colorTransform = trans;
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
    
    public static function selectChild(obj : MovieClip, selectName : String, childNames : Array<String>) : MovieClip
    {
        for (checkChild in childNames)
        {
            if (checkChild != selectName)
            {
                obj.removeChild(Reflect.field(obj, checkChild));
            }
        }
        return obj;
    }
    
    public static function callbackWrapper(func : Function, levelInfo : Dynamic) : Function
    {
        return function(ev : Event) : Void
        {
            Reflect.callMethod(null, func, [levelInfo]);
        };
    }
    
    /**
		 * Call a function for each state in a button.
		 * @param	btn Button to call function on.
		 * @param	hitTestState If true, button's hitTestState is included in the list, otherwise, it's not.
		 * @param	func Callback function, called with each button state.
		 */
    public static function forEachButtonState(btn : SimpleButton, hitTestState : Bool, func : Function) : Void
    {
        var states : Array<Dynamic>;
        if (hitTestState)
        {
            states = [btn.upState, btn.overState, btn.downState, btn.hitTestState];
        }
        else
        {
            states = [btn.upState, btn.overState, btn.downState];
        }
        
        for (state in states)
        {
            func(state);
        }
    }

    public function new()
    {
    }
}

