package scenes;

import display.ToolTippableSprite;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.errors.MissingContextError;
import starling.textures.Texture;
import starling.events.Event;
import starling.display.MovieClip;
import starling.display.DisplayObjectContainer;

class BaseComponent extends ToolTippableSprite
{
    public var clipRect(get, set) : Rectangle;

    private var mClipRect : Rectangle;
    
    private var m_disposed : Bool;
    
    //initalized in Game
    private static var loadingAnimationImages : Array<Texture> = null;
    private static var waitAnimationImages : Array<Texture> = null;
    
    private var busyAnimationMovieClip : MovieClip;
    public static inline var KEYFOR_COLOR : Int = 0xFF00FF;
    
    //useful for debugging resource issues
    public static var nextIndex : Int = 0;
    public var objectIndex : Int;
    
    public function new()
    {
        objectIndex = nextIndex++;
        m_disposed = false;
        super();
    }
    
    override public function dispose() : Void
    {
        if (m_disposed)
        {
            return;
        }
        m_disposed = true;
        disposeChildren();
        super.dispose();
    }
    
    public function disposeChildren() : Void
    {
        while (this.numChildren > 0)
        {
            var obj : DisplayObject = getChildAt(0);
            if (Std.is(obj, BaseComponent))
            {
                (try cast(obj, BaseComponent) catch(e:Dynamic) null).disposeChildren();
            }
            obj.removeFromParent(true);
        }
    }
    
    override public function render(support : RenderSupport, alpha : Float) : Void
    {
        if (mClipRect == null)
        {
            super.render(support, alpha);
        }
        else
        {
            var context : Context3D = Starling.context;
            if (context == null)
            {
                throw new MissingContextError();
            }
            
            support.finishQuadBatch();
            support.scissorRectangle = mClipRect;
            
            super.render(support, alpha);
            
            support.finishQuadBatch();
            support.scissorRectangle = null;
        }
    }
    
    override public function hitTest(localPoint : Point, forTouch : Bool = false) : DisplayObject
    // without a clip rect, the sprite should behave just like before
    {
        
        if (mClipRect == null)
        {
            return super.hitTest(localPoint, forTouch);
        }
        
        // on a touch test, invisible or untouchable objects cause the test to fail
        if (forTouch && (!visible || !touchable))
        {
            return null;
        }
        
        if (mClipRect.containsPoint(localToGlobal(localPoint)))
        {
            return super.hitTest(localPoint, forTouch);
        }
        else
        {
            return null;
        }
    }
    
    private function get_clipRect() : Rectangle
    {
        return mClipRect;
    }
    private function set_clipRect(value : Rectangle) : Rectangle
    {
        if (value != null)
        {
            if (mClipRect == null)
            {
                mClipRect = value.clone();
            }
            else
            {
                mClipRect.setTo(value.x, value.y, value.width, value.height);
            }
        }
        else
        {
            mClipRect = null;
        }
        return value;
    }
    
    //use this to force the size of the object
    //it adds a 'transparent' image of the specified size (you can make it non-transparent by changing the alpha value.)
    public function setPosition(_x : Float, _y : Float, _width : Float, _height : Float, _alpha : Float = 0.0, _color : Float = 0x000000) : Void
    {
        this.x = _x;
        this.y = _y;
    }
    
    public function handleUndoEvent(undoEvent : Event, isUndo : Bool = true) : Void
    {
    }
    
    public function startBusyAnimation(animationParent : DisplayObjectContainer = null) : MovieClip
    {
        busyAnimationMovieClip = new MovieClip(loadingAnimationImages, 4);
        
        if (animationParent == null)
        {
            busyAnimationMovieClip.x = (Constants.GameWidth - busyAnimationMovieClip.width) / 2;
            busyAnimationMovieClip.y = (Constants.GameHeight - busyAnimationMovieClip.height) / 2;
            addChild(busyAnimationMovieClip);
        }
        else
        {
            busyAnimationMovieClip.x = (animationParent.width - busyAnimationMovieClip.width) / 2;
            busyAnimationMovieClip.y = (animationParent.height - busyAnimationMovieClip.height) / 2;
            animationParent.addChild(busyAnimationMovieClip);
        }
        Starling.juggler.add(this.busyAnimationMovieClip);
        
        return busyAnimationMovieClip;
    }
    
    public function stopBusyAnimation() : Void
    {
        if (busyAnimationMovieClip != null)
        {
            removeChild(busyAnimationMovieClip);
            Starling.juggler.remove(this.busyAnimationMovieClip);
            
            busyAnimationMovieClip.dispose();
            busyAnimationMovieClip = null;
        }
    }
}
