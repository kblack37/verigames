package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import starling.display.Sprite;
import events.ToolTipEvent;
import starling.display.DisplayObject;
import display.NineSliceBatch;
import display.ToolTipText;
/**
 * ...
 * @author ...
 */
class WorldToolTipScript extends ScriptNode 
{
	private var childToAdd : Sprite;
	public function new(gameEngine: IGameEngineid:String=null) 
	{
		super(id);
		
		childToAdd = new Sprite();
		gameEngine.getSprite().addChild(childToAdd);
		gameEngine.addEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
        gameEngine.addEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);

	}
	
	private function onToolTipAdded(evt : ToolTipEvent) : Void
    {
        if (evt.text != null && evt.text.length > 0 && evt.component != null && active_level != null && m_activeToolTip == null)
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
            m_activeToolTip = new ToolTipText(evt.text, active_level, false, pointAt, pointFrom);
            if (evt.point != null)
            {
                m_activeToolTip.setGlobalToPoint(evt.point.clone());
            }
            childToAdd.addChild(m_activeToolTip);
        }
    }
}