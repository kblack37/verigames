package display
{
	import events.ToolTipEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import utils.XSprite;

	[Event(name="triggered", type="starling.events.Event")]
	[Event(name="hoverOver", type="starling.events.Event")]
	
	public class BasicButton extends ToolTippableSprite
	{
		private static const DEBUG_HIT:Boolean = false;
		private static const DEBUG_STATE:Boolean = false;
		
		public static const HOVER_OVER:String = "hoverOver";
		
		public static const UP_STATE:String = "upState";
		public static const OVER_STATE:String = "overState";
		public static const DOWN_STATE:String = "downState";
		
		protected var m_up:DisplayObject;
		protected var m_over:DisplayObject;
		protected var m_down:DisplayObject;
		private var m_current:DisplayObject;

		private var m_hitSubRect:Rectangle;

		private var m_enabled:Boolean;
		private var m_useHandCursor:Boolean;

		private var m_data:Object;
		protected var m_toolTipText:String;
		
		public function BasicButton(up:DisplayObject, over:DisplayObject, down:DisplayObject, hitSubRect:Rectangle = null)
		{
			m_enabled = true;
			m_useHandCursor = false;
			
			m_hitSubRect = hitSubRect;
			
			var container:Sprite = new Sprite();
			addChild(container);
			
			m_up = up;
			m_up.visible = false;
			container.addChild(m_up);
			
			m_over = over;
			m_over.visible = false;
			container.addChild(m_over);
			
			m_down = down;
			m_down.visible = false;
			container.addChild(m_down);
			
			m_current = m_up;
			m_current.visible = true;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			if (DEBUG_HIT) {
				var hit:DisplayObject;
				if (m_hitSubRect) {
					hit = XSprite.createPolyRect(m_hitSubRect.width, m_hitSubRect.height, 0xFF00FF, 0, 0.25);
					hit.x = m_hitSubRect.x;
					hit.y = m_hitSubRect.y;
				} else {
					hit = XSprite.createPolyRect(width, height, 0xFF00FF, 0, 0.25);
				}
				container.addChild(hit);
			}
		}

		public override function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			
			super.dispose();
		}
		
		public function get enabled():Boolean
		{
			return m_enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (m_enabled != value) {
				m_enabled = value;
				alpha = m_enabled ? 1.0 : 0.5;
				toState(m_up);
			}
		}
		
		public function set data(value:Object):void
		{
			m_data = value;
		}
		
		public function get data():Object
		{
			return m_data;
		}
		
		public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			var superHit:DisplayObject = super.hitTest(localPoint, forTouch);
			
			if (!m_hitSubRect) {
				return superHit;
			}
			
			if (superHit == null) {
				return null;
			}
			
			return m_hitSubRect.containsPoint(localPoint) ? this : null;
		}
		
		protected var lastTouchState:DisplayObject = m_up;
		protected override function onTouch(event:TouchEvent):void
		{
			super.onTouch(event);
			
			Mouse.cursor = (m_useHandCursor && m_enabled && event.interactsWith(this)) ? MouseCursor.BUTTON : MouseCursor.AUTO;
			
			var touch:Touch = event.getTouch(this);
			var isHovering:Boolean = (event.getTouch(event.target as DisplayObject, TouchPhase.HOVER) != null);
			if (!m_enabled || touch == null) {
				if(!m_current)
					m_current = m_up;
				toState(lastTouchState);
				lastTouchState = m_up;
				return;
			}
			
			if (touch.phase == TouchPhase.HOVER) {
				if (m_current != m_over) {
					lastTouchState = m_current;
					toState(m_over);
					dispatchEventWith(HOVER_OVER, true, dispatchEventWith);
				}
			} else if (touch.phase == TouchPhase.MOVED) {
				if (hitTest(touch.getLocation(this))) {
					toState(m_down);
				} else {
					toState(m_up);
				}
			} else if (touch.phase == TouchPhase.BEGAN) {
				toState(m_down);
			} else if (touch.phase == TouchPhase.ENDED) {
				if (m_current == m_down) {
					if(!m_data) m_data = new Object;
					m_data.tapCount = touch.tapCount;
					toState(m_up);
					dispatchEventWith(Event.TRIGGERED, true, m_data);
				}
			}
		}
		
		public function toState(state:DisplayObject):void
		{
			if (DEBUG_STATE) trace("Current: " + getState(m_current));
			if (m_current != state) {
				if (DEBUG_STATE) trace("To: " + getState(state));
				m_current.visible = false;
				m_current = state;
				if(!m_current)
					m_current = m_up;
				m_current.visible = true;
			}
		}
		
		private function getState(state:DisplayObject):String
		{
			if (state == m_down) return DOWN_STATE;
			if (state == m_over) return OVER_STATE;
			if (state == m_up) return UP_STATE;
			if (state == null) return "null";
			return "unknown";
		}
		
		public function setStatePosition(stateString:String):void
		{
			if(stateString == UP_STATE)
				toState(m_up);
			else if(stateString == OVER_STATE)
				toState(m_over);
			else if(stateString == DOWN_STATE)
				toState(m_down);
		}
		
		protected override function getToolTipEvent():ToolTipEvent
		{
			if (m_toolTipText) return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, m_toolTipText);
			return null;
		}
	}
}
