package scenes.game.display
{
	import audio.AudioManager;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.display.Sprite;
	
	import assets.AssetInterface;
	import assets.AssetsAudio;
	
	import constraints.ConstraintValue;
	import constraints.ConstraintVar;
	import constraints.events.VarChangeEvent;
	
	import display.NineSliceBatch;
	
	import events.ToolTipEvent;
	import events.UndoEvent;
	
	import graph.PropDictionary;
	
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	
	public class GameNode extends GameNodeBase
	{
		private var m_gameNodeDictionary:Dictionary = new Dictionary;
		private var m_scoreBlock:ScoreBlock;
		private var m_highlightRect:Quad;
		
		public function GameNode(_layoutObj:Object, _constraintVar:ConstraintVar, _draggable:Boolean = true)
		{
			super(_layoutObj, _constraintVar);
			boundingBox = (m_layoutObj["bb"] as Rectangle).clone();
			draggable = _draggable;
			
			shapeWidth = boundingBox.width;
			shapeHeight = boundingBox.height;
			
			m_isEditable = !constraintVar.constant;
			m_isWide = !constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW);
			
			constraintVar.addEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onVarChange);
			
			draw();
		}
		
		public function updateLayout(newLayoutObj:Object):void
		{
			m_layoutObj = newLayoutObj;
			boundingBox = (m_layoutObj["bb"] as Rectangle).clone();
			this.x = boundingBox.x;
			this.y = boundingBox.y;
			m_isDirty = true;
		}
		
		public override function onClicked(pt:Point):void
		{
			var changeEvent:VarChangeEvent,  undoEvent:UndoEvent;
			if (m_propertyMode == PropDictionary.PROP_NARROW) {
				if(m_isEditable) {
					var newIsWide:Boolean = !m_isWide;
					//constraintVar.setProp(m_propertyMode, !newIsWide);
					//dispatchEvent(new starling.events.Event(Level.UNSELECT_ALL, true, this));
					changeEvent = new VarChangeEvent(VarChangeEvent.VAR_CHANGE_USER, constraintVar, PropDictionary.PROP_NARROW, !newIsWide, pt);
					undoEvent = new UndoEvent(changeEvent, this);
					if (newIsWide) {
						// Wide
						AudioManager.getInstance().audioDriver().playSfx(AssetsAudio.SFX_LOW_BELT);
					} else {
						// Narrow
						AudioManager.getInstance().audioDriver().playSfx(AssetsAudio.SFX_HIGH_BELT);
					}
				}
			} else if (m_propertyMode.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0) {
				var propVal:Boolean = constraintVar.getProps().hasProp(m_propertyMode);
				//constraintVar.setProp(m_propertyMode, propVal);
				changeEvent = new VarChangeEvent(VarChangeEvent.VAR_CHANGE_USER, constraintVar, m_propertyMode, propVal, pt);
				undoEvent = new UndoEvent(changeEvent, this);
			}
			if (undoEvent) dispatchEvent(undoEvent);
			if (changeEvent) dispatchEvent(changeEvent);
		}
		
		public function onVarChange(evt:VarChangeEvent):void
		{
			handleWidthChange(!constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW));
		}
		
		public function handleWidthChange(newIsWide:Boolean):void
		{
			var redraw:Boolean = (m_isWide != newIsWide);
			m_isWide = newIsWide;
			m_isDirty = redraw;
			for each (var iedge:GameEdgeContainer in orderedIncomingEdges) {
				iedge.onWidgetChange(this);
			}
			for each (var oedge:GameEdgeContainer in orderedOutgoingEdges) {
				oedge.onWidgetChange(this);
			}
		}
		
		public function get assetName():String
		{
			var _assetName:String;
			if(m_isEditable == true)
			{
				if (m_isWide == true)
					_assetName = AssetInterface.PipeJamSubTexture_BlueDarkBoxPrefix;
				else
					_assetName = AssetInterface.PipeJamSubTexture_BlueLightBoxPrefix;
			}
			else //not adjustable
			{
				if(m_isWide == true)
					_assetName = AssetInterface.PipeJamSubTexture_GrayDarkBoxPrefix;
				else
					_assetName = AssetInterface.PipeJamSubTexture_GrayLightBoxPrefix;
			}
			//if (isSelected) _assetName += "Select";
			return _assetName;
		}
		
		override public function draw():void
		{
			if (costume) {
				costume.removeFromParent(true);
			}
			
			costume = new NineSliceBatch(shapeWidth, shapeHeight, shapeHeight / 3.0, shapeHeight / 3.0, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", assetName);
			addChild(costume);
			
			var wideScore:Number = constraintVar.scoringConfig.getScoringValue(ConstraintValue.VERBOSE_TYPE_1);
			var narrowScore:Number = constraintVar.scoringConfig.getScoringValue(ConstraintValue.VERBOSE_TYPE_0);
			const BLK_SZ:Number = 20; // create an upscaled version for better quality, then update width/height to shrink
			const BLK_RAD:Number = (shapeHeight / 3.0) * (BLK_SZ * 2 / boundingBox.height);
			if (wideScore > narrowScore) {
				m_scoreBlock = new ScoreBlock(AssetInterface.PipeJamSubTexture_BlueDarkBoxPrefix, (wideScore - narrowScore).toString(), BLK_SZ - BLK_RAD, BLK_SZ - BLK_RAD, BLK_SZ, null, BLK_RAD);
				m_scoreBlock.width = m_scoreBlock.height = boundingBox.height / 2;
				addChild(m_scoreBlock);
			} else if (narrowScore > wideScore) {
				m_scoreBlock = new ScoreBlock(AssetInterface.PipeJamSubTexture_BlueLightBoxPrefix, (narrowScore - wideScore).toString(), BLK_SZ - BLK_RAD, BLK_SZ - BLK_RAD, BLK_SZ, null, BLK_RAD);
				m_scoreBlock.width = m_scoreBlock.height = boundingBox.height / 2;
				addChild(m_scoreBlock);
			}
			useHandCursor = m_isEditable;
			
			if (constraintVar) {
				var i:int = 0;
				for (var prop:String in constraintVar.getProps().iterProps()) {
					if (prop == PropDictionary.PROP_NARROW) continue;
					if (prop == m_propertyMode) {
						var keyQuad:Quad = new Quad(3, 3, KEYFOR_COLOR);
						keyQuad.x = 1 + i * 4;
						keyQuad.y = boundingBox.height - 4;
						addChild(keyQuad);
						i++;
					}
				}
			}
			
			if (isSelected)
			{
				// Apply the glow filter
				this.filter = BlurFilter.createGlow();
			}
			else
			{
				if(this.filter)
					this.filter.dispose();
			}
			super.draw();
		}
		
		override public function isWide():Boolean
		{
			return m_isWide;
		}
		
		override public function dispose():void
		{
			if (m_scoreBlock) m_scoreBlock.dispose();
			if (constraintVar) constraintVar.removeEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onVarChange);
			super.dispose();
		}
		
		override protected function getToolTipEvent():ToolTipEvent
		{
			var lockedTxt:String = isEditable() ? "" : "Locked ";
			var wideTxt:String = isWide() ? "Wide " : "Narrow ";
			return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, lockedTxt + wideTxt + "Widget", 8);
		}
		
	}
}