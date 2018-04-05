package NetworkGraph
{
	import Events.*;
	
	import VisualWorld.VerigameSystem;
	
	import flash.utils.Dictionary;
	
	/* a class to hold flow state - i.e. information for Drop Objects that needs to flow down the edges, such as current size. */
	public class FlowObject
	{
		public var _starting_ball_type:Number;
		public var exit_ball_type:Number;
		public var m_color:Number;
		public var m_edgeHasBuzz:Boolean;
		public var m_edgeHasPinch:Boolean;
		
		public var parentFlowObject:FlowObject;
		public var childrenFlowObjectArray:Array;
		public var flowStartingEdge:Edge;
		public var associatedEdge:Edge;
		
		//a unique id
		public var objectID:uint;
		
		private static var objCount:uint = 0;

		// create a new object, must be from a starting edge, else we would use createChildCopy
		public function FlowObject(_associatedEdge:Edge, startingEdge:Edge, startingBallType:Number = 0)
		{
			associatedEdge = _associatedEdge;
			flowStartingEdge = startingEdge;
			
			if(startingBallType == VerigameSystem.BALL_TYPE_NONE)
				starting_ball_type = startingBallType;
			else
				starting_ball_type = associatedEdge.is_wide ? VerigameSystem.BALL_TYPE_WIDE : VerigameSystem.BALL_TYPE_NARROW;
			exit_ball_type = VerigameSystem.BALL_TYPE_UNDETERMINED;
			objectID = objCount;
			objCount++;
			parentFlowObject = null;
			childrenFlowObjectArray = new Array;
			m_color = startingEdge.associated_pipe.theme_color;
			m_edgeHasBuzz = associatedEdge.has_buzzsaw;
			m_edgeHasPinch = associatedEdge.has_pinch;
		}
		
		// create a new object, updating ball types to be correct for child edges
		public function createChildCopy(parent:Edge):FlowObject
		{
			var newObject:FlowObject = new FlowObject(parent, this.flowStartingEdge, this.exit_ball_type);
			newObject.starting_ball_type = this.exit_ball_type;
			newObject.parentFlowObject = this;
			this.childrenFlowObjectArray.push(newObject);
			return newObject;
		}
		
		public function updateOnEdgeChange(edge:Edge, recursive:Boolean):void
		{
			switch(flowStartingEdge.from_node.kind)
			{
				case NodeTypes.START_LARGE_BALL:
					starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
					break;
				case NodeTypes.INCOMING:
				case NodeTypes.START_PIPE_DEPENDENT_BALL:
					if(edge.is_wide)
						starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
					else
						starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
					break;
				case NodeTypes.START_SMALL_BALL:
					starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
					break;
				case NodeTypes.START_NO_BALL:
					starting_ball_type = VerigameSystem.BALL_TYPE_NONE;
					break;
				default:
					starting_ball_type = this.parentFlowObject.exit_ball_type;
			}
			
			if(starting_ball_type == VerigameSystem.BALL_TYPE_WIDE && edge.has_pinch)
				exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
			else if(edge.has_buzzsaw)
				exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
			else
				exit_ball_type = starting_ball_type;
			
			m_edgeHasBuzz = edge.has_buzzsaw;
			
			if(recursive)
			{
				for each(var childFlowObj:FlowObject in childrenFlowObjectArray)
				{
					childFlowObj.updateFromFlowObject(this, true);
				}
			}
		}
		
		public function updateChildren(recursive:Boolean):void
		{
			for each(var childFlowObj:FlowObject in childrenFlowObjectArray)
			{
				childFlowObj.updateFromFlowObject(this, recursive);
			}
		}
		
		public function updateFromFlowObject(flowObject:FlowObject, recursive:Boolean):void
		{
			starting_ball_type = flowObject.exit_ball_type;
			//allow normal travel if you get on a pipe that has a blocked top
			if(starting_ball_type != VerigameSystem.BALL_TYPE_NONE)
				exit_ball_type = starting_ball_type;
			else
			{
				if(this.associatedEdge.associated_pipe.is_wide)
					starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
				else
					starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
				
				exit_ball_type = starting_ball_type;
			}
			
			if(recursive)
			{
				for each(var childFlowObj:FlowObject in childrenFlowObjectArray)
				{
					childFlowObj.updateFromFlowObject(this, true);
				}
			}
		}
		
		public function compare(otherObject:FlowObject):Boolean
		{
			if(otherObject.starting_ball_type != this.starting_ball_type ||
				otherObject.flowStartingEdge.edge_id != this.flowStartingEdge.edge_id)
					return false;
			
			return true;
		}
		
		public function checkForTroubleSpotsInArray(otherDropObjectInfoArray:Array):Boolean
		{
			//in here we should be checking widths, and other relevant stuff
			return false;
		}
		
		public function set starting_ball_type(newValue:uint):void
		{
			_starting_ball_type = newValue;
		}
		
		public function get starting_ball_type():uint
		{
			return _starting_ball_type;
		}
		
	}
}