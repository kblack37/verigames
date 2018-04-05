package scenes.game.display;

import flash.geom.Rectangle;
import constraints.ConstraintClause;

class ClauseNode extends Node
{
    public var graphClause(get, never) : ConstraintClause;
    public var hadError(get, set) : Bool;

    
    private var _hasError : Bool = false;
    private var _hadError : Bool = false;
    
    public function new(_id : String, _bb : Rectangle, _graphClause : ConstraintClause)
    {
        super(_id, _bb, _graphClause);
        
        isClause = true;
    }
    
    private function get_graphClause() : ConstraintClause
    {
        return try cast(graphConstraintSide, ConstraintClause) catch(e:Dynamic) null;
    }
    
    public function hasError() : Bool
    {
        return _hasError;
    }
    
    private function get_hadError() : Bool
    {
        return _hadError;
    }
    
    private function set_hadError(_val : Bool) : Bool
    {
        _hadError = _val;
        return _val;
    }
    
    public function addError(_error : Bool) : Void
    {
        if (isClause && _hasError != _error)
        {
            _hasError = _error;
        }
    }
    
    override public function createSkin() : Void
    //	trace('create node skin', id);
    {
        
        if (skin == null)
        {
            skin = NodeSkin.getNextSkin();
        }
        if (skin != null)
        {
            setupSkin();
            skin.draw();
            skin.x = centerPoint.x;
            skin.y = centerPoint.y;
        }
        
        //create background
        if (backgroundSkin == null)
        {
            backgroundSkin = NodeSkin.getNextSkin();
        }
        if (backgroundSkin != null)
        {
            setupBackgroundSkin();
            backgroundSkin.draw();
            backgroundSkin.x = centerPoint.x;
            backgroundSkin.y = centerPoint.y;
        }
    }
    
    override public function setupSkin() : Void
    {
        if (skin != null)
        {
            skin.setNodeProps(true, false, isSelected, solved, hasError(), false);
        }
    }
    
    override public function setupBackgroundSkin() : Void
    {
        if (backgroundSkin != null)
        {
            backgroundSkin.setNodeProps(true, false, isSelected, false, hasError(), true);
        }
    }
    
    override public function skinIsDirty() : Bool
    {
        if (skin == null)
        {
            return false;
        }
        if (skin.isDirty)
        {
            return true;
        }
        if (skin.hasError() != hasError())
        {
            return true;
        }
        return false;
    }
    
    override public function backgroundIsDirty() : Bool
    {
        if (backgroundSkin == null)
        {
            return false;
        }
        if (backgroundSkin.isDirty)
        {
            return true;
        }
        if (backgroundSkin.hasError() != hasError())
        {
            return true;
        }
        return false;
    }
}
