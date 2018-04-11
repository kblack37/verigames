package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.dependencies.IRequestDependency;

class RequestPropertyDependency implements IRequestDependency
{
    public var ready(get, never) : Bool;
    public var key(get, never) : String;
    public var value(never, set) : Dynamic;

    private var _propertyKey : String;
    private var _value : Dynamic;
    private var _valueSet : Bool;
    
    //Function that will be called when the property is set.
    private var _changeListener : Function;
    
    public function new(propertyKey : String)
    {
        _propertyKey = propertyKey;
    }
    
    public function setChangeListener(listener : Function) : Void
    {
        _changeListener = listener;
    }
    
    private function get_ready() : Bool
    {
        return _valueSet;
    }
    
    private function get_key() : String
    {
        return _propertyKey;
    }
    
    private function set_value(val : Dynamic) : Dynamic
    {
        _valueSet = true;
        _value = val;
        
        if (_changeListener != null)
        {
            _changeListener();
        }
        return val;
    }
}
