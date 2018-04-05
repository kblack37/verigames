package NetworkGraph
{
	import NetworkGraph.Edge;
	
	import VisualWorld.Board;
	import VisualWorld.VerigameSystem;
	
	import Utilities.Metadata;
	
	import flash.geom.Point;
	import VisualWorld.Pipe;
	import VisualWorld.TroublePoint;
	
	/**
	 * Directed Graph Node created when a graph structure is read in from XML (or internally for pipe objects - but this is being deprecated)
	 * 
	 * Incoming and outgoing edges each have a to_port (for incoming) or from_port (for outgoing) that correspond to this node.
	 * 
	 */
	public class Node
	{
		
		/** X coordinate of the center of this node in board space (where 0, 0 is the top left of the board and it extends to board.max_pipe_width, board.max_pipe_height) */
		public var x:Number;
		
		/** Y coordinate of center of this node in board space (where 0, 0 is the top left of the board and it extends to board.max_pipe_width, board.max_pipe_height) */
		public var y:Number;
		
		/** Parametric coordinate of this node in pipe space (where 0 is typically the top of the pipe and t extends downward to pipe.current_t at the bottom) */
		public var t:Number;
		
		/** String describing the type of node - the entire list is contained in the NodeTypes class */
		public var kind:String;
		
		/** Extra information about this node (for example: any attributes in the original XML object) */
		public var metadata:Object;
		
		/** All ports for edges that end at this node */
		public var incoming_ports:Vector.<Port>;
		
		/** All ports for edges that originate from this node */
		public var outgoing_ports:Vector.<Port>;
		
		/** Any pipe objects that were created/added based on this node */
		public var associated_pipes:Vector.<Pipe>;
		
		/** Trouble point created based on this node */
		public var associated_trouble_point:TroublePoint;
		
		/** The associated board this node appears on */
		public var node_board:Board;
		
		/** The unique id given as input from XML (unique within a given world) */
		public var node_id:String;
		
		/**
		 * Directed Graph Node created when a graph structure is read in from XML (or internally for pipe objects - but this is being deprecated)
		 * @param	_x X coordinate of this node in board space
		 * @param	_y Y coordinate of this node in board space
		 * @param	_t Parametric coordinate of this node in pipe object space
		 * @param	_kind String describing the type of node (Ex: SPLIT, MERGE, etc)
		 * @param	_metadata Extra information about this node (for example: any attributes in the original XML object)
		 */
		public function Node(_x:Number, _y:Number, _t:Number, _kind:String, _metadata:Object = null)
		{
			x = _x;
			y = _y;
			t = _t;
			kind = _kind;
			metadata = _metadata;
			if (_metadata == null) {
				metadata = new Metadata(null);
			} else if (_metadata.data != null) {
				if (_metadata.data.id != null)
					if (String(_metadata.data.id).length > 0)
						node_id = String(_metadata.data.id);
			}
			incoming_ports = new Vector.<Port>();
			outgoing_ports = new Vector.<Port>();
			associated_pipes = new Vector.<Pipe>();
			associated_trouble_point = null;
			node_board = null;
		}
		
		/**
		 * Creates an outgoing edge object and links it to the desired destination node
		 * @param	_outgoing_port Port on this node to be associated with the new outgoing edge
		 * @param	_destination_node Destination node to be associated with the new outgoing edge
		 * @param	_destination_port Port on destination node to be associated with the new outgoing edge
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
		public function addOutgoingEdge(_outgoing_port:String, _destination_node:Node, _destination_port:String, _edge_spline_control_points:Vector.<Point>, _linked_edge_set:EdgeSetRef, _metadata:Object = null):void {
			var e:Edge = new Edge(this, _outgoing_port, _destination_node, _destination_port, _edge_spline_control_points, _linked_edge_set, _metadata);
			outgoing_ports.push(e.from_port);
			_destination_node.connectIncomingEdge(e);
		}
		
		/**
		 * Connect an incoming edge to this node 
		 * @param	_e Edge to be connected/linked to this node
		 */
		public function connectIncomingEdge(_e:Edge):void {
			incoming_ports.push(_e.to_port);
		}
		
		/**
		 * Remove trouble point (graphics) from board
		 */
		public function clearTroublePoint():void {
			if (node_board == null) {
				return;
			}
			if (associated_trouble_point !=null && associated_trouble_point.parent != null) {
				associated_trouble_point.parent.removeChild(associated_trouble_point);
			}
			if (node_board.trouble_points.indexOf(associated_trouble_point) > -1) {
				node_board.trouble_points.splice(node_board.trouble_points.indexOf(associated_trouble_point), 1);
			}
		}
		
		/**
		 * Add a circular trouble point to the node's board
		 * @param	dx (Optional) X coordinate offset from the node X coordinate
		 * @param	dy (Optional) Y coordinate offset from the node X coordinate
		 * @param	radius (Optional) Radius of the new TroublePoint 
		 */
		public function insertCircularTroublePoint(dx:Number = 0.0, dy:Number = 0.0, radius:Number = 110):void {
			if (node_board == null) {
				throw new Error("Node.insertCircularTroublePoint() called but this node.node_board == null");
				return;
			}
			clearTroublePoint();
			var tp:TroublePoint = new TroublePoint(this.x + dx, this.y + dy, radius, radius, true);
			
			if (TroublePoint.USE_ANIMATED_VERSIONS) {
				tp.scaleX = 2.0;
				tp.scaleY = 2.0;
			} else {
				tp.scaleX = 0.7;
				tp.scaleY = 0.7;
			}
			
			tp.x = VerigameSystem.PIPE_CONSTANT_LEFT_EDGE + VerigameSystem.PIPE_CONSTANT_X_GRID_SIZE * this.x + dx;
			tp.y = VerigameSystem.PIPE_CONSTANT_TOP_MARGIN + VerigameSystem.PIPE_CONSTANT_Y_GRID_SIZE * this.y + dy;
			
			associated_trouble_point = tp;
			node_board.trouble_points.push(tp);
			node_board.trouble_point_pane.addChild(tp);
			node_board.draw();	
		}
		
		/**
		 * Add a rectangular trouble point to the node's board
		 * @param	dx (Optional) X coordinate offset from the node X coordinate
		 * @param	dy (Optional) Y coordinate offset from the node X coordinate
		 * @param	w (Optional) Width of the new TroublePoint 
		 * @param	h (Optional) Height of the new TroublePoint 
		 */
		public function insertRectangularTroublePoint(dx:Number = 0.0, dy:Number = 0.0, w:Number = 200.0, h:Number = 100.0):void {
			if (node_board == null) {
				throw new Error("Node.insertCircularTroublePoint() called but this node.node_board == null, or not a pipe node");
				return;
			}
			clearTroublePoint();
			var tp:TroublePoint = new TroublePoint(this.x + dx, this.y + dy, w, h, false);
			
			if (TroublePoint.USE_ANIMATED_VERSIONS) {
				tp.scaleX = 0.75 * w / tp.shape.width;
				tp.scaleY = 0.8 * h / tp.shape.height;
			} else {
				tp.scaleX = 0.68;
				tp.scaleY = 0.7;
			}
			
			tp.x = this.x + dx;
			tp.y = this.y + dy;
			associated_trouble_point = tp;
			node_board.trouble_points.push(tp);
			node_board.trouble_point_pane.addChild(tp);
			node_board.draw();	
		}
		
		/**
		 * This orders the incoming and outgoing edges from smallest port to largest port (Ex: 0, 2, 4, 5, 6)
		 * This is used when drawing the incoming pipes to a subnetwork node, as the pipe order should be consistent from
		 * smallest to largest port, as it will appear on the zoomed in version of the board (if clicked).
		 */
		public function orderEdgesByPort():void {
			incoming_ports.sort(comparei);
			function comparei(x:Port, y:Port):Number {
					if ((x as Port).port_id < (y as Port).port_id)
						return -1.0;
					if ((x as Port).port_id > (y as Port).port_id)
						return 1.0;
					return 0.0;
				}
			outgoing_ports.sort(compareo);
			function compareo(x:Port, y:Port):Number {
					if ((x as Port).port_id < (y as Port).port_id)
						return -1.0;
					if ((x as Port).port_id > (y as Port).port_id)
						return 1.0;
					return 0.0;
				}
		}
		
	}
}