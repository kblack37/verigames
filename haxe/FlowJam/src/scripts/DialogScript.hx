package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import events.DialogEvent;
import starling.display.Sprite;

import dialogs.SimpleAlertDialog;
import dialogs.SaveDialog;
import dialogs.SubmitLevelDialog;
import events.MenuEvent;
import haxe.Constraints.Function;
import networking.Achievements;
/**
 * ...
 * @author ...
 */
class DialogScript extends ScriptNode 
{
	var childToAdd :Sprite;
	//Dialog events from the old menu events class
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		childToAdd = new Sprite();
		
		gameEngine.addEventListener(DialogEvent.LEVEL_SAVED, onLevelUploadSuccess);
		gameEngine.addEventListener(DialogEvent.POST_SAVE_DIALOG, postSaveDialog );
		gameEngine.addEventListener(DialogEvent.LEVEL_SUBMITTED, onLevelUploadSuccess);
		gameEngine.addEventListener(DialogEvent.LAYOUT_SAVED, onLevelUploadSuccess);
		gameEngine.addEventListener(DialogEvent.POST_SUBMIT_DIALOG, postSubmitDialog);
		gameEngine.addEventListener(DialogEvent.ACHIEVEMENT_ADDED, achievementAdded);
	}
	
	private function postSaveDialog(event : DialogEvent) : Void
    {
        if (shareDialog == null)
        {
            shareDialog = new SaveDialog(150, 100);
        }
        
        addChild(shareDialog);
    }
	
	private function onLevelUploadSuccess(event : DialogEvent) : Void
    {
        var dialogText : String;
        var dialogWidth : Float = 160;
        var dialogHeight : Float = 80;
        var socialText : String = "";
        var numLinesInText : Int = 1;
        var callbackFunction : Function = null;
        
        if (event.type == DialogEvent.LEVEL_SAVED)
        {
            dialogText = "Level Saved.";
        }
        else if (event.type == DialogEvent.LAYOUT_SAVED)
        {
            dialogText = "Layout Saved.";
            callbackFunction = reportSavedLayoutAchievement;
        }
        //MenuEvent.LEVEL_SUBMITTED
        else
        {
            
            {
                dialogText = "Level Submitted!";
                //	socialText = "I just finished a level!"; wait till social integration library
                //	dialogHeight = 130;
                callbackFunction = reportSubmitAchievement;
            }
        }
        var alert : SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, callbackFunction, numLinesInText);
        addChild(alert);
    }
	
	private function reportSavedLayoutAchievement() : Void
    {
        Achievements.checkAchievements(DialogEvent.SAVE_LAYOUT, 0);
    }
	
	private function reportSubmitAchievement() : Void
    {
        Achievements.checkAchievements(DialogEvent.LEVEL_SUBMITTED, 0);
        
        if (PipeJamGame.levelInfo.layoutUpdated)
        {
            Achievements.checkAchievements(MenuEvent.SET_NEW_LAYOUT, 0);
        }
    }
	
	private function postSubmitDialog(event : MenuEvent) : Void
    {
        var submitLevelDialog : SubmitLevelDialog = new SubmitLevelDialog(150, 120);
        addChild(submitLevelDialog);
    }
	
	private function switchToLevelSelect() : Void
    {
        gameEngine.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
    }
	
	public function achievementAdded(event : MenuEvent) : Void
    {
        var achievement : Achievements = try cast(event.data, Achievements) catch(e:Dynamic) null;
        var dialogText : String = achievement.m_message;
        var achievementID : String = achievement.m_id;
        var dialogWidth : Float = 160;
        var dialogHeight : Float = 60;
        var socialText : String = "";
        
        var alert : SimpleAlertDialog;
        if (achievementID == Achievements.TUTORIAL_FINISHED_ID)
        {
            alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, switchToLevelSelect);
        }
        else
        {
            alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
        }
        addChild(alert);
    }
}