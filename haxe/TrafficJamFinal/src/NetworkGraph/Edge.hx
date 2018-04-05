package networkGraph;

import flash.errors.Error;
import events.*;
import networkGraph.Node;
import utilities.Geometry;
import utilities.Metadata;
import visualWorld.Ball;
import visualWorld.Board;
import visualWorld.Car;
import visualWorld.DropObjectBase;
import visualWorld.Pipe;
import visualWorld.Theme;
import visualWorld.TroublePoint;
import visualWorld.VerigameSystem;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;

/**
	 * Directed Edge created when a graph structure is read in from XML.
	 */
class Edge extends EventDispatcher
{
    public var associated_pipe(get, set) : Pipe;
    public var midpoint(get, never) : Point;
    public var from_node(get, never) : Node;
    public var to_node(get, never) : Node;
    public var from_port_id(get, never) : String;
    public var to_port_id(get, never) : String;

    /* Network connections */
    /** Port on source node */
    public var from_port : Port;
    
    /** Port on destination node */
    public var to_port : Port;
    
    /** Any extra information contained in the orginal XML for this edge */
    public var metadata : Dynamic;
    
    /** The numerical index (starting at 0 = first) corresponding to the linked edge set (by level) that this edge belongs to */
    public var linked_edge_set : EdgeSetRef;
    
    /* Edge identifiers */
    /** Name of the variable provided in XML */
    public var description : String = "";
    
    /** The unique id given as input from XML (unique within a given world) */
    public var edge_id : String;
    
    /** Id of the variable identified in XML */
    public var variableID : Int;
    
    /** The spline control points associated with this edge for drawing purposes */
    public var spline_control_points : Array<Point>;
    
    /** The pipe object (if any) created from this edge */
    public var _associated_pipe : Pipe;
    
    /** pointers back up to all starting edges that can reach this edge. */
    public var topmostEdgeDictionary : Dictionary = new Dictionary();
    public var topmostEdgeIDArray : Array<Dynamic> = new Array<Dynamic>();
    
    /* Starting state of the pipe */
    /** True if edge has attribute width="wide" in XML, false otherwise */
    public var starting_is_wide : Bool = false;
    
    /** True if edge has attribute buzzsaw="true" in XML, false otherwise */
    public var starting_has_buzzsaw : Bool = false;
    
    /** True if this edge's width can be changed by the user, if false pipe is gray and cannot be changed */
    public var editable : Bool = false;
    
    /* current state of the pipe */
    /** True if edge has attribute width="wide" in XML, false otherwise */
    public var is_wide : Bool = false;
    
    /** True if edge has attribute buzzsaw="true" in XML, false otherwise */
    public var has_buzzsaw : Bool = false;
    
    /** True if this edge contains a pinch point, false otherwise */
    public var has_pinch : Bool = false;
    
    /* Flow state information */
    /** an array of values for the drop objects, a set for each incoming pipe (one for each parent that's a starting node) **/
    public var dropObjectFlowStateEdgeIDArray : Array<Dynamic> = new Array<Dynamic>();
    
    /* used for lookup so we don't create/store multiple copies of them. */
    public var dropObjectFlowStateCache : Dictionary = new Dictionary();
    
    private var currentFlowStateObjectIndex : Int = 0;
    
    /** used to mark nodes that think they are starting nodes, and we check later if they actually are. 
		 I think this is only a situation that arises on mismade boards (like some I hand created) but I'll handle the case anyway as it helps with debugging
		*/
    public var isStartingNode : Bool;
    
    /**
		 * Directed Edge created when a graph structure is read in from XML.
		 * @param	_from_node Source node
		 * @param	_from_port Port on source node
		 * @param	_to_node Destination node
		 * @param	_to_port Port on destination node
		 * @param   _spline_control_points Points defining the spline to connect the from_node to the to_node
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
    public function new(_from_node : Node, _from_port_id : String, _to_node : Node, _to_port_id : String, _spline_control_points : Array<Point> = null, _linked_edge_set : EdgeSetRef = null, _metadata : Dynamic = null)
    {
        super();
        if (Std.is(_from_node, SubnetworkNode))
        {
            from_port = new SubnetworkPort((try cast(_from_node, SubnetworkNode) catch(e:Dynamic) null), this, _from_port_id, Port.OUTGOING_PORT_TYPE);
        }
        else
        {
            from_port = new Port(_from_node, this, _from_port_id, Port.OUTGOING_PORT_TYPE);
        }
        
        if (Std.is(_to_node, SubnetworkNode))
        {
            to_port = new SubnetworkPort((try cast(_to_node, SubnetworkNode) catch(e:Dynamic) null), this, _to_port_id, Port.INCOMING_PORT_TYPE);
        }
        else
        {
            to_port = new Port(_to_node, this, _to_port_id, Port.INCOMING_PORT_TYPE);
        }
        
        metadata = _metadata;
        linked_edge_set = _linked_edge_set;
        if (_metadata == null)
        {
            metadata = new Metadata(null);
        }
        else if (_metadata.data != null)
        
        //Example: <edge description="chute1" variableID="-1" pinch="false" width="wide" id="e1" buzzsaw="false">{
            
            if (metadata.data.description)
            {
                if (Std.string(metadata.data.description).length > 0)
                {
                    description = Std.string(metadata.data.description);
                }
            }
            if (metadata.data.variableID)
            {
                if (!Math.isNaN(as3hx.Compat.parseInt(metadata.data.variableID)))
                {
                    variableID = as3hx.Compat.parseInt(metadata.data.variableID);
                }
            }
            if (Std.string(metadata.data.pinch).toLowerCase() == "true")
            {
                has_pinch = true;
            }
            if (Std.string(metadata.data.editable).toLowerCase() == "true")
            {
                editable = true;
            }
            if (Std.string(metadata.data.width).toLowerCase() == "wide")
            {
                starting_is_wide = true;
                is_wide = true;
            }
            if (Std.string(metadata.data.buzzsaw).toLowerCase() == "true")
            {
                starting_has_buzzsaw = true;
                has_buzzsaw = true;
            }
            if (Std.string(_metadata.data.id).length > 0)
            {
                edge_id = Std.string(_metadata.data.id);
            }
        }
        _associated_pipe = null;
        
        // Default is to add control points to make a straight line between endpoints
        spline_control_points = _spline_control_points;
        if (spline_control_points == null)
        {
            spline_control_points = new Array<Point>();
        }
        
        if (spline_control_points.length < 4)
        
        // If none supplied, assume a straight line (from_node -> to_node){
            
            spline_control_points = new Array<Point>();
            var from_point : Point = new Point(from_node.x, from_node.y);
            spline_control_points.push(from_point);
            spline_control_points.push(from_point);
            var to_point : Point = new Point(to_node.x, to_node.y);
            spline_control_points.push(to_point);
            spline_control_points.push(to_point);
        }
        
        Network.edgeDictionary[edge_id] = this;
    }
    
    private function set_associated_pipe(p : Pipe) : Pipe
    //		if(_associated_pipe != null)
    {
        
        //			_associated_pipe.removeEventListener(PipeChangeEvent.PIPE_CHANGE, onPipeChange);
        _associated_pipe = p;
        return p;
    }
    
    private function get_associated_pipe() : Pipe
    {
        return _associated_pipe;
    }
    
    public function pipeChanged() : Void
    //Update local variables
    {
        
        is_wide = associated_pipe.is_wide;
        has_buzzsaw = associated_pipe.has_buzzsaw;
    }
    
    public function updateEdgeWidth(isWide : Bool) : Void
    {
        if (editable)
        {
            is_wide = isWide;
        }
    }
    
    //set has_buzzsaw var to true or false depending if pipe
    //then recurse through children, passing down value, except if value = false, and child pipe does actually have one, then pass true
    public function updateEdgeHasBuzz(hasBuzz : Bool = true) : Void
    {
        has_buzzsaw = hasBuzz;
        
        //update flow objects and their children
        updateFlowObjects(true);
    }
    
    public function updateFlowObjects(recursive : Bool) : Void
    {
        for (flowObjID/* AS3HX WARNING could not determine type for var: flowObjID exp: EField(EIdent(this),dropObjectFlowStateEdgeIDArray) type: null */ in this.dropObjectFlowStateEdgeIDArray)
        {
            var flowObj : FlowObject = this.dropObjectFlowStateCache[flowObjID];
            flowObj.updateOnEdgeChange(this, recursive);
        }
    }
    public function addToFlowStateStore(newDropObjectFlowState : FlowObject) : Void
    //if we currently have an exact match, skip this
    {
        
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        {
            var id : Int = dropObjectFlowStateEdgeIDArray[index];
            var flowStateObject : FlowObject = dropObjectFlowStateCache[id];
            if (flowStateObject.compare(newDropObjectFlowState) == true)
            {
                return;
            }
        }
        
        dropObjectFlowStateEdgeIDArray.push(newDropObjectFlowState.objectID);
        dropObjectFlowStateCache[newDropObjectFlowState.objectID] = newDropObjectFlowState;
    }
    
    public function removeFromFlowStateStore(dropObject : FlowObject) : Void
    {
        var index : Int = Lambda.indexOf(dropObjectFlowStateEdgeIDArray, dropObject.objectID);
        if (index != -1)
        {
            dropObjectFlowStateEdgeIDArray.splice(index, 1);
            This is an intentional compilation error. See the README for handling the delete keyword
            delete dropObjectFlowStateCache[null];
        }
    }
    
    public function getCurrentFlowObject() : FlowObject
    {
        var arrayLength : Int = dropObjectFlowStateEdgeIDArray.length;
        var currentIndex : Int = currentFlowStateObjectIndex;
        
        //resimulation might change the number of flow objects
        if (currentIndex >= arrayLength)
        {
            currentIndex = 0;
        }
        
        currentFlowStateObjectIndex = as3hx.Compat.parseInt((currentFlowStateObjectIndex + 1) % arrayLength);
        
        var flowObjID : Int = dropObjectFlowStateEdgeIDArray[currentIndex];
        return this.dropObjectFlowStateCache[flowObjID];
    }
    
    //find this edge's flow object with this flow Object as parent
    public function findSimilarFlowObject(flowObject : FlowObject) : FlowObject
    {
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        {
            var id : Int = dropObjectFlowStateEdgeIDArray[index];
            var ourFlowObject : FlowObject = dropObjectFlowStateCache[id];
            if (ourFlowObject.parentFlowObject == flowObject)
            {
                return ourFlowObject;
            }
        }
        
        return null;
    }
    
    //loop over flow objects fixing up starting ball types
    public function setStartingBallType() : Void
    {
        var flowObject : FlowObject;
        if (from_port.node.kind != NodeTypes.SUBBOARD && dropObjectFlowStateEdgeIDArray.length == 0)
        {
            this.createDropObjectFlowArray();
            flowObject = new FlowObject(this, this);  //only get's called for starting edges  
            addToFlowStateStore(flowObject);
        }
        //grab first (and only) existing one
        else
        {
            
            flowObject = Reflect.field(dropObjectFlowStateCache, Std.string(dropObjectFlowStateEdgeIDArray[0]));
        }
        
        var _sw1_ = (from_port.node.kind);        

        switch (_sw1_)
        {  // TODO: not totally clear in this case, just stick to wide for wide, small for small - CC: I think this is right  
            case NodeTypes.INCOMING, NodeTypes.START_PIPE_DEPENDENT_BALL:
                flowObject.starting_ball_type = (is_wide) ? VerigameSystem.BALL_TYPE_WIDE : VerigameSystem.BALL_TYPE_NARROW;
            case NodeTypes.START_LARGE_BALL:
                flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
            case NodeTypes.START_NO_BALL:
                flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NONE;
            case NodeTypes.START_SMALL_BALL:
                flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
            default:
                trace("FOUND a " + from_node.kind);
        }
    }
    
    
    /*This sets up the default exit ball type, which will be modified if there are trouble points along the way */
    public function setExitBallType() : Bool
    {
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        {
            var edgeID : String = dropObjectFlowStateEdgeIDArray[index];
            var flowObject : FlowObject = Reflect.field(dropObjectFlowStateCache, edgeID);
            
            // Set outgoing ball type
            var _sw2_ = (flowObject.starting_ball_type);            

            switch (_sw2_)
            {
                case VerigameSystem.BALL_TYPE_NONE, VerigameSystem.BALL_TYPE_GHOST:
                    flowObject.exit_ball_type = flowObject.starting_ball_type;
                case VerigameSystem.BALL_TYPE_WIDE, VerigameSystem.BALL_TYPE_NARROW, VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
                    if (has_buzzsaw)
                    {
                        flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
                    }
                    else
                    {
                        flowObject.exit_ball_type = flowObject.starting_ball_type;
                    }
                default:
                    throw new Error("Flow sensitive Simulator: Ball type not defined - ");
            }
        }
        
        return true;
    }
    
    public function isStartingEdge() : Bool
    {
        var _sw3_ = (from_node.kind);        

        switch (_sw3_)
        {
            case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.INCOMING:
            //	case NodeTypes.SUBBOARD:
            return true;
        }
        
        return false;
    }
    
    
    /*
		clear old (when simulator starts to run) and
		create new Drop Object Info object for the edge
		*/
    public function createDropObjectFlowArray() : Void
    {
        isStartingNode = true;
        dropObjectFlowStateEdgeIDArray = new Array<Dynamic>();
        dropObjectFlowStateCache = new Dictionary();
    }
    
    //returns the active stamps associated with this edge
    private function getActiveStampVector() : Array<StampRef>
    {
        var activeStampVector : Array<StampRef> = new Array<StampRef>();
        
        var numActiveStamps : Int = linked_edge_set.num_active_stamps;
        for (i in 0...numActiveStamps)
        {
            var activeStamp : StampRef = linked_edge_set.getActiveStampAt(i);
            activeStampVector[activeStampVector.length] = activeStamp;
        }
        
        return activeStampVector;
    }
    
    /*
			copy current DropObjectInfo into the new edge, usually from parent to child
		*/
    public function copyDropObjectFlowInfoToEdge(newEdge : Edge = null) : Void
    //copy all of parent's drop info object to here
    {
        
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        
        //create object and then copy over relevant data{
            
            var parentFOEdgeID : String = dropObjectFlowStateEdgeIDArray[index];
            var parentFlowStateObj : FlowObject = Reflect.field(dropObjectFlowStateCache, parentFOEdgeID);
            
            //that we get here is probably an error, but for the time being...
            if (parentFlowStateObj.exit_ball_type == VerigameSystem.BALL_TYPE_UNDETERMINED)
            {
                parentFlowStateObj.exit_ball_type = parentFlowStateObj.starting_ball_type;
            }
            //check to make sure both parent and child have flow objects, else copy down
            if (parentFlowStateObj.childrenFlowObjectArray.length == 0 || newEdge.dropObjectFlowStateEdgeIDArray.length == 0)
            {
                var newDropObjectFlowStateObj : FlowObject = parentFlowStateObj.createChildCopy(newEdge);
                newEdge.addToFlowStateStore(newDropObjectFlowStateObj);
            }
            else
            {
                for (childFlowObj/* AS3HX WARNING could not determine type for var: childFlowObj exp: EField(EIdent(parentFlowStateObj),childrenFlowObjectArray) type: null */ in parentFlowStateObj.childrenFlowObjectArray)
                {
                    childFlowObj._starting_ball_type = parentFlowStateObj.exit_ball_type;
                }
            }
        }
    }
    
    /* check for all edge related trouble spots
			ball and width issues - pinchpoints, buzzsaws
			exit issues -outgoing size compared to next ports
			drop object issues - existing stamps versus allowed ones
		*/
    public function checkForTroubleSpots(resultsDictionary : Dictionary) : Void
    {
        var listEdgeTroublePointsVector : Array<Edge> = Reflect.field(resultsDictionary, "edge");
        var listPortTroublePointsVector : Array<Port> = Reflect.field(resultsDictionary, "port");
        
        if (hasWidthTroubleSpot())
        {
            if (Lambda.indexOf(listEdgeTroublePointsVector, this) == -1)
            {
                listEdgeTroublePointsVector.push(this);
            }
        }
        
        var problemPort : Port = hasExitTroubleSpot();
        if (problemPort != null)
        {
            if (Lambda.indexOf(listPortTroublePointsVector, to_port) == -1)
            {
                listPortTroublePointsVector.push(to_port);
            }
            if (Lambda.indexOf(listPortTroublePointsVector, problemPort) == -1)
            {
                listPortTroublePointsVector.push(problemPort);
            }
        }
    }
    
    //check incoming edges vs. outgoing, taking into account buzzsaws and pinch points
    public function hasWidthTroubleSpot() : Bool
    {
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        {
            var edgeID : String = dropObjectFlowStateEdgeIDArray[index];
            var flowObject : FlowObject = Reflect.field(dropObjectFlowStateCache, edgeID);
            
            var in_type : Int = flowObject.starting_ball_type;
            var out_type : Int = flowObject.exit_ball_type;
            switch (in_type)
            {
                case VerigameSystem.BALL_TYPE_WIDE, VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
                    if (out_type != VerigameSystem.BALL_TYPE_NARROW)
                    {
                        if (this.has_pinch)
                        {
                            flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
                            
                            flowObject.updateChildren(true);
                            return true;
                        }
                    }
            }
        }
        return false;
    }
    
    //check outgoing nodes, our ingoing port versus all outgoing ports
    //return outgoing port that we have issues with, or null
    public function hasExitTroubleSpot() : Port
    {
        var outgoingNode : Node = this.to_node;
        
        for (index in 0...dropObjectFlowStateEdgeIDArray.length)
        
        //find my exit ball sizes{
            
            var edgeID : String = dropObjectFlowStateEdgeIDArray[index];
            var flowObject : FlowObject = Reflect.field(dropObjectFlowStateCache, edgeID);
            var exitBallType : Int = flowObject.exit_ball_type;
            
            //check for width issues
            var outgoingPort : Port = hasExitWidthTroubleSpot(outgoingNode, flowObject);
            
            if (outgoingPort != null)
            {
                return outgoingPort;
            }
            
            
            //check for stamp conflicts (i.e. next road has stamps that current car doesn't)
            outgoingPort = hasStampTroubleSpot(outgoingNode, flowObject);
            
            if (outgoingPort != null)
            {
                return outgoingPort;
            }
        }
        return null;
    }
    
    public function hasExitWidthTroubleSpot(outgoingNode : Node, flowObject : FlowObject) : Port
    {
        var exitBallType : Int = flowObject.exit_ball_type;
        
        for (outgoingPortIndex in 0...outgoingNode.outgoing_ports.length)
        {
            var outgoingPort : Port = outgoingNode.outgoing_ports[outgoingPortIndex];
            
            if (!outgoingPort.edge.is_wide && (exitBallType == VerigameSystem.BALL_TYPE_WIDE))
            {
                var foundProblem : Bool = false;
                for (nextEdgeFOIndex in 0...outgoingPort.edge.dropObjectFlowStateEdgeIDArray.length)
                {
                    var nextEdgeFOID : String = outgoingPort.edge.dropObjectFlowStateEdgeIDArray[nextEdgeFOIndex];
                    var nextEdgeFOFlowObject : FlowObject = outgoingPort.edge.dropObjectFlowStateCache[nextEdgeFOID];
                    //make sure we are dealing with our children only
                    if (flowObject.objectID == nextEdgeFOFlowObject.parentFlowObject.objectID)
                    {
                        if (exitBallType == VerigameSystem.BALL_TYPE_WIDE_AND_NARROW)
                        
                        //this state shouldn't exist, but until I'm sure I'll leave it here{
                            
                            nextEdgeFOFlowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
                            foundProblem = true;
                        }
                        else if (exitBallType == VerigameSystem.BALL_TYPE_WIDE)
                        {
                            flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NONE;
                            nextEdgeFOFlowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
                            foundProblem = true;
                        }
                    }
                }
                if (foundProblem)
                {
                    return outgoingPort;
                }
            }
        }
        return null;
    }
    
    public function hasStampTroubleSpot(outgoingNode : Node, flowObject : FlowObject) : Port
    {
        var objectStampVector : Array<StampRef> = flowObject.flowStartingEdge.getActiveStampVector();
        for (outgoingPort/* AS3HX WARNING could not determine type for var: outgoingPort exp: EField(EIdent(outgoingNode),outgoing_ports) type: null */ in outgoingNode.outgoing_ports)
        {
            var edgeStampVector : Array<StampRef> = outgoingPort.edge.getActiveStampVector();
            
            //for each stamp on the road, make sure there is a similar one on the object
            for (index1 in 0...edgeStampVector.length)
            {
                var edgeStamp : StampRef = edgeStampVector[index1];
                var found : Bool = false;
                for (index2 in 0...objectStampVector.length)
                {
                    var objectStamp : StampRef = objectStampVector[index2];
                    //if the current stamp is active (and it should be) and we find a matching edge set id, and the next stamp is active
                    //(it also should be), then check the next case
                    if (edgeStamp.edge_set_id == objectStamp.edge_set_id)
                    {
                        found = true;
                        continue;
                    }
                }
                if (!found)
                {
                    flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NONE;
                    return outgoingPort;
                }
            }
        }
        return null;
    }
    
    //notify prior edge(s) that it needs to redraw (update)
    public function updatePriorEdges() : Void
    {
        for (port/* AS3HX WARNING could not determine type for var: port exp: EField(EIdent(from_node),incoming_ports) type: null */ in from_node.incoming_ports)
        {
            port.edge.associated_pipe.draw();
        }
    }
    
    private function get_midpoint() : Point
    {
        var my_pt : Point = _associated_pipe.getXYbyT(0.5);
        return my_pt;
    }
    
    private function get_from_node() : Node
    {
        return from_port.node;
    }
    
    private function get_to_node() : Node
    {
        return to_port.node;
    }
    
    private function get_from_port_id() : String
    {
        return from_port.port_id;
    }
    
    private function get_to_port_id() : String
    {
        return to_port.port_id;
    }
}
