package networking;

import haxe.Constraints.Function;
import flash.events.Event;
import flash.net.URLRequestMethod;
import flash.utils.Dictionary;
import events.MenuEvent;
import scenes.game.display.World;

class Achievements
{
    public static var add_achievement : Int = 0;
    public static var get_achievements : Int = 1;
    
    public static var CHECK_SCORE : String = "check_score";
    
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
    
    public static var TUTORIAL_FINISHED_ID : String = "54c96d07677ea4b705d666a3";
    public static var TUTORIAL_FINISHED_STRING : String = "Achievement: You've Finished All the Tutorials!";
    
    public static var SCORED_50_ID : String = "54c92bf8677ea4b705d665a5";
    public static var SCORED_50_STRING : String = "Achievement: You've scored 50 points on one level!";
    
    public static var SCORED_250_ID : String = "54c96cb0677ea4b705d666a1";
    public static var SCORED_250_STRING : String = "Achievement: You've scored 250 on one level!";
    
    public static var SCORED_1000_ID : String = "54c96cd4677ea4b705d666a2";
    public static var SCORED_1000_STRING : String = "Achievement: You've scored 1000 on one level!";
    
    public static var BEAT_THE_TARGET_ID : String = "54c92def677ea4b705d665c0";
    public static var BEAT_THE_TARGET_STRING : String = "Achievement: You beat the target score!";
    
    
    public var m_id : String;
    public var m_message : String;
    
    private static var currentAchievementList : Dynamic = {};
    
    public static function getAchievementsEarnedForPlayer() : Void
    {
        var newAchievement : Achievements = new Achievements();
        newAchievement.sendMessage(get_achievements, getAchievements);
    }
    
    private static function getAchievements(result : Int, e : Event) : Void
    {
        if (result != NetworkConnection.EVENT_ERROR)
        {
            var achievementObject : Dynamic = haxe.Json.parse(Reflect.field(e.target, "data"));
			var playerAchievements : Array<Dynamic> = achievementObject.playerAchievements;
            currentAchievementList = {};
            for (achievement in playerAchievements)
            {
                Reflect.setField(currentAchievementList, achievement.achievementId, achievement);
            }
        }
    }
    
    public static function addAchievement(type : String, message : String) : Void
    {
        var newAchievement : Achievements = new Achievements(type, message);
        if (currentAchievementList == null)
        {
            currentAchievementList = new Dictionary();
        }
        Reflect.setField(currentAchievementList, type, newAchievement);
        newAchievement.post();
    }
    
    public static function isAchievementNew(achievementNumber : String) : Bool
    {
        if (currentAchievementList != null && (Reflect.field(currentAchievementList, achievementNumber) != null))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public function new(id : String = null, message : String = null)
    {
        m_id = id;
        m_message = message;
    }
    
    public function post() : Void
    {
        sendMessage(add_achievement, postMessage);
    }
    
    private function postMessage(result : Int, e : Event) : Void
    {
        if (World.m_world)
        {
            World.m_world.dispatchEvent(new MenuEvent(MenuEvent.ACHIEVEMENT_ADDED, this));
        }
    }
    
    public function sendMessage(type : Int, callback : Function) : Void
    {
        var request : String;
        var data : String = null;
        var method : String;
        var url : String = null;
        
        
        switch (type)
        {
            case get_achievements:
                url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/achievements/search/player?playerId=" + PlayerValidation.playerID + "'&data2='" + PlayerValidation.accessToken + "'";
            case add_achievement:
                url = NetworkConnection.productionInterop + "?function=jsonPOST&data_id='/api/achievement/assign'&data2='" + PlayerValidation.accessToken + "'";
                var dataObj : Dynamic = {};
                dataObj.playerId = PlayerValidation.playerID;
                dataObj.gameId = PipeJam3.GAME_ID;
                dataObj.achievementId = m_id;
                dataObj.earnedOn = DateTools.format(Date.now(), "%F");
                
                data = haxe.Json.stringify(dataObj);
                
                method = URLRequestMethod.POST;
        }
        
        NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
    }
    
    public static function checkForFinishedTutorialAchievement() : Void
    {
        var nextLevelQID : Int = TutorialController.getTutorialController().getNextUnplayedTutorial();
        if (nextLevelQID == 0)
        {
            Achievements.checkAchievements(Achievements.TUTORIAL_FINISHED_ID);
        }
    }
    
    //checks to see if we should award an achievement for the type, and if so, award it
    public static function checkAchievements(type : String, value : Int = 0) : Bool
    {
        if (PlayerValidation.accessGranted() != true)
        {
            return false;
        }
        
        if (type == CHECK_SCORE)
        {
            if (value >= 50)
            {
                if (isAchievementNew(SCORED_50_ID))
                {
                    addAchievement(SCORED_50_ID, SCORED_50_STRING);
                    return true;
                }
            }
            if (value >= 250)
            {
                if (isAchievementNew(SCORED_250_ID))
                {
                    addAchievement(SCORED_250_ID, SCORED_250_STRING);
                    return true;
                }
            }
            if (value >= 1000)
            {
                if (isAchievementNew(SCORED_1000_ID))
                {
                    addAchievement(SCORED_1000_ID, SCORED_1000_STRING);
                    return true;
                }
            }
        }
        else if (type == BEAT_THE_TARGET_ID)
        {
            if (isAchievementNew(BEAT_THE_TARGET_ID))
            {
                addAchievement(BEAT_THE_TARGET_ID, BEAT_THE_TARGET_STRING);
                return true;
            }
        }
        else if (type == TUTORIAL_FINISHED_ID)
        {
            if (isAchievementNew(TUTORIAL_FINISHED_ID))
            {
                addAchievement(TUTORIAL_FINISHED_ID, TUTORIAL_FINISHED_STRING);
                return true;
            }
        }
        
        return false;
    }
}
