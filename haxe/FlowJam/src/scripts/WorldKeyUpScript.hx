package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import starling.events.KeyboardEvent;
import events.UndoEvent;
import starling.events.Event;
 /* ...
 * @author ...
 */
class WorldKeyUpScript extends ScriptNode 
{

	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		gameEngine.getSprite().stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		
	}
	private function handleKeyUp(event : starling.events.KeyboardEvent) : Void
    {
        if (event.ctrlKey)
        {
            var _sw1_ = (event.keyCode);            

            switch (_sw1_)
            {
                case 90, 82, 89, 72:

                    switch (_sw1_)
                    {case 90:  //'z'  
                        {
                            if ((undoStack.length > 0) && !PipeJam3.RELEASE_BUILD)
                            {
                            //high risk item, don't allow undo/redo until well tested
                                
                                {
                                    var undoDataEvent : UndoEvent = undoStack.pop();
                                    handleUndoRedoEvent(undoDataEvent, true);
                                }
                            }
                        }
                    }

                    switch (_sw1_)
                    {case 89:  //'y'  
                        {
                            if ((redoStack.length > 0) && !PipeJam3.RELEASE_BUILD)
                            {
                            //high risk item, don't allow undo/redo until well tested
                                
                                {
                                    var redoDataEvent : UndoEvent = redoStack.pop();
                                    handleUndoRedoEvent(redoDataEvent, false);
                                }
                            }
                        }
                    }  //'h' for hide  
                    if ((this.active_level != null) && !PipeJam3.RELEASE_BUILD)
                    {
                        active_level.toggleUneditableStrings();
                    }
                case 76:  //'l' for copy layout  
                if (this.active_level != null)
                {
                // && !PipeJam3.RELEASE_BUILD)
                    
                    {
                        active_level.updateLayoutObj(this);
                        System.setClipboard(haxe.Json.stringify(active_level.m_levelLayoutObjWrapper));
                    }
                }
                case 66:  //'b' for load Best scoring config  
                if (this.active_level != null)
                {
                // && !PipeJam3.RELEASE_BUILD)
                    
                    {
                        active_level.loadBestScoringConfiguration();
                    }
                }
                case 67:  //'c' for copy constraints  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    active_level.updateAssignmentsObj();
                    System.setClipboard(haxe.Json.stringify(active_level.m_levelAssignmentsObj));
                }
                case 65:  //'a' for copy of ALL (world)  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    var worldObj : Dynamic = updateAssignments();//from world
                    System.setClipboard(haxe.Json.stringify(worldObj));
                }
                case 88:  //'x' for copy of level  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    var levelObj : Dynamic = updateAssignments(true);
                    System.setClipboard(haxe.Json.stringify(levelObj));
                }
            }
        }
    }
	private function handleUndoRedoEvent(event : UndoEvent, isUndo : Bool) : Void
    //added newest at the end, so start at the end
    {
        
        var i : Int = event.eventsToUndo.length - 1;
        while (i >= 0)
        {
            var eventObj : Event = event.eventsToUndo[i];
            handleUndoRedoEventObject(eventObj, isUndo, event.levelEvent, event.component);
            i--;
        }
        if (isUndo)
        {
            redoStack.push(event);
        }
        else
        {
            undoStack.push(event);
        }
    }
	private function handleUndoRedoEventObject(evt : Event, isUndo : Bool, levelEvent : Bool, component : BaseComponent) : Void
    {
        if (active_level != null && levelEvent)
        {
            active_level.handleUndoEvent(evt, isUndo);
        }
        else if (component != null)
        {
            component.handleUndoEvent(evt, isUndo);
        }
    }
	
}