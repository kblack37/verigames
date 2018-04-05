package networking;

import haxe.Constraints.Function;
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
class PlayerValidation
{
    public static var VERIFY_SESSION : Int = 1;
    public static var GET_ENCODED_COOKIES : Int = 2;
    public static var PLAYER_INFO : Int = 3;
    
    public static var playerLoggedIn : Bool = false;
    
    public static var playerID : String = "";
    public static var playerIDForTesting : String = "51e5b3460240288229000026";  //hard code one for local testing  
    public static var playerUserName : String = "";
    
    public static var LOGIN_STATUS_CHANGE : String = "login_status_change";
    
    private static var validationObject : PlayerValidation = null;
    private var pipejamCallbackFunction : Function;
    private var controller : Scene;
    private var encodedCookies : String;
    
    public static var GETTING_COOKIE : String = "Getting Cookie";
    public static var VALIDATING_SESSION : String = "Validating Session";
    public static var ACTIVATING_PLAYER : String = "Activating Player";
    public static var GETTING_PLAYER_INFO : String = "Getting Player ID";
    
    public static var VALIDATION_SUCCEEDED : String = "Player Logged In";
    public static var VALIDATION_FAILED : String = "Validation Failed";
    
    //callback:Function, request:String, type:String, data:String = null, method:String = URLRequestMethod.GET, url:String = null
    
    //callback function should check PlayerValidation.playerLoggedIn for success or not - for use in release builds
    public static function validatePlayerIsLoggedInAndActive(callback : Function, _controller : Scene) : Void
    {
        if (validationObject == null)
        {
            validationObject = new PlayerValidation();
            validationObject.controller = _controller;
        }
        
        validationObject.pipejamCallbackFunction = callback;
        validationObject.controller.setStatus(GETTING_COOKIE);
        validationObject.checkForCookie();
    }
    
    //check for session ID cookie, and if found, try to validate it
    private function checkForCookie() : Void
    {
        sendMessage(GET_ENCODED_COOKIES, cookieCallback);
    }
    
    public function cookieCallback(result : Int, event : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var cookies : String = event.target.data;
            if (cookies.indexOf("<html>") == -1 && cookies.length > 10)
            
            //not an error message or empty cookie string = {} = %7B%7D{
                
                {
                    controller.setStatus(VALIDATING_SESSION);
                    //encode cookies
                    encodedCookies = escape(cookies);
                    //if encodedCookies is double encoded, we get %25 (= encoded %) in front of encoded %7Bs, etc.
                    if (encodedCookies.indexOf("%257B") != -1)
                    {
                        encodedCookies = cookies;
                    }
                    sendMessage(VERIFY_SESSION, sessionIDValidityCallback);
                    return;
                }
            }
        }
        
        //if we make it this far, just exit
        onValidationFailed();
        pipejamCallbackFunction();
    }
    
    //callback for checking the validity of the session id
    //if the session id is valid, then get the player id and make sure they are in the RA
    public function sessionIDValidityCallback(result : Int, event : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = event.target.data;
            if (response.indexOf("<html>") == -1)
            
            //else assume auth required dialog{
                
                {
                    var jsonResponseObj : Dynamic = haxe.Json.parse(response);
                    
                    if (jsonResponseObj.userId != null)
                    {
                        playerID = jsonResponseObj.userId;
                        
                        if (LoggingServerInterface.LOGGING_ON)
                        {
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
        }
        //if we make it this far, just exit
        onValidationFailed();
        pipejamCallbackFunction();
    }
    
    public function getPlayerInfo() : Void
    {
        sendMessage(PLAYER_INFO, playerInfoCallback);
    }
    
    public function playerInfoCallback(result : Int, e : flash.events.Event) : Void
    {
        if (result == NetworkConnection.EVENT_COMPLETE)
        {
            var response : String = e.target.data;
            var jsonResponseObj : Dynamic = haxe.Json.parse(response);
            
            if (jsonResponseObj.username != null)
            {
                playerUserName = jsonResponseObj.username;
            }
        }
    }
    
    public function onValidationSucceeded() : Void
    {
        playerLoggedIn = true;  //whee  
        Achievements.getAchievementsEarnedForPlayer();
        TutorialController.getTutorialController().getTutorialsCompletedByPlayer();
        controller.setStatus(VALIDATION_SUCCEEDED);
    }
    
    public function onValidationFailed() : Void
    {
        controller.setStatus(VALIDATION_FAILED);
        
        TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
    }
    
    public function sendMessage(type : Int, callback : Function) : Void
    {
        var request : String;
        var method : String;
        var url : String = null;
        switch (type)
        {
            case PLAYER_INFO:
                url = NetworkConnection.productionInterop + "?function=passURL2&data_id='/api/users/" + PlayerValidation.playerID + "'";
                method = URLRequestMethod.GET;
                request = "";
            case VERIFY_SESSION:
                url = NetworkConnection.baseURL + "/verifySession";
                request = "?cookies=" + encodedCookies;
                method = URLRequestMethod.POST;
            case GET_ENCODED_COOKIES:
                url = NetworkConnection.baseURL + "/encodeCookies";
                request = "";
                method = URLRequestMethod.POST;
        }
        
        NetworkConnection.sendMessage(callback, null, url, method, request);
    }

    public function new()
    {
    }
}
