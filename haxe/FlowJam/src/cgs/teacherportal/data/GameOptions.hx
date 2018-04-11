package cgs.teacherportal.data;
import haxe.Json;

class GameOptions
{
    private var m_obj : Dynamic;
    
    public function new(obj : Dynamic)
    {
        m_obj = clone(obj);
    }
    
    public function containsProperty(name : String) : Bool
    {
        return (getProperty(name) != null);
    }
    
    public function getProperty(name : String) : Dynamic
    {
        var result : Dynamic = null;
        if (name != null && name.length > 0)
        {
            result = m_obj;
            var path : Array<Dynamic> = name.split(".");
            while (result != null && path.length > 0)
            {
                var prop : String = path.shift();
                if (Reflect.hasField(result, prop))
                {
                    result = Reflect.field(result, prop);
                }
                else
                {
                    result = null;
                }
            }
        }
        return (result);
    }
    
    private static function clone(obj : Dynamic) : Dynamic
    {
        var json : String = Json.stringify(obj);
        return (Json.parsehn(json));
    }
}
