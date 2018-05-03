package dialogs;

import assets.AssetInterface;
import assets.AssetsFont;
import display.BasicButton;
import display.NineSliceBatch;
import display.NineSliceButton;
import events.MenuEvent;
import flash.geom.Rectangle;
import openfl.Assets;
import scenes.BaseComponent;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class SaveDialog extends BaseDialog
{
    private var cancel_button : NineSliceButton;
    private var dont_share_button : NineSliceButton;
    private var share_button : NineSliceButton;
    
    public function new(_width : Float, _height : Float)
    {
        super(_width, _height);
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField("Share with\nyour group\nalso?", "_sans", _width - 30, 32, 18, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = 15 + background.x;
        label.y = 15 + background.y;
        
        cancel_button = ButtonFactory.getInstance().createButton("Cancel", buttonWidth, buttonHeight, 8, 8);
        cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
        addChild(cancel_button);
        cancel_button.x = _width - cancel_button.width - 15 + background.x;
        cancel_button.y = _height - cancel_button.height - 18 + background.y;
        
        dont_share_button = ButtonFactory.getInstance().createButton("No", buttonWidth, buttonHeight, 8, 8);
        dont_share_button.addEventListener(starling.events.Event.TRIGGERED, onNoButtonTriggered);
        addChild(dont_share_button);
        //add background to y but not x because caucel_button has already been adjusted by background.x
        dont_share_button.x = cancel_button.x - dont_share_button.width - 6;
        dont_share_button.y = _height - dont_share_button.height - 18 + background.y;
        
        share_button = ButtonFactory.getInstance().createButton("Yes", buttonWidth, buttonHeight, 8, 8);
        share_button.addEventListener(starling.events.Event.TRIGGERED, onYesButtonTriggered);
        addChild(share_button);
        share_button.x = dont_share_button.x - cancel_button.width - 6;
        share_button.y = _height - share_button.height - 18 + background.y;
    }
    
    private function onCancelButtonTriggered(evt : Event) : Void
    {
        parent.removeChild(this);
    }
    
    private function onNoButtonTriggered(evt : Event) : Void
    {
        PipeJamGame.levelInfo.shareWithGroup = 0;
        dispatchEvent(new MenuEvent(MenuEvent.SAVE_LEVEL));
        parent.removeChild(this);
    }
    
    private function onYesButtonTriggered(evt : Event) : Void
    {
        PipeJamGame.levelInfo.shareWithGroup = 1;
        dispatchEvent(new MenuEvent(MenuEvent.SAVE_LEVEL));
        parent.removeChild(this);
    }
}
