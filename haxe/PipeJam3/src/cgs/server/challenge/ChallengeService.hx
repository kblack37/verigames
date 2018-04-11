package cgs.server.challenge;

import haxe.Constraints.Function;
import cgs.server.CgsService;
import cgs.server.data.UserData;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.ICGSServerProps.LoggingVersion;
import cgs.server.logging.ICGSServerProps.ServerType;
import cgs.server.logging.messages.Message;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.logging.requests.ServiceRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.ResponseStatus;
import cgs.user.CgsUser;
import cgs.user.ICgsUser;

class ChallengeService extends CgsService
{
    public var challengeId(never, set) : Int;
    private var challengeMessage(get, never) : Message;

    //Reference to the server that has user data.
    private var _cgsServer : ICgsServerApi;
    
    private var _challengeId : Int;
    
    private var _cgsUser : ICgsUser;
    
    public function new(requestHandler : IUrlRequestHandler,
            cgsUser : CgsUser,
            challengeId : Int,
            serverTag : String,
            version : Int = CURRENT_VERSION,
            useHttps : Bool = false)
    {
        super(requestHandler, serverTag, version, useHttps);
        
        _challengeId = challengeId;
        registerUser(cgsUser);
    }
    
    private function registerUser(user : CgsUser) : Void
    {
        _cgsUser = user;
        _cgsServer = user.server;
    }
    
    private function set_challengeId(value : Int) : Int
    {
        _challengeId = value;
        return value;
    }
    
    /**
		 * @param callback function called when the server responds. Function
		 * should have the following signature (started:Boolean, serverSuccess:Boolean):void
		 */
    public function hasChallengeStarted(callback : Function) : Void
    {
        checkChallengeDetails(function(data : Dynamic, success : Bool) : Void
                {
                    var started : Bool = false;
                    if (data != null)
                    {
                        if (Reflect.hasField(data, "r_data"))
                        {
                            var challengeData : Dynamic = data.r_data;
                            if (Reflect.hasField(challengeData, "started"))
                            {
                                started = data.r_data.started == 1;
                            }
                        }
                    }
                    callback(started, success);
                });
    }
    
    /**
     * Register a member for a challenge. This is used for users who are not students.
     */
    public function registerMember(gradeLevel : Int, callback : Function) : Void
    {
        var message : Message = _cgsServer.message;
        message.addProperty("challenge_id", _challengeId);
        message.addProperty("teacher_uid", "0");
        message.addProperty("grade", gradeLevel);
        
        var request : ServiceRequest = new ServiceRequest(
        REGISTER_MEMBER, message, _cgsServer.getCurrentGameServerData(), 
        function(responseStatus : CgsResponseStatus) : Void
        {
            if (callback != null)
            {
                callback(responseStatus);
            }
        });
        
        if (!_cgsUser.isUidValid)
        {
            request.addRequestDependency(_cgsUser.uidRequestDependency);
            request.addReadyHandler(function(request : ServiceRequest) : Void
                    {
                        request.injectUid();
                    });
        }
        else
        {
            request.injectUid();
        }
        
        request.addParameter("challenge_id", Std.string(_challengeId));
        
        request.requestType = ServerRequest.POST;
        request.generalUrl = url;
        _cgsServer.sendRequest(request);
    }
    
    /**
		 * @param callback function called when the server responds. Function
		 * should have the following signature (ended:Boolean, serverSuccess:Boolean):void
		 */
    public function hasChallengeEnded(callback : Function) : Void
    {
        checkChallengeDetails(function(data : Dynamic, success : Bool) : Void
                {
                    var ended : Bool = true;
                    if (data != null)
                    {
                        if (Reflect.hasField(data, "r_data"))
                        {
                            var challengeData : Dynamic = data.r_data;
                            if (Reflect.hasField(challengeData, "ended"))
                            {
                                ended = data.ended == 1;
                            }
                        }
                    }
                    callback(ended, success);
                });
    }
    
    private function checkChallengeDetails(dataHandler : Function) : Void
    {
        var message : Message = _cgsServer.message;
        message.addProperty("challenge_id", _challengeId);
        
        var request : ServiceRequest = new ServiceRequest(RETRIEVE_DETAILS, 
        message, _cgsServer.getCurrentGameServerData(), 
        function(responseStatus : CgsResponseStatus) : Void
        {
            if (dataHandler != null)
            {
                var data : Dynamic = responseStatus.data;
                dataHandler(data, responseStatus.success);
            }
        });
        
        request.requestType = ServerRequest.GET;
        request.generalUrl = url;
        _cgsServer.sendRequest(request);
    }
    
    //
    // New challenge logging.
    //
    
    public function saveUserEquationWithPlaytime(
            time : Int, solveStatus : Int = 1, callback : Function = null) : Void
    {
        var message : Message = challengeMessage;
        message.addProperty("playtime", time);
        message.addProperty("status", solveStatus);
        
        //Send the message to the server.
        handleSimpleRequest(SAVE_EQUATION_WITH_TIME, message, callback);
    }
    
    public function saveMasteryEquation(
            time : Int, masteryStatus : Int = 1,
            solveStatus : Int = 1, callback : Function = null) : Void
    {
        var message : Message = challengeMessage;
        message.addProperty("playtime", time);
        message.addProperty("status", solveStatus);
        message.addProperty("mastery", masteryStatus);
        
        //Send the message to the server.
        handleSimpleRequest(SAVE_MASTERY_EQUATION, message, callback);
    }
    
    //
    // Old challenge logging.
    //
    
    /**
		 * Update the total active playtime for the user.
		 *
		 * @param time the current total playtime for user in seconds.
		 * @param dqid the quest that this playtime occured within.
		 * @callback callback function to be called when server has responded,
		 * function should have the following signature callback(failed:Boolean):void.
		 */
    public function updateUserPlaytime(time : Int, callback : Function = null) : Void
    {
        var message : Message = challengeMessage;
        message.addProperty("playtime", time);
        
        //Send the message to the server.
        handleSimpleRequest(SAVE_ACTIVE_TIME, message, callback);
    }
    
    /**
		 * Save a solved user equation.
		 *
		 * @param dqid the dynamic quest id for which the equation was solved.
		 * @param solveStatus the status of the solved equation. This could be
		 * used to save the stars earned on the level.
		 * @param callback function to be called when server has responded,
		 * function should have the following signature callback(failed:Boolean):void.
		 */
    public function saveUserEquation(solveStatus : Int = 1, callback : Function = null) : Void
    {
        var message : Message = challengeMessage;
        
        message.addProperty("status", solveStatus);
        
        //Send the message to the server.
        handleSimpleRequest(SAVE_EQUATION, message, callback);
    }
    
    /**
		 * Save user mastery for the user.
		 * 
		 * @param callback
 		 * 		Callback when the request has finished, accepts a single boolean param that is true
 		 * 		if the request failed and false if it succeeded
 		 * @param masteryStatus
 		 * 		This is a special value to differentiate between different types of mastery.
 		 * 		For example, we might have defined a mastery problem as being easy or hard which
 		 * 		requires keeping track of two different layers of mastery. Easy might be 1 and hard
		 * 		might be 2 in that case.
		 */
    public function updateUserMastery(callback : Function = null, masteryStatus : Int = 1) : Void
    {
        var message : Message = challengeMessage;
        message.addProperty("mastery", masteryStatus);
        
        //Send the message to the server.
        handleSimpleRequest(UPDATE_MASTERY, message, callback);
    }
    
    public function handleSimpleRequest(
            method : String, message : Message, callback : Function = null) : Void
    {
        var request : ServiceRequest = new ServiceRequest(method, 
        message, _cgsServer.getCurrentGameServerData(), 
        function(responseStatus : ResponseStatus) : Void
        {
            if (callback != null)
            {
                callback(responseStatus.failed);
            }
        });
        
        request.addParameter("challenge_id", Std.string(_challengeId));
        
        //Handle the dqid for the message.
        if (_cgsUser.isDqidValid())
        {
            var dqid : String = _cgsUser.getDqid();
            
            //Get the current dqid or dqid request id.
            message.addProperty("dqid", dqid);
            message.addProperty("quest_id", _cgsUser.getQuestId());
        }
        else
        {
            _cgsUser.addDqidCallback(function handleDqid(dqid : String) : Void
                    {
                        message.addProperty("dqid", dqid);
                    });
            request.addDependencyById(_cgsUser.getDqidRequestId(), true);
        }
        
        if (!_cgsUser.isUidValid)
        {
            request.addRequestDependency(_cgsUser.uidRequestDependency);
            request.addReadyHandler(function(request : ServiceRequest) : Void
                    {
                        request.injectUid();
                    });
        }
        else
        {
            request.injectUid();
        }
        
        request.requestType = ServerRequest.POST;
        request.generalUrl = url;
        _cgsServer.sendRequest(request);
    }
    
    private function get_challengeMessage() : Message
    {
        var message : Message = _cgsServer.message;
        message.injectClientTimeStamp();
        message.injectParams();
        
        var userData : UserData = _cgsServer.userData;
        
        var teacherUid : String = null;
        if (userData != null)
        {
            teacherUid = userData.teacherUid;
        }
        if (teacherUid == null)
        {
            teacherUid = "0";
        }
        
        message.addProperty("teacher_uid", teacherUid);
        message.addProperty("challenge_id", _challengeId);
        
        return message;
    }
    
    //
    // Service url handling.
    //
    
    //Get the url used for the service.
    override private function getUrl(server : String, version : Int) : String
    {
        var domain : String = DEV_URL_DOMAIN;
        if (server == PRODUCTION_SERVER)
        {
            domain = ((this.useHttps)) ? URL_DOMAIN_HTTPS : URL_DOMAIN_HTTP;
        }
        else
        {
            if (server == LOCAL_SERVER)
            {
                domain = "localhost:10051";
            }
        }
        
        var url : String = CGSServerConstants.getHttpPrefix(this.useHttps) + domain + URL_PATH;
        if (version == CURRENT_VERSION)
        {
            url += CGSServerConstants.CURRENT_VERSION;
        }
        else
        {
            if (version == VERSION1)
            {
                url += CGSServerConstants.VERSION_1;
            }
            else
            {
                if (version == VERSION2)
                {
                    url += CGSServerConstants.VERSION_2;
                }
                else
                {
                    if (version == VERSION_DEV)
                    {
                        url += CGSServerConstants.VERSION_0;
                    }
                }
            }
        }
        
        return url + URL_PHP;
    }
    
    public static inline var URL_DOMAIN_HTTP : String = "prd.integration.centerforgamescience.com";
    public static inline var URL_DOMAIN_HTTPS : String = "integration.centerforgamescience.org";
    public static inline var URL_PATH : String = "/cgs/apps/integration/";
    public static inline var URL_PHP : String = "/index.php/";
    
    public static inline var DEV_URL_DOMAIN : String = "dev.integration.centerforgamescience.com";
    
    //
    // Service methods.
    
    public static inline var UPDATE_MASTERY : String = "challenge/updatemastery";
    public static inline var SAVE_ACTIVE_TIME : String = "challenge/saveactivetime";
    public static inline var SAVE_EQUATION : String = "challenge/saveequation";
    public static inline var SAVE_EQUATION_WITH_TIME : String = "challenge/saveequationwtime";
    public static inline var SAVE_MASTERY_EQUATION : String = "challenge/savemasteryequation";
    private static inline var REGISTER_MEMBER : String = "challenge/register";
    
    public static inline var RETRIEVE_DETAILS : String = "challenge/retrievebyid";
}
