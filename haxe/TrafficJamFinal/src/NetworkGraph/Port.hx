package networkGraph;

import flash.errors.Error;
import visualWorld.Theme;
import visualWorld.VerigameSystem;
import flash.geom.Point;
import visualWorld.Pipe;
import visualWorld.TroublePoint;

/** This object connects a Node to an edge. It is useful as a separate object because
	 *  trouble points will often occur at ports, so associated them with Nodes is not useful
	 *  because it could refer to any number of ports (say the 2nd outgoing edge). */
class Port
{
    /** Associated Node that this port is coming out of/into */
    public var node : Node;
    
    /** Edge that leads into/out of the associated node */
    public var edge : Edge;
    
    /** Id assigned to the port from input XML */
    public var port_id : String;
    
    /** Type - incoming or outgoing, assigned in child class */
    public var type : Int = 0;
    
    /** Trouble point created based on this port */
    public var associated_trouble_point : TroublePoint;
    
    /** Types are defined here */
    public static inline var INCOMING_PORT_TYPE : Int = 0;
    public static inline var OUTGOING_PORT_TYPE : Int = 1;
    
    public function new(_node : Node, _edge : Edge, _id : String, _type : Int = INCOMING_PORT_TYPE)
    {
        node = _node;
        edge = _edge;
        port_id = _id;
        type = _type;
    }
    
    /**
		 * Remove trouble point (graphics) from board
		 */
    public function clearTroublePoint() : Void
    {
        if (associated_trouble_point == null)
        {
            return;
        }
        if (!edge.associated_pipe)
        {
            throw new Error("Attempted to call Port.clearTroublePoint() but this port's edge has no associated_pipe");
            return;
        }
        if (!edge.associated_pipe.board)
        {
            throw new Error("Attempted to call Port.clearTroublePoint() but this port's edge's associated_pipe has board = null");
            return;
        }
        if (associated_trouble_point != null && associated_trouble_point.parent)
        {
            associated_trouble_point.parent.removeChild(associated_trouble_point);
        }
        if (edge.associated_pipe.board.trouble_points.indexOf(associated_trouble_point) > -1)
        {
            edge.associated_pipe.board.trouble_points.splice(edge.associated_pipe.board.trouble_points.indexOf(associated_trouble_point), 1);
        }
        associated_trouble_point = null;
    }
    
    /**
		 * Add a circular trouble point to the edge's pipe's board
		 * @param	radius (Optional) Radius of the new TroublePoint 
		 */
    public function insertCircularTroublePoint(radius : Float = 110) : Void
    {
        if (!edge.associated_pipe)
        {
            throw new Error("Attempted to call Port.insertCircularTroublePoint() but this port's edge has no associated_pipe");
            return;
        }
        if (!edge.associated_pipe.board)
        {
            throw new Error("Attempted to call Port.insertCircularTroublePoint() but this port's edge's associated_pipe has board = null");
            return;
        }
        /*
			var my_pt:Point;
			if (type == Port.INCOMING_PORT_TYPE) {
				my_pt = new Point( node.x, node.y );
				if (edge.spline_control_points.length >= 4) {
					my_pt = edge.spline_control_points[edge.spline_control_points.length - 1].clone();
				}
			} else {
				my_pt = new Point( node.x, node.y );
				if (edge.spline_control_points.length > 0) {
					my_pt = edge.spline_control_points[0].clone();
				}
			}
			my_pt = VerigameSystem.nodeSpaceToBoardSpace(my_pt);
			*/
        var tp_y_off : Float = 0.0;
        var _sw5_ = (Theme.CURRENT_THEME);        

        switch (_sw5_)
        {
            case Theme.PIPES_THEME:
                tp_y_off = 0;
            case Theme.TRAFFIC_THEME:
                tp_y_off = Math.min(4 * Pipe.WIDE_BALL_RADIUS, 0.45 * edge.associated_pipe.interpolated_spline_length);
        }
        var my_pt : Point;
        edge.associated_pipe.interpolateSpline();
        if (type == Port.OUTGOING_PORT_TYPE)
        {
            my_pt = edge.associated_pipe.getXYbyT(tp_y_off / edge.associated_pipe.interpolated_spline_length);
        }
        else
        {
            my_pt = edge.associated_pipe.getXYbyT(1.0 - tp_y_off / edge.associated_pipe.interpolated_spline_length);
        }
        
        clearTroublePoint();
        var tp : TroublePoint = new TroublePoint(my_pt.x, my_pt.y, radius, radius, true);
        if (edge.associated_pipe)
        {
            tp.buttonMode = true;
            edge.associated_pipe.assignCallbacks(tp);
        }
        else
        {
        }
        edge.associated_pipe.board.trouble_points.push(tp);
        
        if (TroublePoint.USE_ANIMATED_VERSIONS)
        {
            tp.scaleX = 2.0;
            tp.scaleY = 2.0;
        }
        else
        {
            tp.scaleX = 0.7;
            tp.scaleY = 0.7;
        }
        tp.x = my_pt.x;
        tp.y = my_pt.y;
        
        // Associate it with the port
        associated_trouble_point = tp;
        edge.associated_pipe.board.trouble_point_pane.addChild(tp);
    }
    
    public function hideTroublePoint() : Void
    {
        if (associated_trouble_point != null && associated_trouble_point.parent)
        {
            associated_trouble_point.parent.removeChild(associated_trouble_point);
        }
    }
    
    public function showTroublePoint() : Void
    {
        if (associated_trouble_point != null)
        
        ////edge.associated_pipe.top_layer.addChild(associated_trouble_point);{
            
            edge.associated_pipe.board.trouble_point_pane.addChild(associated_trouble_point);
        }
    }
}
