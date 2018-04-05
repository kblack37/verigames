package display
{
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
	
	public class ScrollBarThumb extends ImageStateButton
	{
		protected static const MAX_DRAG_DIST:Number = 50;
		
		protected var minYPosition:Number;
		protected var maxYPosition:Number;
		
		protected var startYPosition:Number;
		protected var startYClickPoint:Number;
		
		public function ScrollBarThumb(minYPos:Number, maxYPos:Number)
		{
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
			var thumbUp:Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_Thumb);
			var thumbOver:Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_ThumbOver);
			var thumbDown:Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_ThumbSelected);
			
			var thumbUpImage:Image = new Image(thumbUp);
			var thumbOnOverImage:Image = new Image(thumbOver);
			var thumbOnDownImage:Image = new Image(thumbDown);
			
			super(
				Vector.<DisplayObject>([thumbUpImage]),
				Vector.<DisplayObject>([thumbOnOverImage]),
				Vector.<DisplayObject>([thumbOnDownImage])
			);
			
			width = width/2;
			height = height/2;
			
			minYPosition = minYPos;
			maxYPosition = maxYPos-height;
			
			y = minYPosition;

			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		protected var mEnabled:Boolean = true;
		protected var mIsDown:Boolean = false;
		protected var mIsHovering:Boolean = false;
		protected override function onTouch(event:TouchEvent):void
		{
			if(enabled == false)
				return;
			
			var touch:Touch = event.getTouch(this);
			
			if (touch == null)
			{
				mIsHovering = false;
				toState(m_up);
			}
			else if (touch.phase == TouchPhase.BEGAN)
			{
				mIsHovering = false;
				if (!mIsDown) {
					startYPosition = y;
					startYClickPoint = touch.getLocation(parent).y;
					toState(m_down);
					mIsDown = true;
				}
			}
			else if (touch.phase == TouchPhase.HOVER)
			{
				if (!mIsHovering) {
					toState(m_over);
				}
				mIsHovering = true;
				mIsDown = false;
			}
			else if (touch.phase == TouchPhase.MOVED && mIsDown)
			{
				// reset button when user dragged too far away after pushing
				var currentPosition:Point = touch.getLocation(parent);
				
				var buttonRect:Rectangle = getBounds(stage);
				if (currentPosition.x < x - MAX_DRAG_DIST ||
					currentPosition.x > x + MAX_DRAG_DIST ||
					currentPosition.y > minYPosition - MAX_DRAG_DIST ||
					currentPosition.y < maxYPosition + MAX_DRAG_DIST)
				{
					toState(m_down);
					
					//find the difference between old and new click position here, apply to y position
					y = startYPosition + (currentPosition.y - startYClickPoint);
					y = XMath.clamp(y, minYPosition, maxYPosition);

					dispatchEvent(new Event(Event.TRIGGERED, true, (y - minYPosition)/(maxYPosition - minYPosition)));
				}
				else
				{
					toState(m_up);
					y = startYPosition;
					
					dispatchEvent(new Event(Event.TRIGGERED, true, y/(maxYPosition - minYPosition)));
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
		
		public function setThumbPercent(percent:Number):void
		{
			percent = XMath.clamp(percent, 0, 100);
			y = (maxYPosition - minYPosition)*(percent/100) + minYPosition; 
		}
	}
}
