package Utilities 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Tim Pavlik
	 */
	public class Geometry 
	{
		private static var m_locked:Boolean = false;
		
		public function Geometry() 
		{
		}
		
		// Static vars used for performance reasons when possible
		private static var half:Number = 0.5;
		private static var dx:Number; // x-diff between endpoints
		private static var dy:Number; // y-diff between endpoints
		private static var m:Number; // diff between endpoints
		private static var b:Number; // diff between endpoints
		private static var sq_dist1:Number; // dist squared value from control point 1 to line between endpoints
		private static var sq_dist2:Number; // dist squared value from control point 2 to line between endpoints
		/**
		 * Function to recursively subdivide a spline into line segments meeting a given tolerance
		 * 
		 * Note: this function was adapted from the degrafa library's GeometryUtils.cubicToQuadratic() function - http://www.degrafa.org
		 * 
		 * @param	p1x X value of first endpoint
		 * @param	p1y Y value of first endpoint
		 * @param	c1x X value of first control point
		 * @param	c1y Y value of first control point
		 * @param	c2x X value of second control point
		 * @param	c2y Y value of second control point
		 * @param	p2x X value of second endpoint
		 * @param	p2y Y value of second endpoint
		 * @param	tolerance Tolerance (in pixels) that each line segment must meet to be used as an approximation for a spline (if not met, the spline is further subdivided)
		 * @param	prev_lines List of previous line segments generated (used for recursion)
		 * @return List of points representing line segments that approximate the given input spline
		 */
		public static function splineToLineSegments(p1x:Number,p1y:Number, c1x:Number,c1y:Number, c2x:Number,c2y:Number, p2x:Number,p2y:Number, tolerance:Number = 1.5, prev_lines:Array = null):Array {
			
			if (m_locked) {
				throw new Error("Call to Geometry.splineToLineSegments when class is locked - check for concurrent calls");
				return null;
			}
			m_locked = true;
			if (!prev_lines) {
				prev_lines = new Array();
			}
			if (prev_lines.length == 0) {
				prev_lines.push(new Point(p1x, p1y));
			}
			dx = p2x - p1x;
			dy = p2y - p1y;
			
			// If the distance between endpoints is less than or equal to the tolerance, assume a good enough approximation
			if (dx * dx + dy * dy <= tolerance * tolerance) {
				prev_lines.push(new Point(p2x, p2y));
				m_locked = false;
				return prev_lines;
			}
			
			if (!dx) {
				// handle the vertical line case (slope = infinity): sq distance to line = dx^2
				sq_dist1 = (c1x - p1x) * (c1x - p1x);
				sq_dist2 = (c2x - p1x) * (c2x - p1x);
			} else {
				m = dy / dx;
				b = p1y - m * p1x;
				sq_dist1 = (c1y - b - m * c1x) * (c1y - b - m * c1x) / (1 + m * m);
				sq_dist2 = (c2y - b - m * c2x) * (c2y - b - m * c2x) / (1 + m * m);
			}
			
			// split curve in half if the tolerance isn't reached
			if (sq_dist1 + sq_dist2 > tolerance * tolerance) {
				//dev note:these cannot be static external variables for performance gain, as they are required to maintain previous values on return from recusive execution
				var p01x:Number = (p1x + c1x) * half;
				var p01y:Number = (p1y + c1y) * half;
				var p12x:Number = (c1x + c2x) * half;
				var p12y:Number = (c1y + c2y) * half;				
				var p23x:Number = (c2x + p2x) * half;
				var p23y:Number = (c2y + p2y) * half;					
				var p02x:Number = (p01x + p12x) * half;
				var p02y:Number = (p01y + p12y) * half;
				var p13x:Number = (p12x + p23x ) * half;
				var p13y:Number = (p12y + p23y ) * half;					
				var p03x:Number = (p02x + p13x) * half;
				var p03y:Number = (p02y + p13y) * half;	
				// recursive calls to subdivide curve
				m_locked = false;
				splineToLineSegments(p1x, p1y, p01x, p01y, p02x, p02y, p03x, p03y, tolerance, prev_lines);
				splineToLineSegments(p03x, p03y, p13x, p13y, p23x, p23y, p2x, p2y, tolerance, prev_lines);
				m_locked = true;
			} else{
				// end recursion by saving point
				prev_lines.push(new Point(p2x, p2y));
			}
			m_locked = false;
			return prev_lines;
		}
		
		private static var p1:Point; // endpoint 1
		private static var p2:Point; // control point 1
		private static var p3:Point; // control point 2
		private static var p4:Point; // endpoint 2
		private static var p1_weight:Number;
		private static var p2_weight:Number;
		private static var p3_weight:Number;
		private static var p4_weight:Number;
		/**
		 * Returns the XY coordinates for the given t in the edge based on the spline control points
		 * @param	spline_control_points Array of Points - spline control points (endpoint1 = first point, endpoint2 = 4th point)
		 * @param	input_t Parametric coordinate offset from beginning of edge (t = 0) to end (t = 1) get coordinate from
		 * @return Array (size = 2) of XY coordinates for the given t in the edge based on the spline control points
		 */
		public static function getXYbyTSpline(spline_control_points:Array, input_t:Number):Array {
			if (m_locked) {
				throw new Error("Call to Geometry.getXYbyTSpline when class is locked - check for concurrent calls");
				return new Array(0, 0);
			}
			if (!spline_control_points) {
				throw new Error("The spline_control_points called using getXYbyTSpline was null");
				return new Array(0, 0);
			}
			if (spline_control_points.length != 4) {
				throw new Error("The spline_control_points called using getXYbyTSpline has an incorrect number of control points");
				return new Array(0, 0);
			}
			m_locked = true;
			var mtx_a:Array = new Array(4);
			var mtx_b:Array = new Array(4);
			
			var p1:Point = spline_control_points[0];
			var p2:Point = spline_control_points[1];
			var p3:Point = spline_control_points[2];
			var p4:Point = spline_control_points[3];
			
			p1_weight = (1 - input_t) * (1 - input_t) * (1 - input_t);
			p2_weight = 3 * (1 - input_t) * (1 - input_t) * input_t;
			p3_weight = 3 * input_t * input_t * (1 - input_t);
			p4_weight = input_t * input_t * input_t;
			
			m_locked = false;
			return new Array( p1_weight * p1.x + p2_weight * p2.x + p3_weight * p3.x + p4_weight * p4.x, p1_weight * p1.y + p2_weight * p2.y + p3_weight * p3.y + p4_weight * p4.y);
		}
		
	}

}