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
import scenes.game.display.Level;
import scenes.game.display.TutorialLevelManager;
import state.FlowJamGameState;

/**
 * ...
 * @author Zan Balcom
 */
class MoveScript extends ScriptNode 
{
	
	private var m_gameEngine : IGameEngine;

	public function new(gameEngine : IGameEngine, id:String=null) 
	{
		super(id);
		
		gameEngine.addEventListener(MoveEvent.MOVE_EVENT, onMoveEvent);
        gameEngine.addEventListener(MoveEvent.FINISHED_MOVING, onFinishedMoving);
		
		m_gameEngine = gameEngine;
	}
	
	private function onMoveEvent(evt : MoveEvent) : Void
    {
		var level : Level = cast(m_gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().getActiveLevel();
		var tutorialManager : TutorialLevelManager = level.tutorialManager;
		var boundingBox : Rectangle = level.m_boundingBox;
        var delta : Point = evt.delta;
        var newLeft : Float = boundingBox.left;
        var newRight : Float = boundingBox.right;
        var newTop : Float = boundingBox.top;
        var newBottom : Float = boundingBox.bottom;
        var movedNodes : Array<GameNode> = new Array<GameNode>();
        //if component isn't in the currently selected group, unselect everything, and then move component
        if (Lambda.indexOf(level.selectedComponents, evt.component) == -1)
        {
            level.unselectAll();
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
            for (component in level.selectedComponents)
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
        level.totalMoveDist.x += delta.x;
        level.totalMoveDist.y += delta.y;
        //trace(totalMoveDist);
        m_gameEngine.dispatchEvent(new MiniMapEvent(MiniMapEvent.ERRORS_MOVED));
        level.m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
    }
	
	private function onFinishedMoving(evt : MoveEvent) : Void
    // Recalc bounds
    {
        var level : Level = cast(m_gameEngine.getStateMachine().getCurrentState, FlowJamGameState).getWorld().getActiveLevel();
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
            
            for (nodeId in Reflect.fields(level.getNodes()))
            {
                var gameNode : GameNode = level.getNode(nodeId);
                minX = Math.min(minX, gameNode.boundingBox.left);
                minY = Math.min(minY, gameNode.boundingBox.top);
                maxX = Math.max(maxX, gameNode.boundingBox.right);
                maxY = Math.max(maxY, gameNode.boundingBox.bottom);
            }
        }
        for (edgeId in Reflect.fields(level.getEdges()))
        {
            var gameEdge : GameEdgeContainer = level.getEdgeContainer(edgeId);
            minX = Math.min(minX, gameEdge.boundingBox.left);
            minY = Math.min(minY, gameEdge.boundingBox.top);
            maxX = Math.max(maxX, gameEdge.boundingBox.right);
            maxY = Math.max(maxY, gameEdge.boundingBox.bottom);
        }
        var oldBB : Rectangle = level.m_boundingBox.clone();
        level.m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
        if (oldBB.x != level.m_boundingBox.x ||
            oldBB.y != level.m_boundingBox.y ||
            oldBB.width != level.m_boundingBox.width ||
            oldBB.height != level.m_boundingBox.height)
        {
            m_gameEngine.dispatchEvent(new MiniMapEvent(MiniMapEvent.LEVEL_RESIZED));
        }
    }
	
}