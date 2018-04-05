package networkGraph;

import events.StampChangeEvent;
import networkGraph.EdgeSetRef;

class StampRef
{
    public var active(get, set) : Bool;

    public var edge_set_id : String;
    private var pipe_edge_set_ref : EdgeSetRef;
    private var m_active : Bool;
    
    public function new(_edge_set_id : String, _active : Bool, _pipe_edge_set_ref : EdgeSetRef)
    {
        edge_set_id = _edge_set_id;
        m_active = _active;
        pipe_edge_set_ref = _pipe_edge_set_ref;
    }
    
    private function get_active() : Bool
    {
        return m_active;
    }
    
    private function set_active(b : Bool) : Bool
    {
        m_active = b;
        pipe_edge_set_ref.onActivationChange(this);
        return b;
    }
    
    public function toString() : String
    {
        return "{'edge_set_id':'" + edge_set_id + "', 'active':'" + Std.string(m_active) + "'}";
    }
}

