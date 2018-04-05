package scenes.game.display
{
	import assets.AssetInterface;
	import starling.display.Sprite;
	
	import events.EdgePropChangeEvent;
	import events.EdgeContainerEvent;
	
	import flash.geom.Point;
	
	import graph.PropDictionary;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.XSprite;

	public class GameEdgeJoint extends GameComponent
	{		
		public var m_jointType:int;
		public var m_position:int;
		public var m_closestWall:int = 0;
		
		private var m_jointImage:Sprite;
		
		private var m_incomingPt:Point;
		private var m_outgoingPt:Point;
		
		static public var STANDARD_JOINT:int = 0;
		static public var MARKER_JOINT:int = 1;
		static public var END_JOINT:int = 2;
		static public var INNER_CIRCLE_JOINT:int = 3;
		private var m_props:PropDictionary;
		
		public function GameEdgeJoint(jointType:int = 0, _isWide:Boolean = false, _isEditable:Boolean = false, _draggable:Boolean = true, _props:PropDictionary = null, _propMode:String = PropDictionary.PROP_NARROW)
		{
			super("");
			if (_props != null) m_props = _props;
			m_propertyMode = _propMode;
			draggable = _draggable;
			m_isWide = _isWide;
			m_jointType = jointType;
			m_isDirty = true;
			
			m_isEditable = _isEditable;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//if (jointType == INNER_CIRCLE_JOINT) {
				touchable = false;
			//} else {
			//	addEventListener(TouchEvent.TOUCH, onTouch);
			//}
		}
		
		override public function dispose():void
		{
			if (m_disposed) {
				return;
			}
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}

			disposeChildren();
			if (m_jointImage) {
				m_jointImage.removeFromParent(true);
				m_jointImage = null;
			}
			super.dispose();
		}
		
		public function setIncomingPoint(pt:Point):void
		{
			//trace("incoming: " + pt);
			if (pt.x != 0 && pt.y != 0) return;
			m_incomingPt = pt;
			m_isDirty = true;
		}
		
		public function setOutgoingPoint(pt:Point):void
		{
			//trace("outgoing: " + pt);
			if (pt.x != 0 && pt.y != 0) return;
			m_outgoingPt = pt;
			m_isDirty = true;
		}
		
		override protected function onTouch(event:TouchEvent):void
		{
			if (!draggable) return;
			
			var touches:Vector.<Touch> = event.touches;
			
			if(event.getTouches(this, TouchPhase.MOVED).length)
			{

			}
			else if(event.getTouches(this, TouchPhase.ENDED).length)
			{

			}
			else if(event.getTouches(this, TouchPhase.HOVER).length)
			{
				if (touches.length == 1)
				{
					m_isDirty = true;
					dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OVER, null, this));
				}
			}
			else if(event.getTouches(this, TouchPhase.BEGAN).length)
			{
			}
			else
			{
				m_isDirty = true;
				dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OUT, null, this));
			}
		}
		
		public function draw():void
		{
			var lineSize:Number = m_isWide ? GameEdgeContainer.WIDE_WIDTH : GameEdgeContainer.NARROW_WIDTH;
			var color:int = getColor();
			
			if (m_jointType == INNER_CIRCLE_JOINT) {
				lineSize *= 1.5;
			}
			
			if (m_jointImage) {
				m_jointImage.removeFromParent(true);
				m_jointImage = null;
			}
			
			var isRound:Boolean = (m_jointType == INNER_CIRCLE_JOINT);
			
			if ((m_propertyMode != PropDictionary.PROP_NARROW) && getProps().hasProp(m_propertyMode)) {
				m_jointImage = createJoint(isRound, false, m_isWide, m_incomingPt, m_outgoingPt, KEYFOR_COLOR);
			} else {
				var isGray:Boolean = m_isEditable;
				var myColor:uint = isHoverOn ? 0xeeeeee : 0xcccccc;
				m_jointImage = createJoint(isRound, isGray, m_isWide, m_incomingPt, m_outgoingPt, myColor);
			}
			m_jointImage.width = m_jointImage.height = lineSize;
			m_jointImage.x = -lineSize/2;
			m_jointImage.y = -lineSize/2;
			addChild(m_jointImage);
			
//			var number:String = ""+count;
//			var txt:TextField = new TextField(10, 10, number, "Veranda", 6,0x00ff00); 
//			txt.y = 1;
//			txt.x = 1;
//			m_shape.addChild(txt);
//			addChild(m_shape);
		}
		
		// These are used to load assets such as GrayDarkSegmentTop
		private static const TOP:String = "Top";
		private static const BOTTOM:String = "Bottom";
		private static const LEFT:String = "Left";
		private static const RIGHT:String = "Right";
		private static function getDir(pt:Point):String
		{
			if (pt.x > 0) return LEFT;
			if (pt.x < 0) return RIGHT;
			if (pt.y > 0) return TOP;
			return BOTTOM;
		}
		
		private static function setupConnector(connector:Image, joint:Image, dir:String):void
		{
			switch (dir) {
				case TOP:
					connector.width = joint.width;
					connector.height = joint.height / 2.0;
					connector.x = joint.x;
					connector.y = joint.y + connector.height;
					break;
				case BOTTOM:
					connector.width = joint.width;
					connector.height = joint.height / 2.0;
					connector.x = joint.x;
					connector.y = joint.y;
					break;
				case LEFT:
					connector.width = joint.width / 2.0;
					connector.height = joint.height;
					connector.x = joint.x + connector.width;
					connector.y = joint.y;
					break;
				case RIGHT:
					connector.width = joint.width / 2.0;
					connector.height = joint.height;
					connector.x = joint.x;
					connector.y = joint.y;
					break;
			}
		}
		
		public static function createJoint(isRound:Boolean, editable:Boolean, wide:Boolean, fromPt:Point = null, toPt:Point = null, applyColor:int = -1):Sprite
		{	
			var jointAssetName:String;
			var connectorAssetName:String;
			if (isRound) {
				fromPt = toPt = null; // starting/ending joints don't need connectors
				if(editable == true)
				{
					if (wide == true) {
						jointAssetName = AssetInterface.PipeJamSubTexture_BlueDarkStart;
					} else {
						jointAssetName = AssetInterface.PipeJamSubTexture_BlueLightStart;
					}
				}
				else //not adjustable
				{
					if(wide == true) {
						jointAssetName = AssetInterface.PipeJamSubTexture_GrayDarkStart;
					} else {
						jointAssetName = AssetInterface.PipeJamSubTexture_GrayLightStart;
					}
				}
			} else {
				if(editable == true)
				{
					if (wide == true) {
						jointAssetName = AssetInterface.PipeJamSubTexture_BlueDarkJoint;
						connectorAssetName = AssetInterface.PipeJamSubTexture_BlueDarkSegmentPrefix;
					} else {
						jointAssetName = AssetInterface.PipeJamSubTexture_BlueLightJoint;
						connectorAssetName = AssetInterface.PipeJamSubTexture_BlueLightSegmentPrefix;
					}
				}
				else //not adjustable
				{
					if(wide == true) {
						jointAssetName = AssetInterface.PipeJamSubTexture_GrayDarkJoint;
						connectorAssetName = AssetInterface.PipeJamSubTexture_GrayDarkSegmentPrefix;
					} else {
						jointAssetName = AssetInterface.PipeJamSubTexture_GrayLightJoint;
						connectorAssetName = AssetInterface.PipeJamSubTexture_GrayLightSegmentPrefix;
					}
				}
			}
			
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			var jointTexture:Texture = atlas.getTexture(jointAssetName);
			var jointImg:Image = new Image(jointTexture);
			if (applyColor >= 0) jointImg.color = applyColor;
			
			var jointSprite:Sprite = new Sprite();
			jointSprite.addChild(jointImg);
			
			var inDir:String = "";
			if (fromPt) {
				inDir = getDir(fromPt);
				var inTexture:Texture = atlas.getTexture(connectorAssetName + inDir);
				var inImg:Image = new Image(inTexture);
				setupConnector(inImg, jointImg, inDir);
				if (applyColor >= 0) inImg.color = applyColor;
				jointSprite.addChild(inImg);
			}
			var outDir:String = ""
			if (toPt) outDir = getDir(toPt);
			if (toPt && (inDir != outDir)) {
				// Don't both making two of the same image
				var outTexture:Texture = atlas.getTexture(connectorAssetName + outDir);
				var outImg:Image = new Image(outTexture);
				setupConnector(outImg, jointImg, outDir);
				if (applyColor >= 0) outImg.color = applyColor;
				jointSprite.addChild(outImg);
			}
			
			return jointSprite;
		}
		
		public function onEnterFrame(event:Event):void
		{
			if(m_isDirty)
			{
				draw();
				m_isDirty = false;
			}
		}
		
		// Make edge joints slightly darker to be more visible
		override public function getColor():int
		{
			var color:int = super.getColor();
			var red:int = XSprite.extractRed(color);
			var green:int = XSprite.extractGreen(color);
			var blue:int = XSprite.extractBlue(color);
			return  ( ( Math.round(red * 0.8) << 16 ) | ( Math.round(green * 0.8) << 8 ) | Math.round(blue * 0.8) );
		}
	}
}