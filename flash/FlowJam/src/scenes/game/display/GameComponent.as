package scenes.game.display
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import graph.PropDictionary;
	
	import scenes.BaseComponent;
	
	import starling.display.DisplayObjectContainer;
	
	public class GameComponent extends BaseComponent
	{
		protected static const DEBUG_TRACE_IDS:Boolean = true;
		public var m_id:String;
		
		public var isSelected:Boolean;
		public var m_isDirty:Boolean = false;
		
		public var boundingBox:Rectangle;
		
		//these are here in that they determine color, so all screen objects need them set
		public var m_isWide:Boolean = false;
		public var m_hasError:Boolean = false;
		public var m_isEditable:Boolean;
		public var m_shouldShowError:Boolean = true;
		public var isHoverOn:Boolean = false;
		public var draggable:Boolean = true;
		protected var m_propertyMode:String = PropDictionary.PROP_NARROW;
		public var m_forceColor:Number = -1;
		private var m_hidden:Boolean = false;
		
		public static const NARROW_COLOR:uint = 0x6ED4FF;
		public static const NARROW_COLOR_BORDER:uint = 0x1773B8
		public static const WIDE_COLOR:uint = 0x0077FF;
		public static const WIDE_COLOR_BORDER:uint = 0x1B3C86;
		public static const UNADJUSTABLE_WIDE_COLOR:uint = 0x808184;
		public static const UNADJUSTABLE_WIDE_COLOR_BORDER:uint = 0x404144;
		public static const UNADJUSTABLE_NARROW_COLOR:uint = 0xD0D2D3;
		public static const UNADJUSTABLE_NARROW_COLOR_BORDER:uint = 0x0;
		public static const ERROR_COLOR:uint = 0xF05A28;
		public static const SCORE_COLOR:uint = 0x0;
		public static const SELECTED_COLOR:uint = 0xFF0000;
		
		public function GameComponent(_id:String)
		{
			super();
			
			m_id = _id;
			isSelected = false;
		}
		
		public function componentMoved(delta:Point):void
		{
			x += delta.x;
			y += delta.y;
			boundingBox.x += delta.x;
			boundingBox.y += delta.y;
		}
		
		public function hasError():Boolean
		{
			return m_hasError;
		}
		
		public function componentSelected(_isSelected:Boolean):void
		{
			isSelected = _isSelected;
			m_isDirty = true;
		}
		
		public function hideComponent(hide:Boolean):void
		{
			visible = !hide;
			m_hidden = hide;
			m_isDirty = true;
		}
		
		public function get hidden():Boolean { return m_hidden; }
		
		public function getGlobalScaleFactor():Point
		{
			var pt:Point = new Point(1,1);
			var currentParent:DisplayObjectContainer = parent;
			while(currentParent != null)
			{
				pt.x *= currentParent.scaleX;
				pt.y *= currentParent.scaleY;
				
				currentParent =  currentParent.parent;
			}
			
			return pt;
		}
		
		public function isEditable():Boolean
		{
			return m_isEditable;
		}
		
		//override this
		public function isWide():Boolean
		{
			return m_isWide;
		}
		
		public function setIsWide(b:Boolean):void
		{
			m_isWide = b;
		}
		
		public function forceColor(color:Number):void
		{
			m_forceColor = color;
			m_isDirty = true;
		}
		
		//set children's color, based on incoming and outgoing component and error condition
		public function getColor():int
		{
			var color:int;
			if (m_forceColor > -1) {
				color = m_forceColor;
			}
			else if(m_shouldShowError && hasError())
				color = ERROR_COLOR;
			else if(m_isEditable == true)
			{
				if(m_isWide == true)
					color = WIDE_COLOR;
				else
					color = NARROW_COLOR;
			}
			else //not adjustable
			{
				if(m_isWide == true)
					color = UNADJUSTABLE_WIDE_COLOR;
				else
					color = UNADJUSTABLE_NARROW_COLOR;				
			}
			
			return color;
		}
		
		public function updateSize():void
		{
		}
		
		public function getProps():PropDictionary
		{
			// Implemented by children
			return new PropDictionary();
		}
		
		public function setProps(props:PropDictionary):void
		{
			// Implemented by children
			m_isDirty = true;
		}
		
		public function setPropertyMode(prop:String):void
		{
			m_propertyMode = prop;
			m_isDirty = true;
		}
		
	}
}