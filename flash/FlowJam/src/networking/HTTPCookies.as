package networking
{
	import flash.external.ExternalInterface;
	
	public class HTTPCookies
	{
		public static const TUTORIALS_COMPLETED:String = "tutorialLevelCompleted";
		
		public static function getCookie(key:String):*
		{
			if (!ExternalInterface.available) {
				return null;
			}
			return ExternalInterface.call("getCookie", key);
		}
		
		public static function setCookie(key:String, val:*):void
		{
			if (!ExternalInterface.available) {
				return;
			}
			ExternalInterface.call("setCookie", key, val);
		}
		
		public static function displayAlert(str:String):void
		{
			if (!ExternalInterface.available) {
				return;
			}
			ExternalInterface.call("alert", str);
		}
		
		public static function callGetEncodedCookie():void
		{
			if (!ExternalInterface.available) {
				return;
			}
			ExternalInterface.call("getEncodedCookie");
		}
		
		public static function getEncodedCookieResult():*
		{
			if (!ExternalInterface.available) {
				return;
			}
			return ExternalInterface.call("getEncodedCookieResult");
		}
	}
}

/*
Need to make sure this is in the JS:

			function getCookie(key)
			{
				var cookieValue = null;
				
				if (key)
				{
					var cookieSearch = key + "=";
					
					if (document.cookie)
					{
						var cookieArray = document.cookie.split(";");
						for (var i = 0; i < cookieArray.length; i++)
						{
							var cookieString = cookieArray[i];
							
							// skip past leading spaces
							while (cookieString.charAt(0) == ' ')
							{
								cookieString = cookieString.substr(1);
							}
							
							// extract the actual value
							if (cookieString.indexOf(cookieSearch) == 0)
							{
								cookieValue = cookieString.substr(cookieSearch.length);
							}
						}
					}
				}
			
				return cookieValue;
			}

function setCookie(key, val)
{
	if (key)
	{
		var date = new Date();
		
		if (val != null)
		{
			// expires in one year
			date.setTime(date.getTime() + (365*24*60*60*1000));
			document.cookie = key + "=" + val + "; expires=" + date.toGMTString();
		}
		else
		{
			// expires yesterday
			date.setTime(date.getTime() - (24*60*60*1000));
			document.cookie = key + "=; expires=" + date.toGMTString();
		}
	}
}

*/