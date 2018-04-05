package display
{
	import assets.AssetInterface;
	import assets.AssetsFont;
	
	import display.NineSliceBatch;
	
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import scenes.game.components.GameControlPanel;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.XSprite;
	
	public class TextBubble extends Sprite
	{
		protected var m_fontSize:Number;
		protected var m_pointAt:DisplayObject;
		protected var m_pointAtContainer:DisplayObjectContainer;
		protected var m_pointFrom:String;
		protected var m_pointTo:String;
		protected var m_arrowSz:Number;
		protected var m_arrowBounce:Number;
		protected var m_arrowBounceSpeed:Number;
		protected var m_inset:Number;
		protected var m_pointPosAlwaysUpdate:Boolean;
		
		protected var m_paddingSz:Number;
		protected var m_textContainer:Sprite;
		protected var m_tutorialArrow:Image;
		
		protected var m_pointPos:Point = new Point();
		protected var m_pointPosNeedsInit:Boolean = true;
		protected var m_arrowTextSeparationAdjustment:Number = 0;
		protected var m_globalToPoint:Point;
		
		public static const GOLD:uint = 0xFFEC00;
		public static const RED:uint = 0xFF0000;
		
		public function TextBubble(_text:String, _fontSize:Number = 10, _fontColor:uint = 0xEEEEEE, 
		                           _pointAt:DisplayObject = null, _pointAtContainer:DisplayObjectContainer = null, 
								   _pointFrom:String = NineSliceBatch.BOTTOM_LEFT, 
								   _pointTo:String = NineSliceBatch.BOTTOM_LEFT, _size:Point = null, 
								   _pointPosAlwaysUpdate:Boolean = true, _arrowSz:Number = 10, 
								   _arrowBounce:Number = 2, _arrowBounceSpeed:Number = 0.5, _inset:Number = 3,
								   _showBox:Boolean = true, _arrowColor:uint = GOLD, _outlineWeight:Number = 0,
								   _outlineColor:uint = 0x0)
		{
			m_fontSize = _fontSize;
			m_pointAt = _pointAt;
			m_pointAtContainer = _pointAtContainer;
			m_pointFrom = _pointFrom;
			m_pointTo = _pointTo;
			m_pointPosAlwaysUpdate = _pointPosAlwaysUpdate;
			m_arrowSz = _arrowSz;
			m_arrowBounce = _arrowBounce;
			m_arrowBounceSpeed = _arrowBounceSpeed;
			m_inset = Math.max(_inset, 1); // must specify some inset
			m_paddingSz = m_arrowSz + 2 * m_arrowBounce + 4 * m_inset;
			
			// estimate size if none given
			var size:Point = _size ? _size : TextFactory.getInstance().estimateTextFieldSize(_text, AssetsFont.FONT_UBUNTU, m_fontSize);
			
			// a transparent sprite with padding around the edges so we can put the arrow outside the text box
			var padding:Quad = new Quad(10, 10, 0xff00ff);
			padding.alpha = 0.0;
			padding.touchable = false;
			padding.width = size.x + 2 * m_paddingSz;
			padding.height = size.y + 2 * m_paddingSz;
			padding.x = -padding.width / 2;
			padding.y = -padding.height / 2;
			addChild(padding);
			
			// to hold text
			m_textContainer = new Sprite();
			m_textContainer.x = -size.x / 2;
			m_textContainer.y = -size.y / 2;
			addChild(m_textContainer);
			
			// background box
			if (_showBox) {
				var box:NineSliceBatch = new NineSliceBatch(size.x, size.y, 8, 8, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", AssetInterface.PipeJamSubTexture_TutorialBoxPrefix);
				m_textContainer.addChild(box);
			} else {
				//squeeze text closer to arrow if no box
				m_arrowTextSeparationAdjustment = -m_arrowSz / 2 - m_arrowBounce - 4 * m_inset;
			}
			
			// text field
			var textField:TextFieldWrapper = TextFactory.getInstance().createTextField(_text, AssetsFont.FONT_UBUNTU, size.x - 2 * m_inset, size.y - 2 * m_inset, m_fontSize, _fontColor);
			if (_outlineWeight > 0 && !PipeJam3.DISABLE_FILTERS) TextFactory.getInstance().updateFilter(textField, new GlowFilter(_outlineColor, 1, _outlineWeight, _outlineWeight, 4 * _outlineWeight));
			textField.x = m_inset;
			textField.y = m_inset;
			m_textContainer.addChild(textField);
			
			// arrow
			if (m_pointAt) {
				var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
				var arrowTexture:Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_TutorialArrow);
				m_tutorialArrow = new Image(arrowTexture);
				m_tutorialArrow.color = _arrowColor;
				m_tutorialArrow.width = m_tutorialArrow.height = m_arrowSz;
				XSprite.setPivotCenter(m_tutorialArrow);
				addChild(m_tutorialArrow);
			}
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function onAdded(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		public function onRemoved(evt:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			addEventListener(Event.ADDED_TO_STAGE, onAdded); // allow this to be removed and re-added
		}

		protected function onEnterFrame(evt:Event):void
		{
			var timeSec:Number = new Date().time / 1000.0;
			var timeArrowOffset:Number = m_arrowBounce * (int(timeSec / m_arrowBounceSpeed) % 2);
			
			if (m_pointAt && m_pointAt.parent && m_tutorialArrow) {
				var pt:Point = new Point();
				var offset:Point = new Point();
				
				switch (m_pointFrom) {
					case NineSliceBatch.TOP_LEFT:
						offset.x = -1;
						offset.y = -1;
						break;
					
					case NineSliceBatch.BOTTOM_RIGHT:
						offset.x = 1;
						offset.y = 1;
						break;
					
					case NineSliceBatch.TOP_RIGHT:
						offset.x = 1;
						offset.y = -1;
						break;
					
					case NineSliceBatch.BOTTOM_LEFT:
						offset.x = -1;
						offset.y = 1;
						break;
					
					case NineSliceBatch.LEFT:
						offset.x = -1;
						offset.y = 0;
						break;
					
					case NineSliceBatch.RIGHT:
						offset.x = 1;
						offset.y = 0;
						break;
					
					case NineSliceBatch.BOTTOM:
						offset.x = 0;
						offset.y = 1;
						break;
					
					case NineSliceBatch.TOP:
					default:
						offset.x = 0;
						offset.y = -1;
						break;
				}
				
				switch (m_pointTo ? m_pointTo : m_pointFrom) {
					case NineSliceBatch.CENTER:
						pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), 0.5 * (m_pointAt.bounds.top + m_pointAt.bounds.bottom));
						break;
					
					case NineSliceBatch.TOP_LEFT:
						pt = m_pointAt.bounds.topLeft;
						break;
					
					case NineSliceBatch.BOTTOM_RIGHT:
						pt = m_pointAt.bounds.bottomRight;
						break;
					
					case NineSliceBatch.TOP_RIGHT:
						pt = new Point(m_pointAt.bounds.right, m_pointAt.bounds.top);
						break;
					
					case NineSliceBatch.BOTTOM_LEFT:
						pt = new Point(m_pointAt.bounds.left, m_pointAt.bounds.bottom);
						break;
					
					case NineSliceBatch.LEFT:
						pt = new Point(m_pointAt.bounds.left, 0.5 * (m_pointAt.bounds.bottom + m_pointAt.bounds.top));
						break;
					
					case NineSliceBatch.RIGHT:
						pt = new Point(m_pointAt.bounds.right, 0.5 * (m_pointAt.bounds.bottom + m_pointAt.bounds.top));
						break;
					
					case NineSliceBatch.BOTTOM:
						pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), m_pointAt.bounds.bottom);
						break;
					
					case NineSliceBatch.TOP:
					default:
						pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), m_pointAt.bounds.top);
						break;
				}
				
				var desiredParent:DisplayObjectContainer = (m_pointAtContainer != null) ? m_pointAtContainer : m_pointAt.parent;
				if (desiredParent) {
					pt = m_pointAt.parent.localToGlobal(pt);
					pt = desiredParent.globalToLocal(pt);
					pt = (m_globalToPoint != null) ? m_globalToPoint : desiredParent.localToGlobal(pt);
					pt = parent.globalToLocal(pt);
					
					if (m_pointPosNeedsInit || m_pointPosAlwaysUpdate) {
						m_pointPos = pt;
						m_pointPosNeedsInit = false;
					}
				}
				
				x = m_pointPos.x + offset.x * (width / 2 - m_paddingSz + 2 * m_inset + m_arrowSz + m_arrowBounce + m_arrowTextSeparationAdjustment);
				y = m_pointPos.y + offset.y * (height / 2 - m_paddingSz + 2 * m_inset + m_arrowSz + m_arrowBounce + m_arrowTextSeparationAdjustment);
				
				var arrowPos:Number = m_inset + m_arrowSz / 2 - timeArrowOffset;
				
				m_tutorialArrow.rotation = Math.atan2(-offset.y, -offset.x);
				m_tutorialArrow.x = -offset.x * (width / 2 - m_paddingSz + arrowPos + m_arrowTextSeparationAdjustment);
				m_tutorialArrow.y = -offset.y * (height / 2 - m_paddingSz + arrowPos + m_arrowTextSeparationAdjustment);
			} else if (m_pointFrom != null) {
				var newX:Number = Constants.GameWidth / 2;
				var newY:Number = height / 2 - m_paddingSz + m_inset;
				switch (m_pointFrom) {
					case NineSliceBatch.CENTER:
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
						break;
					case NineSliceBatch.TOP_LEFT:
						newX = width / 2 - m_paddingSz + m_inset;
						break;
					case NineSliceBatch.TOP_RIGHT:
						newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
						break;
					case NineSliceBatch.LEFT:
						newX = width / 2 - m_paddingSz + m_inset;
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
						break;
					case NineSliceBatch.RIGHT:
						newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
						break;
					case NineSliceBatch.BOTTOM:
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
						break;
					case NineSliceBatch.BOTTOM_LEFT:
						newX = width / 2 - m_paddingSz + m_inset;
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
						break;
					case NineSliceBatch.BOTTOM_RIGHT:
						newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
						newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
						break;
				}
				x = newX;
				y = newY;
			} else {
				x = Constants.GameWidth / 2;
				y = height / 2 - m_paddingSz + m_inset;
			}
		}
		
		public function setGlobalToPoint(pt:Point):void
		{
			m_globalToPoint = pt;
		}
		
		private function sign(x:Number):Number
		{
			if (x < 0.0) {
				return -1.0;
			} else if (x > 0.0) {
				return 1.0;
			} else {
				return 0.0;
			}
		}
		
		public function hideText():void
		{
			if (m_textContainer != null) m_textContainer.visible = false;
		}
		
		public function showText():void
		{
			if (m_textContainer != null) m_textContainer.visible = true;
		}
	}
}
