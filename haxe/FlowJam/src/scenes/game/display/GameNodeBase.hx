package scenes.game.display;

import flash.errors.Error;
import flash.geom.Point;
import flash.utils.Dictionary;
import graph.PropDictionary;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import constraints.ConstraintVar;
import events.GameComponentEvent;
import events.GroupSelectionEvent;
import events.MoveEvent;
import events.UndoEvent;
import utils.XMath;

class GameNodeBase extends GameComponent
{
    private var isMoving(get, set) : Bool;

    public var costume : DisplayObject;
    private var shapeWidth : Float = 100.0;
    private var shapeHeight : Float = 100.0;
    
    public var storedXPosition : Int;
    public var storedYPosition : Int;
    
    public var constraintVar : ConstraintVar;
    private var m_layoutObj : Dynamic;
    public var orderedOutgoingEdges : Array<GameEdgeContainer>;
    public var orderedIncomingEdges : Array<GameEdgeContainer>;
    
    private var m_edgePortArray : Array<Dynamic>;
    private var m_incomingPortsToEdgeDict : Dictionary;
    private var m_outgoingPortsToEdgeDict : Dictionary;
    
    private static var WIDTH_CHANGE : String = "width_change";
    
    public function new(_layoutObj : Dynamic, _constraintVar : ConstraintVar)
    {
        super(_constraintVar.id);
        constraintVar = _constraintVar;
        m_layoutObj = _layoutObj;
        
        orderedOutgoingEdges = new Array<GameEdgeContainer>();
        orderedIncomingEdges = new Array<GameEdgeContainer>();
        m_incomingPortsToEdgeDict = new Dictionary();
        m_outgoingPortsToEdgeDict = new Dictionary();
        m_edgePortArray = new Array<Dynamic>();
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    override public function getProps() : PropDictionary
    {
        return constraintVar.getProps().clone();
    }
    
    public function updatePortIndexes() : Void
    //sort things
    {
        
        orderedOutgoingEdges.sort(GameEdgeContainer.sortOutgoingXPositions);
        orderedIncomingEdges.sort(GameEdgeContainer.sortIncomingXPositions);
        var currentPos : Int = 0;
        m_edgePortArray = new Array<Dynamic>();
        var i : Int;
        var j : Int;
        // Reset positions to -1
        for (i in 0...orderedOutgoingEdges.length)
        {
            orderedOutgoingEdges[i].outgoingEdgePosition = -1;
        }
        for (j in 0...orderedIncomingEdges.length)
        {
            orderedIncomingEdges[j].incomingEdgePosition = -1;
        }
        for (i in 0...orderedOutgoingEdges.length)
        
        // m_outgoingEdges have been ordered from min X to{
            
            // max X so we are moving from left to right
            var startingCurrentPos : Int = currentPos;
            var oedge : GameEdgeContainer = orderedOutgoingEdges[i];
            //if (oedge.outgoingEdgePosition != -1) trace("oedge:" + oedge.m_id + " skipped, outgoingEdgePosition:" + oedge.outgoingEdgePosition);
            if (oedge.outgoingEdgePosition != -1)
            {
                continue;
            }
            var oedgeXPos : Float = oedge.globalStart.x;
            //trace("oedge:" + oedge.m_id + " oedgeXPos:" + oedgeXPos);
            for (j in 0...orderedIncomingEdges.length)
            {
                var iedge : GameEdgeContainer = orderedIncomingEdges[j];
                //if (iedge.incomingEdgePosition != -1) trace("iedge:" + iedge.m_id + " skipped, incomingEdgePosition:" + iedge.incomingEdgePosition);
                if (iedge.incomingEdgePosition != -1)
                {
                    continue;
                }
                var iedgeXPos : Float = iedge.globalEnd.x;
                //trace("iedge:" + iedge.m_id + " iedgeXPos:" + iedgeXPos);
                if (oedgeXPos < iedgeXPos)
                {
                    oedge.outgoingEdgePosition = currentPos;
                    m_edgePortArray[currentPos] = oedge.m_fromPortID;
                    currentPos++;
                    break;
                }
                else
                {
                    iedge.incomingEdgePosition = currentPos;
                    m_edgePortArray[currentPos] = iedge.m_toPortID;
                    currentPos++;
                }
            }
            //no incoming edges, or all incoming edges less than this outgoing edge?
            if (startingCurrentPos == currentPos || oedge.outgoingEdgePosition == -1)
            {
                oedge.outgoingEdgePosition = currentPos;
                m_edgePortArray[currentPos] = oedge.m_fromPortID;
                //trace("leftover oedge:" + oedge.m_id + " assigned:" + currentPos);
                currentPos++;
            }
        }
        
        //pick up any missed ones
        for (j in 0...orderedIncomingEdges.length)
        {
            var edge : GameEdgeContainer = orderedIncomingEdges[j];
            if (edge.incomingEdgePosition == -1)
            {
                edge.incomingEdgePosition = currentPos;
                m_edgePortArray[currentPos] = edge.m_toPortID;
                //trace("edge:" + edge.m_id + " assigned:" + currentPos);
                currentPos++;
            }
        }
    }
    
    override public function dispose() : Void
    {
        if (m_disposed)
        {
            return;
        }
        disposeChildren();
        if (costume != null)
        {
            costume.removeFromParent(true);
        }
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        removeEventListener(TouchEvent.TOUCH, onTouch);
        super.dispose();
    }
    
    private var m_isMoving : Bool = false;
    private function set_isMoving(value : Bool) : Bool
    {
        if (m_isMoving == value)
        {
            return value;
        }
        m_isMoving = value;
        if (m_isMoving)
        {
            disableHover();
        }
        else
        {
            enableHover();
        }
        return value;
    }
    private function get_isMoving() : Bool
    {
        return m_isMoving;
    }
    
    private var hasMovedOutsideClickDist : Bool = false;
    private var startingTouchPoint : Point;
    private var startingPoint : Point;
    private static inline var CLICK_DIST : Float = 0.2;  // if the node is moved just a tiny bit, chances are the user meant to click rather than move  
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Array<Touch> = event.touches;
        var touch : Touch = touches[0];
        super.onTouch(event);
        //trace(m_id);
        if (event.getTouches(this, TouchPhase.ENDED).length)
        {
            if (DEBUG_TRACE_IDS)
            {
                trace("GameNodeBase '" + m_id + "'");
            }
            if (DEBUG_TRACE_IDS)
            {
                for (i in 0...orderedIncomingEdges.length)
                {
                    trace("i:" + orderedIncomingEdges[i].graphConstraint.lhs.id + "->" + orderedIncomingEdges[i].graphConstraint.rhs.id);
                }
            }
            if (DEBUG_TRACE_IDS)
            {
                for (o in 0...orderedOutgoingEdges.length)
                {
                    trace("o:" + orderedOutgoingEdges[o].graphConstraint.lhs.id + "->" + orderedOutgoingEdges[o].graphConstraint.rhs.id);
                }
            }
            
            var undoData : Dynamic;
            var undoEvent : Event;
            if (isMoving)
            
            //if we were moving, stop it, and exit{
                
                {
                    isMoving = false;
                    dispatchEvent(new MoveEvent(MoveEvent.FINISHED_MOVING, this));
                    if (draggable && hasMovedOutsideClickDist)
                    {
                        var startPoint : Point = startingPoint.clone();
                        var endPoint : Point = new Point(x, y);
                        undoEvent = new MoveEvent(MoveEvent.MOVE_EVENT, this, startPoint, endPoint);
                        var eventToDispatch : UndoEvent = new UndoEvent(undoEvent, this);
                        eventToDispatch.levelEvent = true;
                        dispatchEvent(eventToDispatch);
                        hasMovedOutsideClickDist = false;
                        return;
                    }
                }
            }
            
            if (event.shiftKey && event.ctrlKey && !PipeJam3.RELEASE_BUILD)
            {
                this.m_isEditable = !this.m_isEditable;
                this.m_isDirty = true;
            }
            
            //if shift key, select, else change size
            if (!event.shiftKey)
            {
                unflattenConnectedEdges();
                
                var touchClick : Touch = event.getTouch(this, TouchPhase.ENDED);
                var touchPoint : Point = (touchClick != null) ? new Point(touchClick.globalX, touchClick.globalY) : null;
                
                onClicked(touchPoint);
            }
            //shift key down
            else
            {
                
                {
                    if (!draggable)
                    {
                        return;
                    }
                    if (touch.tapCount == 1)
                    {
                        componentSelected(!isSelected);
                        if (isSelected)
                        {
                            dispatchEvent(new GameComponentEvent(GameComponentEvent.COMPONENT_SELECTED, this));
                        }
                        else
                        {
                            dispatchEvent(new GameComponentEvent(GameComponentEvent.COMPONENT_UNSELECTED, this));
                        }
                    }
                    //select/unselect whole group
                    else
                    {
                        
                        {
                            var groupDictionary : Dictionary = new Dictionary();
                            this.findGroup(groupDictionary);
                            var selection : Array<GameComponent> = new Array<GameComponent>();
                            for (comp/* AS3HX WARNING could not determine type for var: comp exp: EIdent(groupDictionary) type: Dictionary */ in groupDictionary)
                            {
                                if (Lambda.indexOf(selection, comp) == -1)
                                {
                                    if (Std.is(comp, GameNodeBase))
                                    {
                                        selection.push(comp);
                                    }
                                }
                            }
                            if (isSelected)
                            
                            //we were selected on the first click{
                                
                                dispatchEvent(new GroupSelectionEvent(GroupSelectionEvent.GROUP_SELECTED, this, selection));
                            }
                            else
                            {
                                dispatchEvent(new GroupSelectionEvent(GroupSelectionEvent.GROUP_UNSELECTED, this, selection));
                            }
                        }
                    }
                }
            }
        }
        else if (event.getTouches(this, TouchPhase.MOVED).length)
        {
            if (touches.length == 1)
            {
                var touchXY : Point = new Point(touch.globalX, touch.globalY);
                touchXY = this.globalToLocal(touchXY);
                if (!isMoving)
                {
                    onHoverEnd();
                    startingTouchPoint = touchXY;
                    startingPoint = new Point(x, y);
                    isMoving = true;
                    hasMovedOutsideClickDist = false;
                    return;
                }
                else if (!hasMovedOutsideClickDist)
                {
                    if (XMath.getDist(startingTouchPoint, touchXY) > CLICK_DIST * Constants.GAME_SCALE)
                    {
                        hasMovedOutsideClickDist = true;
                    }
                    // Don't move if haven't moved outside CLICK_DIST
                    else
                    {
                        
                        return;
                    }
                }
                if (!draggable)
                {
                    return;
                }
                var currentMoveLocation : Point = touch.getLocation(this);
                var previousLocation : Point = touch.getPreviousLocation(this);
                unflattenConnectedEdges();
                dispatchEvent(new MoveEvent(MoveEvent.MOVE_EVENT, this, previousLocation, currentMoveLocation));
            }
        }
    }
    
    private function unflattenConnectedEdges() : Void
    {
        for (oedge1/* AS3HX WARNING could not determine type for var: oedge1 exp: EField(EIdent(this),orderedOutgoingEdges) type: null */ in this.orderedOutgoingEdges)
        {
            oedge1.unflatten();
        }
        for (iedge1/* AS3HX WARNING could not determine type for var: iedge1 exp: EField(EIdent(this),orderedIncomingEdges) type: null */ in this.orderedIncomingEdges)
        {
            iedge1.unflatten();
        }
    }
    
    public function onClicked(pt : Point) : Void
    {  // overriden by children  
        
    }
    
    public function onEnterFrame(event : Event) : Void
    {
        if (m_isDirty)
        {
            removeChildren();
            draw();
            m_isDirty = false;
        }
    }
    
    public function draw() : Void
    {
    }
    
    override public function componentMoved(delta : Point) : Void
    {
        super.componentMoved(delta);
        
        rubberBandEdges(delta);
    }
    
    private function rubberBandEdges(endPt : Point) : Void
    {
        for (oedge1/* AS3HX WARNING could not determine type for var: oedge1 exp: EField(EIdent(this),orderedOutgoingEdges) type: null */ in this.orderedOutgoingEdges)
        {
            oedge1.rubberBandEdge(endPt, true);
        }
        for (iedge1/* AS3HX WARNING could not determine type for var: iedge1 exp: EField(EIdent(this),orderedIncomingEdges) type: null */ in this.orderedIncomingEdges)
        {
            iedge1.rubberBandEdge(endPt, false);
        }
    }
    
    public function drawEdges(rubberBanding : Bool = false) : Void
    {
        for (oedge1/* AS3HX WARNING could not determine type for var: oedge1 exp: EField(EIdent(this),orderedOutgoingEdges) type: null */ in this.orderedOutgoingEdges)
        {
            oedge1.draw();
        }
        for (iedge1/* AS3HX WARNING could not determine type for var: iedge1 exp: EField(EIdent(this),orderedIncomingEdges) type: null */ in this.orderedIncomingEdges)
        {
            iedge1.draw();
        }
    }
    
    //adds edge to outgoing edge method (unless currently in vector), then sorts
    public function setOutgoingEdge(edge : GameEdgeContainer) : Void
    {
        if (Lambda.indexOf(orderedOutgoingEdges, edge) > -1)
        {
            throw new Error("Unexpected: edge already added to Node before setOutgoingEdge call: " + edge.m_id);
        }
        orderedOutgoingEdges.push(edge);
        edge.m_fromPortID = orderedOutgoingEdges.length + orderedIncomingEdges.length - 1;
        if (m_outgoingPortsToEdgeDict.exists(edge.m_fromPortID))
        {
            throw new Error("Multiple outgoing edges found with same port id: " + edge.m_fromPortID + " node:" + m_id + " edge id:" + edge.m_id);
        }
        m_outgoingPortsToEdgeDict[edge.m_fromPortID] = edge;
        
        //I want the edges to be in ascending order according to x position, so do that here
        //only works when added to stage, so don't rely on initial placements
        orderedOutgoingEdges.sort(GameEdgeContainer.sortOutgoingXPositions);
    }
    
    //adds edge to incoming edge method (unless currently in vector), then sorts
    public function setIncomingEdge(edge : GameEdgeContainer) : Void
    {
        if (Lambda.indexOf(orderedIncomingEdges, edge) > -1)
        {
            throw new Error("Unexpected: edge already added to Node before setIncomingEdge call: " + edge.m_id);
        }
        orderedIncomingEdges.push(edge);
        edge.m_toPortID = orderedOutgoingEdges.length + orderedIncomingEdges.length - 1;
        if (m_incomingPortsToEdgeDict.exists(edge.m_toPortID))
        {
            throw new Error("Multiple incoming edges found with same port id: " + edge.m_toPortID + " node:" + m_id + " edge id:" + edge.m_id);
        }
        m_incomingPortsToEdgeDict[edge.m_toPortID] = edge;
        
        //I want the edges to be in ascending order according to x position, so do that here
        //only works when added to stage, so don't rely on initial placements
        orderedIncomingEdges.sort(GameEdgeContainer.sortIncomingXPositions);
    }
    
    public function removeEdges() : Void
    // Delete references to edges, i.e. if recreating them
    {
        
        orderedOutgoingEdges = new Array<GameEdgeContainer>();
        orderedIncomingEdges = new Array<GameEdgeContainer>();
        m_edgePortArray = new Array<Dynamic>();
        m_incomingPortsToEdgeDict = new Dictionary();
        m_outgoingPortsToEdgeDict = new Dictionary();
    }
    
    //used when double clicking a node, handles selecting entire group.
    public function findGroup(dictionary : Dictionary) : Void
    {
        Reflect.setField(dictionary, m_id, this);
        for (oedge1/* AS3HX WARNING could not determine type for var: oedge1 exp: EField(EIdent(this),orderedOutgoingEdges) type: null */ in this.orderedOutgoingEdges)
        {
            if (dictionary[oedge1.m_toNode.m_id] == null)
            {
                oedge1.m_toNode.findGroup(dictionary);
            }
        }
        for (iedge1/* AS3HX WARNING could not determine type for var: iedge1 exp: EField(EIdent(this),orderedIncomingEdges) type: null */ in this.orderedIncomingEdges)
        {
            if (dictionary[iedge1.m_fromNode.m_id] == null)
            {
                iedge1.m_fromNode.findGroup(dictionary);
            }
        }
    }
    
    public function organizePorts(edge : GameEdgeContainer, incrementing : Bool) : Void
    {
        var isEdgeOutgoing : Bool = (edge.m_fromNode == this);
        var edgeIndex : Int;
        var edgeGlobalPt : Point;
        var savedEdgeGlobalPt : Point;
        if (isEdgeOutgoing)
        {
            edgeIndex = edge.outgoingEdgePosition;
            edgeGlobalPt = edge.globalStart;
            savedEdgeGlobalPt = edge.localToGlobal(edge.undoObject.m_savedStartPoint);
        }
        else
        {
            edgeIndex = edge.incomingEdgePosition;
            edgeGlobalPt = edge.globalEnd;
            savedEdgeGlobalPt = edge.localToGlobal(edge.undoObject.m_savedEndPoint);
        }
        
        var nextEdgeIndex : Int = getNextEdgePosition(edgeIndex, incrementing);
        var nextEdge : GameEdgeContainer = edgeAt(nextEdgeIndex);
        if (nextEdge == null)
        {
            trace("nextEdge == null");
        }
        //trace("edgeGlobalPtX:" + edgeGlobalPt.x + " savedEdgeGlobalPtX:" + savedEdgeGlobalPt.x + "edgeIndex:" + edgeIndex + " nextEdgeIndex:" + nextEdgeIndex);
        if (nextEdge != null)
        {
            var isNextEdgeOutgoing : Bool = (nextEdge.m_fromNode == this);
            var nextEdgeGlobalPt : Point = (isNextEdgeOutgoing) ? nextEdge.globalStart : nextEdge.globalEnd;
            var edgeUpdated : Bool = false;
            //trace("nextEdgeGlobalPtX:" + nextEdgeGlobalPt.x + "nextEdgeIndex:" + nextEdgeIndex + " nextEdge:" + (nextEdge ? nextEdge.m_id : null));
            if (incrementing)
            {
                if (nextEdgeGlobalPt.x < edgeGlobalPt.x)
                {
                    updateEdges(edge, nextEdgeGlobalPt, nextEdge, savedEdgeGlobalPt);
                    edgeUpdated = true;
                }
            }
            else if (nextEdgeGlobalPt.x > edgeGlobalPt.x)
            {
                updateEdges(edge, nextEdgeGlobalPt, nextEdge, savedEdgeGlobalPt);
                edgeUpdated = true;
            }
            
            if (edgeUpdated)
            {
                switchEdgePositions(edge, edgeIndex, nextEdge, nextEdgeIndex);
            }
        }
    }
    
    //find and return the position in the port array for the next edge, or -1
    private function getNextEdgePosition(currentPos : Int, increasing : Bool) : Int
    {
        var i : Int;
        if (increasing)
        {
            currentPos++;
            for (i in currentPos...m_edgePortArray.length)
            {
                if (edgeAt(currentPos))
                {
                    return i;
                }
            }
        }
        else
        {
            currentPos--;
            i = currentPos;
            while (i >= 0)
            {
                if (edgeAt(currentPos))
                {
                    return i;
                }
                i--;
            }
        }
        return -1;
    }
    
    private function edgeAt(edgePortArrayIndex : Int) : GameEdgeContainer
    {
        if (edgePortArrayIndex < 0)
        {
            return null;
        }
        if (edgePortArrayIndex > m_edgePortArray.length - 1)
        {
            return null;
        }
        var port : Int = as3hx.Compat.parseInt(m_edgePortArray[edgePortArrayIndex]);
        if (m_incomingPortsToEdgeDict.exists(port))
        {
            return try cast(m_incomingPortsToEdgeDict[port], GameEdgeContainer) catch(e:Dynamic) null;
        }
        if (m_outgoingPortsToEdgeDict.exists(port))
        {
            return try cast(m_outgoingPortsToEdgeDict[port], GameEdgeContainer) catch(e:Dynamic) null;
        }
        return null;
    }
    
    private function updateEdges(edge : GameEdgeContainer, newPosition : Point, nextEdge : GameEdgeContainer, newNextPosition : Point) : Void
    {
        var isNextEdgeOutgoing : Bool = (nextEdge.m_fromNode == this) ? true : false;
        //for (var ee:int = 0; ee < m_edgePortArray.length; ee++) trace(ee + " p:" + m_edgePortArray[ee] + " e:" + (edgeAt(ee) ? edgeAt(ee).m_id : null));////debug
        //trace("rb edge0 " + nextEdge.m_id + " pt:" + (isNextEdgeOutgoing ? nextEdge.m_startPoint : nextEdge.m_endPoint));
        updateEdgePosition(edge, newPosition);
        updateNextEdgePosition(nextEdge, newNextPosition);
        nextEdge.rubberBandEdge(new Point(), isNextEdgeOutgoing);
        //trace("rb edge " + nextEdge.m_id + " pt:" + (isNextEdgeOutgoing ? nextEdge.m_startPoint : nextEdge.m_endPoint));
        
        //edge.hasChanged = true;
        edge.restoreEdge = false;
    }
    
    //update edge and extension edge to be at newPosition.x
    //the difference between this function and the next one, is that the mechanism is going to try to restore this
    //edge to the beginning state (as when you drag it a little bit, and it snaps back)
    //but, by setting the saved point, we will be snapping back to the new position, not the old one
    // in the next function, none of that holds, so we can just directly update the start and end points
    private function updateEdgePosition(edge : GameEdgeContainer, newPosition : Point) : Void
    {
        var isEdgeOutgoing : Bool = (edge.m_fromNode == this) ? true : false;
        if (isEdgeOutgoing)
        {
            if (edge.undoObject.m_savedStartPoint)
            {
                edge.undoObject.m_savedStartPoint.x = edge.globalToLocal(newPosition).x;
            }
        }
        else if (edge.undoObject.m_savedEndPoint)
        {
            edge.undoObject.m_savedEndPoint.x = edge.globalToLocal(newPosition).x;
        }
    }
    
    //update edge and extension edge to be at newPosition.x
    private function updateNextEdgePosition(edge : GameEdgeContainer, newPosition : Point) : Void
    {
        var isEdgeOutgoing : Bool = (edge.m_fromNode == this) ? true : false;
        if (isEdgeOutgoing)
        {
            edge.m_startPoint.x = edge.globalToLocal(newPosition).x;
        }
        else
        {
            edge.m_endPoint.x = edge.globalToLocal(newPosition).x;
        }
    }
    
    //switch edge port positions - both in the port index array and internally in the incoming and outgoing position variables
    private function switchEdgePositions(currentEdgeContainer : GameEdgeContainer, currentPosition : Int, nextEdgeContainer : GameEdgeContainer, nextPosition : Int) : Void
    {
        var isEdgeOutgoing : Bool = (currentEdgeContainer.m_fromNode == this) ? true : false;
        var isNextEdgeOutgoing : Bool = (nextEdgeContainer.m_fromNode == this) ? true : false;
        
        //currentEdgeContainer.hasChanged = false;
        
        m_edgePortArray[currentPosition] = (isNextEdgeOutgoing) ? nextEdgeContainer.m_fromPortID : nextEdgeContainer.m_toPortID;
        m_edgePortArray[nextPosition] = (isEdgeOutgoing) ? currentEdgeContainer.m_fromPortID : currentEdgeContainer.m_toPortID;
        
        //trace("switch " + currentEdgeContainer.m_id + " out:"+isEdgeOutgoing+" @ pos " + currentPosition + " with " + nextEdgeContainer.m_id + " out:"+isNextEdgeOutgoing+" @ pos " + nextPosition);
        
        if (isEdgeOutgoing)
        {
            currentEdgeContainer.outgoingEdgePosition = nextPosition;
        }
        else
        {
            currentEdgeContainer.incomingEdgePosition = nextPosition;
        }
        if (isNextEdgeOutgoing)
        {
            nextEdgeContainer.outgoingEdgePosition = currentPosition;
        }
        else
        {
            nextEdgeContainer.incomingEdgePosition = currentPosition;
        }
    }
    
    override public function hideComponent(hide : Bool) : Void
    {
        super.hideComponent(hide);
        
        for (outgoingEdge in orderedOutgoingEdges)
        {
            outgoingEdge.hideComponent(hide);
        }
        for (incomingEdge in orderedIncomingEdges)
        {
            incomingEdge.hideComponent(hide);
        }
    }
}
