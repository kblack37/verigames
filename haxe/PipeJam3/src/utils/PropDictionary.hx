package utils;

import flash.utils.Dictionary;

class PropDictionary
{
    public static inline var PROP_NARROW : String = "NARROW";
    public static inline var PROP_KEYFOR_PREFIX : String = "KEYFOR_";
    
    private var m_props : Dictionary;
    
    public function new()
    {
        m_props = new Dictionary();
    }
    
    public function setProp(prop : String, val : Bool) : Void
    {
        if (val)
        {
            Reflect.setField(m_props, prop, true);
        }
        else
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete m_props[prop];
        }
    }
    
    public function setPropCheck(prop : String, val : Bool) : Bool
    {
        if (val)
        {
            if (Reflect.field(m_props, prop) == null)
            {
                Reflect.setField(m_props, prop, true);
                return true;
            }
            else
            {
                return false;
            }
        }
        else if (Reflect.field(m_props, prop) != null)
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete m_props[prop];
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function hasProp(prop : String) : Bool
    {
        return Reflect.field(m_props, prop) != null;
    }
    
    public function iterProps() : Dynamic
    {
        return m_props;
    }
    
    public function addProps(other : PropDictionary) : Void
    {
        for (prop in Reflect.fields(other.m_props))
        {
            Reflect.setField(m_props, prop, true);
        }
    }
    
    public function matches(other : PropDictionary) : Bool
    {
        var prop : String;
        for (prop in Reflect.fields(m_props))
        {
            if (other.m_props[prop] == null)
            {
                return false;
            }
        }
        for (prop in Reflect.fields(other.m_props))
        {
            if (Reflect.field(m_props, prop) == null)
            {
                return false;
            }
        }
        return true;
    }
    
    public function clone() : PropDictionary
    {
        var ret : PropDictionary = new PropDictionary();
        ret.addProps(this);
        return ret;
    }
    
    public static function getProps(props : PropDictionary, prefix : String) : Array<String>
    {
        var ret : Array<String> = new Array<String>();
        for (prop in Reflect.fields(props.iterProps()))
        {
            if (prop.indexOf(prefix) == 0)
            {
                ret.push(prop);
            }
        }
        return ret;
    }
}

