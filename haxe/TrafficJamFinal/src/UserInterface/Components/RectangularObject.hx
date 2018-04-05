package userInterface.components;

import flash.geom.Point;
import mx.core.UIComponent;

/**
	 * Generic display object with X, Y (defining the top left corner) and width and height
	 */
class RectangularObject extends UIComponent
{
    public var position(get, never) : Point;
    public var midpoint(get, never) : Point;

    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int)
    {
        super();
        
        setPositionAndSize(_x, _y, _width, _height);
    }
    
    public function setPositionAndSize(_x : Int, _y : Int, _width : Int, _height : Int) : Void
    {
        x = _x;
        y = _y;
        width = _width;
        height = _height;
    }
    
    private function get_position() : Point
    {
        return new Point(x, y);
    }
    
    private function get_midpoint() : Point
    {
        return new Point(x + width / 2, y + height / 2);
    }
}
