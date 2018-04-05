package scenes;

import haxe.Constraints.Function;
import flash.display3D.Context3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import assets.AssetInterface;
import display.NineSliceToggleButton;
import display.RadioButton;
import display.ToolTippableSprite;
import scenes.game.components.GridViewPanel;
import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.errors.MissingContextError;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class BaseComponent extends ToolTippableSprite
{
    public var clipRect(get, set) : Rectangle;

    private var mClipRect : Rectangle;
    
    //initalized in Game
    private static var loadingAnimationImages : Array<Texture> = null;
    private static var waitAnimationImages : Array<Texture> = null;
    
    private var busyAnimationMovieClip : MovieClip;
    
    //for selection color
    private var helperPoint : Point = new Point(0, 0);
    private var STARTING_ROTATION : Float = -54;
    private var ROTATION_MULTIPLIER : Float = 2.05;
    
    //useful for debugging resource issues
    public static var nextIndex : Int = 0;
    public var objectIndex : Int;
    
    public function new()
    {
        objectIndex = nextIndex++;
        super();
    }
    
    override public function dispose() : Void
    {
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
    
    public function handleUndoEvent(undoEvent : starling.events.Event, isUndo : Bool = true) : Void
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
    
    private function createPaintBrushButton(style : String, onClickFunction : Function, toolTipText : String = "") : Sprite
    {
        var paintBrushButton : NineSliceToggleButton = ButtonFactory.getInstance().createDefaultToggleButton("", 25, 25, toolTipText);
        
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        var buttonTexture : Texture = atlas.getTexture("Button" + style);
        var image : Image = new Image(buttonTexture);
        image.width = image.height = 25;
        image.x = image.y = -.5;
        var sbuttonTexture : Texture = atlas.getTexture("Button" + style + "Over");  // "Click" and "Over" are the same icon  
        //just use one, so I don't have to line them both up exactly
        var simage : Image = new Image(sbuttonTexture);
        simage.width = simage.height = 25;
        simage.x = simage.y = -.5;
        var obuttonTexture : Texture = atlas.getTexture("Button" + style + "Over");
        var oimage : Image = new Image(obuttonTexture);
        oimage.width = oimage.height = 25;
        oimage.x = oimage.y = -.5;
        paintBrushButton.setIcon(image, simage, oimage);
        
        paintBrushButton.useHandCursor = true;
        paintBrushButton.addEventListener(Event.TRIGGERED, onClickFunction);
        
        paintBrushButton.name = style;
        
        return paintBrushButton;
    }
    
    private function createPaintBrush(style : String) : Sprite
    {
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        var brushTexture : Texture = atlas.getTexture(style);
        var brushImage : Image = new Image(brushTexture);
        brushImage.width = brushImage.height = 2 * GridViewPanel.PAINT_RADIUS;
        brushImage.x = -0.5 * brushImage.width;
        brushImage.y = -0.5 * brushImage.height;
        brushImage.alpha = 0.9;
        var selectionDisplayArc : Sprite = new Sprite();
        
        var paintBrush : Sprite = new Sprite();
        
        var selectionColorTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_BrushSelectionColor);
        //Assume these are about 10% of the total length, so make 10
        for (i in 0...10)
        {
            var selectionColorImage : Image = new Image(selectionColorTexture);
            selectionColorImage.width = selectionColorImage.height = 2 * GridViewPanel.PAINT_RADIUS;
            
            selectionColorImage.x = brushImage.x;
            selectionColorImage.y = brushImage.y;
            paintBrush.addChild(selectionColorImage);
            rotateToDegree(selectionColorImage, helperPoint, STARTING_ROTATION);
        }
        
        //do same thing with solver color
        var solverColorTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_BrushSolverColor);
        //Assume these are about 10% of the total length, so make 10
        for (ii in 0...10)
        {
            var solverColorImage : Image = new Image(solverColorTexture);
            solverColorImage.width = solverColorImage.height = 2 * GridViewPanel.PAINT_RADIUS;
            
            solverColorImage.x = brushImage.x;
            solverColorImage.y = brushImage.y;
            paintBrush.addChild(solverColorImage);
            rotateToDegree(solverColorImage, helperPoint, STARTING_ROTATION);
        }
        //add last
        paintBrush.addChild(brushImage);
        paintBrush.name = style;
        
        return paintBrush;
    }
    
    public var degConversion : Float = (Math.PI / 180);
    public function rotateToDegree(image : Image, currentCenter : Point, angleDegrees : Float) : Void
    {
        image.rotation = degConversion * angleDegrees;
        var newXCenter : Float = image.bounds.left + (image.bounds.right - image.bounds.left) / 2;
        var newYCenter : Float = image.bounds.top + (image.bounds.bottom - image.bounds.top) / 2;
        image.x += currentCenter.x - newXCenter;
        image.y += currentCenter.y - newYCenter;
    }
}
