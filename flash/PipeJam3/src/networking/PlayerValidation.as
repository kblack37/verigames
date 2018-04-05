package networking
{
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	
	import scenes.game.display.World;
	
	import utils.XMath;

	//the steps are: 
	//	get the cookie with the express.sid value
	//  send that to validateSession, to see if it's still a valid session id
	//	if it is, you will get the player ID number, else null

	public class PlayerValidation
	{
		public static var GET_ACCESS_TOKEN:int = 1;
		public static var GET_PLAYER_ID:int = 2;
		public static var GET_PLAYER_INFO:int = 3;
		public static var GET_PLAYER_ACTIVITY:int = 4;
		public static var SET_PLAYER_ACTIVITY:int = 5;
		
		public static var AuthorizationAttempted:Boolean = false;
		public static var accessToken:String = null;
		
		public static var playerID:String = "";
		public static var playerActivity:Object;
		public static var playerIDForTesting:String = "51e5b3460240288229000026"; //hard code one for local testing
		public static var userNames:Dictionary = new Dictionary;
		public static var outstandingUserNamesRequests:int = 0;
		
		public static var currentActivityLevel:int = 1;
		
		static public var validationObject:PlayerValidation = new PlayerValidation;
		
		static public var production_authURL:String = "http://oauth.verigames.com/oauth2/authorize";
		static public var staging_authURL:String = "http://oauth.verigames.org/oauth2/authorize";
		static public var production_redirect_uri:String ="http://paradox.verigames.com/game/Paradox.html";
		static public var staging_redirect_uri:String ="http://paradox.verigames.org/game/Paradox.html";
		static public var staging_client_id:String = "54b97ebee0da42ff17b927c5";
		static public var production_client_id:String = "551b0d8e998171ae18cd94ac";
		static public var production_oauthURL:String = "http://oauth.verigames.com/oauth2/token";
		static public var staging_oauthURL:String = "http://oauth.verigames.org/oauth2/token";
		
		public static var playerInfoQueue:Array = new Array;
		
		public static function initiateAccessTokenAccess(accessCode:String):void
		{
			validationObject.getAccessToken(accessCode);
		}
		
		public function getAccessToken(accessCode:String):void
		{
			AuthorizationAttempted = true;
			
			//this call is missing the client secret, which is added at the server level.
			var obj:Object = new Object;
			obj.code = accessCode;
			if(PipeJam3.PRODUCTION_BUILD)
			{
				obj.client_id = production_client_id;
				obj.redirect_uri = production_redirect_uri;
			}
			else
			{
				obj.client_id = staging_client_id;
				obj.redirect_uri = staging_redirect_uri;
			}
			obj.grant_type = "authorization_code";
			var objStr:String = JSON.stringify(obj);
			trace(objStr);
			sendMessage(GET_ACCESS_TOKEN, tokenCallback, objStr);
		}
		
		public function tokenCallback(result:int, e:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = e.target.data;
				var jsonResponseObj:Object = JSON.parse(response);
				
				if(jsonResponseObj.response != null)
				{
					accessToken = jsonResponseObj.response;
					trace("accessToken", accessToken);
					getCurrentPlayerID(accessToken);
				}
			}
		}
		
		public function getCurrentPlayerID(accessToken:String):void
		{
			sendMessage(GET_PLAYER_ID, getCurrentPlayerIDCallback, accessToken);
		}
		
		private function getCurrentPlayerIDCallback(result:int, e:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = e.target.data;
				var jsonResponseObj:Object = JSON.parse(response);
				
				if(jsonResponseObj.userId != null)
				{
					playerID = jsonResponseObj.userId;
					playerInfoQueue.push(playerID);
					getPlayerInfo();
					getPlayerActivityInfo();
					PipeJam3.logging.addPlayerID(playerID);
					Achievements.checkForFinishedTutorialAchievement();
					Achievements.getAchievementsEarnedForPlayer();
				}
				else
					playerID = "rand" + XMath.randomInt(0, 100000);
			}
		}
		
		static public function accessGranted():Boolean
		{
			return AuthorizationAttempted && accessToken != null && accessToken != "denied";
		}
		
		public function getPlayerInfo():void
		{
			if(!accessToken) //can't look anyone up without this. This method will be called at least once after obtaining token.
				return;
			
			var temp:Dictionary = userNames;
			
			while(playerInfoQueue.length > 0)
			{
				var nextPlayer:String = playerInfoQueue.pop();
				if(userNames[nextPlayer] == null)
					sendMessage(GET_PLAYER_INFO, playerInfoCallback, nextPlayer);
			}
		}
		
		public function playerInfoCallback(result:int, e:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = e.target.data;
				var jsonResponseObj:Object = JSON.parse(response);
					
				if(jsonResponseObj.username != null)
				{
					userNames[jsonResponseObj.id] = jsonResponseObj.username;
				}
			}
		}
		
		
		public function getPlayerActivityInfo():void
		{
			if(!playerID) 
				return;
			
			sendMessage(GET_PLAYER_ACTIVITY, playerActivityInfoCallback, playerID);
		}
		
		public function playerActivityInfoCallback(result:int, e:flash.events.Event):void
		{
			if(result == NetworkConnection.EVENT_COMPLETE)
			{
				var response:String = e.target.data;
				playerActivity = JSON.parse(response);
			}
		}
		
		public function setPlayerActivityInfo(scoreDiff:Number, levelID:String):void
		{
			if(!playerID) 
				return;
			if (!playerActivity)
				return;
			var score:int = scoreDiff;
			var cumScore:int = 0;
			if (playerActivity.hasOwnProperty("cummulative_score"))
			{
				cumScore = parseInt(playerActivity["cummulative_score"]);
				if (isNaN(cumScore))
					cumScore = 0;
			}
			score += cumScore;
			if (isNaN(score))
				score = scoreDiff;
			playerActivity["cummulative_score"] = String(score);
			if (playerActivity.hasOwnProperty("submitted_boards"))
			{
				var currentNumSubmissions:int = parseInt(playerActivity["submitted_boards"]) + 1;
				if (isNaN(currentNumSubmissions))
					currentNumSubmissions = 1;
				playerActivity["submitted_boards"] = String(currentNumSubmissions);
			}
			else
			{
				playerActivity["submitted_boards"] = "1";
			}
			if(levelID)
			{
				var completedBoards:Array = playerActivity["completed_boards"];
				if(!completedBoards)
					completedBoards = new Array;
				if(completedBoards.indexOf(levelID) == -1)
					completedBoards.push(levelID);
				playerActivity["completed_boards"] = completedBoards;
				if(GameFileHandler.levelPlayedDict)
					GameFileHandler.levelPlayedDict[levelID] = 1;
			}
			var info:String = JSON.stringify(playerActivity);
			sendMessage(SET_PLAYER_ACTIVITY, null, info);
		}
		
		public static function getUserName(playerID:String, defaultNumber:int):String
		{
			if(userNames[playerID] != null)
				return userNames[playerID];
			else
				return 'Player' + defaultNumber;
		}
		
		public function sendMessage(type:int, callback:Function, data:String = null):void
		{
			var request:String = "";
			var method:String;
			var url:String = null;
			switch(type)
			{
				case GET_ACCESS_TOKEN: //don't call the function 'getAccessToken', as that's too explicit
					url = NetworkConnection.productionInterop + "?function=reportData&data_id='/token'&data2='" + data +"'";
					method = URLRequestMethod.GET; 
					break;
				case GET_PLAYER_ID:
					url = NetworkConnection.productionInterop + "?function=getPlayerIDPOST&data_id='/validate'&data2='" + PlayerValidation.accessToken +"'";
					method = URLRequestMethod.POST; 
					break;
				case GET_PLAYER_INFO:
					url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/users/" + data +"'&data2='" + PlayerValidation.accessToken +"'";
					method = URLRequestMethod.GET; 
					request = "authorize";
					break;
				case GET_PLAYER_ACTIVITY:
					url = NetworkConnection.productionInterop + "?function=getPlayerActivityInfo&data_id="+ data;
					method = URLRequestMethod.GET; 
					break;
				case SET_PLAYER_ACTIVITY:
					url = NetworkConnection.productionInterop + "?function=setPlayerActivityInfoPOST&data_id='/foo'";
					method = URLRequestMethod.POST; 
					break;

			}
			
			NetworkConnection.sendMessage(callback, data, url, method, request);
		}
	}
}