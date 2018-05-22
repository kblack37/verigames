package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.MiniMapEvent;
import events.MoveEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import scenes.game.display.GameEdgeContainer;
import scenes.game.display.GameNode;
import scenes.game.display.GameNodeBase;

/**
 * ...
 * @author ...
 */
class MoveScript extends ScriptNode 
{

	public function new(gameEngine : IGameEngine, id:String=null) 
	{
		super(id);
		
		gameEngine.addEventListener(MoveEvent.MOVE_EVENT, onMoveEvent);
        gameEngine.addEventListener(MoveEvent.FINISHED_MOVING, onFinishedMoving);
	}
	
	private function onMoveEvent(evt : MoveEvent) : Void
    {
        var delta : Point = evt.delta;
        var newLeft : Float = m_boundingBox.left;
        var newRight : Float = m_boundingBox.right;
        var newTop : Float = m_boundingBox.top;
        var newBottom : Float = m_boundingBox.bottom;
        var movedNodes : Array<GameNode> = new Array<GameNode>();
        //if component isn't in the currently selected group, unselect everything, and then move component
        if (Lambda.indexOf(selectedComponents, evt.component) == -1)
        {
            unselectAll();
            evt.component.componentMoved(delta);
            newLeft = Math.min(newLeft, evt.component.boundingBox.left);
            newRight = Math.max(newRight, evt.component.boundingBox.left);
            newTop = Math.min(newTop, evt.component.boundingBox.top);
            newBottom = Math.max(newBottom, evt.component.boundingBox.bottom);
            if (tutorialManager != null && (Std.is(evt.component, GameNode)))
            {
                movedNodes.push(try cast(evt.component, GameNode) catch(e:Dynamic) null);
                tutorialManager.onGameNodeMoved(movedNodes);
            }
        }
        //if (selectedComponents.length == 0) {
        else
        {
            
            //	totalMoveDist = new Point();
            //	return;
            //}
            var movedGameNode : Bool = false;
            for (component in selectedComponents)
            {
                component.componentMoved(delta);
                newLeft = Math.min(newLeft, component.boundingBox.left);
                newRight = Math.max(newRight, component.boundingBox.left);
                newTop = Math.min(newTop, component.boundingBox.top);
                newBottom = Math.max(newBottom, component.boundingBox.bottom);
                
                if (Std.is(component, GameNode))
                {
                    movedNodes.push(try cast(component, GameNode) catch(e:Dynamic) null);
                    movedGameNode = true;
                }
            }
            if (tutorialManager != null && movedGameNode)
            {
                tutorialManager.onGameNodeMoved(movedNodes);
            }
        }
        totalMoveDist.x += delta.x;
        totalMoveDist.y += delta.y;
        //trace(totalMoveDist);
        dispatchEvent(new MiniMapEvent(MiniMapEvent.ERRORS_MOVED));
        m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
    }
	
	private function onFinishedMoving(evt : MoveEvent) : Void
    // Recalc bounds
    {
        
        var minX : Float;
        var minY : Float;
        var maxX : Float;
        var maxY : Float;
        minX = minY = Math.POSITIVE_INFINITY;
        maxX = maxY = Math.NEGATIVE_INFINITY;
        var i : Int;
        if (Std.is(evt.component, GameNodeBase))
        {
        // If moved node, check those bounds - otherwise assume they're unchanged
            
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                minX = Math.min(minX, gameNode.boundingBox.left);
                minY = Math.min(minY, gameNode.boundingBox.top);
                maxX = Math.max(maxX, gameNode.boundingBox.right);
                maxY = Math.max(maxY, gameNode.boundingBox.bottom);
            }
        }
        for (edgeId in Reflect.fields(m_gameEdgeDict))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            minX = Math.min(minX, gameEdge.boundingBox.left);
            minY = Math.min(minY, gameEdge.boundingBox.top);
            maxX = Math.max(maxX, gameEdge.boundingBox.right);
            maxY = Math.max(maxY, gameEdge.boundingBox.bottom);
        }
        var oldBB : Rectangle = m_boundingBox.clone();
        m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
        if (oldBB.x != m_boundingBox.x ||
            oldBB.y != m_boundingBox.y ||
            oldBB.width != m_boundingBox.width ||
            oldBB.height != m_boundingBox.height)
        {
            dispatchEvent(new MiniMapEvent(MiniMapEvent.LEVEL_RESIZED));
        }
    }
	
}