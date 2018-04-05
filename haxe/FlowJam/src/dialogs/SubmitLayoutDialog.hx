package dialogs;

import assets.AssetsFont;
import display.NineSliceBatch;
import display.NineSliceButton;
import events.MenuEvent;
import feathers.controls.Label;
import feathers.controls.text.StageTextTextEditor;
import feathers.controls.TextInput;
import feathers.core.ITextEditor;
import feathers.events.FeathersEventType;
import flash.text.TextFormat;
import scenes.BaseComponent;
import starling.events.Event;

class SubmitLayoutDialog extends BaseComponent
{
    private var input : TextInput;
    private var description : TextInput;
    /** Button to save the current layout */
    public var submit_button : NineSliceButton;
    
    /** Button to close the dialog */
    public var cancel_button : NineSliceButton;
    
    private var background : NineSliceBatch;
    
    private var buttonPaddingWidth : Int = 8;
    private var buttonPaddingHeight : Int = 8;
    private var textInputHeight : Int = 18;
    private var descriptionInputHeight : Int = 60;
    private var labelHeight : Int = 12;
    private var shapeWidth : Int = 150;
    private var buttonHeight : Int = 24;
    private var buttonWidth : Int = (shapeWidth - 3 * buttonPaddingWidth) / 2;
    private var shapeHeight : Int = 4 * buttonPaddingHeight + buttonHeight + textInputHeight + descriptionInputHeight + labelHeight;
    private var m_defaultName : String;
    
    public function new(defaultName : String = "Layout Name")
    {
        m_defaultName = defaultName;
        super();
        
        background = new NineSliceBatch(shapeWidth, shapeHeight, shapeHeight / 3.0, shapeHeight / 3.0, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", "MenuBoxAttached");
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
        var label : Label = new Label();
        label.text = "Enter a layout name:";
        label.x = buttonPaddingWidth;
        addChild(label);
        label.textRendererProperties.textFormat = new TextFormat(AssetsFont.FONT_UBUNTU, 12, 0xffffff);
        
        input = new TextInput();
        
        input.textEditorFactory = function() : ITextEditor
                {
                    var editor : StageTextTextEditor = new StageTextTextEditor();
                    editor.fontSize = 11;
                    return editor;
                };
        
        this.addChild(input);
        input.width = shapeWidth - 2 * buttonPaddingWidth;
        input.height = 18;
        input.x = buttonPaddingWidth;
        input.y = buttonPaddingHeight + 12;
        input.text = m_defaultName;
        input.selectRange(0, input.text.length);
        input.addEventListener(FeathersEventType.FOCUS_IN, onFocus);
        input.addEventListener(FeathersEventType.ENTER, onSubmitButtonTriggered);
        
        description = new TextInput();
        
        description.textEditorFactory = function() : ITextEditor
                {
                    var editor : StageTextTextEditor = new StageTextTextEditor();
                    editor.fontSize = 11;
                    return editor;
                };
        
        this.addChild(description);
        description.width = shapeWidth - 2 * buttonPaddingWidth;
        description.height = descriptionInputHeight;
        description.x = buttonPaddingWidth;
        description.y = input.y + input.height + buttonPaddingHeight;
        description.text = "Add Description Here";
        description.selectRange(0, description.text.length);
        description.addEventListener(FeathersEventType.FOCUS_IN, onFocus);
        description.addEventListener(FeathersEventType.ENTER, onSubmitButtonTriggered);
    }
    
    private function onFocus(e : starling.events.Event) : Void
    {
        if (e.target == input)
        {
            if (input.text == "Layout Name")
            {
                input.text = "";
            }
        }
        else if (e.target == description)
        {
            if (description.text == "Add Description Here")
            {
                description.text = "";
            }
        }
    }
    
    private function onCancelButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
    }
    
    private function onSubmitButtonTriggered(e : starling.events.Event) : Void
    {
        visible = false;
        var data : Dynamic = {};
        data.name = input.text;
        data.description = description.text;
        dispatchEvent(new MenuEvent(MenuEvent.SAVE_LAYOUT, data));
    }
    
    public function resetText(defaultName : String = "Layout Name") : Void
    {
        m_defaultName = defaultName;
        input.text = m_defaultName;
        description.text = "Add Description Here";
    }
}
