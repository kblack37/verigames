package utils
{
	import flash.geom.Point;
	
	/**
	 * My own extended Object class
	 * @author pavlik
	 */	
	public final class XObject
	{
		/**
		 * Take an input JSON compatible object and return clone of it
		 * @param	obj: Object to clone
		 * @return Cloned obj
		 */
		public static function clone(obj:Object):Object
		{
			var cloneStr:String = JSON.stringify(obj);
			var clone:Object = JSON.parse(cloneStr);
			return clone;
		}
		
		public static function clonePointArray(arrToClone:Array):Array
		{
			var newArray:Array = new Array(arrToClone.length);
			for (var i:int = 0; i < arrToClone.length; i++) {
				var pt:Point  = arrToClone[i] as Point;
				newArray[i] = pt.clone(); // need to clone to avoid referencing the actual points in the array
			}
			return newArray;
		}
	}
}
