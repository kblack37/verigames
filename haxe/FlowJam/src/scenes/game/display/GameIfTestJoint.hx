package scenes.game.display;

import assets.AssetInterface;
import events.ToolTipEvent;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
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

class GameIfTestJoint extends GameNode
{
    private static inline var LEFT_EDGE_X_LOC : Float = 0.23;  // center of left passage is @ x = 23% of the width  
    private static inline var RIGHT_EDGE_X_LOC : Float = 0.64;  //center of right passage is @ x = 64% of the width  
    
    private var m_inputEdge : GameEdgeContainer;
    private var m_wideEdge : GameEdgeContainer;
    private var m_narrowEdge : GameEdgeContainer;
    private var m_connectionLayer : Sprite;
    
    public function new(_layoutXML : FastXML, _draggable : Bool, _node : Node, _port : Port = null)
    {
        super(_layoutXML, _draggable, _node, _port);
    }
    
    override public function setIncomingEdge(edge : GameEdgeContainer) : Void
    {
        super.setIncomingEdge(edge);
        m_inputEdge = edge;
        var newEnd : Point = new Point(boundingBox.x + RIGHT_EDGE_X_LOC * boundingBox.width - edge.x, edge.m_endPoint.y + boundingBox.height / 2.0);
        edge.setEndPosition(newEnd);
        edge.increaseOutputHeight(boundingBox.height / 2.0);
    }
    
    // TODO: update when input edge changes width
    private function update(evt : Event) : Void
    {
        m_isDirty = true;
    }
    
    override public function setOutgoingEdge(edge : GameEdgeContainer) : Void
    {
        super.setOutgoingEdge(edge);
        var newStart : Point;
        if (edge.graphConstraint)
        {
            if (edge.graphConstraint.is_wide)
            {
                m_wideEdge = edge;
                newStart = new Point(boundingBox.x + RIGHT_EDGE_X_LOC * boundingBox.width - edge.x, edge.m_startPoint.y - boundingBox.height / 2.0 - 0.2);
            }
            else
            {
                m_narrowEdge = edge;
                newStart = new Point(boundingBox.x + LEFT_EDGE_X_LOC * boundingBox.width - edge.x, edge.m_startPoint.y - boundingBox.height / 2.0 - 0.2);
            }
            edge.setStartPosition(newStart);
            edge.increaseInputHeight(boundingBox.height / 2.0);
        }
    }
    
    override public function draw() : Void
    {
        if (costume)
        {
            costume.removeFromParent(true);
        }
        
        var assetName : String;
        if (m_propertyMode == PropDictionary.PROP_NARROW)
        {
            assetName = AssetInterface.PipeJamSubTexture_BallSizeTestSimple;
        }
        else if (m_inputEdge != null && m_inputEdge.isWide())
        {
            assetName = AssetInterface.PipeJamSubTexture_BallSizeTestMapWide;
        }
        else
        {
            assetName = AssetInterface.PipeJamSubTexture_BallSizeTestMapNarrow;
        }
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        var texture : Texture = atlas.getTexture(assetName);
        costume = new Image(texture);
        var scaleFactor : Float = boundingBox.width / costume.width;
        costume.width *= scaleFactor;
        costume.height *= scaleFactor;
        costume.y = (boundingBox.height - costume.height) / 2.0;
        addChild(costume);
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    {
        var label : String = "Split Test";  // TODO: name this  
        return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, label, 8);
    }
}

