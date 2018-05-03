package dialogs;

import assets.AssetsFont;
import display.NineSliceBatch;
import display.NineSliceButton;
import events.MenuEvent;
//import feathers.controls.Label;
//import feathers.controls.text.StageTextTextEditor;
//import feathers.controls.TextInput;
//import feathers.core.ITextEditor;
//import feathers.events.FeathersEventType;
import flash.text.TextFormat;
import scenes.BaseComponent;
import starling.events.Event;

// TODO: this class will need a bit of work to replace its dependencies
class SubmitLayoutDialog extends BaseComponent
{
    //private var input : TextInput;
    //private var description : TextInput;
    /** Button to save the current layout */
    public var submit_button : NineSliceButton;
    
    /** Button to close the dialog */
    public var cancel_button : NineSliceButton;
    
    private var background : NineSliceBatch;
    
    private var buttonPaddingWidth : Float = 8;
    private var buttonPaddingHeight : Float = 8;
    private var textInputHeight : Float = 18;
    private var descriptionInputHeight : Float = 60;
    private var labelHeight : Float = 12;
    private var shapeWidth : Float = 150;
    private var buttonHeight : Float = 24;
    private var buttonWidth : Float;
    private var shapeHeight : Float;
    private var m_defaultName : String;
    
    public function new(defaultName : String = "Layout Name")
    {
        m_defaultName = defaultName;
        super();
		
		buttonWidth = (shapeWidth - 3 * buttonPaddingWidth) / 2;
		shapeHeight = 4 * buttonPaddingHeight + buttonHeight + textInputHeight + descriptionInputHeight + labelHeight;
        
        background = new NineSliceBatch(shapeWidth, shapeHeight, shapeHeight / 3.0, shapeHeight / 3.0, "atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml", "MenuBoxAttached");
        addChild(background);
        
        submit_button = ButtonFactory.getInstance().createButton("Submit", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        submit_button.addEventListener(starling.events.Event.TRIGGERED, onSubmitButtonTriggered);
        submit_button.x = background.width - buttonPaddingWidth - buttonWidth;
        submit_button.y = background.height - buttonPaddingHeight - buttonHeight;
        addChild(submit_button);
        
        cancel_button = ButtonFactory.getInstance().createButton("Cancel", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
        cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
        cancel_button.x = background.width - 2 * buttonPaddingWidth - 2 * buttonWidth;
        cancel_button.y = background.height - buttonPaddingHeight - buttonHeight;
        addChild(cancel_button);
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onAddedToStage(event : starling.events.Event) : Void
    {
        //var label : Label = new Label();
        //label.text = "Enter a layout name:";
        //label.x = buttonPaddingWidth;
        //addChild(label);
        //label.textRendererProperties.textFormat = new TextFormat(Assets.getFont("fonts/UbuntuTitling-Bold.otf"), 12, 0xffffff);
        //
        //input = new TextInput();
        //
        //input.textEditorFactory = function() : ITextEditor
                //{
                    //var editor : StageTextTextEditor = new StageTextTextEditor();
                    //editor.fontSize = 11;
                    //return editor;
                //};
        //
        //this.addChild(input);
        //input.width = shapeWidth - 2 * buttonPaddingWidth;
        //input.height = 18;
        //input.x = buttonPaddingWidth;
        //input.y = buttonPaddingHeight + 12;
        //input.text = m_defaultName;
        //input.selectRange(0, input.text.length);
        //input.addEventListener(FeathersEventType.FOCUS_IN, onFocus);
        //input.addEventListener(FeathersEventType.ENTER, onSubmitButtonTriggered);
        //
        //description = new TextInput();
        //
        //description.textEditorFactory = function() : ITextEditor
                //{
                    //var editor : StageTextTextEditor = new StageTextTextEditor();
                    //editor.fontSize = 11;
                    //return editor;
                //};
        //
        //this.addChild(description);
        //description.width = shapeWidth - 2 * buttonPaddingWidth;
        //description.height = descriptionInputHeight;
        //description.x = buttonPaddingWidth;
        //description.y = input.y + input.height + buttonPaddingHeight;
        //description.text = "Add Description Here";
        //description.selectRange(0, description.text.length);
        //description.addEventListener(FeathersEventType.FOCUS_IN, onFocus);
        //description.addEventListener(FeathersEventType.ENTER, onSubmitButtonTriggered);
    }
    
    private function onFocus(e : starling.events.Event) : Void
    {
        //if (e.target == input)
        //{
            //if (input.text == "Layout Name")
            //{
                //input.text = "";
            //}
        //}
        //else if (e.target == description)
        //{
            //if (description.text == "Add Description Here")
            //{
                //description.text = "";
            //}
        //}
    }
    
    private function onCancelButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
    }
    
    private function onSubmitButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
        var data : Dynamic = {};
        //data.name = input.text;
        //data.description = description.text;
        dispatchEvent(new MenuEvent(MenuEvent.SAVE_LAYOUT, data));
    }
    
    public function resetText(defaultName : String = "Layout Name") : Void
    {
        m_defaultName = defaultName;
        //input.text = m_defaultName;
        //description.text = "Add Description Here";
    }
}
