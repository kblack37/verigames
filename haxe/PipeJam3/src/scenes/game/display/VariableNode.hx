package scenes.game.display;

import flash.geom.Rectangle;
import constraints.ConstraintVar;
import utils.PropDictionary;

class VariableNode extends Node
{
    public var graphVar(get, never) : ConstraintVar;

    
    public function new(_id : String, _bb : Rectangle, _graphVar : ConstraintVar)
    {
        super(_id, _bb, _graphVar);
        //this is only intesting for non-clause Nodes
        isNarrow = graphVar.getProps().hasProp(PropDictionary.PROP_NARROW);
    }
    
    private function get_graphVar() : ConstraintVar
    {
        return try cast(graphConstraintSide, ConstraintVar) catch(e:Dynamic) null;
    }
}
