package cgs.server.logging;

import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.logging.requests.RequestPropertyDependency;

/**
 * Base class for passing log data to cgs user. This class can not be reused for
 * multiple log calls safely.
 */
class LogData
{
    public var dependencies(get, never) : Array<IRequestDependency>;
    public var ready(get, never) : Bool;

    private var _propertyDependencies : Array<RequestPropertyDependency>;
    
    public function new()
    {
        _propertyDependencies = new Array<RequestPropertyDependency>();
    }
    
    private function get_dependencies() : Array<IRequestDependency>
    {
        var depends : Array<IRequestDependency> = new Array<IRequestDependency>();
        for (depend in _propertyDependencies)
        {
            depends.push(depend);
        }
        
        return depends;
    }
    
    private function get_ready() : Bool
    {
        for (depen in _propertyDependencies)
        {
            if (!depen.ready)
            {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Set a property value to be sent as part of logging request.
     */
    public function setPropertyValue(key : String, value : Dynamic) : Void
    {
        for (propDepen in _propertyDependencies)
        {
            if (propDepen.key == key)
            {
                propDepen.value = value;
            }
        }
    }
    
    /**
     * Add a property dependency for the logging data. This will prevent the request
     * from being sent to the server until the property is set.
     */
    public function addPropertyDependcy(propertyKey : String) : IRequestDependency
    {
        var propDependency : RequestPropertyDependency = 
        new RequestPropertyDependency(propertyKey);
        
        _propertyDependencies.push(propDependency);
        
        return propDependency;
    }
}
