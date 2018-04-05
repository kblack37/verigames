package utils 
{
	
	import flash.geom.Point;

	/**
	 * My own extended math class for doing cool things 
	 * @author akirilov
	 * 
	 */	
	public final class XMath
	{
		/**
		 * Returns a random number between <code>min</code> (inclusive) and <code>max</code> (exclusive).  
		 * @param min The lower bound for the random number.
		 * @param max The upper bound for the random number.
		 * @return A random Number.
		 */		
		public static function random(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		/**
		 * Returns a random integer between <code>min</code> and <code>max</code> (inclusive).  
		 * @param min The lower bound for the random number.
		 * @param max The upper bound for the random number.
		 * @return A random int.
		 */	
		public static function randomInt(min:int, max:int):int
		{
			return Math.round(Math.random() * (max - min) + min);
		}
		
		/**
		 * Calculates and returns the distance between two points. 
		 * @param p1 The first Point.
		 * @param p2 The second Point.
		 * @return An Number representing the distance between two points (in pixels).
		 */
		public static function getDist(p1:Point, p2:Point):Number
		{
			return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
		}
		
		/**
		 * Calculates and returns the square of the distance between two points. Use when you don't need exact distance to save from doing expensive sqrt.
		 * @param p1 The first Point.
		 * @param p2 The second Point.
		 * @return An Number representing the distance between two points (in pixels).
		 */
		public static function getDistSquared(p1:Point, p2:Point):Number
		{
			return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
		}
		
		/**
		 * Calculates and returns the angle between two vectors. 
		 * @param p1 The first vector.
		 * @param p2 The second vector.
		 * @return An int representing the angle between the two vectors (in radians).
		 */
		public static function getAngle(p1:Point, p2:Point):Number
		{
			return Math.acos(dot(p1, p2) / (p1.length * p2.length));
		}
		
		/**
		 * Calculates and returns the dot product of two vectors. 
		 * @param p1 The first vector.
		 * @param p2 The second vector.
		 * @return A number representing the dot product of the two vectors.
		 */
		public static function dot(p1:Object, p2:Object):Number
		{
			return ((Number(p1.x) * Number(p2.x)) + (Number(p1.y) * Number(p2.y)));
		}
		
		/**
		 * Project a vector onto another (normalized) vector, and store the result back in the vector.
		 * @param toProj The vector to project.
		 * @param onto The vector to project onto. Must be normalized!
		 */
		public static function projectOntoNormalized(toProj:Object, onto:Object):void
		{
			var dt:Number = dot(toProj, onto);
			toProj.x = dt * onto.x;
			toProj.y = dt * onto.y;
		}
	
		/**
		 * Calculates and returns the x-th triangualar number 
		 * @param x The triangular number to compute
		 * @return An int.
		 */
		public static function triangleNum(x:int):int
		{
			return (Math.pow(x, 2) + x) / 2;
		}
		
		/**
		 * Uses Euclid's Algorithm to calculate the gcd of <code>x</code> and <code>y</code>. 
		 * @param x An integer.
		 * @param y An integer.
		 * @return An int corresponding to the gcd of <code>x</code> and <code>y</code>
		 */		
		public static function gcd(x:int, y:int):int
		{
			var a:int = x;
			var b:int = y;
			while(b != 0) {
				var q:int = a/b;
				var r:int = a - q*b;
				a = b;
				b = r;
			}
			return a;
		}

		/**
		 * Generates a random n-gon given the n and the parameters for a bounding circle. 
		 * @param location The center of the enclosing circle
		 * @param radius The radius of the enclosing circle
		 * @param sides	The number of sides the polygon should have
		 * @return An array of Points defining a convex polygon (in clockwise, Box2D order)
		 */
		public static function getNgonFromCircle(location:Point, radius:Number, sides:int):Array
		{ 
			var angles:Array = [];
			for (var i:int = 0; i < sides; i++) {
				do {
					var angle:Number = XMath.random(0, 2 * Math.PI);
				} while (angles.indexOf(angle) != -1);
				angles.push(angle);
			}
			angles = angles.sort(16);
			//trace("Angles: " + angles);
			
			var points:Array = [];
			for (var j:int = 0; j < angles.length; j++) {
				points.push(getPointOnCircle(angles[j], radius));
			}
			//trace("Points: " + points);
			return points;
		}
		
		/**
		 * Determine if a polygon is convex.  Vertices must be in clockwise, Box2D order.
		 * @param vertices The polygon vertices.
		 * @return Whether the polygon is convex.
		 */		
		public static function isPolygonConvex(vertices:Array):Boolean
		{
			if (vertices.length <= 3) {
				return true;
			}
			
			for (var ii:uint = 0; ii < vertices.length; ++ ii) {
				var ptA:Object = vertices[(ii + 0) % vertices.length];
				var ptB:Object = vertices[(ii + 1) % vertices.length];
				var ptC:Object = vertices[(ii + 2) % vertices.length];
				
				var vecBA:Point = new Point(ptA.x - ptB.x, ptA.y - ptB.y);
				var vecBC:Point = new Point(ptC.x - ptB.x, ptC.y - ptB.y);
				
				var crossZ:Number = (vecBA.x * vecBC.y - vecBA.y * vecBC.x);
				if (crossZ > 0.0) {
					return false;
				}
			}
			return true;
		}

		public static function compareNum(i1:Number, i2:Number):Number
		{
			return i1 - i2;
		}
		
		public static function compareNumDesc(i1:Number, i2:Number):Number
		{
			return i2 - i1;
		}
		
		public static function getPointOnCircle(a:Number, r:Number=1):Point
		{
			return new Point(r * Math.cos(a), r * Math.sin(a));
		}

		/**
		 * Linearly interpolate between two numbers.  Interpolation parameters outside [0, 1] will extrapolate.
		 * @param t Interpolation parameter.
		 * @param x0 Value at interpolation parameter 0.
		 * @param x1 Value at interpolation parameter 1.
		 * @return Linearly interpolated value.
		 */
		public static function lerp(t:Number, x0:Number, x1:Number):Number
		{
			return x0 + t * (x1 - x0);
		}
		
		/**
		 * Reverse linear interpolation between two numbers.  Might be outside the range [0, 1].
		 * Find the linear interpolation parameter that would produce a given value.
		 * @param x Value to use.
		 * @param x0 Value at interpolation parameter 0.
		 * @param x1 Value at interpolation parameter 1.
		 * @return Interpolation parameter.
		 */
		public static function rlerp(x:Number, x0:Number, x1:Number):Number
		{
			return (x - x0) / (x1 - x0);
		}

		/**
		 * Clamp a value to lie in a given range.
		 * @param x Value to clamp.
		 * @param lo Lowest possible value.
		 * @param hi Highest possible value.
		 * @return Clamped value, will be in the range [lo, hi].
		 */
		public static function clamp(x:Number, lo:Number, hi:Number):Number
		{
			return Math.max(lo, Math.min(x, hi));
		}

		/**
		 * Perform a linear remapping of a value.
		 * The mapping is such that lo0 maps to li1, hi0 maps to h1, and all other values are computer linearly.
		 * @param x The value to remap.
		 * @param lo0 Low end of the input mapping.
		 * @param hi0 High end of the input mapping.
		 * @param lo1 Low end of the output mapping.
		 * @param hi1 High end of the output mapping.
		 * @return The remapped value.
		 */
		public static function lremap(x:Number, lo0:Number, hi0:Number, lo1:Number, hi1:Number):Number
		{
			return lerp(rlerp(x, lo0, hi0), lo1, hi1);
		}

		/**
		 * Perform a linear remapping of a value clamped to the given output range.
		 * The mapping is such that lo0 maps to li1, hi0 maps to h1, and all other values are computer linearly.
		 * The remapped value is clamped to fall between lo1 and hi1.
		 * @param x The value to remap.
		 * @param lo0 Low end of the input mapping.
		 * @param hi0 High end of the input mapping.
		 * @param lo1 Low end of the output mapping.
		 * @param hi1 High end of the output mapping.
		 * @return The remapped value.
		 */
		public static function lremapClamp(x:Number, lo0:Number, hi0:Number, lo1:Number, hi1:Number):Number
		{
			return lerp(clamp(rlerp(x, lo0, hi0), 0, 1), lo1, hi1);
		}
		
		/**
		 * Convert from degrees to radians.
		 * @param x Angle in degrees.
		 * @return Angle in radians.
		 */
		public static function degreesToRadians(x:Number):Number
		{
			return x / 180.0 * Math.PI;
		}

		/**
		 * Convert from radians to degrees.
		 * @param x Angle in radians.
		 * @return Angle in degrees.
		 */
		public static function radiansToDegrees(x:Number):Number
		{
			return x * 180.0 / Math.PI;
		}
		
		/**
		 * Square a number.
		 * @param x Number to be squared.
		 * @return Number squared.
		 */
		public static function square(x:Number):Number
		{
			return x * x;
		}
		
		/**
		 * Cube a number.
		 * @param x Number to be cubed.
		 * @return Number cubed.
		 */
		public static function cube(x:Number):Number
		{
			return x * x * x;
		}
	}
}
