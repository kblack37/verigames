package Utilities
{
	/**
	 * Class to store arbitary data, such ass the attributes of an XML object where are fields are not necessarily known
	*/
	public class Metadata extends Object
	{
		public var data:Object;
		public var xml:XML;
		
		/**
		 * Class to store arbitary data, such ass the attributes of an XML object where are fields are not necessarily known
		 * @param	_data
		 */
		public function Metadata(_data:Object, _xml:XML = null)
		{
			data = _data;
			xml = _xml;
		}
		
		/**
		 * Function to check whether a desired field exists in this object, return null if not (as opposed to throwing an error)
		 * @param	_s Field to lookup
		 * @return Value of field
		 */
		public function get(_s:String):Object {
			if (data != null)
				if (data[_s] != null)
					return data[_s]
			return null;
		}
		
		
	}
}