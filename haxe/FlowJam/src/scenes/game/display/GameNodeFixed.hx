package scenes.game.display;

import constraints.ConstraintVar;
import graph.PropDictionary;

class GameNodeFixed extends GameNode
{
    public function new(_layoutObj : Dynamic, _constraintVar : ConstraintVar, _draggable : Bool = true)
    {
        super(_layoutObj, _constraintVar, _draggable);
        m_isEditable = false;
        m_isWide = !constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW);
    }
    
    override public function isWide() : Bool
    {
        return m_isWide;
    }
}

