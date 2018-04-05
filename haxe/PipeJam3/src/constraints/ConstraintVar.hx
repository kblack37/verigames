package constraints;

import flash.errors.Error;
import constraints.events.VarChangeEvent;
import utils.PropDictionary;
import starling.events.EventDispatcher;

class ConstraintVar extends ConstraintSide
{
    
    public var defaultVal : ConstraintValue;
    
    private var m_props : PropDictionary;
    private var m_value : ConstraintValue;
    
    public function new(_id : String, _val : ConstraintValue, _defaultVal : ConstraintValue, _scoringConfig : ConstraintScoringConfig)
    {
        super(_id, _scoringConfig);
        m_value = _val;
        defaultVal = _defaultVal;
        m_props = new PropDictionary();
        if (m_value.intVal == 0)
        {
            m_props.setProp(PropDictionary.PROP_NARROW, true);
        }
    }
    
    public function getValue() : ConstraintValue
    {
        return m_value;
    }
    public function getProps() : PropDictionary
    {
        return m_props;
    }
    
    public function setProp(prop : String, value : Bool) : Void
    {
        if (prop == PropDictionary.PROP_NARROW)
        {
            m_value = ConstraintValue.fromStr((value) ? ConstraintValue.TYPE_0 : ConstraintValue.TYPE_1);
        }
        else
        {
            throw new Error("Unsupported property: " + prop);
        }
        if (m_props.hasProp(prop) != value)
        {
            trace(id, (value) ? " -> narrow" : " -> wide");
            m_props.setProp(prop, value);
            dispatchEvent(new VarChangeEvent(VarChangeEvent.VAR_CHANGED_IN_GRAPH, this, prop, value));
        }
    }
    
    override public function toString() : String
    {
        return id + "(=" + m_value.verboseStrVal + ")";
    }
}

