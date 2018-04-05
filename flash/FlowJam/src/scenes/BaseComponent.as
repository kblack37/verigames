package scenes
{
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

	public class BaseComponent extends ToolTippableSprite
	{	
		private var mClipRect:Rectangle;
		
		protected var m_disposed:Boolean;
		
		//initalized in Game
		static protected var loadingAnimationImages:Vector.<Texture> = null;
		static protected var waitAnimationImages:Vector.<Texture> = null;
		
		protected var busyAnimationMovieClip:MovieClip;
		public static const KEYFOR_COLOR:uint = 0xFF00FF;
		
		//useful for debugging resource issues
		public static var nextIndex:int = 0;
		public var objectIndex:int;
		
		public function BaseComponent()
		{
			objectIndex = nextIndex++;
			m_disposed = false;
			super();
		}
		
		override public function dispose():void
		{
			if (m_disposed) {
				return;
			}
			m_disposed = true;
			disposeChildren();
			super.dispose();
		}
		
		public function disposeChildren():void
		{
			while (this.numChildren > 0) {
				var obj:DisplayObject = getChildAt(0);
				if (obj is BaseComponent) {
					(obj as BaseComponent).disposeChildren();
				}
				obj.removeFromParent(true);
			}
		}
		
		public override function render(support:RenderSupport, alpha:Number):void
		{
			if (mClipRect == null) super.render(support, alpha);
			else
			{
				var context:Context3D = Starling.context;
				if (context == null) throw new MissingContextError();
				 
				support.finishQuadBatch();
				support.scissorRectangle = mClipRect;
				
				super.render(support, alpha);
				
				support.finishQuadBatch();
				support.scissorRectangle = null;
			}
		}
		
		public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			// without a clip rect, the sprite should behave just like before
			if (mClipRect == null) return super.hitTest(localPoint, forTouch); 
			
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!visible || !touchable)) return null;
			
			if (mClipRect.containsPoint(localToGlobal(localPoint)))
				return super.hitTest(localPoint, forTouch);
			else
				return null;
		}
		
		public function get clipRect():Rectangle { return mClipRect; }
		public function set clipRect(value:Rectangle):void
		{
			if (value) 
			{
				if (mClipRect == null) mClipRect = value.clone();
				else mClipRect.setTo(value.x, value.y, value.width, value.height);
			}
			else mClipRect = null;
		}
		
		//use this to force the size of the object
		//it adds a 'transparent' image of the specified size (you can make it non-transparent by changing the alpha value.)
		public function setPosition(_x:Number, _y:Number, _width:Number, _height:Number, _alpha:Number = 0.0, _color:Number = 0x000000):void
		{
			this.x = _x;
			this.y = _y;
		}
		
		public function handleUndoEvent(undoEvent:Event, isUndo:Boolean = true):void
		{
			
		}
		
		public function startBusyAnimation(animationParent:DisplayObjectContainer = null):MovieClip
		{
			busyAnimationMovieClip = new MovieClip(loadingAnimationImages, 4);
			
			if(!animationParent)
			{
				busyAnimationMovieClip.x = (Constants.GameWidth-busyAnimationMovieClip.width)/2;
				busyAnimationMovieClip.y = (Constants.GameHeight-busyAnimationMovieClip.height)/2;
				addChild(busyAnimationMovieClip);
			}
			else
			{
				busyAnimationMovieClip.x = (animationParent.width-busyAnimationMovieClip.width)/2;
				busyAnimationMovieClip.y = (animationParent.height-busyAnimationMovieClip.height)/2;
				animationParent.addChild(busyAnimationMovieClip);
			}
			Starling.juggler.add(this.busyAnimationMovieClip);
			
			return busyAnimationMovieClip;
		}
		
		public function stopBusyAnimation():void
		{
			if(busyAnimationMovieClip)
			{
				removeChild(busyAnimationMovieClip);
				Starling.juggler.remove(this.busyAnimationMovieClip);
				
				busyAnimationMovieClip.dispose();
				busyAnimationMovieClip = null;
			}
			
			
		}
	}
}