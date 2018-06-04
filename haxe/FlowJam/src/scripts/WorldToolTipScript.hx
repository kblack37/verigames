package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import starling.display.Sprite;
import events.ToolTipEvent;
import starling.display.DisplayObject;
import display.NineSliceBatch;
import display.ToolTipText;
import scenes.game.display.Level;
import state.FlowJamGameState;
/**
 * ...
 * @author ...
 */
class WorldToolTipScript extends ScriptNode 
{
	private var m_activeToolTip : ToolTipText;
	private var m_activeLevel : Level;
	private var childToAdd : Sprite;
	private var m_gameEngine : IGameEngine;
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		
		m_activeLevel = cast(gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().getActiveLevel();
		
		childToAdd = new Sprite();
		gameEngine.getSprite().addChild(childToAdd);
		gameEngine.addEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
        gameEngine.addEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
		
		m_gameEngine = gameEngine;
	}
	
	private function onToolTipAdded(evt : ToolTipEvent) : Void
    {
        if (evt.text != null && evt.text.length > 0 && evt.component != null && m_activeLevel != null && m_activeToolTip == null)
        {
            function pointAt(lev : Level) : DisplayObject
            {
                return evt.component;
            };
            var pointFrom : String = NineSliceBatch.TOP_LEFT;
            var onTop : Bool = evt.point.y < 80;
            var onLeft : Bool = evt.point.x < 80;
            if (onTop && onLeft)
            {
            // If in top left corner, move to bottom right
                
                pointFrom = NineSliceBatch.BOTTOM_RIGHT;
            }
            else if (onLeft)
            {
            // If on left, move to top right
                
                pointFrom = NineSliceBatch.TOP_RIGHT;
            }
            else if (onTop)
            {
            // If on top, move to bottom left
                
                pointFrom = NineSliceBatch.BOTTOM_LEFT;
            }
            m_activeToolTip = new ToolTipText(evt.text, m_activeLevel, false, pointAt, pointFrom);
            if (evt.point != null)
            {
                m_activeToolTip.setGlobalToPoint(evt.point.clone());
            }
            childToAdd.addChild(m_activeToolTip);
        }
    }
	
	private function onToolTipCleared(evt : ToolTipEvent) : Void
    {
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
        }
        m_activeToolTip = null;
    }
	
	override public function dispose(){
		super.dispose();
		m_gameEngine.removeEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
        m_gameEngine.removeEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
	}
}