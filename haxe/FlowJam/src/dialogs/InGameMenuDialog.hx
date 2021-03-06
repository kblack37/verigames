package dialogs;

import flash.geom.Rectangle;
import display.NineSliceBatch;
import display.NineSliceButton;
import events.NavigationEvent;
import networking.GameFileHandler;
import scenes.BaseComponent;
import scenes.Scene;
import scenes.game.PipeJamGameScene;
import scenes.layoutselectscene.LayoutSelectScene;
import starling.animation.Juggler;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

class InGameMenuDialog extends BaseComponent
{
    /** Button to share the current game */
    private var submit_score_button : NineSliceButton;
    
    /** Button to save the current game */
    private var save_score_button : NineSliceButton;
    
    /** Button to submit the current layout */
    private var submit_layout_button : NineSliceButton;
    
    /** Button to select a new layout */
    private var select_layout_button : NineSliceButton;
    
    /** Button to exit to the splash screen */
    private var exit_button : NineSliceButton;
    
    /** Button to switch to the next level only available in debug build */
    private var next_level_button : NineSliceButton;
    
    private var background : NineSliceBatch;
    
    private var submitLayoutDialog : SubmitLayoutDialog;
    
    private var shapeWidth : Float = 96;
    private var buttonPaddingWidth : Float = 8;
    private var buttonPaddingHeight : Float = 8;
    private var buttonHeight : Float = 24;
    private var buttonWidth : Float;
    
    private var numButtons : Int = 3;
    
    private var hideMainDialog : Bool = true;
    public var animatingDown : Bool = false;
    public var animatingUp : Bool = false;
    
    public static inline var TOP_BUFFER : Float = 5;
    public static inline var BOTTOM_BUFFER : Float = 20;  // bottom part obscured by control panel, build in a buffer  
    
    public function new()
    {
        super();
		
		buttonWidth = shapeWidth - 2 * buttonPaddingWidth;
        
        if (!PipeJam3.RELEASE_BUILD)
        {
            numButtons++;
        }
        
        var backgroundHeight : Int = Std.int(numButtons * buttonHeight + (numButtons + 1) * buttonPaddingHeight + BOTTOM_BUFFER + TOP_BUFFER);
        background = new NineSliceBatch(shapeWidth, backgroundHeight, backgroundHeight / 3.0, backgroundHeight / 3.0, "atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml", "MenuBoxAttached");
        addChild(background);
        
        exit_button = ButtonFactory.getInstance().createButton("Exit", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0, "Return to\nLevel Select");
        exit_button.addEventListener(starling.events.Event.TRIGGERED, onExitButtonTriggered);
        exit_button.x = buttonPaddingWidth;
        exit_button.y = background.height - buttonPaddingHeight - exit_button.height - BOTTOM_BUFFER;
        addChild(exit_button);
        
        submit_layout_button = ButtonFactory.getInstance().createButton("Share Layout", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0, "Share your\nlayout with\nother players");
        submit_layout_button.addEventListener(starling.events.Event.TRIGGERED, onSubmitLayoutButtonTriggered);
        submit_layout_button.x = buttonPaddingWidth;
        submit_layout_button.y = exit_button.y - buttonPaddingHeight - submit_layout_button.height;
        if (PipeJam3.TUTORIAL_DEMO || PipeJamGameScene.inTutorial || PipeJamGameScene.inDemo)
        {
            submit_layout_button.enabled = false;
        }
        addChild(submit_layout_button);
        
        select_layout_button = ButtonFactory.getInstance().createButton("Select Layout", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0, "Load a\nsaved layout,\nscoring will\nnot change");
        select_layout_button.addEventListener(starling.events.Event.TRIGGERED, onSelectLayoutButtonTriggered);
        select_layout_button.x = buttonPaddingWidth;
        select_layout_button.y = submit_layout_button.y - buttonPaddingHeight - select_layout_button.height;
        if (PipeJam3.TUTORIAL_DEMO || PipeJamGameScene.inTutorial || PipeJamGameScene.inDemo)
        {
            select_layout_button.enabled = false;
        }
        addChild(select_layout_button);
        
        //			save_score_button = ButtonFactory.getInstance().createButton("Save Level", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0, "Save or share\nyour progress");
        //			save_score_button.addEventListener(starling.events.Event.TRIGGERED, onSaveScoreButtonTriggered);
        //			save_score_button.x = buttonPaddingWidth;
        //			save_score_button.y = select_layout_button.y - buttonPaddingHeight - save_score_button.height;
        //			if (PipeJam3.TUTORIAL_DEMO || PipeJamGameScene.inTutorial || PipeJamGameScene.inDemo) save_score_button.enabled = false;
        //			addChild(save_score_button);
        //
        //			submit_score_button = ButtonFactory.getInstance().createButton("Submit Level", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0, "Submit your\nsolution for\ncredit");
        //			submit_score_button.addEventListener(starling.events.Event.TRIGGERED, onSubmitScoreButtonTriggered);
        //			submit_score_button.x = buttonPaddingWidth;
        //			submit_score_button.y = save_score_button.y - buttonPaddingHeight - submit_score_button.height;
        //
        //			if (PipeJam3.TUTORIAL_DEMO || PipeJamGameScene.inTutorial || PipeJamGameScene.inDemo) submit_score_button.enabled = false;
        //			addChild(submit_score_button);
        
        if (!PipeJam3.RELEASE_BUILD)
        {
            next_level_button = ButtonFactory.getInstance().createButton("Next Level", buttonWidth, buttonHeight, buttonHeight / 2.0, buttonHeight / 2.0);
            next_level_button.addEventListener(starling.events.Event.TRIGGERED, onNextLevelButtonTriggered);
            next_level_button.x = buttonPaddingWidth;
            next_level_button.y = select_layout_button.y - buttonPaddingHeight - next_level_button.height;
            addChild(next_level_button);
        }
    }
    
    private var m_levelName : String = "";
    public function setActiveLevelName(name : String) : Void
    {
        m_levelName = name;
    }
    
    private function onSubmitLayoutButtonTriggered() : Void
    //get the name
    {
        
        if (submitLayoutDialog == null)
        {
            if (m_levelName != null && m_levelName.length > 0)
            {
                submitLayoutDialog = new SubmitLayoutDialog(m_levelName);
            }
            else
            {
                submitLayoutDialog = new SubmitLayoutDialog();
            }
            parent.addChild(submitLayoutDialog);
            submitLayoutDialog.x = background.width - submitLayoutDialog.width;
            submitLayoutDialog.y = y + (height - submitLayoutDialog.height);
            submitLayoutDialog.visible = true;
            submitLayoutDialog.clipRect = new Rectangle(background.width, y + (height - submitLayoutDialog.height), 
                    submitLayoutDialog.width, submitLayoutDialog.height);
            Starling.current.juggler.tween(submitLayoutDialog, 1.0, {
                        transition : Transitions.EASE_IN_OUT,
                        x : background.width
                    });
        }
        else if (submitLayoutDialog.visible)
        {
            hideSecondaryDialog(submitLayoutDialog, false);
        }
        else
        {
            if (m_levelName != null && m_levelName.length > 0)
            {
                submitLayoutDialog.resetText(m_levelName);
            }
            else
            {
                submitLayoutDialog.resetText();
            }
            submitLayoutDialog.x = background.width - submitLayoutDialog.width;
            submitLayoutDialog.y = y + (height - submitLayoutDialog.height);
            submitLayoutDialog.visible = true;
            submitLayoutDialog.clipRect = new Rectangle(background.width, y + (height - submitLayoutDialog.height), 
                    submitLayoutDialog.width, submitLayoutDialog.height);
            
            Starling.current.juggler.tween(submitLayoutDialog, 1.0, {
                        transition : Transitions.EASE_IN_OUT,
                        x : background.width
                    });
        }
    }
    
    private function onSelectLayoutButtonTriggered() : Void
    {
        onBackToGameButtonTriggered();  //close menu  
        if (PipeJamGame.levelInfo != null)
        {
            dispatchEvent(new Event(Game.START_BUSY_ANIMATION, true));
            GameFileHandler.getLayoutList(onRequestLayoutList);
        }
        else
        {
            onRequestLayoutList(0, null);
        }
    }
    
    private function onRequestLayoutList(result : Int, layoutList : Array<Dynamic>) : Void
    {
        dispatchEvent(new Event(Game.STOP_BUSY_ANIMATION, true));
        var layoutSelectScene : LayoutSelectScene = new LayoutSelectScene(try cast(Scene.m_gameSystem, PipeJamGame) catch(e:Dynamic) null);
        layoutSelectScene.setLayouts(layoutList);
        parent.addChild(layoutSelectScene);
    }
    
    public function onBackToGameButtonTriggered() : Void
    //hide other dialogs
    {
        
        hideAllDialogs();
    }
    
    private function onExitButtonTriggered() : Void
    {
        hideAllDialogs();
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
    }
    
    public function hideAllDialogs() : Void
    {
        if (submitLayoutDialog != null && submitLayoutDialog.visible == true)
        {
            hideSecondaryDialog(submitLayoutDialog, true);
        }
        else
        {
            hideSelf();
        }
    }
    
    private function hideSelf() : Void
    {
        var juggler : Juggler = Starling.current.juggler;
        juggler.removeTweens(this);
        animatingUp = false;
        animatingDown = true;
        juggler.tween(this, 1.0, {
                    transition : Transitions.EASE_IN_OUT,
                    onComplete : onHideSelfComplete,
                    y : y + height
                });
    }
    
    private function onHideSelfComplete() : Void
    {
        animatingDown = false;
        visible = false;
    }
    
    public function hideSecondaryDialog(dialog : BaseComponent, _hideMainDialog : Bool) : Void
    {
        hideMainDialog = _hideMainDialog;
        
        var juggler : Juggler = Starling.current.juggler;
        
        juggler.tween(dialog, 1.0, {
                    transition : Transitions.EASE_IN_OUT,
                    onComplete : onHideSecondaryDialogComplete,
                    x : dialog.x - dialog.width
                });
    }
    
    private function onHideSecondaryDialogComplete() : Void
    {
        submitLayoutDialog = null;
        if (hideMainDialog)
        {
            hideSelf();
        }
    }
    
    private function onNextLevelButtonTriggered() : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.SWITCH_TO_NEXT_LEVEL, "", true));
    }
}
