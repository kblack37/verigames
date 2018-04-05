package scenes.game.display;

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

class GameEdgeJoint extends GameComponent
{
    public var m_jointType : Int;
    public var m_position : Int;
    public var m_closestWall : Int = 0;
    
    private var m_jointImage : Sprite;
    
    private var m_incomingPt : Point;
    private var m_outgoingPt : Point;
    
    public static var STANDARD_JOINT : Int = 0;
    public static var MARKER_JOINT : Int = 1;
    public static var END_JOINT : Int = 2;
    public static var INNER_CIRCLE_JOINT : Int = 3;
    private var m_props : PropDictionary;
    
    public function new(jointType : Int = 0, _isWide : Bool = false, _isEditable : Bool = false, _draggable : Bool = true, _props : PropDictionary = null, _propMode : String = PropDictionary.PROP_NARROW)
    {
        super("");
        if (_props != null)
        {
            m_props = _props;
        }
        m_propertyMode = _propMode;
        draggable = _draggable;
        m_isWide = _isWide;
        m_jointType = jointType;
        m_isDirty = true;
        
        m_isEditable = _isEditable;
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        //if (jointType == INNER_CIRCLE_JOINT) {
        touchable = false;
    }
    
    override public function dispose() : Void
    {
        if (m_disposed)
        {
            return;
        }
        if (hasEventListener(Event.ENTER_FRAME))
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        disposeChildren();
        if (m_jointImage != null)
        {
            m_jointImage.removeFromParent(true);
            m_jointImage = null;
        }
        super.dispose();
    }
    
    public function setIncomingPoint(pt : Point) : Void
    //trace("incoming: " + pt);
    {
        
        if (pt.x != 0 && pt.y != 0)
        {
            return;
        }
        m_incomingPt = pt;
        m_isDirty = true;
    }
    
    public function setOutgoingPoint(pt : Point) : Void
    //trace("outgoing: " + pt);
    {
        
        if (pt.x != 0 && pt.y != 0)
        {
            return;
        }
        m_outgoingPt = pt;
        m_isDirty = true;
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        if (!draggable)
        {
            return;
        }
        
        var touches : Array<Touch> = event.touches;
        
        if (event.getTouches(this, TouchPhase.MOVED).length)
        {
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length)
        {
        }
        else if (event.getTouches(this, TouchPhase.HOVER).length)
        {
            if (touches.length == 1)
            {
                m_isDirty = true;
                dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OVER, null, this));
            }
        }
        else if (event.getTouches(this, TouchPhase.BEGAN).length)
        {
        }
        else
        {
            m_isDirty = true;
            dispatchEvent(new EdgeContainerEvent(EdgeContainerEvent.HOVER_EVENT_OUT, null, this));
        }
    }
    
    public function draw() : Void
    {
        var lineSize : Float = (m_isWide) ? GameEdgeContainer.WIDE_WIDTH : GameEdgeContainer.NARROW_WIDTH;
        var color : Int = getColor();
        
        if (m_jointType == INNER_CIRCLE_JOINT)
        {
            lineSize *= 1.5;
        }
        
        if (m_jointImage != null)
        {
            m_jointImage.removeFromParent(true);
            m_jointImage = null;
        }
        
        var isRound : Bool = (m_jointType == INNER_CIRCLE_JOINT);
        
        if ((m_propertyMode != PropDictionary.PROP_NARROW) && getProps().hasProp(m_propertyMode))
        {
            m_jointImage = createJoint(isRound, false, m_isWide, m_incomingPt, m_outgoingPt, KEYFOR_COLOR);
        }
        else
        {
            var isGray : Bool = m_isEditable;
            var myColor : Int = (isHoverOn) ? 0xeeeeee : 0xcccccc;
            m_jointImage = createJoint(isRound, isGray, m_isWide, m_incomingPt, m_outgoingPt, myColor);
        }
        m_jointImage.width = m_jointImage.height = lineSize;
        m_jointImage.x = -lineSize / 2;
        m_jointImage.y = -lineSize / 2;
        addChild(m_jointImage);
    }
    
    // These are used to load assets such as GrayDarkSegmentTop
    private static inline var TOP : String = "Top";
    private static inline var BOTTOM : String = "Bottom";
    private static inline var LEFT : String = "Left";
    private static inline var RIGHT : String = "Right";
    private static function getDir(pt : Point) : String
    {
        if (pt.x > 0)
        {
            return LEFT;
        }
        if (pt.x < 0)
        {
            return RIGHT;
        }
        if (pt.y > 0)
        {
            return TOP;
        }
        return BOTTOM;
    }
    
    private static function setupConnector(connector : Image, joint : Image, dir : String) : Void
    {
        switch (dir)
        {
            case TOP:
                connector.width = joint.width;
                connector.height = joint.height / 2.0;
                connector.x = joint.x;
                connector.y = joint.y + connector.height;
            case BOTTOM:
                connector.width = joint.width;
                connector.height = joint.height / 2.0;
                connector.x = joint.x;
                connector.y = joint.y;
            case LEFT:
                connector.width = joint.width / 2.0;
                connector.height = joint.height;
                connector.x = joint.x + connector.width;
                connector.y = joint.y;
            case RIGHT:
                connector.width = joint.width / 2.0;
                connector.height = joint.height;
                connector.x = joint.x;
                connector.y = joint.y;
        }
    }
    
    public static function createJoint(isRound : Bool, editable : Bool, wide : Bool, fromPt : Point = null, toPt : Point = null, applyColor : Int = -1) : Sprite
    {
        var jointAssetName : String;
        var connectorAssetName : String;
        if (isRound)
        {
            fromPt = toPt = null;  // starting/ending joints don't need connectors  
            if (editable == true)
            {
                if (wide == true)
                {
                    jointAssetName = AssetInterface.PipeJamSubTexture_BlueDarkStart;
                }
                else
                {
                    jointAssetName = AssetInterface.PipeJamSubTexture_BlueLightStart;
                }
            }
            //not adjustable
            else
            {
                
                {
                    if (wide == true)
                    {
                        jointAssetName = AssetInterface.PipeJamSubTexture_GrayDarkStart;
                    }
                    else
                    {
                        jointAssetName = AssetInterface.PipeJamSubTexture_GrayLightStart;
                    }
                }
            }
        }
        else if (editable == true)
        {
            if (wide == true)
            {
                jointAssetName = AssetInterface.PipeJamSubTexture_BlueDarkJoint;
                connectorAssetName = AssetInterface.PipeJamSubTexture_BlueDarkSegmentPrefix;
            }
            else
            {
                jointAssetName = AssetInterface.PipeJamSubTexture_BlueLightJoint;
                connectorAssetName = AssetInterface.PipeJamSubTexture_BlueLightSegmentPrefix;
            }
        }
        //not adjustable
        else
        {
            
            {
                if (wide == true)
                {
                    jointAssetName = AssetInterface.PipeJamSubTexture_GrayDarkJoint;
                    connectorAssetName = AssetInterface.PipeJamSubTexture_GrayDarkSegmentPrefix;
                }
                else
                {
                    jointAssetName = AssetInterface.PipeJamSubTexture_GrayLightJoint;
                    connectorAssetName = AssetInterface.PipeJamSubTexture_GrayLightSegmentPrefix;
                }
            }
        }
        
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        var jointTexture : Texture = atlas.getTexture(jointAssetName);
        var jointImg : Image = new Image(jointTexture);
        if (applyColor >= 0)
        {
            jointImg.color = applyColor;
        }
        
        var jointSprite : Sprite = new Sprite();
        jointSprite.addChild(jointImg);
        
        var inDir : String = "";
        if (fromPt != null)
        {
            inDir = getDir(fromPt);
            var inTexture : Texture = atlas.getTexture(connectorAssetName + inDir);
            var inImg : Image = new Image(inTexture);
            setupConnector(inImg, jointImg, inDir);
            if (applyColor >= 0)
            {
                inImg.color = applyColor;
            }
            jointSprite.addChild(inImg);
        }
        var outDir : String = "";
        if (toPt != null)
        {
            outDir = getDir(toPt);
        }
        if (toPt != null && (inDir != outDir))
        
        // Don't both making two of the same image{
            
            var outTexture : Texture = atlas.getTexture(connectorAssetName + outDir);
            var outImg : Image = new Image(outTexture);
            setupConnector(outImg, jointImg, outDir);
            if (applyColor >= 0)
            {
                outImg.color = applyColor;
            }
            jointSprite.addChild(outImg);
        }
        
        return jointSprite;
    }
    
    public function onEnterFrame(event : Event) : Void
    {
        if (m_isDirty)
        {
            draw();
            m_isDirty = false;
        }
    }
    
    // Make edge joints slightly darker to be more visible
    override public function getColor() : Int
    {
        var color : Int = super.getColor();
        var red : Int = XSprite.extractRed(color);
        var green : Int = XSprite.extractGreen(color);
        var blue : Int = XSprite.extractBlue(color);
        return as3hx.Compat.parseInt((Math.round(red * 0.8) << 16) | (Math.round(green * 0.8) << 8) | Math.round(blue * 0.8));
    }
}
