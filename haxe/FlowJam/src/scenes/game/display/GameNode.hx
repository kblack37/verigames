package scenes.game.display;

import assets.AssetNames;
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
import starling.filters.GlowFilter;

class GameNode extends GameNodeBase
{
    public var assetName(get, never) : String;

    private var m_scoreBlock : ScoreBlock;
    private var m_highlightRect : Quad;
    
    public function new(_layoutObj : Dynamic, _constraintVar : ConstraintVar, _draggable : Bool = true)
    {
        super(_layoutObj, _constraintVar);
        boundingBox = (try cast(Reflect.field(m_layoutObj, "bb"), Rectangle) catch(e:Dynamic) null).clone();
        draggable = _draggable;
        
        shapeWidth = boundingBox.width;
        shapeHeight = boundingBox.height;
        
        m_isEditable = !constraintVar.constant;
        m_isWide = !constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW);
        
        constraintVar.addEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onVarChange);
        
        draw();
    }
    
    public function updateLayout(newLayoutObj : Dynamic) : Void
    {
        m_layoutObj = newLayoutObj;
        boundingBox = (try cast(Reflect.field(m_layoutObj, "bb"), Rectangle) catch(e:Dynamic) null).clone();
        this.x = boundingBox.x;
        this.y = boundingBox.y;
        m_isDirty = true;
    }
    
    override public function onClicked(pt : Point) : Void
    {
        var changeEvent : VarChangeEvent = null;
        var undoEvent : UndoEvent = null;
        if (m_propertyMode == PropDictionary.PROP_NARROW)
        {
            if (m_isEditable)
            {
                var newIsWide : Bool = !m_isWide;
                //constraintVar.setProp(m_propertyMode, !newIsWide);
                //dispatchEvent(new starling.events.Event(Level.UNSELECT_ALL, true, this));
                changeEvent = new VarChangeEvent(VarChangeEvent.VAR_CHANGE_USER, constraintVar, PropDictionary.PROP_NARROW, !newIsWide, pt);
                undoEvent = new UndoEvent(changeEvent, this);
                if (newIsWide)
                {
                // Wide
                    
                    AudioManager.getInstance().audioDriver().playSfx(AssetsAudio.SFX_LOW_BELT);
                }
                // Narrow
                else
                {
                    
                    AudioManager.getInstance().audioDriver().playSfx(AssetsAudio.SFX_HIGH_BELT);
                }
            }
        }
        else if (m_propertyMode.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0)
        {
            var propVal : Bool = constraintVar.getProps().hasProp(m_propertyMode);
            //constraintVar.setProp(m_propertyMode, propVal);
            changeEvent = new VarChangeEvent(VarChangeEvent.VAR_CHANGE_USER, constraintVar, m_propertyMode, propVal, pt);
            undoEvent = new UndoEvent(changeEvent, this);
        }
        if (undoEvent != null)
        {
            dispatchEvent(undoEvent);
        }
        if (changeEvent != null)
        {
            dispatchEvent(changeEvent);
        }
    }
    
    public function onVarChange(evt : VarChangeEvent) : Void
    {
        handleWidthChange(!constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW));
    }
    
    public function handleWidthChange(newIsWide : Bool) : Void
    {
        var redraw : Bool = (m_isWide != newIsWide);
        m_isWide = newIsWide;
        m_isDirty = redraw;
        for (iedge in orderedIncomingEdges)
        {
            iedge.onWidgetChange(this);
        }
        for (oedge in orderedOutgoingEdges)
        {
            oedge.onWidgetChange(this);
        }
    }
    
    private function get_assetName() : String
    {
        var _assetName : String;
        if (m_isEditable == true)
        {
            if (m_isWide == true)
            {
                _assetName = AssetNames.PipeJamSubTexture_BlueDarkBoxPrefix;
            }
            else
            {
                _assetName = AssetNames.PipeJamSubTexture_BlueLightBoxPrefix;
            }
        }
        //not adjustable
        else
        {
            
            {
                if (m_isWide == true)
                {
                    _assetName = AssetNames.PipeJamSubTexture_GrayDarkBoxPrefix;
                }
                else
                {
                    _assetName = AssetNames.PipeJamSubTexture_GrayLightBoxPrefix;
                }
            }
        }
        //if (isSelected) _assetName += "Select";
        return _assetName;
    }
    
    override public function draw() : Void
    {
        if (costume != null)
        {
            costume.removeFromParent(true);
        }
        
        costume = new NineSliceBatch(shapeWidth, shapeHeight, shapeHeight / 3.0, shapeHeight / 3.0, "atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml", assetName);
        addChild(costume);
        
        var wideScore : Float = constraintVar.scoringConfig.getScoringValue(ConstraintValue.VERBOSE_TYPE_1);
        var narrowScore : Float = constraintVar.scoringConfig.getScoringValue(ConstraintValue.VERBOSE_TYPE_0);
        var BLK_SZ : Float = 20;  // create an upscaled version for better quality, then update width/height to shrink  
        var BLK_RAD : Float = (shapeHeight / 3.0) * (BLK_SZ * 2 / boundingBox.height);
        if (wideScore > narrowScore)
        {
            m_scoreBlock = new ScoreBlock(AssetNames.PipeJamSubTexture_BlueDarkBoxPrefix, Std.string(wideScore - narrowScore), BLK_SZ - BLK_RAD, BLK_SZ - BLK_RAD, BLK_SZ, null, BLK_RAD);
            m_scoreBlock.width = m_scoreBlock.height = boundingBox.height / 2;
            addChild(m_scoreBlock);
        }
        else if (narrowScore > wideScore)
        {
            m_scoreBlock = new ScoreBlock(AssetNames.PipeJamSubTexture_BlueLightBoxPrefix, Std.string(narrowScore - wideScore), BLK_SZ - BLK_RAD, BLK_SZ - BLK_RAD, BLK_SZ, null, BLK_RAD);
            m_scoreBlock.width = m_scoreBlock.height = boundingBox.height / 2;
            addChild(m_scoreBlock);
        }
        useHandCursor = m_isEditable;
        
        if (constraintVar != null)
        {
            var i : Int = 0;
            for (prop in Reflect.fields(constraintVar.getProps().iterProps()))
            {
                if (prop == PropDictionary.PROP_NARROW)
                {
                    continue;
                }
                if (prop == m_propertyMode)
                {
                    var keyQuad : Quad = new Quad(3, 3, BaseComponent.KEYFOR_COLOR);
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
            
            this.filter = new GlowFilter();
        }
        else if (this.filter != null)
        {
            this.filter.dispose();
        }
        super.draw();
    }
    
    override public function isWide() : Bool
    {
        return m_isWide;
    }
    
    override public function dispose() : Void
    {
        if (m_scoreBlock != null)
        {
            m_scoreBlock.dispose();
        }
        if (constraintVar != null)
        {
            constraintVar.removeEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onVarChange);
        }
        super.dispose();
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    {
        var lockedTxt : String = (isEditable()) ? "" : "Locked ";
        var wideTxt : String = (isWide()) ? "Wide " : "Narrow ";
        return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, lockedTxt + wideTxt + "Widget", 8);
    }
}
