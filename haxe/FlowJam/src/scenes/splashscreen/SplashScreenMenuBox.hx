package scenes.splashscreen;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.text.TextField;
import flash.utils.Timer;
import dialogs.SimpleAlertDialog;
import display.NineSliceButton;
import events.NavigationEvent;
import events.ToolTipEvent;
import networking.GameFileHandler;
import networking.PlayerValidation;
import networking.TutorialController;
import scenes.BaseComponent;
import scenes.game.PipeJamGameScene;
import scenes.game.display.Level;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

class SplashScreenMenuBox extends BaseComponent
{
    private var m_mainMenu : Sprite;
    
    //main screen buttons
    private var play_button : NineSliceButton;
    private var return_to_last_level_button : NineSliceButton;
    private var continue_tutorial_button : NineSliceButton;
    
    //These are visible in demo mode only (PipeJam3.RELEASE_BUILD == false)
    private var tutorial_button : NineSliceButton;
    private var demo_button : NineSliceButton;
    
    private var loader : URLLoader;
    
    private var m_parent : SplashScreenScene;
    
    
    public var inputInfo : flash.text.TextField;
    
    public function new(parent : SplashScreenScene)
    {
        super();
        
        parent = m_parent;
        buildMainMenu();
        
        addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
        addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
    }
    
    private function addedToStage(event : starling.events.Event) : Void
    {
        addChild(m_mainMenu);
    }
    
    private function removedFromStage(event : starling.events.Event) : Void
    {
    }
    
    private static var DEMO_ONLY : Bool = false;  // True to only show demo button  
    private function buildMainMenu() : Void
    {
        m_mainMenu = new Sprite();
        
        var BUTTON_CENTER_X : Float = 252;  // center point to put Play and Log In buttons  
        var TOP_BUTTON_Y : Int = 205;
        
        if (PipeJam3.m_savedCurrentLevel.data.exists("levelInfoID") && PipeJam3.m_savedCurrentLevel.data.levelInfoID != null)
        {
            return_to_last_level_button = ButtonFactory.getInstance().createDefaultButton("Continue", 88, 32);
            return_to_last_level_button.addEventListener(starling.events.Event.TRIGGERED, onReturnToLastTriggered);
            return_to_last_level_button.x = BUTTON_CENTER_X - return_to_last_level_button.width / 2;
            return_to_last_level_button.y = TOP_BUTTON_Y;
            
            play_button = ButtonFactory.getInstance().createDefaultButton("New", 88, 32);
        }
        else
        {
            play_button = ButtonFactory.getInstance().createDefaultButton("Play", 88, 32);
        }
        play_button.x = BUTTON_CENTER_X - play_button.width / 2;
        if (return_to_last_level_button != null)
        {
            play_button.y = return_to_last_level_button.y + return_to_last_level_button.height + 5;
        }
        else
        {
            play_button.y = TOP_BUTTON_Y + 15;
        }  //if only two buttons center them  
        
        if (!isTutorialDone())
        {
            continue_tutorial_button = ButtonFactory.getInstance().createDefaultButton("Tutorial", 88, 32);
            continue_tutorial_button.addEventListener(starling.events.Event.TRIGGERED, onContinueTutorialTriggered);
            continue_tutorial_button.x = BUTTON_CENTER_X - continue_tutorial_button.width / 2;
            continue_tutorial_button.y = play_button.y + play_button.height + 5;
        }
        
        if (PipeJam3.RELEASE_BUILD)
        {
            if (return_to_last_level_button != null)
            {
                m_mainMenu.addChild(return_to_last_level_button);
            }
            m_mainMenu.addChild(play_button);
            play_button.addEventListener(starling.events.Event.TRIGGERED, onPlayButtonTriggered);
            if (continue_tutorial_button != null)
            {
                m_mainMenu.addChild(continue_tutorial_button);
            }
        }
        else if (PipeJam3.TUTORIAL_DEMO)
        {
            if (!DEMO_ONLY)
            {
                m_mainMenu.addChild(play_button);
            }
            play_button.addEventListener(starling.events.Event.TRIGGERED, getNextPlayerLevelDebug);
        }
        else if (!PipeJam3.TUTORIAL_DEMO)
        
        //not release, not tutorial demo{
            
            {
                if (!DEMO_ONLY)
                {
                    m_mainMenu.addChild(play_button);
                }
                play_button.addEventListener(starling.events.Event.TRIGGERED, onPlayButtonTriggered);
            }
        }
        
        if (!PipeJam3.RELEASE_BUILD && !PipeJam3.TUTORIAL_DEMO)
        {
            tutorial_button = ButtonFactory.getInstance().createDefaultButton("Tutorial", 56, 22);
            tutorial_button.addEventListener(starling.events.Event.TRIGGERED, onTutorialButtonTriggered);
            tutorial_button.x = Constants.GameWidth - tutorial_button.width - 4;
            tutorial_button.y = 110;
            if (!DEMO_ONLY)
            {
                m_mainMenu.addChild(tutorial_button);
            }
            
            if (DEMO_ONLY)
            {
                demo_button = ButtonFactory.getInstance().createDefaultButton("Demo", play_button.width, play_button.height);
                demo_button.addEventListener(starling.events.Event.TRIGGERED, onDemoButtonTriggered);
                demo_button.x = play_button.x;
                demo_button.y = play_button.y;
            }
            else
            {
                demo_button = ButtonFactory.getInstance().createDefaultButton("Demo", 56, 22);
                demo_button.addEventListener(starling.events.Event.TRIGGERED, onDemoButtonTriggered);
                demo_button.x = Constants.GameWidth - demo_button.width - 4;
                demo_button.y = tutorial_button.y + 30;
            }
            m_mainMenu.addChild(demo_button);
        }
    }
    
    
    
    private function onReturnToLastTriggered(e : starling.events.Event) : Void
    {
        if (!PlayerValidation.playerLoggedIn)
        {
            var dialogText : String = "You must be logged in to continue play.";
            var dialogWidth : Float = 160;
            var dialogHeight : Float = 60;
            var socialText : String = "";
            var alert : SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
            addChild(alert);
        }
        else
        {
            getSavedLevel(null);
        }
    }
    
    private function onPlayButtonTriggered(e : starling.events.Event) : Void
    {
        if (!PlayerValidation.playerLoggedIn)
        {
            var dialogText : String = "You must be logged in to continue play.";
            var dialogWidth : Float = 160;
            var dialogHeight : Float = 60;
            var socialText : String = "";
            var alert : SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
            addChild(alert);
        }
        else
        {
            getNextRandomLevel(null);
        }
    }
    
    private function onContinueTutorialTriggered(e : starling.events.Event) : Void
    {
        loadTutorial();
    }
    
    private function onExitButtonTriggered() : Void
    {
        m_mainMenu.visible = true;
    }
    
    private function onActivate(evt : flash.events.Event) : Void
    {
        Starling.current.nativeStage.removeEventListener(flash.events.Event.ACTIVATE, onActivate);
    }
    
    private function onPlayerActivated(result : Int, e : flash.events.Event) : Void
    {
        m_mainMenu.visible = false;
        getNextPlayerLevel();
    }
    
    //serve either the next tutorial level, or give the full level select screen if done
    private function getNextPlayerLevelDebug(e : starling.events.Event) : Void
    //load tutorial file just in case
    {
        
        onTutorialButtonTriggered(null);
    }
    
    //serve either the next tutorial level, or give the full level select screen if done
    private function getNextPlayerLevel() : Void
    {
        if (isTutorialDone() || !PipeJam3.initialLevelDisplay)
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
            PipeJamGameScene.inTutorial = false;
        }
        else
        {
            loadTutorial();
        }
    }
    
    private function getSavedLevel(evt : TimerEvent) : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.GET_SAVED_LEVEL));
    }
    
    
    private function getNextRandomLevel(evt : TimerEvent) : Void
    //check to see if we have the level list yet, if not, stall
    {
        
        if (GameFileHandler.levelInfoVector == null)
        {
            var timer : Timer = new Timer(200, 1);
            timer.addEventListener(TimerEvent.TIMER, getNextRandomLevel);
            timer.start();
            return;
        }
        
        dispatchEvent(new NavigationEvent(NavigationEvent.GET_RANDOM_LEVEL));
    }
    
    
    
    private function isTutorialDone() : Bool
    //check on next level, returns -1 if
    {
        
        var isDone : Bool = TutorialController.getTutorialController().isTutorialDone();
        
        if (isDone)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    private function onTutorialButtonTriggered(e : starling.events.Event) : Void
    //go to the beginning
    {
        
        TutorialController.getTutorialController().resetTutorialStatus();
        
        loadTutorial();
    }
    
    private function loadTutorial() : Void
    {
        PipeJamGameScene.inTutorial = true;
        PipeJamGameScene.inDemo = false;
        PipeJam3.initialLevelDisplay = false;
        
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
    }
    
    private static var fileNumber : Int = 0;
    private function onDemoButtonTriggered(e : starling.events.Event) : Void
    {
        PipeJamGameScene.inTutorial = false;
        PipeJamGameScene.inDemo = true;
        if (PipeJamGameScene.demoArray.length == fileNumber)
        {
            fileNumber = 0;
        }
        PipeJamGame.levelInfo = {};
        PipeJamGame.levelInfo.baseFileName = PipeJamGameScene.demoArray[fileNumber];
        fileNumber++;
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
    }
    
    public function showMainMenu(show : Bool) : Void
    {
        m_mainMenu.visible = show;
    }
}
