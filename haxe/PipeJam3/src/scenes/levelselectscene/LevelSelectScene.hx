package scenes.levelselectscene;

import flash.errors.Error;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceBatch;
import display.NineSliceButton;
import display.NineSliceToggleButton;
import events.MenuEvent;
import events.NavigationEvent;
import networking.GameFileHandler;
import networking.NetworkConnection;
import networking.PlayerValidation;
import networking.TutorialController;
import scenes.Scene;
import scenes.game.PipeJamGameScene;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.events.Event;

class LevelSelectScene extends Scene
{
    private var background : Image;
    
    private var levelSelectBackground : NineSliceBatch;
    private var levelSelectInfoPanel : NineSliceBatch;
    
    private var matchArrayObjects : Array<Dynamic> = null;
    private var matchArrayMetadata : Array<Dynamic> = null;
    private var savedLevelsArrayMetadata : Array<Dynamic> = null;
    
    private var tutorial_levels_button : NineSliceToggleButton;
    private var new_levels_button : NineSliceToggleButton;
    private var saved_levels_button : NineSliceToggleButton;
    
    private var select_button : NineSliceButton;
    private var cancel_button : NineSliceButton;
    
    private var tutorialListBox : SelectLevelList;
    private var newLevelListBox : SelectLevelList;
    private var currentVisibleListBox : SelectLevelList;
    
    //for the info panel
    private var infoLabel : TextFieldWrapper;
    private var nameText : TextFieldWrapper;
    private var numNodesText : TextFieldWrapper;
    private var numEdgesText : TextFieldWrapper;
    private var numConflictsText : TextFieldWrapper;
    private var scoreText : TextFieldWrapper;
    private var leaderText : TextFieldWrapper;
    
    public function new(game : PipeJamGame)
    {
        super(game);
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        
        background = new Image(AssetInterface.getTexture("Game", "ParadoxLevelSelectBackgroundClass"));
        background.scaleX = stage.stageWidth / background.width;
        background.scaleY = stage.stageHeight / background.height;
        background.blendMode = BlendMode.NONE;
        addChild(background);
        
        var levelSelectWidth : Float = 305;
        var levelSelectHeight : Float = 320;
        levelSelectBackground = new NineSliceBatch(levelSelectWidth, levelSelectHeight, levelSelectWidth / 6.0, levelSelectHeight / 6.0, AssetInterface.PipeJamSpriteSheetAtlas, "LevelSelectWindow");
        levelSelectBackground.x = 10;
        levelSelectBackground.y = 5;
        addChild(levelSelectBackground);
        
        var levelSelectInfoWidth : Float = 150;
        var levelSelectInfoHeight : Float = 320;
        levelSelectInfoPanel = new NineSliceBatch(levelSelectInfoWidth, levelSelectInfoHeight, levelSelectInfoWidth / 6.0, levelSelectInfoHeight / 6.0, AssetInterface.PipeJamSpriteSheetAtlas, "LevelSelectWindow");
        levelSelectInfoPanel.x = width - levelSelectInfoWidth - 10;
        levelSelectInfoPanel.y = 5;
        addChild(levelSelectInfoPanel);
        
        //select side widgets
        var buttonPadding : Int = 7;
        var buttonWidth : Float = (levelSelectWidth - 2 * buttonPadding) / 3 - buttonPadding;
        var buttonHeight : Float = 25;
        var buttonY : Float = 30;
        
        var label : TextFieldWrapper = TextFactory.getInstance().createTextField("Select Level", AssetsFont.FONT_UBUNTU, 120, 30, 24, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(label, 1, 1);
        addChild(label);
        label.x = (levelSelectWidth - label.width) / 2 + levelSelectBackground.x;
        label.y = 10;
        
        infoLabel = TextFactory.getInstance().createTextField("Level Info", AssetsFont.FONT_UBUNTU, 80, 24, 18, 0xFFFFFF);
        TextFactory.getInstance().updateAlign(infoLabel, 1, 1);
        addChild(infoLabel);
        infoLabel.x = (levelSelectInfoWidth - infoLabel.width) / 2 + levelSelectInfoPanel.x;
        infoLabel.y = buttonY + label.y;
        
        tutorial_levels_button = ButtonFactory.getInstance().createTabButton("Intro", buttonWidth, buttonHeight, 6, 6);
        tutorial_levels_button.addEventListener(starling.events.Event.TRIGGERED, onTutorialButtonTriggered);
        addChild(tutorial_levels_button);
        tutorial_levels_button.x = buttonPadding + 12;
        tutorial_levels_button.y = buttonY + label.y;
        
        new_levels_button = ButtonFactory.getInstance().createTabButton("Current", buttonWidth, buttonHeight, 6, 6);
        new_levels_button.addEventListener(starling.events.Event.TRIGGERED, onNewButtonTriggered);
        addChild(new_levels_button);
        new_levels_button.x = tutorial_levels_button.x + buttonWidth + buttonPadding;
        new_levels_button.y = buttonY + label.y;
        
        select_button = ButtonFactory.getInstance().createDefaultButton("Select", 50, 18);
        select_button.addEventListener(starling.events.Event.TRIGGERED, onSelectButtonTriggered);
        addChild(select_button);
        select_button.x = levelSelectWidth - 50 - buttonPadding;
        select_button.y = levelSelectHeight - select_button.height - 12;
        
        cancel_button = ButtonFactory.getInstance().createDefaultButton("Cancel", 50, 18);
        cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
        addChild(cancel_button);
        cancel_button.x = select_button.x - cancel_button.width - buttonPadding;
        cancel_button.y = levelSelectHeight - cancel_button.height - 12;
        
        tutorialListBox = new SelectLevelList(levelSelectWidth - 3 * buttonPadding - 4, levelSelectHeight - label.height - tutorial_levels_button.height - cancel_button.height - 4 * buttonPadding - 2);
        tutorialListBox.y = tutorial_levels_button.y + tutorial_levels_button.height + buttonPadding - 2;
        tutorialListBox.x = (levelSelectWidth - tutorialListBox.width) / 2 + levelSelectBackground.x + 2;
        addChild(tutorialListBox);
        
        newLevelListBox = new SelectLevelList(levelSelectWidth - 3 * buttonPadding - 4, levelSelectHeight - label.height - tutorial_levels_button.height - cancel_button.height - 4 * buttonPadding - 2);
        newLevelListBox.y = tutorialListBox.y;
        newLevelListBox.x = tutorialListBox.x;
        addChild(newLevelListBox);
        
        initialize();
    }
    
    override private function removedFromStage(event : Event) : Void
    {
        removeEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
        Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    public function initialize() : Void
    {
        tutorialListBox.setClipRect();
        newLevelListBox.setClipRect();
        
        if (PlayerValidation.accessGranted())
        {
            newLevelListBox.startBusyAnimation(newLevelListBox);
            
            GameFileHandler.levelInfoVector = null;
            GameFileHandler.getLevelMetadata(onRequestLevels);
        }
        else
        {
            new_levels_button.alphaValue = 0.9;
            new_levels_button.enabled = false;
        }
        
        setTutorialFile(TutorialController.tutorialObj);
        
        if (!TutorialController.getTutorialController().isTutorialDone() || !PlayerValidation.accessGranted())
        {
            onTutorialButtonTriggered(null);
        }
        else
        {
            onNewButtonTriggered(null);
        }
        
        addEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
        Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, false);
    }
    
    private function onTutorialButtonTriggered(e : Event) : Void
    {
        tutorialListBox.visible = true;
        newLevelListBox.visible = false;
        
        tutorial_levels_button.setToggleState(true);
        new_levels_button.setToggleState(false);
        
        currentVisibleListBox = tutorialListBox;
        updateSelectedLevelInfo();
    }
    
    private function onNewButtonTriggered(e : Event) : Void
    {
        tutorialListBox.visible = false;
        newLevelListBox.visible = true;
        
        tutorial_levels_button.setToggleState(false);
        new_levels_button.setToggleState(true);
        saved_levels_button.setToggleState(false);
        
        currentVisibleListBox = newLevelListBox;
        updateSelectedLevelInfo();
    }
    
    public function updateSelectedLevelInfo(e : Event = null) : Void
    {
        var nextTextBoxYPos : Float = tutorialListBox.y;
        if (currentVisibleListBox.currentSelection && currentVisibleListBox.currentSelection.data)
        {
            var currentSelectedLevel : Dynamic = currentVisibleListBox.currentSelection.data;
            
            removeChild(nameText);
            var name : String;
            if (currentSelectedLevel.exists("display_name"))
            {
                name = currentSelectedLevel.display_name;
            }
            else if (currentSelectedLevel.exists("name"))
            {
                name = currentSelectedLevel.name;
            }
            if (currentSelectedLevel.exists("name") || currentSelectedLevel.exists("display_name"))
            {
                nameText = TextFactory.getInstance().createTextField("Name: " + name, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(nameText, 0, 1);
                addChild(nameText);
                nameText.x = levelSelectInfoPanel.x + 10;
                nameText.y = nextTextBoxYPos;  //line up with list box  
                nextTextBoxYPos += 20;
            }
            
            removeChild(numNodesText);
            removeChild(numEdgesText);
            removeChild(numConflictsText);
            removeChild(scoreText);
            removeChild(leaderText);
            
            if (currentSelectedLevel.exists("widgets"))
            {
                numNodesText = TextFactory.getInstance().createTextField("Widgets: " + currentSelectedLevel.widgets, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(numNodesText, 0, 1);
                addChild(numNodesText);
                numNodesText.x = levelSelectInfoPanel.x + 10;
                numNodesText.y = nextTextBoxYPos;
                nextTextBoxYPos += 20;
                
                numEdgesText = TextFactory.getInstance().createTextField("Links: " + currentSelectedLevel.links, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(numEdgesText, 0, 1);
                addChild(numEdgesText);
                numEdgesText.x = levelSelectInfoPanel.x + 10;
                numEdgesText.y = nextTextBoxYPos;
                nextTextBoxYPos += 20;
                
                numConflictsText = TextFactory.getInstance().createTextField("Jams: " + currentSelectedLevel.conflicts, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(numConflictsText, 0, 1);
                addChild(numConflictsText);
                numConflictsText.x = levelSelectInfoPanel.x + 10;
                numConflictsText.y = nextTextBoxYPos;
                nextTextBoxYPos += 20;
                
                scoreText = TextFactory.getInstance().createTextField("Score: " + currentSelectedLevel.current_score, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(scoreText, 0, 1);
                addChild(scoreText);
                scoreText.x = levelSelectInfoPanel.x + 10;
                scoreText.y = nextTextBoxYPos;
                nextTextBoxYPos += 20;
                
                leaderText = TextFactory.getInstance().createTextField("Leader: " + currentSelectedLevel.leader, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
                TextFactory.getInstance().updateAlign(leaderText, 0, 1);
                addChild(leaderText);
                leaderText.x = levelSelectInfoPanel.x + 10;
                leaderText.y = nextTextBoxYPos;
                nextTextBoxYPos += 20;
            }
            
            if (e != null && e.data && e.data.exists("tapCount") && e.data.tapCount == 2)
            {
                onSelectButtonTriggered(e);
            }
        }
    }
    
    private function onMouseWheel(event : MouseEvent) : Void
    {
        var delta : Float = event.delta;
        currentVisibleListBox.scrollPanel(-delta);
    }
    
    private function onCancelButtonTriggered(e : Event) : Void
    {
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
    }
    
    private function onSelectButtonTriggered(ev : Event) : Void
    {
        var dataObj : Dynamic = currentVisibleListBox.currentSelection.data;
        dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
        
        if (currentVisibleListBox == tutorialListBox)
        {
            TutorialController.getTutorialController().fromLevelSelectList = true;
            PipeJamGameScene.inTutorial = true;
        }
        else
        {
            PipeJamGameScene.inTutorial = false;
        }
        
        if (dataObj != null)
        {
            if (dataObj.exists("levelId") && PipeJamGameScene.inTutorial)
            
            //PipeJamGameScene.inDemo = false;{
                
                PipeJamGame.levelInfo.name = dataObj.name;
                PipeJamGame.levelInfo.id = dataObj.levelId;
                PipeJamGame.levelInfo.tutorialLevelID = dataObj.levelId;
                dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
            }
        }
    }
    
    private function onRequestLevels(result : Int, o : Dynamic = null) : Void
    {
        try
        {
            if (result == NetworkConnection.EVENT_COMPLETE)
            {
                GameFileHandler.completedLevelVector = new Array<Dynamic>();
                
                if (GameFileHandler.levelInfoVector != null && GameFileHandler.completedLevelVector != null)
                {
                    onGetLevelMetadataComplete();
                }
            }
        }
        catch (err : Error)
        
        //probably a parse error in trying to decode the RA response{
            
            {
                trace("ERROR: failure in loading levels " + err);
                newLevelListBox.stopBusyAnimation();
            }
        }
    }
    
    private function onGetLevelMetadataComplete() : Void
    {
        matchArrayMetadata = new Array<Dynamic>();
        var i : Int = 0;
        var completedLevelDictionary : Dictionary = new Dictionary();
        for (i in 0...GameFileHandler.completedLevelVector.length)
        {
            var completedLevel : Dynamic = GameFileHandler.completedLevelVector[i];
            completedLevelDictionary[completedLevel.levelID] = completedLevel;
        }
        
        for (i in 0...GameFileHandler.levelInfoVector.length)
        {
            var match : Dynamic = GameFileHandler.levelInfoVector[i];
            matchArrayMetadata.push(match);
            match.unlocked = true;
            if (completedLevelDictionary[match.xmlID] != null)
            {
                match.checked = true;
            }
        }
        
        //alphabetize array
        matchArrayMetadata.sortOn("name");
        setNewLevelInfo(matchArrayMetadata);
        
        onRequestLevelsComplete();
    }
    
    private function onRequestLevelsComplete() : Void
    {
        if (GameFileHandler.levelInfoVector != null && GameFileHandler.completedLevelVector != null && newLevelListBox != null)
        {
            newLevelListBox.stopBusyAnimation();
        }
    }
    
    private static var levelCount : Int = 1;
    private function fileLevelNameFromMatch(match : Dynamic, levelMetadataVector : Array<Dynamic>, savedObjArray : Array<Dynamic>) : Dynamic
    //find the level record based on id, and then find the levelID match
    {
        
        var levelNotFound : Bool = true;
        var index : Int = 0;
        var foundObj : Dynamic;
        
        var objID : String;
        var matchID : String;
        if (Std.is(match.levelId, String))
        {
            matchID = match.levelId;
        }
        else if (Std.is(match.emptorId, String))
        
        //work around for hopefully temporary bug in RA{
            
            matchID = match.emptorId;
        }
        else
        {
            matchID = match.levelId.__DOLLAR__oid;
        }
        
        while (levelNotFound)
        {
            if (index >= levelMetadataVector.length)
            {
                break;
            }
            
            foundObj = levelMetadataVector[index];
            if (Std.is(foundObj.levelId, String))
            {
                objID = foundObj.levelId;
            }
            else
            {
                objID = foundObj.levelId.__DOLLAR__oid;
            }
            
            if (matchID == objID)
            {
                levelNotFound = false;
                break;
            }
            index++;
        }
        if (levelNotFound)
        
        //TODO -report error? or just skip?{
            
            return null;
        }
        
        if (Std.is(foundObj.levelId, String))
        {
            objID = foundObj.levelId;
        }
        else
        {
            objID = foundObj.levelId.__DOLLAR__oid;
        }
        
        for (i in 0...levelMetadataVector.length)
        {
            var levelObj : Dynamic = levelMetadataVector[i];
            //we don't want ourselves
            //	if(levelObj == foundObj) there was a time when the RA info was stored here too, and as such we needed to skip this
            //		continue;
            var levelObjID : String;
            if (Std.is(levelObj.levelId, String))
            {
                levelObjID = levelObj.levelId;
            }
            else
            {
                levelObjID = levelObj.levelId.__DOLLAR__oid;
            }
            
            if (objID == levelObjID)
            {
                savedObjArray.push(levelObj);
                return levelObj;
            }
        }
        
        return null;
    }
    
    private function onLevelSelected(e : starling.events.Event) : Void
    {
    }
    
    public function setNewLevelInfo(_newLevelInfo : Array<Dynamic>) : Void
    {
        this.newLevelListBox.setButtonArray(_newLevelInfo, false);
    }
    
    public function setTutorialFile(tutorialObj : Dynamic) : Void
    {
        var tutorialLevels : Array<Dynamic> = Reflect.field(tutorialObj, "levels");
        var tutorialController : TutorialController = TutorialController.getTutorialController();
        var tutorialArray : Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...tutorialLevels.length)
        {
            var levelObj : Dynamic = tutorialLevels[i];
            var obj : Dynamic = {};
            obj.levelId = Std.string(Reflect.field(levelObj, "qid"));
            obj.name = Std.string(Reflect.field(levelObj, "id"));
            if (levelObj.exists("display_name"))
            {
                obj.display_name = Std.string(Reflect.field(levelObj, "display_name"));
            }
            else
            {
                obj.display_name = Std.string(Reflect.field(levelObj, "id"));
            }
            
            obj.unlocked = true;
            obj.checked = true;
            
            tutorialArray.push(obj);
        }
        tutorialListBox.setButtonArray(tutorialArray, false);
    }
}


