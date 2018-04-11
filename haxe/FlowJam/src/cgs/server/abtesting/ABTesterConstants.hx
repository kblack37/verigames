package cgs.server.abtesting;

import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.ICGSServerProps;
import cgs.server.logging.ICGSServerProps.LoggingVersion;
import cgs.server.logging.ICGSServerProps.ServerType;

class ABTesterConstants
{
    public static inline var VERSION_0 : String = "dev";
    public static inline var VERSION_1 : String = "ws";
    public static inline var VERSION_2 : String = "v2";
    public static var CURRENT_VERSION : String = VERSION_2;
    
    /**
     * Get the url for the given version of the server code.
     * 
     * An example return value: "http://prd.ws.centerforgamescience.com/cgs/apps/abtest/ws/index.php/"
     */
    public static function GetAbTestingUrl(serverTag : String, useHttps : Bool, version : Int = 1) : String
    {
		var url : String;
		
        if (serverTag == LOCAL_SERVER)
        {
            url = ABTesterConstants.AB_TEST_URL_LOCAL;
        }
        else
        {
            var domain : String = DEV_AB_TEST_URL_DOMAIN;
            if (serverTag == PRODUCTION_SERVER)
            {
                domain = ((useHttps)) ? CGSServerConstants.BASE_URL_DOMAIN_HTTPS : AB_TEST_URL_DOMAIN_HTTP;
            }
            else
            {
                if (serverTag == STAGING_SERVER)
                {
                    domain = STAGING_AB_TEST_URL_DOMAIN;
                }
                else
                {
                    if (serverTag == STUDY_SERVER)
                    {
                        domain = SCHOOLS_AB_TEST_BASE_URL;
                    }
                    else
                    {
                        if (serverTag == CUSTOM_SERVER)
                        {
                            domain = CUSTOM_AB_TEST_URL_DOMAIN;
                        }
                    }
                }
            }
            
            url = CGSServerConstants.getHttpPrefix(useHttps) + domain + AB_TEST_URL_PATH;
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
            url += AB_TEST_URL_PHP;
        }
        
        return url;
    }
    
    //
    // AB testing url's.
    //
    
    public static var CUSTOM_AB_TEST_URL_DOMAIN : String = "prd.ws.centerforgamescience.com";
    
    //Temp set to local. Change to a dev server once that is setup.
    public static inline var AB_TEST_URL_LOCAL : String = "http://localhost:10052/";
    
    //Development URL for ab testing.
    public static inline var DEV_AB_TEST_URL_DOMAIN : String = "dev.ws.centerforgamescience.com";
    
    //Production URL for ab testing.
    public static inline var STAGING_AB_TEST_URL_DOMAIN : String = "staging.ws.centerforgamescience.com";
    
    //Production URL for ab testing.
    public static inline var AB_TEST_URL_DOMAIN_HTTP : String = "prd.ws.centerforgamescience.com";
    public static inline var AB_TEST_URL_PATH : String = "/cgs/apps/abtest/";
    public static inline var AB_TEST_URL_PHP : String = "/index.php/";
    
    public static inline var SCHOOLS_AB_TEST_BASE_URL : String = "schools.centerforgamescience.com";
    
    //URL to be used to create a new ab test.
    public static inline var CREATE_TEST : String = "abtest/set/";
    
    public static inline var EDIT_TEST : String = "abtest/edit/";
    
    //
    // Test request methods.
    //
    
    public static inline var REQUEST_ALL_TESTS : String = "abtest/request/";
    
    public static inline var REQUEST_TESTS_BY_ID : String = "abtest/requesttestsbyid/";
    
    public static inline var REQUEST_TEST_STATS : String = "teststatus/requestteststats/";
    
    //
    // Condition request methods.
    //
    
    public static inline var REQUEST_TEST_CONDITIONS : String = "abtest/requesttestconditions/";
    
    //
    // Variable request methods.
    //
    
    public static inline var REQUEST_CONDITION_VARIABLES : String = "abtest/requestconditionvariables/";
    
    public static inline var GET_USER_CONDITIONS : String = "userconditions/request/";
    
    public static inline var GET_EXISTING_USER_CONDITIONS : String = "userconditions/requestexisting/";
    
    public static inline var NO_CONDITION_USER : String = "userconditions/nocondition/";
    
    public static inline var LOG_TEST_START_END : String = "teststatus/set/";
    
    public static inline var LOG_CONDITION_RESULTS : String = "conditionresults/set/";
    
    //
    // Test queue request methods.
    //
    
    public static inline var REQUEST_TEST_QUEUE_TESTS : String = "queue/requesttests/";
    
    public static inline var REQUEST_ACTIVE_TEST_QUEUE : String = "queue/requestactivetests/";
    
    //
    // Test update methods.
    //
    
    public static inline var DEACTIVATE_TEST : String = "abtest/deactivate/";
    public static inline var STOP_TEST : String = "abtest/stop";
    public static inline var ACTIVATE_TEST : String = "abtest/activate/";
    
    //
    // Test results methods.
    //
    
    public static inline var REQUEST_USER_COUNT : String = "userconditions/usercount/";
    
    public static inline var USERS_CONDITIONS_REQUEST : String = "userconditions/requestusers/";
    
    public static inline var USERS_TEST_RESULTS_REQUEST : String = "conditionresults/requestresultsbyuid/";
    
    public static inline var REQUEST_TEST_RESULTS_BY_ID : String = "testresults/getbyids/";
    public static inline var LOAD_TEST_RESULTS : String = "testresults/load/";
    public static inline var RELOAD_TEST_RESULTS : String = "testresults/reload/";
    public static inline var LOAD_USER_RESULTS_DATA : String = "testresults/retrieve/";
    
    //Method to get all test status information.
    public static inline var LOAD_TEST_RESULTS_STATUS : String = "testresults/getstatus/";
    
    public static inline var LOAD_TEST_RESULTS_STATUS_BY_IDS : String = "testresults/getstatusbyids/";
    
    public static inline var CANCEL_TEST_RESULTS : String = "testresults/cancel/";
    
    public static inline var REQUEST_CUSTOM_RESULTS : String = "testresults/getcustom/";
    
    public static inline var CREATE_CUSTOM_RESULTS : String = "testresults/createcustom/";
    
    public static inline var EDIT_CUSTOM_RESULTS : String = "testresults/editcustom/";
    
    public static inline var DELETE_CUSTOM_RESULTS : String = "testresults/deletecustom/";
    
    /**
     * Get the game specific url for the game with the given name.
     */
    public static function getGameABTestingURL(gameName : String) : String
    {
        return "http://" + gameName + ".ws.centerforgamescience.com/cgs/apps/abtest/ws/index.php/";
    }

    public function new()
    {
    }
}
