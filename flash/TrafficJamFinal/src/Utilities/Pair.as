package Utilities
{
	/**
	 * Pair Class to associate two objects
	*/
	public class Pair
	{
		protected var m_object1:Object;
		protected var m_object2:Object;
		
		/**
		 * Pair Class to associate two objects
		 * @param	firstObject The first object to be paired
		 * @param	secondObject The second object to be paired
		 */
		public function Pair(firstObject:Object, secondObject:Object)
		{
			m_object1 = firstObject;
			m_object2 = secondObject;
		}
		
		/**
		 * Get the first object
		 */
		public function get first():Object {
			return m_object1;
		}
		
		/**
		 * Get the second object
		 */
		public function get second():Object {
			return m_object2;
		}
		
		/**
		 * Sets the first object
		 */
		public function set first(o:Object):void {
			m_object1 = o;
		}
		
		/**
		 * Sets the second object
		 */
		public function set second(o:Object):void {
			m_object2 = o;
		}
		
		/**
		 * Displays both objects in the pair
		 * @return String displaying both objects
		 */
		public function toString():String {
			return "pair: " + first.toString() + "," + second.toString() + ". ";
		}
	
	}
}