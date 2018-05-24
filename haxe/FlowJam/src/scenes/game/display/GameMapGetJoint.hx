package scenes.game.display;

import assets.AssetInterface;
import constraints.ConstraintVar;
import events.ToolTipEvent;
import display.NineSliceBatch;
import events.EdgePropChangeEvent;
import events.PropertyModeChangeEvent;
import flash.events.Event;
import flash.geom.Point;
import graph.Edge;
import graph.MapGetNode;
import graph.Node;
import graph.NodeTypes;
import graph.Port;
import graph.PropDictionary;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

class GameMapGetJoint extends GameNode
{
    public var getNode(get, never) : MapGetNode;

    private var m_valueEdge : GameEdgeContainer;
    private var m_argumentEdge : GameEdgeContainer;
    private var m_outputEdge : GameEdgeContainer;
    private var m_connectionLayer : Sprite;
    private var m_props : PropDictionary;
    
    public function new(_layoutObj : Dynamic, _constraintVar : ConstraintVar, _draggable : Bool = true)
    {
        super(_layoutObj, _constraintVar, _draggable);
        useHandCursor = true;
        m_props = new PropDictionary();
        m_props.setProp(getNode.getMapProperty(), true);
    }
    
    override public function setIncomingEdge(edge : GameEdgeContainer) : Int
    {
        super.setIncomingEdge(edge);
        //if (edge.graphConstraint == getNode.valueEdge) {
        //if (m_valueEdge) m_valueEdge.graphConstraint.removeEventListener(EdgePropChangeEvent.EXIT_BALL_TYPE_CHANGED, update);
        //m_valueEdge = edge;
        //m_valueEdge.graphConstraint.addEventListener(EdgePropChangeEvent.EXIT_BALL_TYPE_CHANGED, update);
        //alignOutputEdge();
        //} else if (edge.graphConstraint == getNode.argumentEdge) {
        //if (m_argumentEdge) m_argumentEdge.graphConstraint.removeEventListener(EdgePropChangeEvent.EXIT_PROPS_CHANGED, update);
        //m_argumentEdge = edge;
        //m_argumentEdge.graphConstraint.addEventListener(EdgePropChangeEvent.EXIT_PROPS_CHANGED, update);
        //}
        return 0;
    }
    //
    //public function getUpstreamEdgeContainers():Vector.<GameEdgeContainer>
    //{
    //var vec:Vector.<GameEdgeContainer> = new Vector.<GameEdgeContainer>();
    //if (!m_argumentEdge) return vec;
    //var edgesToCheck:Vector.<GameEdgeContainer> = new Vector.<GameEdgeContainer>();
    //edgesToCheck.push(m_argumentEdge);
    //var visitedEdges:Vector.<GameEdgeContainer> = new Vector.<GameEdgeContainer>();
    //while (edgesToCheck.length > 0) {
    //var edge:GameEdgeContainer = edgesToCheck.shift();
    //if (visitedEdges.indexOf(edge) > -1) continue; // avoid looping
    //visitedEdges.push(edge);
    //if (edge.graphConstraint && edge.graphConstraint.linked_edge_set.canSetProp(getNode.getMapProperty())) {
    //if (vec.indexOf(edge) == -1) {
    //vec.push(edge);
    //switch (edge.graphConstraint.from_node.kind) {
    //case NodeTypes.GET:
    // Don't continue traversing through this node, KeyFor does not propagate thru
    //continue;
    //case NodeTypes.BALL_SIZE_TEST:
    //case NodeTypes.CONNECT:
    //case NodeTypes.MERGE:
    //case NodeTypes.SPLIT:
    //case NodeTypes.SUBBOARD: // ??
    //case NodeTypes.BALL_SIZE_TEST:
    // Continue traversing back through these nodes, KeyFor propagates through these
    //break;
    //}
    //if (edge.m_fromNode) {
    //var i:int;
    //for (i = 0; i < edge.m_fromNode.orderedIncomingEdges.length; i++) {
    //edgesToCheck.push(edge.m_fromNode.orderedIncomingEdges[i]);
    //}
    //}
    //}
    //}
    //}
    //return vec;
    //}
    //
    private function update(evt : Event) : Void
    {
        m_isDirty = true;
    }
    
    override public function setOutgoingEdge(edge : GameEdgeContainer) : Int
    {
        super.setOutgoingEdge(edge);
        m_outputEdge = edge;
        alignOutputEdge();
        return 0;
    }
    
    private function alignOutputEdge() : Void
    {
        if (m_outputEdge == null || m_valueEdge == null)
        {
            return;
        }
        // Have output edge line up with value edge
        var newStart : Point = new Point(m_valueEdge.m_endPoint.x + m_valueEdge.x - m_outputEdge.x, m_outputEdge.m_startPoint.y);
        m_outputEdge.setStartPosition(newStart);
    }
    
    private function get_getNode() : MapGetNode
    {
        return null;
    }
    
    override public function draw() : Void
    {  //if (costume)  
        //costume.removeFromParent(true);
        //
        //var assetName:String = isSelected ? AssetNames.PipeJamSubTexture_GrayDarkBoxSelectPrefix : AssetInterface.PipeJamSubTexture_GrayDarkBoxPrefix;
        //costume = new NineSliceBatch(boundingBox.width, boundingBox.height, boundingBox.height / 3.0, boundingBox.height / 3.0, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", assetName);
        //addChild(costume);
        //
        //if (m_connectionLayer) m_connectionLayer.removeFromParent(true);
        //m_connectionLayer = new Sprite();
        //if (m_valueEdge && m_argumentEdge && m_outputEdge) {
        //var valWidth:Number = m_valueEdge.isWide() ? GameEdgeContainer.WIDE_WIDTH : GameEdgeContainer.NARROW_WIDTH;
        //var seg1:Image, seg2:Image, seg3:Image, j1:Sprite, j2:Sprite, connectColor:uint;
        //if (getNode.argumentHasMapStamp()) {
        //seg1 = GameEdgeSegment.createEdgeSegment(new Point(0, boundingBox.height / 2.0), m_valueEdge.isWide(), m_valueEdge.isEditable());
        //seg1.x = m_valueEdge.m_endPoint.x - seg1.width / 2.0 + m_valueEdge.x - this.x;
        //seg1.y = m_valueEdge.m_endPoint.y + m_valueEdge.y - this.y;
        //m_connectionLayer.addChild(seg1);
        //j1 = GameEdgeJoint.createJoint(false, m_valueEdge.isEditable(), m_valueEdge.isWide());
        //j1.width = j1.height = valWidth;
        //j1.x = seg1.x;
        //j1.y = seg1.y + seg1.height - j1.height / 2.0;
        //m_connectionLayer.addChildAt(j1, 0);
        //seg3 = GameEdgeSegment.createEdgeSegment(new Point(0, boundingBox.height / 2.0), m_valueEdge.isWide(), m_valueEdge.isEditable());
        //seg3.x = m_outputEdge.m_startPoint.x - seg3.width / 2.0 + m_outputEdge.x - this.x;
        //seg3.y = m_outputEdge.m_startPoint.y + m_outputEdge.y - this.y - seg3.height;
        //m_connectionLayer.addChild(seg3);
        //j2 = GameEdgeJoint.createJoint(false, m_valueEdge.isEditable(), m_valueEdge.isWide());
        //j2.width = j2.height = valWidth;
        //j2.x = seg3.x;
        //j2.y = seg3.y - j2.height / 2.0;
        //m_connectionLayer.addChildAt(j2, 0);
        //seg2 = GameEdgeSegment.createEdgeSegment(new Point(Math.abs(seg3.x - seg1.x), 0), m_valueEdge.isWide(), m_valueEdge.isEditable());
        //seg2.x = Math.min(seg3.x, seg1.x) + valWidth / 2.0;
        //seg2.y = boundingBox.height / 2.0 - valWidth / 2.0;
        //addChild(seg2);
        //connectColor = KEYFOR_COLOR;
        //} else {
        //seg1 = GameEdgeSegment.createEdgeSegment(new Point(0, boundingBox.height / 4.0), m_valueEdge.isWide(), m_valueEdge.isEditable());
        //seg1.x = m_valueEdge.m_endPoint.x - seg1.width / 2.0 + m_valueEdge.x - this.x;
        //seg1.y = m_valueEdge.m_endPoint.y + m_valueEdge.y - this.y;
        //m_connectionLayer.addChild(seg1);
        //j1 = GameEdgeJoint.createJoint(false, m_valueEdge.isEditable(), m_valueEdge.isWide());
        //j1.width = j1.height = valWidth;
        //j1.x = seg1.x;
        //j1.y = seg1.y + seg1.height - j1.height / 2.0;
        //m_connectionLayer.addChildAt(j1, 0);
        //seg3 = GameEdgeSegment.createEdgeSegment(new Point(0, boundingBox.height / 4.0), true, false);
        //seg3.x = m_outputEdge.m_startPoint.x - seg3.width / 2.0 + m_outputEdge.x - this.x;
        //seg3.y = m_outputEdge.m_startPoint.y + m_outputEdge.y - this.y - seg3.height;
        //seg3.color = 0x0;
        //m_connectionLayer.addChild(seg3);
        //j2 = GameEdgeJoint.createJoint(false, false, true, null, null, 0x0);
        //j2.width = j2.height = GameEdgeContainer.WIDE_WIDTH;
        //j2.x = seg3.x;
        //j2.y = seg3.y - j2.height / 2.0;
        //m_connectionLayer.addChildAt(j2, 0);
        //connectColor = 0x0;
        //}
        // Connect argument to intersection
        //var outPt:Point = new Point(j2.x + j2.width / 2.0, boundingBox.height / 2.0);
        //var q1:Quad = new Quad(GameEdgeContainer.NARROW_WIDTH / 2.0, outPt.y, connectColor);
        //q1.x = m_argumentEdge.m_endPoint.x - q1.width / 2.0 + m_argumentEdge.x - this.x;
        //q1.y = q1.width / 2.0;
        //m_connectionLayer.addChild(q1);
        //var q2:Quad = new Quad(Math.abs(q1.x - outPt.x), GameEdgeContainer.NARROW_WIDTH / 2.0, connectColor);
        //q2.x = (q1.x < outPt.x) ? (q1.x - q1.width / 2.0) : (outPt.x + q1.width / 2.0);
        //q2.y = outPt.y - q2.height / 2.0;
        //m_connectionLayer.addChild(q2);
        //}
        //addChild(m_connectionLayer);
        
    }
    
    override public function onClicked(pt : Point) : Void
    {
        var prop : String = getNode.getMapProperty();
        // If already in mode for this map, revert to NARROW mode
        if (m_propertyMode == prop)
        {
            prop = PropDictionary.PROP_NARROW;
        }
        dispatchEvent(new PropertyModeChangeEvent(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, prop));
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    {
        var label : String = "";
        if (getNode != null)
        {
            label = (getNode.argumentHasMapStamp()) ? "Activated Map" : "Unactivated Map";
        }
        return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, label, 8);
    }
}

