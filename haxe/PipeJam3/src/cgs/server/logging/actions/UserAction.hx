package cgs.server.logging.actions;


class UserAction
{
    public var actionId(get, never) : Int;
    public var details(get, set) : Dynamic;

    private var _actionId : Int;
    
    private var _detailObject : Dynamic;
    
    public function new(aid : Int, details : Dynamic = null)
    {
        _actionId = aid;
        _detailObject = details;
    }
    
    private function get_actionId() : Int
    {
        return _actionId;
    }
    
    /**
		 * Add a property to the details field of the action message.
		 */
    public function addDetailProperty(key : String, value : Dynamic) : Void
    {
        if (_detailObject == null)
        {
            _detailObject = { };
        }
        
        Reflect.setField(_detailObject, key, value);
    }
    
    /**
		 * Set the detail properties for the action. Only dynamic properties of
		 * the passed object will be added to the detail field of the message.
		 *
		 * @param value instance of the Object class which has detail properties to be logged.
		 */
    private function set_details(value : Dynamic) : Dynamic
    {
        if (value != null)
        {
            for (key in Reflect.fields(value))
            {
                addDetailProperty(key, Reflect.field(value, key));
            }
        }
        return value;
    }
    
    private function get_details() : Dynamic
    {
        return _detailObject;
    }
}
