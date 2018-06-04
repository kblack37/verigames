package src.scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.GameComponentEvent;
import events.GroupSelectionEvent;
import scenes.game.display.GameComponent;

/**
 * ...
 * @author ...
 */
class ComponentSelectScript extends ScriptNode 
{

	public function new(gameEngine : IGameEngine, id:String=null) 
	{
		super(id);
		
		addEventListener(GameComponentEvent.COMPONENT_SELECTED, onComponentSelection);
        addEventListener(GameComponentEvent.COMPONENT_UNSELECTED, onComponentUnselection);
        addEventListener(GroupSelectionEvent.GROUP_SELECTED, onGroupSelection);
        addEventListener(GroupSelectionEvent.GROUP_UNSELECTED, onGroupUnselection);
	}
	
	private function onComponentSelection(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, true);
        }
        
        var selectionChangedComponents : Array<GameComponent> = new Array<GameComponent>();
        selectionChangedComponents.push(component);
        addSelectionUndoEvent(selectionChangedComponents, true);
    }
    
    private function onComponentUnselection(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, false);
        }
        
        var selectionChangedComponents : Array<GameComponent> = new Array<GameComponent>();
        selectionChangedComponents.push(component);
        addSelectionUndoEvent(selectionChangedComponents, false);
    }
    
    private function onGroupSelection(evt : GroupSelectionEvent) : Void
    {
        var selectionChangedComponents : Array<GameComponent> = evt.selection.copy();
        for (comp in selectionChangedComponents)
        {
            comp.componentSelected(true);
            componentSelectionChanged(comp, true);
        }
        addSelectionUndoEvent(evt.selection.copy(), true, true);
    }
    
    private function onGroupUnselection(evt : GroupSelectionEvent) : Void
    {
        var selectionChangedComponents : Array<GameComponent> = evt.selection.copy();
        for (comp in selectionChangedComponents)
        {
            comp.componentSelected(false);
            componentSelectionChanged(comp, false);
        }
        addSelectionUndoEvent(evt.selection.copy(), false);
    }
	
}