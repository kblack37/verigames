package graph;

import flash.utils.Dictionary;
import graph.Edge;
import graph.Port;
import graph.PropDictionary;

class ConflictDictionary
{
    private var portPropertyConflicts : Dictionary = new Dictionary();
    private var edgePropertyConflicts : Dictionary = new Dictionary();
    
    private var ports : Dictionary = new Dictionary();
    private var edges : Dictionary = new Dictionary();
    
    public function new()
    {
    }
    
    public function iterPorts() : Dynamic
    {
        return ports;
    }
    
    public function iterEdges() : Dynamic
    {
        return edges;
    }
    
    public function addPortConflict(port : Port, prop : String, test : Bool = false) : Void
    //trace("added port conflict: " + port + " prop:" + prop + " test:" + test);
    {
        
        if (test)
        {
            return;
        }
        
        var key : String = Std.string(port);
        Reflect.setField(ports, key, port);
        if (!portPropertyConflicts.exists(key))
        {
            Reflect.setField(portPropertyConflicts, key, new PropDictionary());
        }
        (try cast(Reflect.field(portPropertyConflicts, key), PropDictionary) catch(e:Dynamic) null).setProp(prop, true);
    }
    
    public function addEdgeConflict(edge : Edge, prop : String, test : Bool = false) : Void
    //trace("added edge conflict: " + edge.edge_id + " prop:" + prop + " test:" + test);
    {
        
        if (test)
        {
            return;
        }
        
        var key : String = edge.edge_id;
        Reflect.setField(edges, key, edge);
        if (!edgePropertyConflicts.exists(key))
        {
            Reflect.setField(edgePropertyConflicts, key, new PropDictionary());
        }
        (try cast(Reflect.field(edgePropertyConflicts, key), PropDictionary) catch(e:Dynamic) null).setProp(prop, true);
    }
    
    public function getPort(portString : String) : Port
    {
        if (ports.exists(portString))
        {
            return try cast(Reflect.field(ports, portString), Port) catch(e:Dynamic) null;
        }
        return null;
    }
    
    public function getEdge(edgeId : String) : Edge
    {
        if (edges.exists(edgeId))
        {
            return try cast(Reflect.field(edges, edgeId), Edge) catch(e:Dynamic) null;
        }
        return null;
    }
    
    public function getPortConflicts(portString : String) : PropDictionary
    {
        if (portPropertyConflicts.exists(portString))
        {
            return try cast(Reflect.field(portPropertyConflicts, portString), PropDictionary) catch(e:Dynamic) null;
        }
        return null;
    }
    
    public function getEdgeConflicts(edgeId : String) : PropDictionary
    {
        if (edgePropertyConflicts.exists(edgeId))
        {
            return try cast(Reflect.field(edgePropertyConflicts, edgeId), PropDictionary) catch(e:Dynamic) null;
        }
        return null;
    }
    
    public function clone() : ConflictDictionary
    {
        var prop : String;
        var newdict : ConflictDictionary = new ConflictDictionary();
        for (portk in Reflect.fields(portPropertyConflicts))
        {
            var portConfProps : PropDictionary = getPortConflicts(portk);
            for (prop in Reflect.fields(portConfProps.iterProps()))
            {
                newdict.addPortConflict(getPort(portk), prop);
            }
        }
        for (edgek in Reflect.fields(edgePropertyConflicts))
        {
            var edgeConfProps : PropDictionary = getEdgeConflicts(edgek);
            for (prop in Reflect.fields(edgeConfProps.iterProps()))
            {
                newdict.addEdgeConflict(getEdge(edgek), prop);
            }
        }
        return newdict;
    }
}
