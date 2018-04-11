package cgs.utils;

/**
 * ...
 * @author Ric Gray
 */
class DynamicUtils 
{

	static public function exists(obj : Dynamic, field : String) : Bool { return Reflect.hasField(obj, field); } ;
		
}