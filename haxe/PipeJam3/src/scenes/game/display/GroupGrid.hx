package src.scenes.game.display;

import openfl.geom.Point;
import openfl.geom.Rectangle;

class GroupGrid
{
    private static inline var NODE_PER_GRID_ESTIMATE : Int = 300;
    
    public var grid : Dynamic = {};
    public var gridDimensions : Point = new Point();  // in pixels  
    
    @:allow(scenes.game.display)
    private function new(m_boundingBox : Rectangle, levelScale : Float, nodeDict : Dynamic, layoutDict : Dynamic, nodeSize : Int)
    {
    // Note: this assumes a uniform distribution of nodes, which is not a good estimate, but it will do for now
        
        var gridsTotal : Int = Math.ceil(nodeSize / NODE_PER_GRID_ESTIMATE);
        // use right, bottom instead of width, height to ignore (presumably) negligible x or y value that would need to be subtracted from each node.x,y
        var totalDim : Float = 2048;  //Math.max(1, m_boundingBox.right + m_boundingBox.bottom);  
        var gridsWide : Int = Math.ceil(gridsTotal * m_boundingBox.right / totalDim);
        var gridsHigh : Int = Math.ceil(gridsTotal * m_boundingBox.bottom / totalDim);
        gridDimensions = new Point(m_boundingBox.right / gridsWide, m_boundingBox.bottom / gridsHigh);
        
        // Put all node ids in the grid
        var nodeKey : String;
        for (nodeKey in Reflect.fields(nodeDict))
        {
            nodeKey = StringTools.replace(nodeKey, "clause:", "c_").replace(":", "_");
            if (!layoutDict.exists(nodeKey))
            {
                trace("Warning! Node id from group dict not found: ", nodeKey);
                continue;
            }
            var nodeX : Float = as3hx.Compat.parseFloat(Reflect.field(Reflect.field(layoutDict, nodeKey), "x")) * Constants.GAME_SCALE * levelScale;
            var nodeY : Float = as3hx.Compat.parseFloat(Reflect.field(Reflect.field(layoutDict, nodeKey), "y")) * Constants.GAME_SCALE * levelScale;
            var gridKey : String = _getGridKey(nodeX, nodeY, gridDimensions);
            if (!grid.exists(gridKey))
            {
                Reflect.setField(grid, gridKey, new Dictionary());
            }
            Reflect.setField(grid, gridKey, true)[nodeKey];
        }
    }
    
    public static function getGridX(_x : Float, gridDimensions : Point) : Int
    {
        return Math.max(0, Math.floor(_x / gridDimensions.x));
    }
    
    public static function getGridY(_y : Float, gridDimensions : Point) : Int
    {
        return Math.max(0, Math.floor(_y / gridDimensions.y));
    }
    
    public static function getGridXRight(_x : Float, gridDimensions : Point) : Int
    {
        return Math.max(0, Math.ceil(_x / gridDimensions.x));
    }
    
    public static function getGridYBottom(_y : Float, gridDimensions : Point) : Int
    {
        return Math.max(0, Math.ceil(_y / gridDimensions.y));
    }
    
    private static function _getGridKey(_x : Float, _y : Float, gridDimensions : Point) : String
    {
        var GRID_X : Int = getGridX(_x, gridDimensions);
        var GRID_Y : Int = getGridX(_y, gridDimensions);
        return Std.string(GRID_X + "_" + GRID_Y);
    }
}