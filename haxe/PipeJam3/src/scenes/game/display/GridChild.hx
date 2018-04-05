package scenes.game.display;

import flash.geom.Point;
import flash.geom.Rectangle;
import constraints.ConstraintGraph;

class GridChild
{
    public var id : String;
    
    public var layoutObject : Dynamic;
    
    public var bb : Rectangle;
    public var centerPoint : Point;
    
    public var isSelected : Bool = false;
    public var isNarrow : Bool;
    
    public var startingSelectionState : Bool = false;
    
    public var connectedEdgeIds : Array<String> = new Array<String>();
    public var outgoingEdgeIds : Array<String> = new Array<String>();
    public var unused : Bool = true;
    
    public var skin : NodeSkin;
    public var backgroundSkin : NodeSkin;
    public var currentGroupDepth : Int = 0;
    public var animating : Bool = false;
    
    public function new(_id : String, _bb : Rectangle)
    {
        id = _id;
        bb = _bb;
        
        //calculate center point
        var xCenter : Float = bb.x + bb.width * .5;
        var yCenter : Float = bb.y + bb.height * .5;
        centerPoint = new Point(xCenter, yCenter);
        isNarrow = false;
    }
    
    public function createSkin() : Void
    {  // implemented by children  
        
    }
    
    public function removeSkin() : Void
    {
        if (skin != null)
        {
            skin.removeFromParent();
        }
        if (backgroundSkin != null)
        {
            backgroundSkin.removeFromParent();
        }
        skin = null;
        backgroundSkin = null;
    }
    
    public function setupSkin() : Void
    {  // implemented by children  
        
    }
    
    public function setupBackgroundSkin() : Void
    {  // implemented by children  
        
    }
    
    public function select() : Void
    {
        isSelected = true;
    }
    
    public function unselect() : Void
    {
        isSelected = false;
    }
    
    public function draw() : Void
    {  // implemented by children  
        
    }
    
    public function backgroundIsDirty() : Bool
    {
        return false;
    }
    
    public function skinIsDirty() : Bool
    {
        return false;
    }
    
    public function updateSelectionAssignment(_isWide : Bool, levelGraph : ConstraintGraph) : Void
    {
        isNarrow = !_isWide;
    }
}

