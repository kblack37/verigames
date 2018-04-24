package scenes.game.display;

import flash.errors.Error;
import assets.AssetInterface;
import events.EdgeContainerEvent;
import events.MoveEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import graph.PropDictionary;
import openfl.Vector;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import utils.XMath;
import utils.XSprite;

class GameEdgeSegment extends GameComponent
{
    private var m_quad : Quad;
    
    public var m_endPt : Point;
    public var m_currentRect : Rectangle;
    public var updatePoint : Point;
    
    public var m_isInnerBoxSegment : Bool;
    public var m_isFirstSegment : Bool;
    public var m_isLastSegment : Bool;
    public var m_dir : String;
    
    public var currentTouch : Touch;
    public var currentDragSegment : Bool = false;
    private var m_props : PropDictionary;
    
    public function new(_dir : String, _isInnerBoxSegment : Bool = false, _isFirstSegment : Bool = false, _isLastSegment : Bool = false, _isWide : Bool = false, _isEditable : Bool = false, _draggable : Bool = true, _props : PropDictionary = null, _propMode : String = PropDictionary.PROP_NARROW)
    {
        super("");
        draggable = _draggable;
        if (_props != null)
        {
            m_props = _props;
        }
        m_propertyMode = _propMode;
        m_isWide = _isWide;
        m_dir = _dir;
        m_isInnerBoxSegment = _isInnerBoxSegment;
        m_isFirstSegment = _isFirstSegment;
        m_isLastSegment = _isLastSegment;
        
        m_isDirty = false;
        m_endPt = new Point(0, 0);
        
        m_isEditable = _isEditable;
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addEventListener(TouchEvent.TOUCH, onTouch);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onAddedToStage(event : starling.events.Event) : Void
    //		this.blendMode = BlendMode.NONE;
    {
        
        m_isDirty = true;
    }
    
    override public function dispose() : Void
    //if we are the currentDragSegment we will be re-added, so keep original values
    {
        
        if (m_disposed || currentDragSegment)
        {
            return;
        }
        
        if (hasEventListener(Event.ENTER_FRAME))
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        if (hasEventListener(TouchEvent.TOUCH))
        {
            removeEventListener(TouchEvent.TOUCH, onTouch);
        }
        disposeChildren();
        super.dispose();
    }
    
    public var returnLocation : Point;
    private var isMoving : Bool = false;
    private var hasMovedOutsideClickDist : Bool = false;
    private var startingPoint : Point;
    private static inline var CLICK_DIST : Float = 0.2;  //for extensions, register distance dragged  
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Vector<Touch> = event.touches;
        if (touches.length == 0)
        {
            return;
        }
        
        if (GameComponent.DEBUG_TRACE_IDS && event.getTouches(this, TouchPhase.ENDED).length > 0&& parent != null && (Std.is(parent, GameComponent)))
        {
            trace("EdgeContainer '" + (try cast(parent, GameComponent) catch(e:Dynamic) null).m_id + "'");
        }
        
        if (m_isInnerBoxSegment && event.getTouches(this, TouchPhase.ENDED).length > 0 &&
            (!isMoving || !hasMovedOutsideClickDist))
        {
        // If haven't moved enough, register this as a click on the node itself
            
            dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.INNER_SEGMENT_CLICKED, this, null, event.touches));
        }
        if (!draggable)
        {
            return;
        }
        
        var touch : Touch = touches[0];
        if (event.getTouches(this, TouchPhase.MOVED).length > 0)
        {
            if (touches.length == 1)
            {
                var touchXY : Point = new Point(touch.globalX, touch.globalY);
                touchXY = this.globalToLocal(touchXY);
                if (!isMoving)
                {
                    startingPoint = touchXY;
                    dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.SAVE_CURRENT_LOCATION, this));
                    isMoving = true;
                    hasMovedOutsideClickDist = false;
                    return;
                }
                else if (!hasMovedOutsideClickDist)
                {
                    if (XMath.getDist(startingPoint, touchXY) > CLICK_DIST * Constants.GAME_SCALE)
                    {
                        hasMovedOutsideClickDist = true;
                    }
                    // Don't move if haven't moved outside CLICK_DIST
                    else
                    {
                        
                        return;
                    }
                }
                
                var currentMoveLocation : Point = touch.getLocation(this);
                var previousLocation : Point = touch.getPreviousLocation(this);
                updatePoint = currentMoveLocation.subtract(previousLocation);
                currentDragSegment = true;
                dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.RUBBER_BAND_SEGMENT, this));
                currentDragSegment = false;
            }
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            if (touches.length == 1)
            {
                m_isDirty = true;
                
                if (isMoving)
                {
                    isMoving = false;
                    dispatchEvent(new MoveEvent(MoveEvent.FINISHED_MOVING, this));
                    if (m_isInnerBoxSegment || m_isFirstSegment || m_isLastSegment)
                    {
                        dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.RESTORE_CURRENT_LOCATION, this));
                        dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OUT, this));
                    }
                }
            }
            
            if (touch.tapCount == 2)
            {
                this.currentTouch = touch;
                if (!m_isInnerBoxSegment)
                {
                    dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.CREATE_JOINT, this));
                }
            }
        }
        else if (event.getTouches(this, TouchPhase.HOVER).length > 0)
        {
            if (touches.length == 1)
            {
                m_isDirty = true;
                dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OVER, this));
            }
        }
        else if (event.getTouches(this, TouchPhase.BEGAN).length > 0)
        {
            trace(touches[0].target);
        }
        else
        {
            m_isDirty = true;
            if (isMoving)
            {
                isMoving = false;
                dispatchEvent(new MoveEvent(MoveEvent.FINISHED_MOVING, this));
            }
            dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OUT, this));
        }
    }
    
    public function updateSegment(startPt : Point, endPt : Point) : Void
    {
        m_endPt = endPt.subtract(startPt);
        m_isDirty = true;
    }
    
    public function draw() : Void
    {
        if (m_quad != null)
        {
            m_quad.removeFromParent(true);
            m_quad = null;
        }
        
        if ((m_propertyMode != PropDictionary.PROP_NARROW) && getProps().hasProp(m_propertyMode))
        {
            m_quad = createEdgeSegment(m_endPt, m_isWide, false);
            m_quad.color = BaseComponent.KEYFOR_COLOR;
        }
        else
        {
            m_quad = createEdgeSegment(m_endPt, m_isWide, m_isEditable);
            if (isHoverOn)
            {
                m_quad.color = 0xeeeeee;
            }
            else
            {
                m_quad.color = 0xcccccc;
            }
        }
        
        addChild(m_quad);
    }
    
    public static function createEdgeSegment(_toPt : Point, _isWide : Bool, _isEditable : Bool) : Image
    {
        var lineSize : Float = (_isWide) ? GameEdgeContainer.WIDE_WIDTH : GameEdgeContainer.NARROW_WIDTH;
        var assetName : String;
        if (_toPt.x != 0 && _toPt.y != 0)
        {
            throw new Error("Diagonal lines deprecated. Segment from to " + _toPt);
        }
        var isHoriz : Bool = (_toPt.x != 0);
        
        if (_isEditable == true)
        {
            if (_isWide == true)
            {
                assetName = AssetInterface.PipeJamSubTexture_BlueDarkSegmentPrefix;
            }
            else
            {
                assetName = AssetInterface.PipeJamSubTexture_BlueLightSegmentPrefix;
            }
        }
        //not adjustable
        else
        {
            
            {
                if (_isWide == true)
                {
                    assetName = AssetInterface.PipeJamSubTexture_GrayDarkSegmentPrefix;
                }
                else
                {
                    assetName = AssetInterface.PipeJamSubTexture_GrayLightSegmentPrefix;
                }
            }
        }
        assetName += (isHoriz) ? "Horiz" : "Vert";
        
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        var segmentTexture : Texture = atlas.getTexture(assetName);
        
        var pctTextWidth : Float;
        var pctTextHeight : Float;
        var newSegment : Image = new Image(segmentTexture);
        
        if (isHoriz)
        {
        // Horizontal
            
            if (GameEdgeContainer.EDGES_OVERLAPPING_JOINTS)
            {
                newSegment.width = Math.abs(_toPt.x);
            }
            else
            {
                newSegment.width = Math.max(.1, Math.abs(_toPt.x) - lineSize);
            }
            newSegment.height = lineSize;
            
            newSegment.x = ((_toPt.x > 0)) ? 0 : -newSegment.width;
            newSegment.y = -lineSize / 2.0;
        }
        // Vertical
        else
        {
            
            newSegment.width = lineSize;
            if (GameEdgeContainer.EDGES_OVERLAPPING_JOINTS)
            {
                newSegment.height = Math.abs(_toPt.y);
            }
            else
            {
                newSegment.height = Math.max(.1, Math.abs(_toPt.y) - lineSize);
            }
            
            newSegment.x = -lineSize / 2.0;
            newSegment.y = ((_toPt.y > 0)) ? 0 : -newSegment.height;
        }
        
        return newSegment;
    }
    
    public function onEnterFrame(event : Event) : Void
    {
        if (m_isDirty)
        {
            draw();
            m_isDirty = false;
        }
    }
    
    public function onDeleted() : Void
    {
        dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.SEGMENT_DELETED, this));
    }
    
    // Make lines slightly darker to be more visible
    override public function getColor() : Int
    {
        var color : Int = super.getColor();
        var red : Int = XSprite.extractRed(color);
        var green : Int = XSprite.extractGreen(color);
        var blue : Int = XSprite.extractBlue(color);
        return as3hx.Compat.parseInt((Math.round(red * 0.8) << 16) | (Math.round(green * 0.8) << 8) | Math.round(blue * 0.8));
    }
}
