package dialogs;

import haxe.Constraints.Function;
import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceBatch;
import display.NineSliceButton;
import openfl.Assets;
import scenes.BaseComponent;
import starling.events.Event;

class SimpleTwoButtonDialog extends BaseDialog
{
    private var button1_button : NineSliceButton;
    private var button2_button : NineSliceButton;
    
    private var m_answerCallback : Function;
    
    //answerCallback takes an int, specifying if button one or button two was clicked
    public function new(text : String, button1String : String, button2String : String, _width : Float, _height : Float, answerCallback : Function)
    {
        super(_width, _height);
        
        m_answerCallback = answerCallback;
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField(text, Assets.getFont("fonts/UbuntuTitling-Bold.otf"), 120, 14, 12, 0x0077FF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = background.x + (_width - label.width) / 2;
        label.y = background.y + 14;
        
        button1_button = ButtonFactory.getInstance().createButton(button1String, buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        button1_button.addEventListener(starling.events.Event.TRIGGERED, onButtonTriggered);
        addChild(button1_button);
        button1_button.x = background.x + _width / 2 - button1_button.width - 4;
        button1_button.y = background.y + _height - button1_button.height - 14;
        
        button2_button = ButtonFactory.getInstance().createButton(button2String, buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        button2_button.addEventListener(starling.events.Event.TRIGGERED, onButtonTriggered);
        addChild(button2_button);
        button2_button.x = background.x + _width / 2 + 6;
        button2_button.y = button1_button.y;
    }
    
    private function onButtonTriggered(event : Event) : Void
    {
        if (event.target == button1_button)
        {
            m_answerCallback(1);
        }
        else
        {
            m_answerCallback(2);
        }
        
        this.removeFromParent(true);
    }
}
