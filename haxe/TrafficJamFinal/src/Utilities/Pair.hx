package utilities;


/**
	 * Pair Class to associate two objects
	*/
class Pair
{
    public var first(get, set) : Dynamic;
    public var second(get, set) : Dynamic;

    private var m_object1 : Dynamic;
    private var m_object2 : Dynamic;
    
    /**
		 * Pair Class to associate two objects
		 * @param	firstObject The first object to be paired
		 * @param	secondObject The second object to be paired
		 */
    public function new(firstObject : Dynamic, secondObject : Dynamic)
    {
        m_object1 = firstObject;
        m_object2 = secondObject;
    }
    
    /**
		 * Get the first object
		 */
    private function get_first() : Dynamic
    {
        return m_object1;
    }
    
    /**
		 * Get the second object
		 */
    private function get_second() : Dynamic
    {
        return m_object2;
    }
    
    /**
		 * Sets the first object
		 */
    private function set_first(o : Dynamic) : Dynamic
    {
        m_object1 = o;
        return o;
    }
    
    /**
		 * Sets the second object
		 */
    private function set_second(o : Dynamic) : Dynamic
    {
        m_object2 = o;
        return o;
    }
    
    /**
		 * Displays both objects in the pair
		 * @return String displaying both objects
		 */
    public function toString() : String
    {
        return "pair: " + Std.string(first) + "," + Std.string(second) + ". ";
    }
}
