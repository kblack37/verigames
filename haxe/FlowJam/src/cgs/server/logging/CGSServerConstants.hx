package cgs.server.logging;

import cgs.server.logging.ICGSServerProps;
import cgs.server.logging.ICGSServerProps.ServerType;
import cgs.server.logging.ICGSServerProps.LoggingVersion;


/**
 * Contains all URL's, methods and constants for the game.
 */
class CGSServerConstants
{
    public static var TIME_URL_LOCAL(get, never) : String;
    public static var LOCAL_URL(get, never) : String;
    public static var INT_LOCAL_URL(get, never) : String;

    /**
     * Exposed so the port for local testing can be changed without recompiling the entire library.
     */
    public static var LOGGING_LOCAL_PORT : Int = 10050;
    public static var INTEGRATION_LOCAL_PORT : Int = 10051;
    
    public static inline var VERSION_0 : String = "dev";
    public static inline var VERSION_1 : String = "ws";
    public static inline var VERSION_2 : String = "v2";
    public static var CURRENT_VERSION : String = VERSION_2;
    
    /**
     * Get the prefix to append in front of an HTTP request.
     * 
     * To avoid mixed content errors, ensure that for any given domain the prefix is consistent
     * across all requests
     * 
     * @param useHttps
     *      true if we want a request to use https
     */
    public static function getHttpPrefix(useHttps : Bool) : String
    {
        return ((useHttps)) ? "https://" : "http://";
    }
    
    /**
     * Get the url for the given version of the server code.
     * 
     * An example return value: http://prd.ws.centerforgamescience.com/cgs/apps/games/ws/index.php/
     * 
     * @param useHttps
     *      true if should send requests as secure http
     */
    public static function GetBaseUrl(serverTag : String, useHttps : Bool, version : Int = 1) : String
    {
		var url : String;
		
        if (serverTag == LOCAL_SERVER)
        {
            url = CGSServerConstants.LOCAL_URL;
        }
        else
        {
            var domain : String = DEV_URL_DOMAIN;
            if (serverTag == PRODUCTION_SERVER)
            {
                domain = ((useHttps)) ? BASE_URL_DOMAIN_HTTPS : BASE_URL_DOMAIN_HTTP;
            }
            else
            {
                if (serverTag == STAGING_SERVER)
                {
                    domain = STAGING_URL_DOMAIN;
                }
                else
                {
                    if (serverTag == STUDY_SERVER)
                    {
                        domain = SCHOOLS_BASE_URL;
                    }
                    else
                    {
                        if (serverTag == CUSTOM_SERVER)
                        {
                            domain = CUSTOM_BASE_URL;
                        }
                    }
                }
            }
            
            url = getHttpPrefix(useHttps) + domain + BASE_URL_PATH;
            if (version == LoggingVersion.CURRENT_VERSION)
            {
                url += CURRENT_VERSION;
            }
            else
            {
                if (version == VERSION1)
                {
                    url += VERSION_1;
                }
                else
                {
                    if (version == VERSION2)
                    {
                        url += VERSION_2;
                    }
                    else
                    {
                        if (version == VERSION_DEV)
                        {
                            url += VERSION_0;
                        }
                    }
                }
            }
            url += BASE_URL_PHP;
        }
        
        return url;
    }
    
    /**
     * Get the integration url for the given version of the server code.
     * 
     * Example return value: http://prd.integration.centerforgamescience.com/cgs/apps/integration/ws/index.php/
     * 
     * @param useHttps
     *      true if should send requests as secure http
     */
    public static function GetIntegrationUrl(serverTag : String, useHttps : Bool, version : Int = 1) : String
    {
		var url : String;
		
        if (serverTag == LOCAL_SERVER)
        {
            url = CGSServerConstants.INT_LOCAL_URL;
        }
        else
        {
            var domain : String = INT_DEV_URL_DOMAIN;
            if (serverTag == PRODUCTION_SERVER)
            {
                domain = ((useHttps)) ? BASE_URL_DOMAIN_HTTPS : INT_BASE_URL_DOMAIN_HTTP;
            }
            else
            {
                if (serverTag == STAGING_SERVER)
                {
                    domain = INT_STAGING_URL_DOMAIN;
                }
                else
                {
                    if (serverTag == CUSTOM_SERVER)
                    {
                        domain = CUSTOM_INTEGRATION_BASE_URL;
                    }
                    else
                    {
                        if (serverTag == STUDY_SERVER)
                        {
                            domain = INT_BASE_URL_DOMAIN_HTTP;
                        }
                    }
                }
            }
            
            url = getHttpPrefix(useHttps) + domain + INT_BASE_URL_PATH;
            if (version == LoggingVersion.CURRENT_VERSION)
            {
                url += CURRENT_VERSION;
            }
            else
            {
                if (version == VERSION1)
                {
                    url += VERSION_1;
                }
                else
                {
                    if (version == VERSION2)
                    {
                        url += VERSION_2;
                    }
                    else
                    {
                        if (version == VERSION_DEV)
                        {
                            url += VERSION_0;
                        }
                    }
                }
            }
            
            url += INT_BASE_URL_PHP;
        }

        return url;
    }
    
    /**
     * Get the time url for the given server version and server tag.
     * 
     * @param useHttps
     *      true if should send requests as secure http
     */
    public static function GetTimeUrl(serverTag : String, useHttps : Bool, version : Int = 1) : String
    {
        var domain : String = DEV_TIME_URL_DOMAIN;
        if (serverTag ==  PRODUCTION_SERVER || serverTag == STUDY_SERVER)
        {
            domain = ((useHttps)) ? BASE_URL_DOMAIN_HTTPS : TIME_URL_DOMAIN_HTTP;
        }
        else
        {
            if (serverTag == STAGING_SERVER)
            {
                domain = STAGING_TIME_URL_DOMAIN;
            }
        }
        
        var url : String = getHttpPrefix(useHttps) + domain + TIME_URL_PATH;
        if (version == LoggingVersion.CURRENT_VERSION)
        {
            url += CURRENT_VERSION;
        }
        else
        {
            if (version == VERSION1)
            {
                url += VERSION_1;
            }
            else
            {
                if (version == VERSION2)
                {
                    url += VERSION_2;
                }
                else
                {
                    if (version == VERSION_DEV)
                    {
                        url += VERSION_0;
                    }
                }
            }
        }
        
        return url + TIME_URL_PHP;
    }
    
    public static var CUSTOM_BASE_URL : String = "prd.ws.centerforgamescience.com";
    
    /**
     * Production URL for the game. This needs to be set to proper URL for the game.
     */
    public static inline var BASE_URL_DOMAIN_HTTP : String = "prd.ws.centerforgamescience.com";
    
    /**
     * Note the domain for https for logging is the same for the integration services
     */
    public static inline var BASE_URL_DOMAIN_HTTPS : String = "integration.centerforgamescience.org";
    public static inline var BASE_URL_PATH : String = "/cgs/apps/games/";
    public static inline var BASE_URL_PHP : String = "/index.php/";
    
    public static inline var SCHOOLS_BASE_URL : String = "schools.centerforgamescience.com";
    
    /**
     * Development URL for the game.
     */
    public static inline var DEV_URL_DOMAIN : String = "dev.ws.centerforgamescience.com";
    
    /**
     * Staging URL and components.
     */
    public static inline var STAGING_URL_DOMAIN : String = "staging.ws.centerforgamescience.com";
    
    /**
     * Integration urls and components for the game.
     */
    public static inline var INT_DEV_URL_DOMAIN : String = "dev.integration.centerforgamescience.com";
    
    public static inline var INT_STAGING_URL_DOMAIN : String = "staging.integration.centerforgamescience.com";
    
    public static var CUSTOM_INTEGRATION_BASE_URL : String = "prd.integration.centerforgamescience.com";
    
    // To use HTTPS, we need a specific domain name that maps to one of our certificates
    public static inline var INT_BASE_URL_DOMAIN_HTTP : String = "prd.integration.centerforgamescience.com";
    public static inline var INT_BASE_URL_PATH : String = "/cgs/apps/integration/";
    public static inline var INT_BASE_URL_PHP : String = "/index.php/";
    
    //Url used to request time from the server.
    public static inline var TIME_URL_DOMAIN_HTTP : String = "prd.integration.centerforgamescience.com";
    public static inline var TIME_URL_PATH : String = "/cgs/apps/integration/";
    public static inline var TIME_URL_PHP : String = "/time.php";
    
    public static inline var DEV_TIME_URL_DOMAIN : String = "dev.integration.centerforgamescience.com";
    
    public static inline var STAGING_TIME_URL_DOMAIN : String = "staging.integration.centerforgamescience.com";
    
    private static function get_TIME_URL_LOCAL() : String
    {
        return "http://localhost:" + INTEGRATION_LOCAL_PORT + "/time.php/";
    }
    
    /**
     * Local Game Logging URL
     * 
     * CHANGE the port number based on how you configured the local server project files
     */
    private static function get_LOCAL_URL() : String
    {
        return "http://localhost:" + LOGGING_LOCAL_PORT + "/index.php/";
    }
    
    /**
     * Local Integration URL
     * 
     * CHANGE the port number based on how you configured the local server project files
     */
    private static function get_INT_LOCAL_URL() : String
    {
        return "http://localhost:" + INTEGRATION_LOCAL_PORT + "/index.php/";
    }
    
    //
    // Request methods which can be called on the server.
    //
    
    /**
     * Sub-URL to get a UUID for a new user.
     */
    public static inline var UUID_REQUEST : String = "muser/get/";
    
    /**
     * Sub-URL to get a dqid.
     */
    public static inline var DQID_REQUEST : String = "logging/getdynamicquestid/";
    
    /**
     * Sub-URL to log the start of a quest.
     */
    public static inline var LEGACY_QUEST_START : String = "loggingassessment/setquest/";
    
    public static inline var QUEST_START : String = "quest/start/";
    
    public static inline var QUEST_END : String = "quest/end/";
    
    public static inline var HOMEPLAY_QUEST_START : String = "quest/homeplaystart/";
    
    public static inline var HOMEPLAY_QUEST_END : String = "quest/homeplayend/";
    
    /**
     * Sub-URL to log a quest action.
     */
    public static inline var QUEST_ACTIONS : String = "logging/set/";
    
    /**
     * Sub-URL to create a new quest on the server.
     */
    public static inline var CREATE_QUEST : String = "questcreate/set/";
    
    
    /**
		 * Sub-URL to create a new copilot activity on the server.
		 */
    public static inline var CREATE_COPILOT_ACTIVITY : String = "copilot/activitystart";
    
    /**
		 * Sub-URL to end copilot activity on the server.
		 */
    public static inline var END_COPILOT_ACTIVITY : String = "copilot/activityend";
    
    /**
		 * Sub-URL to create a new copilot problem set on the server.
		 */
    public static inline var CREATE_COPILOT_PROBLEM_SET : String = "copilot/problemsetstart";
    
    /**
		 * Sub-URL to end a problem set on the server.
		 */
    public static inline var END_COPILOT_PROBLEM_SET : String = "copilot/problemsetend";
    
    /**
		 * Sub-URL to create a new copilot problem result on the server.
		 */
    public static inline var CREATE_COPILOT_PROBLEM_RESULT : String = "copilot/problemresult";
    
    /**
     * Sub-URL to log user's demographic information.
     */
    public static inline var USER_FEEDBACK : String = "loggingprofile/set/";
    
    /**
     * Sub-URL to log a game event that is not associated with a quest.
     */
    public static inline var ACTION_NO_QUEST : String = "loggingactionnoquest/set/";
    
    /**
     * Sub-URL to log a page load for the user.
     */
    public static inline var PAGELOAD : String = "loggingpageload/set/";
    
    /**
     * Method to save a user's score to the server.
     */
    public static inline var SAVE_SCORE : String = "loggingscore/set/";
    
    public static inline var SCORE_REQUEST : String = "loggingscore/getscoresbyids/";
    
    public static inline var TOS_DATA_ID : String = "tos_status";
    
    //
    // Save save data.
    //
    
    public static inline var SAVE_GAME_DATA : String = "playerdata/set/";
    
    public static inline var LOAD_USER_GAME_DATA : String = "playerdata/getbyuid/";
    
    public static inline var LOAD_USER_GAME_SERVER_DATA : String = "playerdata/getbyuser/";
    
    public static inline var LOAD_GAME_DATA : String = "playerdata/getbyudataidnuid/";
    
    public static inline var BATCH_APP_GAME_DATA : String = "appuserdata/save/";
    
    public static inline var LOAD_USER_APP_SAVE_DATA_V2 : String = "appuserdata/load/";
    
    //
    // User log data request methods
    //
    
    public static inline var QUESTS_REQUEST : String = "logging/getquestsbyuserid/";
    
    public static inline var QUEST_ACTIONS_REQUEST : String = "logging/getactionsbydynamicquestid/";
    
    public static inline var PAGE_LOAD_BY_UID_REQUEST : String = "loggingpageload/getbyuid/";
    
    public static inline var DEMOGRAPHICS_GET_BY_UID : String = "loggingprofile/getbyuid/";
    
    //
    // Failure handling.
    //
    
    public static inline var LOG_FAILURE : String = "loggingfailure/set/";
    
    //
    // Logging request methods.
    //
    
    //LoggingController methods.
    
    public static inline var GET_ACTIONS_BY_DQID : String = "logging/getactionsbydynamicquestid/";
    
    public static inline var GET_QUESTS_BY_DQID : String = "logging/getquestsbydynamicquestid/";
    
    /**
     * Get the quest data for a cid and a timestamp range. Required data values are 'cid', 'tss' and 'tse'.
     */
    public static inline var GET_QUESTS_BY_CID_TS : String = "logging/getquestsbycidnts/";
    
    /**
     * Get quest actions data for a given timestamp range.
     */
    public static inline var GET_ACTIONS_BY_CID_TS : String = "logging/getactionsbycidnts/";
    
    /**
     * Get quest actions by optional parameters. Refer to server documentation for options.
     */
    public static inline var GET_QUEST_ACTIONS : String = "logging/get/";
    
    public static inline var GET_QUESTS_BY_UID : String = "logging/getquestsbyuserid/";
    
    
    //LoggingactionnoquestController methods.
    
    public static inline var GET_NO_QUEST_ACTIONS_BY_UID : String = "loggingactionnoquest/getbyuid/";
    
    
    //LoggingpageloadController methods.
    
    public static inline var GET_PAGELOADS_BY_UID : String = "loggingpageload/getbyuid/";
    
    public static inline var GET_PAGELOADS_BY_CID : String = "loggingpageload/getbycid/";
    
    
    //LoggingprofileController methods.
    
    public static inline var GET_PROFILE_BY_UID : String = "loggingprofile/getbyuid/";
    
    
    //LoggingqueststatusController
    
    public static inline var GET_QUEST_STATUS_BY_UID : String = "loggingqueststatus/getbyuid/";
    
    
    //
    // Homeplay and group creation support.
    //
    
    public static inline var CHECK_USER_NAME_AVAILABLE : String = "homeuser/check";
    
    public static inline var REGISTER_USER : String = "adminmember/add";
    
    public static inline var REGISTER_STUDENT : String = "adminmember/registerstudent/";
    
    public static inline var ADD_STUDENT : String = "homegroup/addstudent";
    
    public static inline var ADD_GROUP : String = "homegroup/add";
    
    public static inline var UPDATE_CLASSROOM : String = "homegroup/update";
    
    public static inline var ADD_CLASSROOM_STUDENT : String = "homegroup/addstudent";
    
    public static inline var CREATE_HOMEPLAY_QUEST : String = "homequest/add";
    
    public static inline var CREATE_HOMEPLAY : String = "homeplay/add";
    
    public static inline var CREATE_HOMEPLAY_ASSIGNMENT : String = "homeassignment/add";
    
    public static inline var UPDATE_HOMEPLAY_ASSIGNMENT : String = "homeassignment/update";
    
    public static inline var RETRIEVE_HOMEPLAY_ASSIGNMENTS : String = "homeassignment/getbyuid";
    
    public static inline var RETRIEVE_HOMEPLAY_ASSIGNMENTS_FOR_STUDENT : String = "homeplay/getassignmentsforstudent";
    
    public static inline var ADD_STUDENT_HOMEPLAY_START : String = "homeplay/assignmentstart";
    
    public static inline var ADD_STUDENT_HOMEPLAY_RESULT : String = "homeplay/assignmentresult";
    
    public static inline var UPDATE_STUDENT : String = "adminmember/updatestudent/";
    
    //
    // Integration URL methods.
    //
    
    //
    // User authentication handling.
    //
    
    public static inline var AUTHENTICATE_USER : String = "adminmember/authnrmem/";
    
    public static inline var AUTHENTICATED : String = "adminmember/authorized/";
    
    public static inline var AUTHENTICATE_STUDENT : String = "adminmember/authstudent/";
    
    public static inline var GET_MEMBER_BY_GROUP_ID : String = "adminmember/getmembersbygroupidnextsid/";
    
    public static inline var GET_UID_BY_EXTERNAL_ID : String = "members/getuidbyexternalid/";
    
    public static inline var UPDATE_EXTERNAL_ID : String = "members/updateexternalid/";
    
    public static inline var AUTHENTICATE_CACHED_STUDENT : String = "adminmember/authcachestudent/";
    
    public static inline var CHECK_STUDENT_NAME_AVAILABLE : String = "adminmember/checkstudent/";
    
    public static inline var GET_STUDENT_BY_UID : String = "adminmember/getstudentbyuid";
    
    //
    // Tos handling.
    //
    
    public static inline var TOS_USER_STATUS : String = "tos/userstatus/";
    
    public static inline var TOS_USER_UPDATE : String = "tos/updateuserstatus/";
    
    public static inline var TOS_USER_EXEMPT : String = "tos/exemptuser/";
    
    public static inline var TOS_REQUEST : String = "tos/request/";
    
    // DynamoDb tos status handling.
    
    public static inline var TOS_USER_STATUS_V2 : String = "tos/userstatusv2/";
    
    public static inline var TOS_USER_UPDATE_V2 : String = "tos/updateuserstatusv2/";
    
    public static inline var TOS_USER_EXEMPT_V2 : String = "tos/exemptuserv2/";
    
    //
    // Buffer handler constants.
    //
    
    /**
     * Time(ms) between log buffer flushes at the start of a quest.
     */
    public static var bufferFlushIntervalStart : Int = 2000;
    
    /**
     * Time(ms) between buffer flushes after the ramp time has elapsed during a quest.
     */
    public static var bufferFlushIntervalEnd : Int = 5000;
    
    /**
     * Time(ms) it takes to change from the start and end times for buffer flushing.
     */
    public static var bufferFlushRampTime : Int = 10000;
    
    /**
     * Minimum number of logs that have to be in the buffer before a flush will occur.
     */
    public static var bufferSizeMin : Int = 1;
    
    /**
     * Maximum number of actions allowed in action buffer before a flush is forced.
     */
    public static var bufferFlushForceCount : Int = 50;
    
    //
    // Server latency simulation.
    //
    
    /**
     * Simulated server latency (in seconds) which can be used when logging to the development server.
     */
    public static var serverLatency : Int = 5;
    
    /**
     * Get the game specific logging URL for the game with the given name.
     */
    public function getGameLoggingURL(gameName : String) : String
    {
        return "http://" + gameName + ".ws.centerforgamescience.com/cgs/apps/games/ws/index.php/";
    }

    public function new()
    {
    }
}
