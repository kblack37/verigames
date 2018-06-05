package engine;


import openfl.Lib;

/**
 * Responsible for keeping track of time in between frames
 * 
 * @author kristen autumn blackburn
 */
class Time {
	
	public var deltaMs(get, never) : Int;
	
	private var m_currentTimeMs : Int;
	
	private var m_previousTimeMs : Int;

	public function new() {
		m_currentTimeMs = Lib.getTimer();
		m_previousTimeMs = Lib.getTimer();
	}
	
	public function update() {
		m_previousTimeMs = m_currentTimeMs;
		m_currentTimeMs = Lib.getTimer();
	}
	
	function get_deltaMs() : Int {
		return m_currentTimeMs - m_previousTimeMs;
	}
	
}