package utils;


/**
	 * Class to store arbitary data, such ass the attributes of an XML object where are fields are not necessarily known
	*/
class Metadata
{
    public var data : Dynamic;
    public var xml : FastXML;
    
    /**
		 * Class to store arbitary data, such ass the attributes of an XML object where are fields are not necessarily known
		 * @param	_data
		 */
    public function new(_data : Dynamic, _xml : FastXML = null)
    {
        data = _data;
        xml = _xml;
    }
    
    /**
		 * Function to check whether a desired field exists in this object, return null if not (as opposed to throwing an error)
		 * @param	_s Field to lookup
		 * @return Value of field
		 */
    public function get(_s : String) : Dynamic
    {
		var val : Dynamic = null;
        if (data != null)
        {
            if (Reflect.hasField(data, _s))
            {
                val = Reflect.field(data, _s);
            }
        }
        return val;
    }
}
