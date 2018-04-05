package networkGraph;

import events.StampChangeEvent;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import networkGraph.StampRef;

class EdgeSetRef extends EventDispatcher
{
    public var num_stamps(get, never) : Int;
    public var num_active_stamps(get, never) : Int;

    public var stamp_dictionary : Dictionary = new Dictionary();
    private var edge_set_dictionary : Dictionary;
    public var id : String;
    public var edge_ids : Array<String> = new Array<String>();
    
    public function new(_id : String, _edge_set_dictionary : Dictionary)
    {
        super();
        id = _id;
        edge_set_dictionary = _edge_set_dictionary;
    }
    
    public function addStamp(_edge_set_id : String, _active : Bool) : Void
    {
        if (Reflect.field(stamp_dictionary, _edge_set_id) == null)
        {
            Reflect.setField(stamp_dictionary, _edge_set_id, new StampRef(_edge_set_id, _active, this));
        }
        else if ((try cast(Reflect.field(stamp_dictionary, _edge_set_id), StampRef) catch(e:Dynamic) null).active != _active)
        {
            (try cast(Reflect.setField(stamp_dictionary, _edge_set_id, _active), StampRef) catch(e:Dynamic) null).active;
        }
    }
    
    public function removeStamp(_edge_set_id : String) : Void
    {
        if (Reflect.field(stamp_dictionary, _edge_set_id) != null)
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete stamp_dictionary[_edge_set_id];
        }
    }
    
    public function activateStamp(_edge_set_id : String) : Void
    {
        if (Reflect.field(stamp_dictionary, _edge_set_id) != null)
        {
            (try cast(Reflect.setField(stamp_dictionary, _edge_set_id, true), StampRef) catch(e:Dynamic) null).active;
        }
    }
    
    public function deactivateStamp(_edge_set_id : String) : Void
    {
        if (Reflect.field(stamp_dictionary, _edge_set_id) != null)
        {
            (try cast(Reflect.setField(stamp_dictionary, _edge_set_id, false), StampRef) catch(e:Dynamic) null).active;
        }
    }
    
    public function hasActiveStampOfEdgeSetId(_edge_set_id : String) : Bool
    {
        if (Reflect.field(stamp_dictionary, _edge_set_id) == null)
        {
            return false;
        }
        return (try cast(Reflect.field(stamp_dictionary, _edge_set_id), StampRef) catch(e:Dynamic) null).active;
    }
    
    private function get_num_stamps() : Int
    {
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamp_dictionary))
        {
            i++;
        }
        return i;
    }
    
    private function get_num_active_stamps() : Int
    {
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamp_dictionary))
        {
            if ((try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null).active)
            {
                i++;
            }
        }
        return i;
    }
    
    public function getStampEdgeSetIdAt(index : Int) : String
    {
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamp_dictionary))
        {
            if (i == index)
            {
                return (try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null).edge_set_id;
            }
            i++;
        }
        return "";
    }
    
    public function getActiveStampEdgeSetIdAt(index : Int) : String
    {
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamp_dictionary))
        {
            if ((try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null).active)
            {
                if (i == index)
                {
                    return (try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null).edge_set_id;
                }
                i++;
            }
        }
        return "";
    }
    
    public function getActiveStampAt(index : Int) : StampRef
    {
        var i : Int = 0;
        for (edge_set_id in Reflect.fields(stamp_dictionary))
        {
            if ((try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null).active)
            {
                if (i == index)
                {
                    return (try cast(Reflect.field(stamp_dictionary, edge_set_id), StampRef) catch(e:Dynamic) null);
                }
                i++;
            }
        }
        return null;
    }
    
    public function onActivationChange(_stampRef : StampRef) : Void
    {
        var ev : StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_ACTIVATION, _stampRef);
        dispatchEvent(ev);
    }
}



