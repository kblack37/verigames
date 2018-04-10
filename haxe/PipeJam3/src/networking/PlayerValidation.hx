package networking;

import haxe.Constraints.Function;
import flash.events.Event;
import flash.net.URLRequestMethod;
import flash.utils.Dictionary;
import scenes.game.display.World;
import utils.XMath;

//the steps are:
//	get the cookie with the express.sid value
//  send that to validateSession, to see if it's still a valid session id
//	if it is, you will get the player ID number, else null
class PlayerValidation
{
    public static var GET_ACCESS_TOKEN : Int = 1;
    public static var GET_PLAYER_ID : Int = 2;
    public static var GET_PLAYER_INFO : Int = 3;
    public static var GET_PLAYER_ACTIVITY : Int = 4;
    public static var SET_PLAYER_ACTIVITY : Int = 5;
    
    public static var AuthorizationAttempted : Bool = false;
    public static var accessToken : String = null;
    
    public static var playerID : String = "";
    public static var playerActivity : Dynamic;
    public static var playerIDForTesting : String = "51e5b3460240288229000026";  //hard code one for local testing  
    public static var userNames : Dictionary = new Dictionary();
    public static var outstandingUserNamesRequests : Int = 0;
    
    public static var currentActivityLevel : Int = 1;
    
    public static var validationObject : PlayerValidation = new PlayerValidation();
    
    public static var production_authURL : String = "http://oauth.verigames.com/oauth2/authorize";
    public static var staging_authURL : String = "http://oauth.verigames.org/oauth2/authorize";
    public static var production_redirect_uri : String = "http://paradox.verigames.com/game/Paradox.html";
    public static var staging_redirect_uri : String = "http://paradox.verigames.org/game/Paradox.html";
    public static var staging_client_id : String = "54b97ebee0da42ff17b927c5";
    public static var production_client_id : String = "551b0d8e998171ae18cd94ac";
    public static var production_oauthURL : String = "http://oauth.verigames.com/oauth2/token";
    public static var staging_oauthURL : String = "http://oauth.verigames.org/oauth2/token";
    
    public static var playerInfoQueue : Array<Dynamic> = new Array<Dynamic>();
    
    public static function initiateAccessTokenAccess(accessCode : String) : Void
    {
        validationObject.getAccessToken(accessCode);
    }
    
    public function getAccessToken(accessCode : String) : Void
    {
        AuthorizationAttempted = true;
        
        //this call is missing the client secret, which is added at the server level.
        var obj : Dynamic = {};
        obj.code = accessCode;
        if (PipeJam3.PRODUCTION_BUILD)
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
        var objStr : String = haxe.Json.stringify(obj);
        trace(objStr);
        sendMessage(GET_ACCESS_TOKEN, tokenCallback, objStr);
    }
    
    public function tokenCallback(result : Int, e : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = e.target.data;
            var jsonResponseObj : Dynamic = haxe.Json.parse(response);
            
            if (jsonResponseObj.response != null)
            {
                accessToken = jsonResponseObj.response;
                trace("accessToken", accessToken);
                getCurrentPlayerID(accessToken);
            }
        }
    }
    
    public function getCurrentPlayerID(accessToken : String) : Void
    {
        sendMessage(GET_PLAYER_ID, getCurrentPlayerIDCallback, accessToken);
    }
    
    private function getCurrentPlayerIDCallback(result : Int, e : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = e.target.data;
            var jsonResponseObj : Dynamic = haxe.Json.parse(response);
            
            if (jsonResponseObj.userId != null)
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
            {
                playerID = "rand" + XMath.randomInt(0, 100000);
            }
        }
    }
    
    public static function accessGranted() : Bool
    {
        return AuthorizationAttempted && accessToken != null && accessToken != "denied";
    }
    
    public function getPlayerInfo() : Void
    {
        if (accessToken == null)
        {
			// can't look anyone up without this. This method will be called at least once after obtaining token.
            
            return;
        }
        
        var temp : Dictionary = userNames;
        
        while (playerInfoQueue.length > 0)
        {
            var nextPlayer : String = playerInfoQueue.pop();
            if (Reflect.field(userNames, nextPlayer) == null)
            {
                sendMessage(GET_PLAYER_INFO, playerInfoCallback, nextPlayer);
            }
        }
    }
    
    public function playerInfoCallback(result : Int, e : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = e.target.data;
            var jsonResponseObj : Dynamic = haxe.Json.parse(response);
            
            if (jsonResponseObj.username != null)
            {
                userNames[jsonResponseObj.id] = jsonResponseObj.username;
            }
        }
    }
    
    
    public function getPlayerActivityInfo() : Void
    {
        if (playerID == null)
        {
            return;
        }
        
        sendMessage(GET_PLAYER_ACTIVITY, playerActivityInfoCallback, playerID);
    }
    
    public function playerActivityInfoCallback(result : Int, e : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = e.target.data;
            playerActivity = haxe.Json.parse(response);
        }
    }
    
    public function setPlayerActivityInfo(scoreDiff : Float, levelID : String) : Void
    {
        if (playerID == null)
        {
            return;
        }
        if (playerActivity == null)
        {
            return;
        }
        var score : Int = as3hx.Compat.parseInt(scoreDiff);
        var cumScore : Int = 0;
        if (playerActivity.exists("cummulative_score"))
        {
            cumScore = as3hx.Compat.parseInt(Reflect.field(playerActivity, "cummulative_score"));
            if (Math.isNaN(cumScore))
            {
                cumScore = 0;
            }
        }
        score += cumScore;
        if (Math.isNaN(score))
        {
            score = as3hx.Compat.parseInt(scoreDiff);
        }
        Reflect.setField(playerActivity, "cummulative_score", Std.string(score));
        if (playerActivity.exists("submitted_boards"))
        {
            var currentNumSubmissions : Int = as3hx.Compat.parseInt(Reflect.field(playerActivity, "submitted_boards")) + 1;
            if (Math.isNaN(currentNumSubmissions))
            {
                currentNumSubmissions = 1;
            }
            Reflect.setField(playerActivity, "submitted_boards", Std.string(currentNumSubmissions));
        }
        else
        {
            Reflect.setField(playerActivity, "submitted_boards", "1");
        }
        if (levelID != null)
        {
            var completedBoards : Array<Dynamic> = Reflect.field(playerActivity, "completed_boards");
            if (completedBoards == null)
            {
                completedBoards = new Array<Dynamic>();
            }
            if (Lambda.indexOf(completedBoards, levelID) == -1)
            {
                completedBoards.push(levelID);
            }
            Reflect.setField(playerActivity, "completed_boards", completedBoards);
            if (GameFileHandler.levelPlayedDict)
            {
                GameFileHandler.levelPlayedDict[levelID] = 1;
            }
        }
        var info : String = haxe.Json.stringify(playerActivity);
        sendMessage(SET_PLAYER_ACTIVITY, null, info);
    }
    
    public static function getUserName(playerID : String, defaultNumber : Int) : String
    {
        if (Reflect.field(userNames, playerID) != null)
        {
            return Reflect.field(userNames, playerID);
        }
        else
        {
            return "Player" + defaultNumber;
        }
    }
    
    public function sendMessage(type : Int, callback : Function, data : String = null) : Void
    {
        var request : String = "";
        var method : String;
        var url : String = null;
        switch (type)
        {
            case GET_ACCESS_TOKEN:  //don't call the function 'getAccessToken', as that's too explicit  
                url = NetworkConnection.productionInterop + "?function=reportData&data_id='/token'&data2='" + data + "'";
                method = URLRequestMethod.GET;
            case GET_PLAYER_ID:
                url = NetworkConnection.productionInterop + "?function=getPlayerIDPOST&data_id='/validate'&data2='" + PlayerValidation.accessToken + "'";
                method = URLRequestMethod.POST;
            case GET_PLAYER_INFO:
                url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/users/" + data + "'&data2='" + PlayerValidation.accessToken + "'";
                method = URLRequestMethod.GET;
                request = "authorize";
            case GET_PLAYER_ACTIVITY:
                url = NetworkConnection.productionInterop + "?function=getPlayerActivityInfo&data_id=" + data;
                method = URLRequestMethod.GET;
            case SET_PLAYER_ACTIVITY:
                url = NetworkConnection.productionInterop + "?function=setPlayerActivityInfoPOST&data_id='/foo'";
                method = URLRequestMethod.POST;
        }
        
        NetworkConnection.sendMessage(callback, data, url, method, request);
    }

    public function new()
    {
    }
}
