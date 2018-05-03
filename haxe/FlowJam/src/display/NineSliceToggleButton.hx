package display;

import assets.AssetInterface;
import assets.AssetsFont;
import flash.geom.Rectangle;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import openfl.Assets;
import openfl.Vector;
import openfl.text.Font;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class NineSliceToggleButton extends NineSliceButton
{
    public var upIcon : Image;
    public var downIcon : Image;
    public var overIcon : Image;
    
    public var currentIcon : Image;
    
    private var label : TextFieldWrapper;
    private var secondaryLabel : TextFieldWrapper;
    private var text : String;
    private var secondaryText : String;
    
    public function new(_text : String, _width : Float, _height : Float, _cX : Float, _cY : Float, _atlasFile : String, _atlasImgName : String, _atlasXMLName : String, _atlasXMLButtonTexturePrefix : String, _fontName : Font, _fontColor : Int, _atlasXMLButtonOverTexturePrefix : String = "", _atlasXMLButtonClickTexturePrefix : String = "", _fontColorOver : Int = 0xFFFFFF, _fontColorClick : Int = 0xFFFFFF)
    {
        super(_text, _width, _height, _cX, _cY, _atlasFile, _atlasImgName, _atlasXMLName, _atlasXMLButtonTexturePrefix, _fontName, _fontColor, _atlasXMLButtonOverTexturePrefix, _atlasXMLButtonClickTexturePrefix, _fontColorOver, _fontColorClick);
        
        addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    
    private var touchState : String;
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Vector<Touch> = event.touches;
        if (touches.length == 0)
        {
            return;
        }
        else if (event.getTouches(this, TouchPhase.BEGAN).length > 0)
        {
            touchState = TouchPhase.BEGAN;
        }
        else if (event.getTouches(this, TouchPhase.HOVER).length > 0)
        {
            if (!mIsDown)
            {
                showButton(m_buttonOverSkin);
                setCurrentIcon(overIcon);
                setText(text);
                setSecondaryText(secondaryText);
                touchState = TouchPhase.HOVER;
            }
        }
        else if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            if (touchState == TouchPhase.HOVER)
            {
                setToggleState(false);
            }
            else if (touchState == TouchPhase.BEGAN)
            {
                if (!mIsDown)
                {
                    dispatchEventWith(Event.TRIGGERED, true);
                }
            }
        }
        else if (!mIsDown)
        {
            setToggleState(false);
        }
        else
        {
            setToggleState(true);
        }
    }
    
    public function setToggleState(toggleOn : Bool) : Void
    {
        mIsDown = toggleOn;
        if (mIsDown)
        {
            showButton(m_buttonClickSkin);
            setCurrentIcon(upIcon);
            setText(text);
            setSecondaryText(secondaryText);
        }
        else
        {
            showButton(m_buttonSkin);
            setCurrentIcon(upIcon);
            setText(text);
            setSecondaryText(secondaryText);
        }
    }
    
    public function setIcon(_upIcon : Image, _downIcon : Image, _overIcon : Image) : Void
    {
        upIcon = _upIcon;
        downIcon = _downIcon;
        overIcon = _overIcon;
        setCurrentIcon(upIcon);
    }
    
    public function setCurrentIcon(icon : Image) : Void
    {
        currentIcon = icon;
        if (currentIcon != null)
        {
            addChild(currentIcon);
        }
    }
    
    public function setText(_text : String) : Void
    {
        text = _text;
        if (_text != null)
        {
            label = TextFactory.getInstance().createTextField(_text, Assets.getFont("fonts/UbuntuTitling-Bold.otf"), width - 4, 10, 10, 0x0077FF);
            TextFactory.getInstance().updateAlign(label, 1, 1);
            addChild(label);
            label.x = 2;
            
            currentIcon.x = 2;
            currentIcon.y = label.height + 2;
            currentIcon.width = 40;
            currentIcon.height = 40;
        }
    }
    
    public function setSecondaryText(_text : String) : Void
    {
        secondaryText = _text;
        if (secondaryText != null)
        {
            secondaryLabel = TextFactory.getInstance().createTextField(_text, Assets.getFont("fonts/UbuntuTitling-Bold.otf"), width - 4 - currentIcon.width, 10, 10, 0x0077FF);
            TextFactory.getInstance().updateAlign(secondaryLabel, 0, 1);
            addChild(secondaryLabel);
            secondaryLabel.x = currentIcon.width + 12;
            secondaryLabel.y = (height - secondaryLabel.height) / 2;
        }
    }
}
