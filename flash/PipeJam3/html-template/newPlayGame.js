

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
			
// For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. 
            var swfVersionStr = "11.1.0";
            // To use express install, set to playerProductInstall.swf, otherwise the empty string. 
            var xiSwfUrlStr = "/game/playerProductInstall.swf";
            var flashvars = {};
            flashvars.swfName="/game/PipeJam3"
		flashvars.swfVersion = "20130913-56e805a55f37"
            var params = {};
            params.quality = "high";
            params.bgcolor = "#ffffff";
            params.allowscriptaccess = "sameDomain";
            params.allowfullscreen = "true";
            params.wmode="direct";
            var attributes = {};
            attributes.id = "PipeJam3";
            attributes.name = "PipeJam3";
            attributes.align = "middle";
            swfobject.embedSWF(
                "/game/PreloaderPipeJam3.swf", "flashContent", 
                "960", "640", 
                swfVersionStr, xiSwfUrlStr, 
                flashvars, params, attributes);
            // JavaScript enabled so display the flashContent div in case it is not replaced with a swf object.
            swfobject.createCSS("#flashContent", "display:block;text-align:left;");

