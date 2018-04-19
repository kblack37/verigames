package scenes.game.display;

import constraints.ConstraintVar;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import starling.events.Event;
import starling.events.KeyboardEvent;
import audio.AudioManager;
//import cgs.server.logging.actions.ClientAction;
import server.ReplayController;
import system.VerigameServerConstants;
import utils.XString;

// TODO: reconfigure for json
class ReplayWorld extends World
{
    
    public function new(_worldGraphDict : Dictionary, _worldObj : Dynamic, _layout : Dynamic, _assignments : Dynamic)
    {
        super(_worldGraphDict, _worldObj, _layout, _assignments);
    }
    
    override private function onAddedToStage(event : starling.events.Event) : Void
    {
        super.onAddedToStage(event);
        AudioManager.getInstance().reset();
    }
    
    override private function selectLevel(newLevel : Level) : Void
    {
        super.selectLevel(newLevel);
        PipeJam3.showReplayText("Replaying Level: " + active_level.original_level_name);
    }
    
    override public function handleKeyUp(event : KeyboardEvent) : Void
    {
        var _sw1_ = (event.keyCode);        

        switch (_sw1_)
        {
            case Keyboard.LEFT, Keyboard.A, Keyboard.NUMPAD_4:
                ReplayController.getInstance().backup(this);
            case Keyboard.RIGHT, Keyboard.D, Keyboard.NUMPAD_6:
                ReplayController.getInstance().advance(this);
        }
    }
    
    //public function performAction(action : ClientAction, isUndo : Bool = false) : Void
    /*{   TODO logging: refactor
			if (!action.detailObject) return;
			if (!active_level) return;
			var varId:String, propChanged:String, newPropValue:Boolean;
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_VAR_ID]) {
				varId = action.detailObject[VerigameServerConstants.ACTION_PARAMETER_VAR_ID] as String;
			}
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED]) {
				propChanged = action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED] as String;
			}
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE]) {
				newPropValue = XString.stringToBool(action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE] as String);
			}
			if (varId && propChanged) {
				var constraintVar:ConstraintVar = active_level.levelGraph.variableDict[varId];
				if (!constraintVar) {
					PipeJam3.showReplayText("Replay action failed: ConstraintVar not found: " + varId);
					return;
				}
				constraintVar.setProp(propChanged, newPropValue);
				PipeJam3.showReplayText("performed: " + varId + " " + propChanged + " -> " + newPropValue + (isUndo ? " (undo)" : ""));
			} else {
				PipeJam3.showReplayText("Replay action failed, varId: " + varId + " propChanged: " + propChanged);
			}
			*/  
        
    //}
    
    //public function previewAction(action : ClientAction, isUndo : Bool = false) : Void
    /*{  		if (!action.detailObject) return;
			if (!active_level) return;
			if (!edgeSetGraphViewPanel) return;
			var edgeSetId:String, propChanged:String, newPropValue:Boolean;
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_VAR_ID]) {
				edgeSetId = action.detailObject[VerigameServerConstants.ACTION_PARAMETER_VAR_ID] as String;
			}
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED]) {
				propChanged = action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED] as String;
			}
			if (action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE]) {
				newPropValue = XString.stringToBool(action.detailObject[VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE] as String);
			}
			if (edgeSetId && propChanged) {
				var gameNode:GameNode = active_level.getNode(edgeSetId);
				if (!gameNode) {
					PipeJam3.showReplayText("Replay action preview failed: Game node not found: " + edgeSetId);
					return;
				}
				edgeSetGraphViewPanel.centerOnComponent(gameNode);
				PipeJam3.showReplayText("Preview: " + edgeSetId + " " + propChanged + " -> " + newPropValue + (isUndo ? " (undo)" : ""));
			} else {
				PipeJam3.showReplayText("Replay action preview failed, edgeSetId: " + edgeSetId + " propChanged: " + propChanged);
			}*/  
        
    //}
}
