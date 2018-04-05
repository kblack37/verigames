package display 
{
	import flash.geom.Point;
	import scenes.game.display.Level;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	/**
	 * Text bubble that updates/follows a component based on the level it uses
	 */
	public class TextBubbleFollowComponent extends TextBubble 
	{
		private var m_pointAtFn:Function;
		private var m_level:Level;
		
		public function TextBubbleFollowComponent(_pointAtFn:Function, _level:Level, _text:String, 
		                                          _fontSize:Number = 10, _fontColor:uint = 0xEEEEEE, 
												  _pointFrom:String = NineSliceBatch.BOTTOM_LEFT,
												  _pointTo:String = NineSliceBatch.BOTTOM_LEFT, 
												  _size:Point = null, _arrowSz:Number = 10, 
												  _arrowBounce:Number = 2, _arrowBounceSpeed:Number = 0.5,
												  _inset:Number = 3, _showBox:Boolean = true, 
												  _arrowColor:uint = GOLD, _outlineWeight:Number = 0, 
												  _outlineColor:uint=0x0)
		{
			m_pointAtFn = _pointAtFn;
			m_level = _level;
			
			var pointAtComponent:DisplayObject = (m_pointAtFn != null) ? m_pointAtFn(m_level) : null;
			
			var pointPosAlwaysUpdate:Boolean = true;
			if (m_level.tutorialManager && !m_level.tutorialManager.getPanZoomAllowed() && m_level.tutorialManager.getLayoutFixed()) {
				pointPosAlwaysUpdate = false;
			}
			
			super(_text, _fontSize, _fontColor, pointAtComponent, m_level, _pointFrom, _pointTo, _size, pointPosAlwaysUpdate, _arrowSz, _arrowBounce, _arrowBounceSpeed, _inset, _showBox, _arrowColor, _outlineWeight, _outlineColor);
		}
		
		override protected function onEnterFrame(evt:Event):void
		{
			if ((m_pointAtFn != null) && ((m_pointAt == null) || (m_pointAt.parent == null))) {
				m_pointAt = m_pointAtFn(m_level);
			}
			super.onEnterFrame(evt);
		}
	}

}