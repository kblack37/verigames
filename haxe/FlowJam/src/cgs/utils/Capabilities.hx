package cgs.utils;

/**
 * TODO - Need platform specific implementations.
 * @author Aaron W
 */
class Capabilities
{
	#if flash
	
		public static function getOs():String
		{
			return flash.system.Capabilities.os;
		}
		
		public static function getCpuArchitecture():String
		{
			return flash.system.Capabilities.cpuArchitecture;
		}
		
		public static function getLanguage():String
		{
			return flash.system.Capabilities.language;
		}
		
		public static function getScreenResolutionX():Float
		{
			return flash.system.Capabilities.screenResolutionX;
		}
		
		public static function getScreenResolutionY():Float
		{
			return flash.system.Capabilities.screenResolutionY;
		}
		
		public static function getScreenDpi():Float
		{
			return flash.system.Capabilities.screenDPI;
		}
		
		public static function getPixelAspectRatio():Float
		{
			return flash.system.Capabilities.pixelAspectRatio;
		}
		
		public static function getVersion():String
		{
			return flash.system.Capabilities.version;
		}
		
		public static function getServerString():String
		{
			return flash.system.Capabilities.serverString;
		}
	
	#else
		public static function getOs():String
		{
			return "";
		}
		
		public static function getCpuArchitecture():String
		{
			return "";
		}
		
		public static function getLanguage():String
		{
			return "";
		}
		
		public static function getScreenResolutionX():Float
		{
			return 0;
		}
		
		public static function getScreenResolutionY():Float
		{
			return 0;
		}
		
		public static function getScreenDpi():Float
		{
			return 0;
		}
		
		public static function getPixelAspectRatio():Float
		{
			return 0;
		}
		
		public static function getVersion():String
		{
			return "";
		}
		
		public static function getServerString():String
		{
			return "";
		}
	
	#end
}