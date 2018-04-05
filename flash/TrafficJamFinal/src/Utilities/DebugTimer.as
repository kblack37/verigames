package Utilities 
{
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class DebugTimer 
	{
		public static var DEBUG_TIMER_ON:Boolean = false;
		private static var m_timestamps:Dictionary = new Dictionary();
		private static var m_totalTimes:Dictionary = new Dictionary();
		private static var m_timesCalled:Dictionary = new Dictionary();
		
		public static function beginTiming(type:String):void {
			if (!DEBUG_TIMER_ON) {
				return;
			}
			m_totalTimes[type] = 0.0;
			m_timesCalled[type] = null;
			beginActivity(type);
		}
		
		public static function beginActivity(type:String):void {
			if (!DEBUG_TIMER_ON) {
				return;
			}
			m_timestamps[type] = new Date().time;
			if (!m_timesCalled[type]) {
				m_timesCalled[type] = 0;
			}
			m_timesCalled[type]++;
		}
		
		public static function endActivity(type:String):void {
			if (!DEBUG_TIMER_ON) {
				return;
			}
			if (m_timestamps[type]) {
				if (m_totalTimes[type]) {
					m_totalTimes[type] += new Date().time - m_timestamps[type];
				} else {
					m_totalTimes[type] = new Date().time - m_timestamps[type];
				}
				m_timestamps[type] = null;
			}
		}
		
		public static function reportTime(type:String):void {
			if (!DEBUG_TIMER_ON) {
				return;
			}
			if (m_timestamps[type]) {
				endActivity(type);
			}
			if (m_totalTimes[type] == null) {
				return;
			}
			trace("~~~~~~~ " + type + " took " + m_totalTimes[type] + " milliseconds to complete, and was called " + m_timesCalled[type] + " times ~~~~~~~");
		}
		
		public static function reportAllTimes():void {
			if (!DEBUG_TIMER_ON) {
				return;
			}
			for (var activity:String in m_totalTimes) {
				trace("~~~~~~~ " + activity + " took " + m_totalTimes[activity] + " milliseconds to complete, and was called " + m_timesCalled[activity] + " times ~~~~~~~");
			}
		}
		
	}

}