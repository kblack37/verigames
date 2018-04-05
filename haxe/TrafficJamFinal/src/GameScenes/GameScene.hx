package gameScenes;

import flash.display.DisplayObject;
import userInterface.components.RectangularObject;

class GameScene extends RectangularObject
{
    
    public var m_controller : SceneController;
    
    //set up class, don't try to call addChild here, as there's no parent to add to, do that in loadScene
    public function new(controller : SceneController)
    {
        super(controller.x, controller.y, controller.width, controller.height);
        m_controller = controller;
    }
    
    //load display objects and other objects that need a parent
    public function loadScene() : Void
    {
    }
    
    //called by controller when scene is being unloaded
    public function unloadScene() : Void
    {
    }
    
    //called when level has no trouble points
    public function levelCompleted() : Void
    {
    }
    
    //call to change to next scene
    public function loadNextScene(nextAction : Int = 0) : Void
    {
        if (Std.is(parent, SceneController))
        {
            (try cast(parent, SceneController) catch(e:Dynamic) null).loadNextScene(nextAction);
        }
    }
    
    
    //called when resizing, so remove and re-add. Could we just invalidate the display list??
    public function draw() : Void
    {
        removeChildren();
    }
    
    //override if you have special update needs
    public function updateSize(newWidth : Float, newHeight : Float) : Void
    {
    }
}
