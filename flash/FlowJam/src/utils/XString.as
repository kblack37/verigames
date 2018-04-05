package utils
{
	import flash.geom.Point;

	/**
	 * My own extended string class
	 * @author pavlik
	 */	
	public final class XString
	{
		/**
		 * Converts a string into a boolean by looking at the contents of the string.
		 * @param s String to convert to Boolean: "false" (any case or combination upper/lowercase), "0", "f", "F", "null" (any case) or empty string ("") return false, everything else returns true
		 * @return The bool represented by the string. Default to true, although "null" and empty string return false
		 */		
		public static function stringToBool(st:String):Boolean
		{
			if (st == null) return false;
			var lcst:String = st.toLowerCase();
			switch(lcst) {
				case "false":
				case "0":
				case "":
				case "null":
				case "f":
					return false;
				break;
			}
			return true;
		}
		
		public static function stringToInt(st:String):int {
			var num:int = 0;
			for (var i:int = 0; i < st.length; i++) {
				if (!isNaN(st.charCodeAt(i))) {
					num += int(st.charCodeAt(i));
				}
			}
			return num;
		}
		
		public static function leftPad(str:*, len:uint, padChar:String = " "):String
		{
			var ret:String = String(str);
			
			while (ret.length < len) {
				ret = padChar + ret;
			}
			
			return ret;
		}
		
		private static function stripParens(a:String):String
		{
			if ( (a.charAt(0)=="(") || (a.charAt(0)=="[") )
				a = a.slice(1, a.length);
			if ( (a.charAt(a.length - 1)==")") || (a.charAt(a.length - 1)=="]") )
				a = a.slice(0, a.length - 1);
			return a;
		}
		
		public static function stringToPointVector(str:String):Vector.<Point>
		{
			var fullString:String = str;
			
			// array of points
			var vec:Vector.<Point> = new Vector.<Point>();
			var pointsArray:Array = stripParens(str).split("),(");
			for (var j:int = 0; j < pointsArray.length; j++) {
				var coords:Array = pointsArray[j].split(",");
				if (isNaN(coords[0]) || isNaN(coords[1]))
					continue;
				vec.push(new Point(coords[0], coords[1]));
			}
			return vec;
		}
		
		public static function pointVectorToString(vec:Vector.<Point>):String
		{
			var new_string:String = "";
			var i:uint = 0;
			for each (var pt:Point in vec) {
				new_string += "(" + pt.x.toFixed(1).toString() + "," + pt.y.toFixed(1).toString() + ")";
				if (i + 1 < vec.length)
					new_string += ",";
				i++;
			}
			return new_string;
		}
	}
}
