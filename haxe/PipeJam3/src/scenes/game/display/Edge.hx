package scenes.game.display;

import flash.geom.Point;
import constraints.Constraint;

class Edge
{
    public var id : String;
    public var graphConstraint : Constraint;
    public var fromNode : Node;
    public var toNode : Node;
    
    public var parentXOffset : Float;
    public var parentYOffset : Float;
    
    public var skin : EdgeSkin;
    public var isDirty : Bool;
    
    public static inline var LINE_THICKNESS : Float = 5;
    
    public function new(_constraintId : String, _graphConstraint : Constraint, _fromNode : Node, _toNode : Node)
    {
        id = _constraintId;
        graphConstraint = _graphConstraint;
        fromNode = _fromNode;
        toNode = _toNode;
    }
    
    public function updateEdge() : Void
    {
        if (skin != null && skin.parent != null)
        {
            drawSkin();
            isDirty = false;
        }
    }
    
    //need to keep track of lines
    public function createSkin(currentGroupDepth : Int) : Void
    {
        if (skin == null)
        {
            var fromGroup : String = fromNode.graphConstraintSide.getGroupAt(currentGroupDepth);
            var toGroup : String = toNode.graphConstraintSide.getGroupAt(currentGroupDepth);
            
            var fromGroupNode : Node = fromGroup == "" ? 
				fromNode : try cast(Reflect.field(World.m_world.active_level.nodeLayoutObjs, fromGroup), Node) catch(e:Dynamic) null;
            var toGroupNode : Node = toGroup == "" ?
				toNode : try cast(Reflect.field(World.m_world.active_level.nodeLayoutObjs, toGroup), Node) catch(e:Dynamic) null;
            
            if (fromGroupNode == toGroupNode)
            {
                if (skin != null)
                {
                    skin.removeFromParent(true);
                }
                skin = null;
                isDirty = false;
                return;
            }
            var p1 : Point = fromGroupNode.centerPoint;
            var p2 : Point = toGroupNode.centerPoint;
            
            //a^2 + b^2 = c^2
            var a : Float = (p2.x - p1.x) * (p2.x - p1.x);
            var b : Float = (p2.y - p1.y) * (p2.y - p1.y);
            var hyp : Float = Math.sqrt(a + b);
            
            //get theta
            //Sin(x) = opp/hyp
            var theta : Float = Math.asin((p2.y - p1.y) / hyp);  // radians  
            
            //draw the quad flat, rotate later
            skin = new EdgeSkin(hyp, Edge.LINE_THICKNESS, this);
            
            drawSkin();
            rotateLine(p1, p2, theta);
        }
        isDirty = false;
    }
    
    private function rotateLine(p1 : Point, p2 : Point, theta : Float) : Void
    {
        var dX : Float = p1.x - p2.x;
        var dY : Float = p1.y - p2.y;
        
        skin.pivotX = dX / 2;
        skin.pivotY = dY / 2;
        
        var centerDx : Float = 0;
        var centerDy : Float = 0;
        if (dX <= 0 && dY < 0)
        {
        // Q4
            
            // theta = theta
            centerDx = -0.5 * LINE_THICKNESS * Math.sin(theta);
            centerDy = -0.5 * LINE_THICKNESS * Math.cos(theta);
        }
        else if (dX > 0 && dY <= 0)
        {
        // Q3
            
            if (dY == 0)
            {
            // -180
                
                theta = -Math.PI;
            }
            else
            {
                theta = (Math.PI / 2) + ((Math.PI / 2) - theta);
            }
            centerDx = -0.5 * LINE_THICKNESS * Math.sin(theta);
            centerDy = 0.5 * LINE_THICKNESS * Math.cos(theta);
        }
        else if (dX >= 0 && dY > 0)
        {
        // Q2
            
            theta = -Math.PI - theta;
            centerDx = 0.5 * LINE_THICKNESS * Math.sin(theta);
            centerDy = 0.5 * LINE_THICKNESS * Math.cos(theta);
            if (dX == 0)
            {
                centerDx = -0.5 * LINE_THICKNESS;
            }
        }
        // Q1
        else
        {
            
            centerDx = 0.5 * LINE_THICKNESS * Math.sin(theta);
            centerDy = -0.5 * LINE_THICKNESS * Math.cos(theta);
            if (dY == 0)
            {
                centerDy = -0.5 * LINE_THICKNESS * Math.cos(theta);
            }
        }
        skin.rotation = theta;
        
        skin.x = -skin.bounds.left + Math.min(p1.x, p2.x) + centerDx;
        skin.y = -skin.bounds.top + Math.min(p1.y, p2.y) + centerDy;
    }
    
    private function drawSkin() : Void
    {
        if (skin != null)
        {
            skin.draw();
        }
    }
}
