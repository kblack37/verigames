package networking
{
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	
	import events.MenuEvent;
	
	import scenes.game.display.World;
	
	public class Achievements
	{
		public static var ADD_ACHIEVEMENT:int = 0;
		public static var GET_ACHIEVEMENTS:int = 1;
		
		public static var CHECK_SCORE:String = "check_score";
		
		/*
		to add an achievement:
		Run this from the command line to enter an achievement into the verigame system:
		
			curl -X POST -H "Content-Type: application/json" -H "Authorization:Bearer authtoken" -d '{"name" : "Test123", "type":"AWARD",
			"description" : "some description", gameId : 1}' http://api.paradox.verigames.com/api/achievement
		
		authtoken - needs to be an authorization token supplied from a run of game. to get one, build game with RELEASE_BUILD=true (production or staging, 
			depending on what you want), debug the game, log in to verigames, steal the 'code=number' end of the redirected url, add it to
			url for your debug version, debug that, and look for the console line:
				{"response": "authtoken"}
		
		Get the ID, and create a new ID and STRING pair, using the ID returned from the above call.
		
		Add a new set to checkAchievements at the bottom of this file. 
		
		Call that routine where appropriate.
		
		To list all current achievements:
		curl -X GET -H "Authorization:Bearer authtoken" "http://api.paradox.verigames.com/api/achievements
		
		To delete an achievement:
			curl -X DELETE -H "Authorization:Bearer authtoken" -F 'id=51c6dfe85042b6e7a5000027' http://localhost:3000/api/achievement
		
		*/
		
		public static var TUTORIAL_FINISHED_ID:String = "54c96d07677ea4b705d666a3";
		public static var TUTORIAL_FINISHED_STRING:String = "Achievement: You've Finished All the Tutorials!";

		public static var SCORED_50_ID:String = "54c92bf8677ea4b705d665a5";
		public static var SCORED_50_STRING:String = "Achievement: You've scored 50 points on one level!";
		
		public static var SCORED_250_ID:String = "54c96cb0677ea4b705d666a1";
		public static var SCORED_250_STRING:String = "Achievement: You've scored 250 on one level!";
		
		public static var SCORED_1000_ID:String = "54c96cd4677ea4b705d666a2";
		public static var SCORED_1000_STRING:String = "Achievement: You've scored 1000 on one level!";

		public static var BEAT_THE_TARGET_ID:String = "54c92def677ea4b705d665c0";
		public static var BEAT_THE_TARGET_STRING:String = "Achievement: You beat the target score!";

		
		public var m_id:String;
		public var m_message:String;
		
		static protected var currentAchievementList:Dictionary = new Dictionary();
		
		public static function getAchievementsEarnedForPlayer():void
		{
			var newAchievement:Achievements = new Achievements();
			newAchievement.sendMessage(GET_ACHIEVEMENTS, getAchievements);
		}
		
		protected static function getAchievements(result:int, e:Event):void
		{
			if(result != NetworkConnection.EVENT_ERROR)
			{
				var achievementObject:Object = JSON.parse(e.target.data);
				currentAchievementList = new Dictionary;
				for each(var achievement:Object in achievementObject.playerAchievements)
				{
					currentAchievementList[achievement.achievementId] = achievement;
				}
			}
		}
		
		public static function addAchievement(type:String, message:String):void
		{
			var newAchievement:Achievements = new Achievements(type, message);
			if(currentAchievementList == null)
				currentAchievementList = new Dictionary;
			currentAchievementList[type] = newAchievement;
			newAchievement.post();
		}
		
		static public function isAchievementNew(achievementNumber:String):Boolean
		{
			if(currentAchievementList && (currentAchievementList[achievementNumber] != null))
				return false;
			else
				return true;
		}
		
		public function Achievements(id:String = null, message:String = null):void
		{
			m_id = id;
			m_message = message;
		}
		
		public function post():void
		{
			sendMessage(ADD_ACHIEVEMENT, postMessage);
		}
		
		protected function postMessage(result:int, e:Event):void
		{
			if(World.m_world)
				World.m_world.dispatchEvent(new MenuEvent(MenuEvent.ACHIEVEMENT_ADDED, this));
		}
		
		public function sendMessage(type:int, callback:Function):void
		{
			var request:String;
			var data:String = null;
			var method:String;
			var url:String = null;
			
			
			switch(type)
			{
				case GET_ACHIEVEMENTS:
					url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/achievements/search/player?playerId=" + PlayerValidation.playerID +"'&data2='" + PlayerValidation.accessToken +"'";
					break;
				case ADD_ACHIEVEMENT:
					url = NetworkConnection.productionInterop + "?function=jsonPOST&data_id='/api/achievement/assign'&data2='"+ PlayerValidation.accessToken + "'";
					var dataObj:Object = new Object;
					dataObj.playerId = PlayerValidation.playerID;
					dataObj.gameId = PipeJam3.GAME_ID;
					dataObj.achievementId = m_id;
					dataObj.earnedOn = (new Date()).time;
					
					data = JSON.stringify(dataObj);

					method = URLRequestMethod.POST; 
					break;
			}
			
			NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
		}
		
		public static function checkForFinishedTutorialAchievement():void
		{
			var nextLevelQID:int = TutorialController.getTutorialController().getNextUnplayedTutorial();
			if(nextLevelQID == 0)
				Achievements.checkAchievements(Achievements.TUTORIAL_FINISHED_ID);
			
		}
		
		//checks to see if we should award an achievement for the type, and if so, award it
		public static function checkAchievements(type:String, value:int = 0):Boolean
		{
			if(PlayerValidation.accessGranted() != true)
				return false;
			
			if(type == CHECK_SCORE)
			{
				if(value >= 50)
				{
					if(isAchievementNew(SCORED_50_ID))
					{
						addAchievement(SCORED_50_ID, SCORED_50_STRING);
						return true;
					}
				}
				if(value >= 250)
				{
					if(isAchievementNew(SCORED_250_ID))
					{
						addAchievement(SCORED_250_ID, SCORED_250_STRING);
						return true;
					}
				}
				if(value >= 1000)
				{
					if(isAchievementNew(SCORED_1000_ID))
					{
						addAchievement(SCORED_1000_ID, SCORED_1000_STRING);
						return true;
					}
				}
			}
			else if (type == BEAT_THE_TARGET_ID)
			{
				if(isAchievementNew(BEAT_THE_TARGET_ID))
				{
					addAchievement(BEAT_THE_TARGET_ID, BEAT_THE_TARGET_STRING);
					return true;
				}
			}
			else if (type == TUTORIAL_FINISHED_ID)
			{
				if(isAchievementNew(TUTORIAL_FINISHED_ID))
				{
					addAchievement(TUTORIAL_FINISHED_ID, TUTORIAL_FINISHED_STRING);
					return true;
				}
			}
			
			return false;
			
		}
	}
}