package visualWorld;

import flash.errors.Error;
import visualWorld.Pipe;
import networkGraph.FlowObject;
import userInterface.components.RectangularObject;
import utilities.XMath;
import utilities.XSprite;
import com.greensock.TweenMax;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.*;
import networkGraph.Edge;
import networkGraph.NodeTypes;

/**
	 * Ball Object is a graphical representation of the ball on a pipe that also contains information about the ball.
	 */
class Ball extends DropObjectBase
{
    /** Height for ball sitting above the pipe for START_*_BALL */
    public var BALL_START_HEIGHT(default, never) : Int = 25;
    
    /** True to draw a highlight around the ball indicating it has been moused over */
    private var highlight : Bool;
    
    /** True to draw ball as alphed out */
    private var ghost : Bool;
    
    /**
		 * Ball Object is a graphical representation of the ball on a pipe that also contains information about the ball.
		 * @param	_begin_x Starting x coordinate in board space
		 * @param	_begin_y Starting y coordinate in board space
		 * @param	_is_wide Set to true for a wide black ball, false for narrow white ball
		 */
    public function new(_starting_edge : Edge, _ghost : Bool = false)
    {
        super(_starting_edge, null);
        
        
        if (!_starting_edge.spline_control_points)
        {
            throw new Error("Ball created using edge: " + _starting_edge.edge_id + " that has no spline_control_points");
        }
        if (_starting_edge.spline_control_points.length == 0)
        {
            throw new Error("Ball created using edge: " + _starting_edge.edge_id + " that has no spline_control_points");
        }
        if (!_starting_edge.associated_pipe)
        {
            throw new Error("Ball created using edge: " + _starting_edge.edge_id + " that has no associated_pipe");
        }
        var p1 : Point = _starting_edge.associated_pipe.getXYbyT(0.0);
        var p2 : Point = _starting_edge.associated_pipe.getXYbyT(Pipe.WIDE_BALL_RADIUS / _starting_edge.associated_pipe.interpolated_spline_length);
        var dx : Float = (p1.x - p2.x) / XMath.getDist(p1, p2);
        var dy : Float = (p1.y - p2.y) / XMath.getDist(p1, p2);
        var top_p0 : Point = new Point(p1.x + dx * (4 + BALL_START_HEIGHT + 1.0 * Pipe.WIDE_BALL_RADIUS), 
        p1.y + dy * (4 + BALL_START_HEIGHT + 1.0 * Pipe.WIDE_BALL_RADIUS));
        begin_x = p1.x;
        begin_y = p1.y;
        if ((_starting_edge.from_node.kind == NodeTypes.START_LARGE_BALL) || (_starting_edge.from_node.kind == NodeTypes.START_SMALL_BALL) || (_starting_edge.from_node.kind == NodeTypes.START_NO_BALL) || (_starting_edge.from_node.kind == NodeTypes.START_PIPE_DEPENDENT_BALL))
        {
            begin_x = top_p0.x;
            begin_y = top_p0.y;
        }
        
        x = begin_x;
        y = begin_y;
        ghost = _ghost;
    }
    
    /**
		 * 
		 */
    override public function updateImageAndFlow(stopObject : Bool = false) : Void
    {
        var alpha : Float = 1.0;
        if (ghost)
        {
            alpha = 0.5;
        }
        
        graphics.clear();
        var _sw0_ = (Theme.CURRENT_THEME);        

        switch (_sw0_)
        {
            case Theme.PIPES_THEME:
            case Theme.TRAFFIC_THEME:
                return;
        }
        var _sw1_ = (m_flowObject.starting_ball_type);        

        switch (_sw1_)
        {
            case VerigameSystem.BALL_TYPE_NARROW:
                drawBall(false, this, alpha);
                cacheAsBitmap = true;
            case VerigameSystem.BALL_TYPE_WIDE:
                drawBall(true, this, alpha);
                cacheAsBitmap = true;
            default:
                // No Ball
                break;
        }
    }
    
    public static function drawBall(_wide : Bool, _drop_object : DropObjectBase, _alpha : Float = 1.0, _highlight : Bool = false) : Void
    {
        var ball_color : Float;
        var ball_border_width : Int = 2;
        
        var refl_offset : Array<Dynamic>;  // shift the "reflection spot" to the bottom right or top left  
        var grad_width : Float;
        var inv_color : Float;
        var radius : Float;
        var colors : Array<Dynamic>;
        var alphas : Array<Dynamic>;
        var ratios : Array<Dynamic>;
        var matrix : Matrix;
        
        if (_wide)
        {
            radius = Pipe.WIDE_BALL_RADIUS;
            ball_color = 0x000000;
            refl_offset = [-0.3 * radius, -0.3 * radius];
            grad_width = 2 * radius;
            inv_color = 0xFFFFFF;
        }
        else
        {
            radius = Pipe.NARROW_BALL_RADIUS;
            ball_color = 0xFFFFFF;
            refl_offset = [0.0 * radius, 0.0 * radius];
            grad_width = 4 * radius;
            inv_color = 0xAAAAAA;
        }
        
        if (_highlight)
        {
            _drop_object.graphics.lineStyle(3 * ball_border_width, 0xFFFFFF, _alpha);
            _drop_object.graphics.drawCircle(0.0, 0.0, radius);
        }
        colors = new Array<Dynamic>(inv_color, ball_color);
        alphas = new Array<Dynamic>(_alpha, _alpha);
        ratios = new Array<Dynamic>(0, 128);
        matrix = new Matrix();
        matrix.createGradientBox(grad_width, grad_width, 0, -0.5 * grad_width + refl_offset[0], -0.5 * grad_width + refl_offset[1]);
        _drop_object.graphics.beginGradientFill("radial", colors, alphas, ratios, matrix);
        _drop_object.graphics.lineStyle(ball_border_width, 0x000000, _alpha);
        _drop_object.graphics.drawCircle(0.0, 0.0, radius);
        _drop_object.graphics.endFill();
    }
    
    override public function reset() : Void
    {
        x = begin_x;
        y = begin_y;
    }
    
    /**
		 * Used to determine is ball size is up to date, redraws if it is not
		 */
    public function updateSize() : Void
    {
        onTimelineUpdate();
    }
}
