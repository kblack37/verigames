package scenes.game.display;

import cgs.server.logging.actions.IClientAction;
import cgs.server.logging.actions.QuestAction;
import constraints.ConstraintVar;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import starling.events.Event;
import starling.events.KeyboardEvent;
import audio.AudioManager;
import server.ReplayController;
import system.VerigameServerConstants;
import utils.XString;

// TODO: reconfigure for json
class ReplayWorld extends World
{
    
    public function new(_worldGraphDict : Dynamic, _worldObj : Dynamic, _layout : Dynamic, _assignments : Dynamic)
    {
        super(null, _worldGraphDict, _worldObj, _layout, _assignments);
    }
    
    override private function onAddedToStage(event : Event) : Void
    {
        super.onAddedToStage(event);
        AudioManager.getInstance().reset();
    }
    
    override private function selectLevel(newLevel : Level, restart : Bool = false) : Void
    {
        super.selectLevel(newLevel, restart);
        PipeJam3.showReplayText("Replaying Level: " + active_level.original_level_name);
    }
    
    override public function handleKeyUp(event : KeyboardEvent) : Void
    {
        var _sw0_ = (event.keyCode);        

        switch (_sw0_)
        {
            case Keyboard.LEFT, Keyboard.A, Keyboard.NUMPAD_4:
                ReplayController.getInstance().backup(this);
            case Keyboard.RIGHT, Keyboard.D, Keyboard.NUMPAD_6:
                ReplayController.getInstance().advance(this);
        }
    }
    
    public function performAction(action : QuestAction, isUndo : Bool = false) : Void
    {
        if (action.detailObject == null)
        {
            return;
        }
        if (active_level == null)
        {
            return;
        }
        var varId : String = null;
        var propChanged : String = null;
        var newPropValue : Bool = null;
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_VAR_ID))
        {
            varId = Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_VAR_ID);
        }
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED))
        {
            propChanged = Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED);
        }
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE))
        {
            newPropValue = XString.stringToBool(Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE));
        }
        if (varId != null && propChanged != null)
        {
            var constraintVar : ConstraintVar = Reflect.field(active_level.levelGraph.variableDict, varId);
            if (constraintVar == null)
            {
                PipeJam3.showReplayText("Replay action failed: ConstraintVar not found: " + varId);
                return;
            }
            constraintVar.setProp(propChanged, newPropValue);
            PipeJam3.showReplayText("performed: " + varId + " " + propChanged + " -> " + newPropValue + ((isUndo) ? " (undo)" : ""));
        }
        else
        {
            PipeJam3.showReplayText("Replay action failed, varId: " + varId + " propChanged: " + propChanged);
        }
    }
    
    public function previewAction(action : QuestAction, isUndo : Bool = false) : Void
    {
        if (!action.detailObject)
        {
            return;
        }
        if (active_level == null)
        {
            return;
        }
        if (edgeSetGraphViewPanel == null)
        {
            return;
        }
        var edgeSetId : String = null;
        var propChanged : String = null;
        var newPropValue : Bool = null ;
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_VAR_ID))
        {
            edgeSetId = Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_VAR_ID);
        }
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED))
        {
            propChanged = Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED);
        }
        if (Reflect.hasField(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE))
        {
            newPropValue = XString.stringToBool(Reflect.field(action.detailObject, VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE));
        }
        if (edgeSetId != null && propChanged != null)
        {
            var gameNode : GameNode = active_level.getNode(edgeSetId);
            if (gameNode == null)
            {
                PipeJam3.showReplayText("Replay action preview failed: Game node not found: " + edgeSetId);
                return;
            }
            edgeSetGraphViewPanel.centerOnComponent(gameNode);
            PipeJam3.showReplayText("Preview: " + edgeSetId + " " + propChanged + " -> " + newPropValue + ((isUndo) ? " (undo)" : ""));
        }
        else
        {
            PipeJam3.showReplayText("Replay action preview failed, edgeSetId: " + edgeSetId + " propChanged: " + propChanged);
        }
    }
}
