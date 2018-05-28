package state;

import assets.AssetInterface;
import engine.IGameEngine;
import particle.ErrorParticleSystem;
import scenes.splashscreen.SplashScreenMenuBox;
import starling.display.BlendMode;
import starling.display.Image;

/**
 * This class is the state that displays the title screen of Flow Jam
 * 
 * @author ...
 */
class TitleScreenState extends BaseState 
{
	private var m_menuBox : SplashScreenMenuBox;
	
	private var m_background : Image;
	private var m_foreground : Image;
	private var m_particleSystem : ErrorParticleSystem;
	
	public function new(gameEngine : IGameEngine) 
	{
		super(gameEngine);
	}
	
	override public function enter(from : IState, params : Dynamic)
	{
		// Add the background image
		m_background = new Image(AssetInterface.getTexture("img/misc", "BoxesStartScreen.jpg"));
        m_background.scaleX = stage.stageWidth / m_background.width;
        m_background.scaleY = stage.stageHeight / m_background.height;
        m_background.blendMode = BlendMode.NONE;
        addChild(m_background);
        
		// Add the title image
		m_foreground = new Image(AssetInterface.getTexture("img/misc", "BoxesStartScreenForeground.png"));
        m_foreground.scaleX = m_background.scaleX;
        m_foreground.scaleY = m_background.scaleY;
        addChild(m_foreground);
		
		// Add the 'sparking' particle system
        m_particleSystem = new ErrorParticleSystem();
        m_particleSystem.x = (721.0 / 2.0) * m_background.width / Constants.GameWidth;
        m_particleSystem.y = (555.0 / 2.0) * m_background.height / Constants.GameHeight;
        m_particleSystem.scaleX = m_particleSystem.scaleY = 8.0;
        addChild(m_particleSystem);
		
		// Add the menu buttons
		m_menuBox = new SplashScreenMenuBox(m_gameEngine);
		m_menuBox.x = (stage.stageWidth - m_menuBox.width) * 0.5;
		m_menuBox.y = 420;
		addChild(m_menuBox);
	}
	
	override public function exit(to : IState) : Dynamic
	{
		return null;
	}
}