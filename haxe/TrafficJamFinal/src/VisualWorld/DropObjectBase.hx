package visualWorld;

import events.StampChangeEvent;
import networkGraph.Edge;
import networkGraph.FlowObject;
import networkGraph.NodeTypes;
import networkGraph.StampRef;
import utilities.XSprite;
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
class DropObjectBase extends Sprite
{
    public var m_below_pipe : Bool = false;
    public var m_after_pinch : Bool = false;
    public var m_after_buzz : Bool = false;
    
    public var timeline : TimelineMax;
    
    public var m_flowObject : FlowObject;
    
    public var activeStampVector : Array<StampRef> = new Array<StampRef>();
    
    private var layerArray : Array<Dynamic> = new Array<Dynamic>();
    private var rowArray : Array<Dynamic> = new Array<Dynamic>(new Array<Dynamic>(), new Array<Dynamic>());
    private var WIDE_LAYER : Int = 1;
    private var NARROW_LAYER : Int = 0;
    private var ROW_1 : Int = 0;
    private var ROW_2 : Int = 1;
    
    //need these to keep track of position and when to hide, set by pipe
    public var pathLength : Float;
    public var begin_x : Float;
    public var begin_y : Float;
    
    //if this is a continuation of a previous object, set this (use to make animations during transitions better)
    public var previousObj : DropObjectBase;
    private static var nextCreateIndex : Int = 0;
    public var createIndex : Int;
    
    
    public function new(_starting_edge : Edge, _timeline : TimelineMax, flowObject : FlowObject = null)
    {
        super();
        createIndex = nextCreateIndex;
        nextCreateIndex++;
        
        
        timeline = _timeline;
        
        if (flowObject == null)
        {
            m_flowObject = _starting_edge.getCurrentFlowObject();
        }
        else
        {
            m_flowObject = flowObject;
        }
        
        if (m_flowObject == null || m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_NONE)
        {
            hide();
            return;
        }
    }
    
    public function initialize() : Void
    {
    }
    
    public function startAnimation(start : Bool) : Void
    {
        if (!visible)
        {
            return;
        }
        
        if (start && m_flowObject.starting_ball_type != VerigameSystem.BALL_TYPE_NONE)
        {
            timeline.play();
        }
        else
        {
            timeline.stop();
        }
    }
    
    //checks the flow object/local vars and shows or hides wide/narrow image as appropriate
    public function updateImageAndFlow(stopObject : Bool = false) : Void
    {
        updateImage();
        updateFlow(stopObject);
    }
    
    //checks the flow object/local vars and shows or hides wide/narrow image as appropriate
    public function updateImage() : Void
    {
        if (m_flowObject == null)
        
        //	don't stop these, as they never get updated again if you do{
            
            visible = false;
            return;
        }
        
        if (m_flowObject.flowStartingEdge.from_node.kind == NodeTypes.START_NO_BALL)
        {
            timeline.stop();
            visible = false;
            return;
        }
        
        visible = true;
        
        //determine visibility
        if (m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_WIDE)
        {
            setLayerVisible(WIDE_LAYER, true);
            setLayerVisible(NARROW_LAYER, false);
            
            if (m_after_buzz)
            {
                setLayerVisible(WIDE_LAYER, false);
                setLayerVisible(NARROW_LAYER, true);
            }
            
            if (m_after_pinch)
            {
                setLayerVisible(WIDE_LAYER, false);
                setLayerVisible(NARROW_LAYER, true);
            }
        }
        else if (m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_NARROW || m_flowObject.associatedEdge.associated_pipe.is_wide == false)
        {
            setLayerVisible(WIDE_LAYER, false);
            setLayerVisible(NARROW_LAYER, true);
        }
        //BALL_TYPE_NONE - allow normal travel if you find your self on one of these roads
        else
        {
            
            {
                if (m_flowObject.starting_ball_type == VerigameSystem.BALL_TYPE_WIDE)
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
    }
    
    //checks the flow object/local vars and shows or hides wide/narrow image as appropriate
    public function updateFlow(stopObject : Bool = false) : Void
    {
        if (m_flowObject == null)
        
        //	don't stop these, as they never get updated again if you do{
            
            visible = false;
            return;
        }
        
        if (m_flowObject.flowStartingEdge.from_node.kind == NodeTypes.START_NO_BALL)
        {
            timeline.stop();
            visible = false;
            return;
        }
        
        visible = true;
        
        //determine movement
        if (stopObject)
        
        //stop at tail of car in front of us, wherever that is{
            
            timeline.stop();
        }
        else
        {
            timeline.play();
        }
    }
    public function updateMovement() : Void
    {
    }
    
    private function setLayerVisible(layer : Int, willBeVisible : Bool) : Void
    {
        if (willBeVisible)
        {
            layerArray[layer].visible = willBeVisible;
        }
        
        for (i in 0...Pipe.NUM_CAR_LENGTHS_IN_GROUP)
        {
            rowArray[layer][i].visible = willBeVisible;
        }
    }
    
    private function setRowVisible(layer : Int, row : Int, willBeVisible : Bool) : Void
    {
        if (willBeVisible)
        {
            layerArray[layer].visible = willBeVisible;
        }
        
        rowArray[layer][row].visible = willBeVisible;
    }
    
    public function isTroubleSpotInArray(otherDropObjectInfoArray : Array<Dynamic>) : Bool
    {
        var isTroubleSpot : Bool = false;
        //to compare stamps, create an set of all otherEdge stamps, and then see if ours are contained in that set
        var stampArray : Array<Dynamic> = new Array<Dynamic>();
        for (index in 0...otherDropObjectInfoArray.length)
        {
            var dObj2 : DropObjectBase = otherDropObjectInfoArray[index];
            for (index2 in 0...dObj2.activeStampVector.length)
            {
                if (dObj2.activeStampVector[index2] != null)
                {
                    stampArray.push(dObj2.activeStampVector[index2]);
                }
            }
        }
        if (isStampTroubleSpot(stampArray))
        {
            isTroubleSpot = true;
        }
        
        //do other tests here....
        
        return isTroubleSpot;
    }
    
    public function isStampTroubleSpot(nextStampSetArray : Array<Dynamic>) : Bool
    //first use of this code is to compare stamps, to make sure the current ones transfer to the edge
    {
        
        for (index1 in 0...activeStampVector.length)
        {
            var currentStamp : StampRef = activeStampVector[index1];
            var found : Bool = false;
            for (index2 in 0...nextStampSetArray.length)
            {
                var nextStamp : StampRef = nextStampSetArray[index2];
                //if the current stamp is active (and it should be) and we find a matching edge set id, and the next stamp is active
                //(it also should be, then check the next case
                if (currentStamp.active == false || (currentStamp.edge_set_id == nextStamp.edge_set_id && nextStamp.active == true))
                {
                    found = true;
                    continue;
                }
            }
            if (!found)
            {
                return true;
            }
        }
        return false;
    }
    
    //repeatedly called during update, use to change states
    public function onTimelineUpdate() : Void
    {
    }
    
    public function onTimelineEnd() : Void
    {
    }
    
    public function onBelowPipe() : Void
    {
        m_below_pipe = true;
        hide();
    }
    
    public function onBuzz() : Void
    {
        m_after_buzz = true;
    }
    
    public function afterPinch() : Void
    {
        m_after_pinch = true;
    }
    
    public function reset() : Void
    {
        m_below_pipe = false;
        m_after_buzz = false;
        m_after_pinch = false;
        visible = true;
        setLayerVisible(WIDE_LAYER, true);
        setLayerVisible(NARROW_LAYER, true);
    }
    
    public function hide() : Void
    {
        visible = false;
    }
    
    public function show() : Void
    {
        visible = true;
    }
    
    public function setFlowObject(newFlowObject : FlowObject) : Void
    {
        m_flowObject = newFlowObject;
    }
}
