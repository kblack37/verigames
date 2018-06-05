package scripts;

import cgs.server.logging.IGameServerData.SkeyHashVersion;
import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.UndoEvent;
/**
 * ...
 * @author ...
 */
class WorldUndoScript extends ScriptNode 
{

	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		
		gameEngine.addEventListener(UndoEvent.UNDO_EVENT, saveEvent);
	}
	
	 private function saveEvent(evt : UndoEvent) : Void
    {
        if (evt.eventsToUndo.length == 0)
        {
            return;
        }
        //sometimes we need to remove the last event to add a complex event that includes that one
        //addToLastSimilar adds to the last event if they are of the same type (i.e. successive mouse wheel events should all undo at the same time)
        //addToLast adds to last event in any case (undo move node event also should put edges back where they were)
        var lastEvent : UndoEvent;
        if (evt.addToSimilar)
        {
            lastEvent = undoStack.pop();
            if (lastEvent != null && (lastEvent.eventsToUndo.length > 0))
            {
                if (lastEvent.eventsToUndo[0].type == evt.eventsToUndo[0].type)
                {
                // Add these to end of lastEvent's list of events to undo
                    
                    lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
                }
                //no match, just push, adding back lastEvent also
                else
                {
                    
                    {
                        undoStack.push(lastEvent);
                        undoStack.push(evt);
                    }
                }
            }
            else
            {
                undoStack.push(evt);
            }
        }
        else if (evt.addToLast)
        {
            lastEvent = undoStack.pop();
            if (lastEvent != null)
            {
            // Add these to end of lastEvent's list of events to undo
                
                lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
            }
            else
            {
                undoStack.push(evt);
            }
        }
        else
        {
            undoStack.push(evt);
        }
        //when we build on the undoStack, clear out the redoStack
        redoStack = new Array<UndoEvent>();
    }
}