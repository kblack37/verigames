package networkGraph;

import events.*;
import visualWorld.VerigameSystem;
import flash.utils.Dictionary;

/* a class to hold flow state - i.e. information for Drop Objects that needs to flow down the edges, such as current size. */
class FlowObject
{
    public var starting_ball_type(get, set) : Int;

    public var _starting_ball_type : Float;
    public var exit_ball_type : Float;
    public var m_color : Float;
    public var m_edgeHasBuzz : Bool;
    public var m_edgeHasPinch : Bool;
    
    public var parentFlowObject : FlowObject;
    public var childrenFlowObjectArray : Array<Dynamic>;
    public var flowStartingEdge : Edge;
    public var associatedEdge : Edge;
    
    //a unique id
    public var objectID : Int;
    
    private static var objCount : Int = 0;
    
    // create a new object, must be from a starting edge, else we would use createChildCopy
    public function new(_associatedEdge : Edge, startingEdge : Edge, startingBallType : Float = 0)
    {
        associatedEdge = _associatedEdge;
        flowStartingEdge = startingEdge;
        
        if (startingBallType == VerigameSystem.BALL_TYPE_NONE)
        {
            starting_ball_type = as3hx.Compat.parseInt(startingBallType);
        }
        else
        {
            starting_ball_type = (associatedEdge.is_wide) ? VerigameSystem.BALL_TYPE_WIDE : VerigameSystem.BALL_TYPE_NARROW;
        }
        exit_ball_type = VerigameSystem.BALL_TYPE_UNDETERMINED;
        objectID = objCount;
        objCount++;
        parentFlowObject = null;
        childrenFlowObjectArray = new Array<Dynamic>();
        m_color = startingEdge.associated_pipe.theme_color;
        m_edgeHasBuzz = associatedEdge.has_buzzsaw;
        m_edgeHasPinch = associatedEdge.has_pinch;
    }
    
    // create a new object, updating ball types to be correct for child edges
    public function createChildCopy(parent : Edge) : FlowObject
    {
        var newObject : FlowObject = new FlowObject(parent, this.flowStartingEdge, this.exit_ball_type);
        newObject.starting_ball_type = this.exit_ball_type;
        newObject.parentFlowObject = this;
        this.childrenFlowObjectArray.push(newObject);
        return newObject;
    }
    
    public function updateOnEdgeChange(edge : Edge, recursive : Bool) : Void
    {
        var _sw4_ = (flowStartingEdge.from_node.kind);        

        switch (_sw4_)
        {
            case NodeTypes.START_LARGE_BALL:
                starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
            case NodeTypes.INCOMING, NodeTypes.START_PIPE_DEPENDENT_BALL:
                if (edge.is_wide)
                {
                    starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
                }
                else
                {
                    starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
                }
            case NodeTypes.START_SMALL_BALL:
                starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
            case NodeTypes.START_NO_BALL:
                starting_ball_type = VerigameSystem.BALL_TYPE_NONE;
            default:
                starting_ball_type = this.parentFlowObject.exit_ball_type;
        }
        
        if (starting_ball_type == VerigameSystem.BALL_TYPE_WIDE && edge.has_pinch)
        {
            exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
        }
        else if (edge.has_buzzsaw)
        {
            exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
        }
        else
        {
            exit_ball_type = starting_ball_type;
        }
        
        m_edgeHasBuzz = edge.has_buzzsaw;
        
        if (recursive)
        {
            for (childFlowObj in childrenFlowObjectArray)
            {
                childFlowObj.updateFromFlowObject(this, true);
            }
        }
    }
    
    public function updateChildren(recursive : Bool) : Void
    {
        for (childFlowObj in childrenFlowObjectArray)
        {
            childFlowObj.updateFromFlowObject(this, recursive);
        }
    }
    
    public function updateFromFlowObject(flowObject : FlowObject, recursive : Bool) : Void
    {
        starting_ball_type = flowObject.exit_ball_type;
        //allow normal travel if you get on a pipe that has a blocked top
        if (starting_ball_type != VerigameSystem.BALL_TYPE_NONE)
        {
            exit_ball_type = starting_ball_type;
        }
        else
        {
            if (this.associatedEdge.associated_pipe.is_wide)
            {
                starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
            }
            else
            {
                starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
            }
            
            exit_ball_type = starting_ball_type;
        }
        
        if (recursive)
        {
            for (childFlowObj in childrenFlowObjectArray)
            {
                childFlowObj.updateFromFlowObject(this, true);
            }
        }
    }
    
    public function compare(otherObject : FlowObject) : Bool
    {
        if (otherObject.starting_ball_type != this.starting_ball_type ||
            otherObject.flowStartingEdge.edge_id != this.flowStartingEdge.edge_id)
        {
            return false;
        }
        
        return true;
    }
    
    public function checkForTroubleSpotsInArray(otherDropObjectInfoArray : Array<Dynamic>) : Bool
    //in here we should be checking widths, and other relevant stuff
    {
        
        return false;
    }
    
    private function set_starting_ball_type(newValue : Int) : Int
    {
        _starting_ball_type = newValue;
        return newValue;
    }
    
    private function get_starting_ball_type() : Int
    {
        return as3hx.Compat.parseInt(_starting_ball_type);
    }
}
