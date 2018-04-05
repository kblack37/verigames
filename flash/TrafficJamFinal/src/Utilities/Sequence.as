package Utilities
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Class to perform functions in a set order
	 */
	public class Sequence extends ArrayCollection
	{
		public static const SEQUENCE_ADVANCED:String = "SequenceAdvancedEvent";
		protected var m_index:int = -1;
		protected var m_immediateScheduleIndex:int = -1;
		
		/**
		 * Class to perform functions in a set order
		 */
		public function Sequence()
		{
		}
		
		/**
		 * Schedule a function on the end of the sequence
		 * @param	f Function to schedule
		 * @param	... argumentArray Arguments to call the function with
		 */
		public function schedule(f:Function, ... argumentArray):void {
			var arguments:Array = new Array();
			//arguments.push(this);
			for (var i:uint = 0; i<argumentArray.length; i++) {
				arguments.push(argumentArray[i]);
			}
			addItem(new Pair(f, arguments));
		}
		
		/**
		 * Starting scheduling functions ASAP
		 */
		public function beginSchedulingImmediately():void {
			m_immediateScheduleIndex = m_index + 1;
		}
		
		/**
		 * Schedule this function ASAP (before any other functions, but after previous "immediate" functions)
		 * @param	f
		 * @param	... argumentArray
		 */
		public function scheduleImmediately(f:Function, ... argumentArray):void {
			var arguments:Array = new Array();
			//arguments.push(this);
			for (var i:uint = 0; i<argumentArray.length; i++) {
				arguments.push(argumentArray[i]);
			}
			addItemAt(new Pair(f, arguments), m_immediateScheduleIndex);
			m_immediateScheduleIndex++;
		}
		
		/**
		 * Current index to insert functions
		 * @return
		 */
		public function getIndex():uint {			
			return m_index;
		}
		
		/**
		 * Current index to insert functions
		 * @param	i
		 */
		public function setIndex(i:uint):void {
			m_index = i;
		}
		
		/**
		 * Start inserting at beginning
		 */
		public function resetIndex():void {
			m_index = -1;
		}

		/**
		 * Start inserting at beginning and erase any scheduled functions
		 */
		public function reset():void {
			removeAll();
			resetIndex();
		}

		/**
		 * Call the next function
		 */
		public function advance():void {
			if (m_index<length) {
				dispatchEvent(new Event(SEQUENCE_ADVANCED));
				m_index++;
				this[m_index].first.apply(this, this[m_index].second);
			}
		}
	}
}