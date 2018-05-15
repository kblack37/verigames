package engine.widget;

import engine.IGameEngine;
import starling.display.Sprite;

/**
 * The base class for almost all display elements; override the resize method
 * 
 * @author kristen autumn blackburn
 */
class BaseWidget extends Sprite {

	private var m_gameEngine : IGameEngine;
	
	public function new(gameEngine : IGameEngine) {
		super();
		
		m_gameEngine = gameEngine;
	}
	
	public function resize(width : Float, height : Float) {
		this.width = width;
		this.height = height;
	}
}