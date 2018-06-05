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
		
		var pj3 : PipeJam3 = new PipeJam3();
		this.stage.addChild(pj3);
	}

}