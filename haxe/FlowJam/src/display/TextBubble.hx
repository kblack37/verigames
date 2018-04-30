package display;

import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceBatch;
import flash.filters.GlowFilter;
import flash.geom.Point;
import scenes.game.components.GameControlPanel;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import utils.XSprite;

class TextBubble extends Sprite
{
    private var m_fontSize : Float;
    private var m_pointAt : DisplayObject;
    private var m_pointAtContainer : DisplayObjectContainer;
    private var m_pointFrom : String;
    private var m_pointTo : String;
    private var m_arrowSz : Float;
    private var m_arrowBounce : Float;
    private var m_arrowBounceSpeed : Float;
    private var m_inset : Float;
    private var m_pointPosAlwaysUpdate : Bool;
    
    private var m_paddingSz : Float;
    private var m_textContainer : Sprite;
    private var m_tutorialArrow : Image;
    
    private var m_pointPos : Point = new Point();
    private var m_pointPosNeedsInit : Bool = true;
    private var m_arrowTextSeparationAdjustment : Float = 0;
    private var m_globalToPoint : Point;
    
    public static inline var GOLD : Int = 0xFFEC00;
    public static inline var RED : Int = 0xFF0000;
    
    public function new(_text : String, _fontSize : Float = 10, _fontColor : Int = 0xEEEEEE,
            _pointAt : DisplayObject = null, _pointAtContainer : DisplayObjectContainer = null,
            _pointFrom : String = NineSliceBatch.BOTTOM_LEFT,
            _pointTo : String = NineSliceBatch.BOTTOM_LEFT, _size : Point = null,
            _pointPosAlwaysUpdate : Bool = true, _arrowSz : Float = 10,
            _arrowBounce : Float = 2, _arrowBounceSpeed : Float = 0.5, _inset : Float = 3,
            _showBox : Bool = true, _arrowColor : Int = GOLD, _outlineWeight : Float = 0,
            _outlineColor : Int = 0x0)
    {
        super();
        m_fontSize = _fontSize;
        m_pointAt = _pointAt;
        m_pointAtContainer = _pointAtContainer;
        m_pointFrom = _pointFrom;
        m_pointTo = _pointTo;
        m_pointPosAlwaysUpdate = _pointPosAlwaysUpdate;
        m_arrowSz = _arrowSz;
        m_arrowBounce = _arrowBounce;
        m_arrowBounceSpeed = _arrowBounceSpeed;
        m_inset = Math.max(_inset, 1);  // must specify some inset  
        m_paddingSz = m_arrowSz + 2 * m_arrowBounce + 4 * m_inset;
        
        // estimate size if none given
        var size : Point = (_size != null) ? _size : TextFactory.getInstance().estimateTextFieldSize(_text, AssetsFont.FONT_UBUNTU, m_fontSize);
        
        // a transparent sprite with padding around the edges so we can put the arrow outside the text box
        var padding : Quad = new Quad(10, 10, 0xff00ff);
        padding.alpha = 0.0;
        padding.touchable = false;
        padding.width = size.x + 2 * m_paddingSz;
        padding.height = size.y + 2 * m_paddingSz;
        padding.x = -padding.width / 2;
        padding.y = -padding.height / 2;
        addChild(padding);
        
        // to hold text
        m_textContainer = new Sprite();
        m_textContainer.x = -size.x / 2;
        m_textContainer.y = -size.y / 2;
        addChild(m_textContainer);
        
        // background box
        if (_showBox)
        {
            var box : NineSliceBatch = new NineSliceBatch(size.x, size.y, 8, 8, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", AssetInterface.PipeJamSubTexture_TutorialBoxPrefix);
            m_textContainer.addChild(box);
        }
        //squeeze text closer to arrow if no box
        else
        {
            
            m_arrowTextSeparationAdjustment = -m_arrowSz / 2 - m_arrowBounce - 4 * m_inset;
        }
        
        // text field
        var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(_text, AssetsFont.FONT_UBUNTU, size.x - 2 * m_inset, size.y - 2 * m_inset, m_fontSize, _fontColor);
        if (_outlineWeight > 0 && !PipeJam3.DISABLE_FILTERS)
        {
            TextFactory.getInstance().updateFilter(textField, new GlowFilter(_outlineColor, 1, _outlineWeight, _outlineWeight, 4 * _outlineWeight));
        }
        textField.x = m_inset;
        textField.y = m_inset;
        m_textContainer.addChild(textField);
        
        // arrow
        if (m_pointAt != null)
        {
            var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
            var arrowTexture : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_TutorialArrow);
            m_tutorialArrow = new Image(arrowTexture);
            m_tutorialArrow.color = _arrowColor;
            m_tutorialArrow.width = m_tutorialArrow.height = m_arrowSz;
            XSprite.setPivotCenter(m_tutorialArrow);
            addChild(m_tutorialArrow);
        }
        touchable = false;
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
    
    public function onAdded(evt : Event) : Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
    }
    
    public function onRemoved(evt : Event) : Void
    {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
    
    private function onEnterFrame(evt : Event) : Void
    {
        var timeSec : Float = Date.now().getTime() / 1000.0;
        var timeArrowOffset : Float = m_arrowBounce * (Std.int(timeSec / m_arrowBounceSpeed) % 2);
        
        if (m_pointAt != null && m_pointAt.parent != null && m_tutorialArrow != null)
        {
            var pt : Point = new Point();
            var offset : Point = new Point();
            
            switch (m_pointFrom)
            {
                case NineSliceBatch.TOP_LEFT:
                    offset.x = -1;
                    offset.y = -1;
                
                case NineSliceBatch.BOTTOM_RIGHT:
                    offset.x = 1;
                    offset.y = 1;
                
                case NineSliceBatch.TOP_RIGHT:
                    offset.x = 1;
                    offset.y = -1;
                
                case NineSliceBatch.BOTTOM_LEFT:
                    offset.x = -1;
                    offset.y = 1;
                
                case NineSliceBatch.LEFT:
                    offset.x = -1;
                    offset.y = 0;
                
                case NineSliceBatch.RIGHT:
                    offset.x = 1;
                    offset.y = 0;
                
                case NineSliceBatch.BOTTOM:
                    offset.x = 0;
                    offset.y = 1;
                
                case NineSliceBatch.TOP:
                    offset.x = 0;
                    offset.y = -1;
                default:
                    offset.x = 0;
                    offset.y = -1;
            }
            
            var _sw0_ = ((m_pointTo != null) ? m_pointTo : m_pointFrom);            

            switch (_sw0_)
            {
                case NineSliceBatch.CENTER:
                    pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), 0.5 * (m_pointAt.bounds.top + m_pointAt.bounds.bottom));
                
                case NineSliceBatch.TOP_LEFT:
                    pt = m_pointAt.bounds.topLeft;
                
                case NineSliceBatch.BOTTOM_RIGHT:
                    pt = m_pointAt.bounds.bottomRight;
                
                case NineSliceBatch.TOP_RIGHT:
                    pt = new Point(m_pointAt.bounds.right, m_pointAt.bounds.top);
                
                case NineSliceBatch.BOTTOM_LEFT:
                    pt = new Point(m_pointAt.bounds.left, m_pointAt.bounds.bottom);
                
                case NineSliceBatch.LEFT:
                    pt = new Point(m_pointAt.bounds.left, 0.5 * (m_pointAt.bounds.bottom + m_pointAt.bounds.top));
                
                case NineSliceBatch.RIGHT:
                    pt = new Point(m_pointAt.bounds.right, 0.5 * (m_pointAt.bounds.bottom + m_pointAt.bounds.top));
                
                case NineSliceBatch.BOTTOM:
                    pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), m_pointAt.bounds.bottom);
                
                case NineSliceBatch.TOP:
                    pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), m_pointAt.bounds.top);
                default:
                    pt = new Point(0.5 * (m_pointAt.bounds.left + m_pointAt.bounds.right), m_pointAt.bounds.top);
            }
            
            var desiredParent : DisplayObjectContainer = ((m_pointAtContainer != null)) ? m_pointAtContainer : m_pointAt.parent;
            if (desiredParent != null)
            {
                pt = m_pointAt.parent.localToGlobal(pt);
                pt = desiredParent.globalToLocal(pt);
                pt = ((m_globalToPoint != null)) ? m_globalToPoint : desiredParent.localToGlobal(pt);
                pt = parent.globalToLocal(pt);
                
                if (m_pointPosNeedsInit || m_pointPosAlwaysUpdate)
                {
                    m_pointPos = pt;
                    m_pointPosNeedsInit = false;
                }
            }
            
            x = m_pointPos.x + offset.x * (width / 2 - m_paddingSz + 2 * m_inset + m_arrowSz + m_arrowBounce + m_arrowTextSeparationAdjustment);
            y = m_pointPos.y + offset.y * (height / 2 - m_paddingSz + 2 * m_inset + m_arrowSz + m_arrowBounce + m_arrowTextSeparationAdjustment);
            
            var arrowPos : Float = m_inset + m_arrowSz / 2 - timeArrowOffset;
            
            m_tutorialArrow.rotation = Math.atan2(-offset.y, -offset.x);
            m_tutorialArrow.x = -offset.x * (width / 2 - m_paddingSz + arrowPos + m_arrowTextSeparationAdjustment);
            m_tutorialArrow.y = -offset.y * (height / 2 - m_paddingSz + arrowPos + m_arrowTextSeparationAdjustment);
        }
        else if (m_pointFrom != null)
        {
            var newX : Float = Constants.GameWidth / 2;
            var newY : Float = height / 2 - m_paddingSz + m_inset;
            switch (m_pointFrom)
            {
                case NineSliceBatch.CENTER:
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
                case NineSliceBatch.TOP_LEFT:
                    newX = width / 2 - m_paddingSz + m_inset;
                case NineSliceBatch.TOP_RIGHT:
                    newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
                case NineSliceBatch.LEFT:
                    newX = width / 2 - m_paddingSz + m_inset;
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
                case NineSliceBatch.RIGHT:
                    newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) / 2;
                case NineSliceBatch.BOTTOM:
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
                case NineSliceBatch.BOTTOM_LEFT:
                    newX = width / 2 - m_paddingSz + m_inset;
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
                case NineSliceBatch.BOTTOM_RIGHT:
                    newX = Constants.GameWidth - (width / 2 - m_paddingSz + m_inset);
                    newY = (Constants.GameHeight - GameControlPanel.HEIGHT) - (height / 2 - m_paddingSz + m_inset) - 12;
            }
            x = newX;
            y = newY;
        }
        else
        {
            x = Constants.GameWidth / 2;
            y = height / 2 - m_paddingSz + m_inset;
        }
    }
    
    public function setGlobalToPoint(pt : Point) : Void
    {
        m_globalToPoint = pt;
    }
    
    private function sign(x : Float) : Float
    {
        if (x < 0.0)
        {
            return -1.0;
        }
        else if (x > 0.0)
        {
            return 1.0;
        }
        else
        {
            return 0.0;
        }
    }
    
    public function hideText() : Void
    {
        if (m_textContainer != null)
        {
            m_textContainer.visible = false;
        }
    }
    
    public function showText() : Void
    {
        if (m_textContainer != null)
        {
            m_textContainer.visible = true;
        }
    }
}

