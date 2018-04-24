package;

import openfl.display.Sprite;
import openfl.Lib;
import starling.core.Starling;

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
		
		m_starling = new Starling(PipeJam3, stage);
		m_starling.start();
	}

}
