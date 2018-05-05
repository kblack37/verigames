package display;

import flash.geom.Point;
import flash.geom.Rectangle;
import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import utils.XMath;

class ScrollBarThumb extends ImageStateButton
{
    private static inline var MAX_DRAG_DIST : Float = 50;
    
    private var minYPosition : Float;
    private var maxYPosition : Float;
    
    private var startYPosition : Float;
    private var startYClickPoint : Float;
    
    public function new(minYPos : Float, maxYPos : Float)
    {
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml");
        var thumbUp : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_Thumb);
        var thumbOver : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_ThumbOver);
        var thumbDown : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_ThumbSelected);
        
        var thumbUpImage : Image = new Image(thumbUp);
        var thumbOnOverImage : Image = new Image(thumbOver);
        var thumbOnDownImage : Image = new Image(thumbDown);
        
        super(
                [thumbUpImage], 
                [thumbOnOverImage], 
                [thumbOnDownImage]
        );
        
        width = width / 2;
        height = height / 2;
        
        minYPosition = minYPos;
        maxYPosition = maxYPos - height;
        
        y = minYPosition;
        
        
        addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    private var mEnabled : Bool = true;
    private var mIsDown : Bool = false;
    private var mIsHovering : Bool = false;
    override private function onTouch(event : TouchEvent) : Void
    {
        if (enabled == false)
        {
            return;
        }
        
        var touch : Touch = event.getTouch(this);
        
        if (touch == null)
        {
            mIsHovering = false;
            toState(m_up);
        }
        else if (touch.phase == TouchPhase.BEGAN)
        {
            mIsHovering = false;
            if (!mIsDown)
            {
                startYPosition = y;
                startYClickPoint = touch.getLocation(parent).y;
                toState(m_down);
                mIsDown = true;
            }
        }
        else if (touch.phase == TouchPhase.HOVER)
        {
            if (!mIsHovering)
            {
                toState(m_over);
            }
            mIsHovering = true;
            mIsDown = false;
        }
        else if (touch.phase == TouchPhase.MOVED && mIsDown)
        {
        // reset button when user dragged too far away after pushing
            
            var currentPosition : Point = touch.getLocation(parent);
            
            var buttonRect : Rectangle = getBounds(stage);
            if (currentPosition.x < x - MAX_DRAG_DIST ||
                currentPosition.x > x + MAX_DRAG_DIST ||
                currentPosition.y > minYPosition - MAX_DRAG_DIST ||
                currentPosition.y < maxYPosition + MAX_DRAG_DIST)
            {
                toState(m_down);
                
                //find the difference between old and new click position here, apply to y position
                y = startYPosition + (currentPosition.y - startYClickPoint);
                y = XMath.clamp(y, minYPosition, maxYPosition);
                
                dispatchEvent(new Event(Event.TRIGGERED, true, (y - minYPosition) / (maxYPosition - minYPosition)));
            }
            else
            {
                toState(m_up);
                y = startYPosition;
                
                dispatchEvent(new Event(Event.TRIGGERED, true, y / (maxYPosition - minYPosition)));
            }
        }
        else if (touch.phase == TouchPhase.ENDED)
        {
            toState(m_up);
            mIsHovering = false;
        }
        else
        {
            toState(m_up);
        }
    }
    
    public function setThumbPercent(percent : Float) : Void
    {
        percent = XMath.clamp(percent, 0, 100);
        y = (maxYPosition - minYPosition) * (percent / 100) + minYPosition;
    }
}

