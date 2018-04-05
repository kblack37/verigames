package scenes.game.display;

import flash.geom.Rectangle;
import flash.utils.Dictionary;
import constraints.ConstraintGraph;
import constraints.ConstraintSide;
import constraints.ConstraintVar;
import starling.events.Event;
import utils.PropDictionary;

class Node extends GridChild
{
    public var graphConstraintSide : ConstraintSide;
    public var isClause : Bool = false;
    public var solved : Bool = false;
    public var solverSelected : Bool;
    public var solverSelectedColor : Int;
    
    public function new(_id : String, _bb : Rectangle, _graphConstraintSide : ConstraintSide)
    {
        super(_id, _bb);
        graphConstraintSide = _graphConstraintSide;
    }
    
    override public function createSkin() : Void
    {
        if (skin == null)
        {
            skin = NodeSkin.getNextSkin();
        }
        if (skin == null)
        {
            return;
        }
        setupSkin();
        skin.draw();
        skin.x = centerPoint.x;
        skin.y = centerPoint.y;
    }
    
    override public function setupSkin() : Void
    {
        if (skin != null)
        {
            skin.setNodeProps(false, isNarrow, isSelected, solved, false, false);
        }
    }
    
    override public function removeSkin() : Void
    {
        super.removeSkin();
        if (skin != null)
        {
            (try cast(skin, NodeSkin) catch(e:Dynamic) null).disableSkin();
        }
        for (gameEdgeID in connectedEdgeIds)
        {
            var edgeObj : Dynamic = World.m_world.active_level.edgeLayoutObjs[gameEdgeID];
            if (edgeObj != null)
            {
                edgeObj.isDirty = true;
            }
        }
    }
    
    override public function skinIsDirty() : Bool
    {
        if (skin == null)
        {
            return false;
        }
        if (skin.isDirty)
        {
            return true;
        }
        if (skin.isNarrow() != isNarrow)
        {
            return true;
        }
        if (skin.isSelected() != isSelected)
        {
            return true;
        }
        if (skin.isSolved() != solved)
        {
            return true;
        }
        return false;
    }
    
    override public function draw() : Void
    {
        if (animating)
        {
            return;
        }
        if (backgroundIsDirty())
        {
            if (backgroundSkin == null)
            {
                createSkin();
            }
            if (backgroundSkin != null)
            {
                setupBackgroundSkin();
                backgroundSkin.draw();
            }
        }
        if (skinIsDirty())
        {
            if (skin == null)
            {
                createSkin();
            }
            if (skin != null)
            {
                setupSkin();
                skin.draw();
            }
        }
    }
    
    // TODO: move to VariableNode
    override public function updateSelectionAssignment(_isWide : Bool, levelGraph : ConstraintGraph) : Void
    {
        super.updateSelectionAssignment(_isWide, levelGraph);
        var constraintVar : ConstraintVar = levelGraph.variableDict[id];
        if (constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW) == _isWide)
        {
            constraintVar.setProp(PropDictionary.PROP_NARROW, !_isWide);
        }
    }
}
