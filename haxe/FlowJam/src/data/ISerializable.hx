package data;

/**
 * @author kristen autumn blackburn
 * 
 * This interface is applied to any classes that should be
 * serialized to be saved to disk or a database, usually for
 * save file data
 */
interface ISerializable {
	/**
	 * @return an anonymous structure ready to be exported
	 * to a JSON file
	 */
	public function serialize() : Dynamic;
	
	/**
	 * @param jsonObject	
	 * Constructs a new object with given object parsed from a JSON file
	 */
	public function deserialize(jsonObject : Dynamic) : Void;
}