package graph;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import events.StampChangeEvent;
import graph.StampRef;

class EdgeSetRef extends EventDispatcher
{
    public var id : String;
    // Level name to Vector.<Edge> containing edges for that level
    private var m_levelNameToEdges : Map<String, Array<Edge>> = new Map<String, Array<Edge>>();
    public var allEdges : Array<Edge> = new Array<Edge>();
    private var m_props : PropDictionary = new PropDictionary();
    // Possible stamps that the edge set can have, can only activate possible props
    private var m_possibleProps : PropDictionary;
    public var editable : Bool = false;
    public var propsInitialized : Bool = false;
    
    public function new(_id : String)
    {
        super();
        id = _id;
        m_possibleProps = new PropDictionary();
        // TODO: if edge set not editable, set to false
        m_possibleProps.setProp(PropDictionary.PROP_NARROW, true);
    }
    
    public function addEdge(edge : Edge, levelName : String) : Void
    {
        allEdges.push(edge);
        if (!m_levelNameToEdges.exists(levelName))
        {
			m_levelNameToEdges[levelName] = new Array<Edge>();
        }
        getLevelEdges(levelName).push(edge);
    }
    
    public function getLevelEdges(levelName : String) : Array<Edge>
    {
        var edges : Array<Edge> = m_levelNameToEdges[levelName];
        if (edges != null)
        {
            return edges;
        }
        
        //assume the dictionary only has one element, if name can't be found
        for (edges in m_levelNameToEdges.iterator())
        {
            return edges;
        }
        return null;
    }
    
    public function addStamp(_edge_set_id : String, _active : Bool) : Void
    {
        m_possibleProps.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, true);
        m_props.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, _active);
    }
    
    public function removeStamp(_edge_set_id : String) : Void
    {
        m_possibleProps.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
        m_props.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
    }
    
    public function activateStamp(_edge_set_id : String) : Void
    {
        if (!canSetProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id))
        {
            return;
        }
        var change : Bool = m_props.setPropCheck(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, true);
        if (change)
        {
            onActivationChange();
        }
    }
    
    public function deactivateStamp(_edge_set_id : String) : Void
    {
        if (!canSetProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id))
        {
            return;
        }
        var change : Bool = m_props.setPropCheck(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
        if (change)
        {
            onActivationChange();
        }
    }
    
    public function hasActiveStampOfEdgeSetId(_edge_set_id : String) : Bool
    {
        return m_props.hasProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id);
    }
    
    public function onActivationChange() : Void
    {
        var ev : StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_ACTIVATION, this);
        dispatchEvent(ev);
    }
    
    public function canSetProp(prop : String) : Bool
    {
        return m_possibleProps.hasProp(prop);
    }
    
    public function setProp(prop : String, val : Bool) : Void
    {
        if (!canSetProp(prop))
        {
            return;
        }
        var change : Bool = m_props.setPropCheck(prop, val);
        if (change && (prop.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0))
        {
            onActivationChange();
        }
    }
    
    // Testbed
    public function getProps() : PropDictionary
    {
        return m_props;
    }
}



