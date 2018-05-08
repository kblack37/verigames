package dialogs;

import haxe.Constraints.Function;
import assets.AssetInterface;
import assets.AssetsFont;
import display.BasicButton;
import display.NineSliceBatch;
import display.NineSliceButton;
import flash.geom.Rectangle;
import openfl.Assets;
import scenes.BaseComponent;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;

class SimpleAlertDialog extends BaseDialog
{
    private var ok_button : NineSliceButton;
    private var m_socialText : String;
    private var m_callback : Function;
    
    public function new(text : String, _width : Float, _height : Float, _socialText : String = "", callback : Function = null, numLinesInText : Int = 1)
    {
        super(_width, _height);
        
        m_socialText = _socialText;
        m_callback = callback;
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField(text, "_sans", 120, 14 * numLinesInText, 12, 0x0077FF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = (width - label.width) / 2;
        label.y = background.y + 15;
        
        ok_button = ButtonFactory.getInstance().createButton("OK", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        ok_button.addEventListener(starling.events.Event.TRIGGERED, onOKButtonTriggered);
        addChild(ok_button);
        ok_button.x = background.x + (_width - ok_button.width) / 2;
        ok_button.y = background.y + _height - 16 - 16;
        
        if (m_socialText.length > 0)
        {
            var fbLogoTexture : Texture = AssetInterface.getTexture("Game", "FacebookLogoWhiteClass");
            var fbLogoImage : Image = new Image(fbLogoTexture);
            var fbButton : BasicButton = new BasicButton(fbLogoImage, fbLogoImage, fbLogoImage);
            fbButton.width = fbButton.height = _height / 4.0;
            fbButton.useHandCursor = true;
            fbButton.addEventListener(Event.TRIGGERED, onClickFacebookShareButton);
            var twitterLogoTexture : Texture = AssetInterface.getTexture("Game", "TwitterLogoWhiteClass");
            var twitterLogoImage : Image = new Image(twitterLogoTexture);
            var twitterButton : BasicButton = new BasicButton(twitterLogoImage, twitterLogoImage, twitterLogoImage);
            twitterButton.width = twitterButton.height = _height / 3.0;
            var X_PAD : Float = (_width - fbButton.width - twitterButton.width) / 3.0;
            fbButton.x = background.x + X_PAD;
            fbButton.y = (label.y + label.height + ok_button.y - fbButton.height) / 2.0;
            twitterButton.x = fbButton.x + fbButton.width + ((_width - fbButton.width - twitterButton.width) / 3.0);
            twitterButton.y = fbButton.y - (twitterButton.height - fbButton.height) / 2;
            twitterButton.useHandCursor = true;
            twitterButton.addEventListener(Event.TRIGGERED, onClickTwitterShareButton);
            addChild(fbButton);
            addChild(twitterButton);
        }
    }
    
    private function onClickFacebookShareButton(evt : Event) : Void
    // TODO: Call Top coder API
    {
        
        trace("Share on Facebook: " + m_socialText);
    }
    
    private function onClickTwitterShareButton(evt : Event) : Void
    // TODO: Call Top coder API
    {
        
        trace("Tweet: " + m_socialText);
    }
    
    private function onOKButtonTriggered(evt : Event) : Void
    {
        visible = false;
        parent.removeChild(this);
        if (m_callback != null)
        {
            m_callback();
        }
    }
}
