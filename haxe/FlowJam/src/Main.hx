package;

import starling.core.Starling;
import openfl.display.Sprite;

/**
 * ...
 * @author 
 */
class Main extends Sprite 
{

	private var m_starling : Starling;
	
	public function new() 
	{
		super();
		
		var asdf = new PipeJam3();
		m_starling = new Starling(PipeJamGame, this.stage);
		m_starling.simulateMultitouch = false;
        m_starling.enableErrorChecking = false;
        m_starling.start();
	}

}
