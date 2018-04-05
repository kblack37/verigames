package display 
{
	import events.ToolTipEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class ToolTippableSprite extends Sprite 
	{
		protected var m_hoverTimer:Timer;
		protected var m_hoverPointGlobal:Point;
		private var m_hoverDisabled:Boolean = false;
		
		public function ToolTippableSprite() 
		{
			super();
			if (getToolTipEvent()) {
				addEventListener(TouchEvent.TOUCH, onTouch);
			}
		}
		
		protected function onTouch(event:TouchEvent):void
		{
			if (event.getTouches(this, TouchPhase.HOVER).length) {
				var touch:Touch = event.getTouches(this, TouchPhase.HOVER)[0];
				m_hoverPointGlobal = new Point(touch.globalX, touch.globalY);
				if (!m_hoverTimer) {
					m_hoverTimer = new Timer(Constants.TOOL_TIP_DELAY_SEC * 1000, 1);
					m_hoverTimer.addEventListener(TimerEvent.TIMER, onHoverDetected);
					m_hoverTimer.start();
				}
			} else {
				if (m_hoverTimer) {
					m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
					m_hoverTimer.stop();
					m_hoverTimer = null;
				}
				m_hoverPointGlobal = null;
				onHoverEnd();
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (m_hoverTimer) {
				m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
				m_hoverTimer.stop();
				m_hoverTimer = null;
			}
			m_hoverPointGlobal = null;
			removeEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		protected function getToolTipEvent():ToolTipEvent
		{
			return null; // implement in subclasses if toolTip text is desired
		}
		
		protected function onHoverEnd():void
		{
			dispatchEvent(new ToolTipEvent(ToolTipEvent.CLEAR_TOOL_TIP, this));
		}
		
		public function disableHover():void
		{
			m_hoverDisabled = true;
			if (m_hoverTimer) {
				m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
				m_hoverTimer.stop();
				m_hoverTimer = null;
			}
			m_hoverPointGlobal = null;
		}
		
		public function enableHover():void
		{
			m_hoverDisabled = false;
		}
		
		protected function onHoverDetected(evt:TimerEvent):void
		{
			if (m_hoverDisabled) return;
			var toolTipEvt:ToolTipEvent = getToolTipEvent();
			if (toolTipEvt) {
				if (m_hoverPointGlobal) toolTipEvt.point = m_hoverPointGlobal.clone();
				dispatchEvent(toolTipEvt);
			}
		}
	}

}