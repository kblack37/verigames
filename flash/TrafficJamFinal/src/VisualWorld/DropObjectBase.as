package VisualWorld 
{
	import Events.StampChangeEvent;
	
	import NetworkGraph.Edge;
	import NetworkGraph.FlowObject;
	import NetworkGraph.NodeTypes;
	import NetworkGraph.StampRef;
	
	import Utilities.XSprite;
	
	import com.greensock.TimelineMax;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/* take two:
		make this an object that traverses the graph
		it contains a ptr to the sprite that is the current visible representation of the object
	*/
	public class DropObjectBase extends Sprite
	{
		public var m_below_pipe:Boolean = false;
		public var m_after_pinch:Boolean = false;
		public var m_after_buzz:Boolean = false;
				 
		public var timeline:TimelineMax;
		
		public var m_flowObject:FlowObject;
			
		public var activeStampVector:Vector.<StampRef> = new Vector.<StampRef>;
		
		protected var layerArray:Array = new Array();
		protected var rowArray:Array = new Array(new Array, new Array);
		protected var WIDE_LAYER:uint = 1;
		protected var NARROW_LAYER:uint = 0;
		protected var ROW_1:uint = 0;
		protected var ROW_2:uint = 1;
		
		//need these to keep track of position and when to hide, set by pipe
		public var pathLength:Number;
		public var begin_x:Number;
		public var begin_y:Number;
		
		//if this is a continuation of a previous object, set this (use to make animations during transitions better)
		public var previousObj:DropObjectBase;
		protected static var nextCreateIndex:uint = 0;
		public var createIndex:uint;

		
		public function DropObjectBase(_starting_edge:Edge, _timeline:TimelineMax, flowObject:FlowObject = null) 
		{
			createIndex = nextCreateIndex;
			nextCreateIndex++;
			
			
			timeline = _timeline;
			
			if(flowObject == null)
				m_flowObject = _starting_edge.getCurrentFlowObject();
			else
				m_flowObject = flowObject;
			
			if(m_flowObject == null || m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_NONE)
			{
				hide();
				return;
			}
		}
		
		public function initialize():void
		{
		}
		
		public function startAnimation(start:Boolean):void
		{
			if(!visible)
				return;
			
			if(start && m_flowObject.starting_ball_type != VerigameSystem.BALL_TYPE_NONE)
				timeline.play();
			else
			{
				timeline.stop();
			}
		}
		
		//checks the flow object/local vars and shows or hides wide/narrow image as appropriate
		public function updateImageAndFlow(stopObject:Boolean = false):void
		{	
			updateImage();
			updateFlow(stopObject);
		}
		
		//checks the flow object/local vars and shows or hides wide/narrow image as appropriate
		public function updateImage():void
		{	
			if(m_flowObject == null)
			{
				//	don't stop these, as they never get updated again if you do
				visible = false;
				return;
			}
			
			if(m_flowObject.flowStartingEdge.from_node.kind == NodeTypes.START_NO_BALL)
			{
				timeline.stop();
				visible = false;
				return;
			}
			
			visible = true;
			
			//determine visibility
			if (m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_WIDE) {
				setLayerVisible(WIDE_LAYER, true);
				setLayerVisible(NARROW_LAYER, false);
				
				if(m_after_buzz)
				{
					setLayerVisible(WIDE_LAYER, false);
					setLayerVisible(NARROW_LAYER, true);
				}
				
				if(m_after_pinch)
				{
					setLayerVisible(WIDE_LAYER, false);
					setLayerVisible(NARROW_LAYER, true);
				}
			}
			else if(m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_NARROW || m_flowObject.associatedEdge.associated_pipe.is_wide == false)
			{
				setLayerVisible(WIDE_LAYER, false);
				setLayerVisible(NARROW_LAYER, true);
			}
			else //BALL_TYPE_NONE - allow normal travel if you find your self on one of these roads
			{
				if(m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_WIDE)
				{
					setLayerVisible(WIDE_LAYER, true);
					setLayerVisible(NARROW_LAYER, false);
				}
				else
				{
					setLayerVisible(WIDE_LAYER, false);
					setLayerVisible(NARROW_LAYER, true);
				}
			}
		}
		
		//checks the flow object/local vars and shows or hides wide/narrow image as appropriate
		public function updateFlow(stopObject:Boolean = false):void
		{	
			if(m_flowObject == null)
			{
				//	don't stop these, as they never get updated again if you do
				visible = false;
				return;
			}
			
			if(m_flowObject.flowStartingEdge.from_node.kind == NodeTypes.START_NO_BALL)
			{
				timeline.stop();
				visible = false;
				return;
			}
			
			visible = true;
			
			//determine movement
			if(stopObject)
			{
				//stop at tail of car in front of us, wherever that is
				timeline.stop();
				
			}
			else
			{
				timeline.play();
			}
		}
		public function updateMovement():void
		{
			
		}
		
		protected function setLayerVisible(layer:uint, willBeVisible:Boolean):void
		{
			if(willBeVisible)
				layerArray[layer].visible = willBeVisible;
			
			for(var i:uint = 0; i<Pipe.NUM_CAR_LENGTHS_IN_GROUP;i++)
			{
				rowArray[layer][i].visible = willBeVisible;
			}
			
			
		}
		
		protected function setRowVisible(layer:uint, row:uint, willBeVisible:Boolean):void
		{
			if(willBeVisible)
				layerArray[layer].visible = willBeVisible;

			rowArray[layer][row].visible = willBeVisible;
		}
		
		public function isTroubleSpotInArray(otherDropObjectInfoArray:Array):Boolean
		{
			var isTroubleSpot:Boolean = false;
			//to compare stamps, create an set of all otherEdge stamps, and then see if ours are contained in that set
			var stampArray:Array = new Array;
			for(var index:uint = 0; index<otherDropObjectInfoArray.length; index++)
			{
				var dObj2:DropObjectBase = otherDropObjectInfoArray[index];
				for(var index2:uint=0; index2<dObj2.activeStampVector.length; index2++)
				{
					if(dObj2.activeStampVector[index2] != null)
						stampArray.push(dObj2.activeStampVector[index2]); 
				}
					
			}
			if(isStampTroubleSpot(stampArray))
				isTroubleSpot = true;
			
			//do other tests here....
			
			return isTroubleSpot;
		}
		
		public function isStampTroubleSpot(nextStampSetArray:Array):Boolean
		{
			//first use of this code is to compare stamps, to make sure the current ones transfer to the edge
			for(var index1:uint=0; index1<activeStampVector.length; index1++)
			{
				var currentStamp:StampRef = activeStampVector[index1];
				var found:Boolean = false;
				for(var index2:uint=0; index2<nextStampSetArray.length; index2++)
				{
					var nextStamp:StampRef = nextStampSetArray[index2];
					//if the current stamp is active (and it should be) and we find a matching edge set id, and the next stamp is active
					//(it also should be, then check the next case
					if( currentStamp.active == false || (currentStamp.edge_set_id == nextStamp.edge_set_id && nextStamp.active == true))
					{
						found = true;
						continue;
					}
				}
				if(!found)
					return true;
			}
			return false;
		}
		
		//repeatedly called during update, use to change states
		public function onTimelineUpdate():void {
			
		}
		
		public function onTimelineEnd():void {
		}
		
		public function onBelowPipe():void {
			m_below_pipe = true;
			hide();
		}
		
		public function onBuzz():void {
			m_after_buzz = true;
		}
		
		public function afterPinch():void {
			m_after_pinch = true;
		}
		
		public function reset():void {
			m_below_pipe = false;
			m_after_buzz = false;
			m_after_pinch = false;
			visible = true;
			setLayerVisible(WIDE_LAYER, true);
			setLayerVisible(NARROW_LAYER, true);
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function show():void {
			visible = true;
		}
		
		public function setFlowObject(newFlowObject:FlowObject):void
		{
			m_flowObject = newFlowObject;
		}
	}
}