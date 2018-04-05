package networking
{
	import flash.events.Event;
	
	import scenes.Scene;
	
	import server.LoggingServerInterface;
	
	import starling.core.Starling;
	import starling.events.Event;
	import flash.net.*;
	
	import utils.XString;


	//the steps are: 
	//	get the cookie with the express.sid value
	//  send that to validateSession, to see if it's still a valid session id
	//	if it is, you will get the player ID number, else null
	//If you have a valid player ID number, then the fun begins
	//	first you have to check to see if the player exists in the RA (why log In doesn't add the player to the RA is beyond me)
	//		If they don't exist, add them
	//	Then you have to make sure they are active by activating them
	public class PlayerValidation
	{
		public static var VERIFY_SESSION:int = 1;
		public static var GET_ENCODED_COOKIES:int = 2;
		public static var PLAYER_INFO:int = 3;

		public static var playerLoggedIn:Boolean = false;
		
		public static var playerID:String = "";
		public static var playerIDForTesting:String = "51e5b3460240288229000026"; //hard code one for local testing
		public static var playerUserName:String = "";
		
		public static var LOGIN_STATUS_CHANGE:String = "login_status_change";
		
		static protected var validationObject:PlayerValidation = null;
		protected var pipejamCallbackFunction:Function;
		protected var controller:Scene;
		protected var encodedCookies:String;
		
		static public var GETTING_COOKIE:String = "Getting Cookie";
		static public var VALIDATING_SESSION:String = "Validating Session";
		static public var ACTIVATING_PLAYER:String = "Activating Player";
		static public var GETTING_PLAYER_INFO:String = "Getting Player ID";
		
		static public var VALIDATION_SUCCEEDED:String = "Player Logged In";
		static public var VALIDATION_FAILED:String = "Validation Failed";
		
		//callback:Function, request:String, type:String, data:String = null, method:String = URLRequestMethod.GET, url:String = null
		
		//callback function should check PlayerValidation.playerLoggedIn for success or not - for use in release builds
		static public function validatePlayerIsLoggedInAndActive(callback:Function, _controller:Scene):void
		{
			if(validationObject == null)
			{
				validationObject = new PlayerValidation;
				validationObject.controller = _controller;
			}
						
			validationObject.pipejamCallbackFunction = callback;
			validationObject.controller.setStatus(GETTING_COOKIE);
			validationObject.checkForCookie();
		}
		
		//check for session ID cookie, and if found, try to validate it
		protected function checkForCookie():void
		{
			sendMessage(GET_ENCODED_COOKIES, cookieCallback);
		}
		
		public function cookieCallback(result:int, event:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var cookies:String = event.target.data;
				if(cookies.indexOf("<html>") == -1 && cookies.length > 10) //not an error message or empty cookie string = {} = %7B%7D
				{
					controller.setStatus(VALIDATING_SESSION);
					//encode cookies
					encodedCookies = escape(cookies);
					//if encodedCookies is double encoded, we get %25 (= encoded %) in front of encoded %7Bs, etc.
					if(encodedCookies.indexOf("%257B") != -1)
						encodedCookies = cookies;
					sendMessage(VERIFY_SESSION, sessionIDValidityCallback);
					return;
				}
			}
			
			//if we make it this far, just exit
			onValidationFailed();
			pipejamCallbackFunction();
		}

		//callback for checking the validity of the session id
		//if the session id is valid, then get the player id and make sure they are in the RA
		public function sessionIDValidityCallback(result:int, event:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = event.target.data;
				if(response.indexOf("<html>") == -1) //else assume auth required dialog
				{
					var jsonResponseObj:Object = JSON.parse(response);
					
					if(jsonResponseObj.userId != null)
					{
						playerID = jsonResponseObj.userId;
						
						if (LoggingServerInterface.LOGGING_ON) {
							PipeJam3.logging = new LoggingServerInterface(LoggingServerInterface.SETUP_KEY_FRIENDS_AND_FAMILY_BETA, PipeJam3.pipeJam3.stage, LoggingServerInterface.CGS_VERIGAMES_PREFIX + playerID);
						}
						controller.setStatus(ACTIVATING_PLAYER);
						onValidationSucceeded();
						
						//get player user name for storing leader info, but don't wait for it
						getPlayerInfo();
						return; 
					}
				}
			}
			//if we make it this far, just exit
			onValidationFailed();
			pipejamCallbackFunction();
		}
		
		public function getPlayerInfo():void
		{
			sendMessage(PLAYER_INFO, playerInfoCallback);
		}
		
		public function playerInfoCallback(result:int, e:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = e.target.data;
				var jsonResponseObj:Object = JSON.parse(response);
					
				if(jsonResponseObj.username != null)
				{
					playerUserName = jsonResponseObj.username;	
				}
			}
		}
		
		public function onValidationSucceeded():void
		{
			playerLoggedIn = true; //whee
			Achievements.getAchievementsEarnedForPlayer();
			TutorialController.getTutorialController().getTutorialsCompletedByPlayer();
			controller.setStatus(VALIDATION_SUCCEEDED);
		}
		
		public function onValidationFailed():void
		{
			controller.setStatus(VALIDATION_FAILED);
			
			TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
		}
		
		public function sendMessage(type:int, callback:Function):void
		{
			var request:String;
			var method:String;
			var url:String = null;
			switch(type)
			{
				case PLAYER_INFO:
					url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/users/" + PlayerValidation.playerID +"'";
					method = URLRequestMethod.GET; 
					request = "";
					break;
				case VERIFY_SESSION:
					url = NetworkConnection.baseURL + "/verifySession";
					request = "?cookies="+encodedCookies;
					method = URLRequestMethod.POST; 
					break;
				case GET_ENCODED_COOKIES:
					url = NetworkConnection.baseURL + "/encodeCookies";
					request = "";
					method = URLRequestMethod.POST; 
					break;
			}
			
			NetworkConnection.sendMessage(callback, null, url, method, request);
		}
	}
}