package gameScenes;

import userInterface.components.Game;
import fl.core.UIComponent;
import flash.display.DisplayObject;
import mx.core.FlexGlobals;
import mx.core.IInvalidating;

/*
		Scene Controller controls what is currently visible on the screen. Basically two states:
			Splash Screen
			Everything else
				this consists of startWorld, victory, and endWorld states.
	*/
class SceneController extends Game
{
    public var currentScene(get, never) : GameScene;

    //keep this out of the hands of derived classes -  use loadScene or unloadScene to change
    private var m_currentScene : GameScene;
    
    public static inline var NATIVE_WIDTH : Int = 1024;
    public static inline var NATIVE_HEIGHT : Int = 768;
    
    private var ACTION_FAILED : Int = 0;
    private var ACTION_SUCCEEDED : Int = 1;
    
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int)
    {
        super(_x, _y, _width, _height);
    }
    
    //override this in derived classes
    public function loadNextScene(nextAction : Int) : Void
    {
    }
    
    
    /* mostly you can leave the below functions as they are */
    private function loadScene(newScene : GameScene) : Void
    {
        addChild(newScene);
        newScene.loadScene();
        newScene.draw();
        m_currentScene = newScene;
    }
    
    private function get_currentScene() : GameScene
    {
        return m_currentScene;
    }
    
    private function unloadCurrentScene() : Void
    {
        if (m_currentScene != null)
        {
            m_currentScene.unloadScene();
            removeChild(m_currentScene);
            m_currentScene = null;
        }
    }
    
    public function updateSize(newWidth : Float, newHeight : Float) : Void
    {
        scaleX = Math.min(as3hx.Compat.parseFloat(newWidth / NATIVE_WIDTH), as3hx.Compat.parseFloat(newHeight / NATIVE_HEIGHT));
        scaleY = Math.min(as3hx.Compat.parseFloat(newWidth / NATIVE_WIDTH), as3hx.Compat.parseFloat(newHeight / NATIVE_HEIGHT));
        if (m_currentScene != null)
        {
            m_currentScene.updateSize(scaleX, scaleY);
        }
    }
}
