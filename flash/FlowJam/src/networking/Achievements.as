package networking
{
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	
	import events.WidgetChangeEvent;
	import events.MenuEvent;
	
	import scenes.game.display.World;
	
	import server.LoggingServerInterface;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	
	import utils.Base64Encoder;
	import utils.XString;
	
	public class Achievements
	{
		public static var ADD_ACHIEVEMENT:int = 0;
		public static var GET_ACHIEVEMENTS:int = 1;
		
		public static var TUTORIAL_FINISHED_ID:String = "5228b505cb99a6030800002a";
		public static var TUTORIAL_FINISHED_STRING:String = "Achievement: You've Finished All the Tutorials!";

		public static var CLICKED_ONE_ID:String = "52542b720a7470c228000029";
		public static var CLICKED_ONE_STRING:String = "Achievement: You've Clicked A Widget!";

		public static var CLICKED_50_ID:String = "52542ba50a7470c22800002a";
		public static var CLICKED_50_STRING:String = "Achievement: You've clicked 50 widgets in a single session!";

		public static var CLASH_CLEARED_ID:String = "52542d5a0a7470c22800002e";
		public static var CLASH_CLEARED_STRING:String = "Achievement: You removed a jam from a level!";

		public static var BEAT_THE_TARGET_ID:String = "52542d8a0a7470c22800002f";
		public static var BEAT_THE_TARGET_STRING:String = "Achievement: You beat the target score!";

		public static var USED_A_LAYOUT_ID:String = "52542c860a7470c22800002d";
		public static var USED_A_LAYOUT_STRING:String = "Achievement: You used someone else's layout when reporting a level!";
		
		public static var SHARED_A_LAYOUT_ID:String = "52542c360a7470c22800002c";
		public static var SHARED_A_LAYOUT_STRING:String = "Achievement: You've shared a layout!";
		
		public static var SHARED_WITH_GROUP_ID:String = "52542dab0a7470c228000030";
		public static var SHARED_WITH_GROUP_STRING:String = "Achievement: You shared a level with your group!";

		public static var REPORTED_A_LEVEL_ID:String = "52542bec0a7470c22800002b";
		public static var REPORTED_A_LEVEL_STRING:String = "Achievement: You've reported a level!";

		
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
			var achievementObject:Object = JSON.parse(e.target.data);
			currentAchievementList = new Dictionary;
			for each(var achievement:Object in achievementObject.playerAchievements)
			{
				currentAchievementList[achievement.achievementId] = achievement;
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
					url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/achievements/search/player?playerId=" + PlayerValidation.playerID +"'";
					break;
				case ADD_ACHIEVEMENT:
					url = NetworkConnection.productionInterop + "?function=passURLPOST2&data_id='/api/achievement/assign'";
					var dataObj:Object = new Object;
					dataObj.playerId = PlayerValidation.playerID;
					dataObj.gameId = PipeJam3.GAME_ID;
					dataObj.achievementId = m_id;
					dataObj.earnedOn = (new Date()).time;
					
					data = JSON.stringify(dataObj);
					//var enc:Base64Encoder = Base64Encoder.getEncoder();
					//enc.encode(data);
					//data = enc.toString();
					method = URLRequestMethod.POST; 
					break;
			}
			
			NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
		}
		
		//checks to see if we should award an achievement for the type, and if so, award it
		public static function checkAchievements(type:String, value:int):void
		{
			if(PlayerValidation.playerLoggedIn != true)
				return;
			
			if(type == WidgetChangeEvent.LEVEL_WIDGET_CHANGED)
			{
				if(value == 1)
				{
					if(isAchievementNew(CLICKED_ONE_ID))
						addAchievement(CLICKED_ONE_ID, CLICKED_ONE_STRING);
				}
				else if(value == 50)
				{
					if(isAchievementNew(CLICKED_50_ID))
						addAchievement(CLICKED_50_ID, CLICKED_50_STRING);
				}
			}
			else if (type == CLASH_CLEARED_ID)
			{
				if(isAchievementNew(CLASH_CLEARED_ID))
					addAchievement(CLASH_CLEARED_ID, CLASH_CLEARED_STRING);
			}
			else if (type == BEAT_THE_TARGET_ID)
			{
				if(isAchievementNew(BEAT_THE_TARGET_ID))
					addAchievement(BEAT_THE_TARGET_ID, BEAT_THE_TARGET_STRING);
			}
			else if (type == MenuEvent.LEVEL_SUBMITTED)
			{
				if(isAchievementNew(REPORTED_A_LEVEL_ID))
					addAchievement(REPORTED_A_LEVEL_ID, REPORTED_A_LEVEL_STRING);
			}
			else if (type == MenuEvent.SET_NEW_LAYOUT)
			{
				if(isAchievementNew(USED_A_LAYOUT_ID))
					addAchievement(USED_A_LAYOUT_ID, USED_A_LAYOUT_STRING);
			}
			else if (type == MenuEvent.SAVE_LAYOUT)
			{
				if(isAchievementNew(SHARED_A_LAYOUT_ID))
					addAchievement(SHARED_A_LAYOUT_ID, SHARED_A_LAYOUT_STRING);
			}
			else if (type == SHARED_WITH_GROUP_ID)
			{
				if(isAchievementNew(SHARED_WITH_GROUP_ID))
					addAchievement(SHARED_WITH_GROUP_ID, SHARED_WITH_GROUP_STRING);
			}
			
		}
	}
}