package cgs.edmodo;


class EdmodoConstants
{
    public static inline var SANDBOX_URL : String = "http://dev.integration.centerforgamescience.com/cgs/apps/integration/ws/index.php/proxy";
    //public static const SANDBOX_URL:String = "https://appsapi.edmodobox.com/";
    
    public static inline var PRODUCTION_URL : String = "http://prd.integration.centerforgamescience.com/cgs/apps/integration/ws/index.php/proxy";
    //public static const PRODUCTION_URL:String = "https://appsapi.edmodo.com/";
    
    //
    // API Resources.
    //
    
    //GET requests.
    
    /**
		 * Gets all of the information related to the user when the application is launched.
		 * This request requires a launch key which is only valid for 30 secs
		 * after the application has been launched.
		 */
    //public static const LAUNCH_REQUESTS:String = "launchRequests";
    
    /**
		 * Get data related to users.
		 */
    public static inline var USERS : String = "users";
    
    /**
		 * Get data related to groups.
		 */
    public static inline var GROUPS : String = "groups";
    
    /**
		 * Get the groups that the user belongs to.
		 */
    public static inline var GROUPS_FOR_USER : String = "groupsForUser";
    
    /**
		 * Get the users data for all users contained within a group.
		 */
    public static inline var MEMBERS : String = "members";
    
    public static inline var CLASSMATES : String = "classmates";
    
    public static inline var TEACHERS : String = "teachers";
    
    public static inline var TEACHER_MATES : String = "teachermates";
    
    public static inline var TEACHER_CONNECTIONS : String = "teacherConnections";
    
    public static inline var ASSIGNMENTS_COMING_DUE : String = "assignmentsComingDue";
    
    public static inline var GRADES_APP_FOR_USER : String = "gradesSetByAppForUser";
    
    public static inline var GRADES_APP_FOR_GROUP : String = "gradesSetByAppForGroup";
    
    public static inline var BADGES_AWARDED : String = "badgesAwarded";
    
    public static inline var EVENTS_BY_APP : String = "eventsByApp";
    
    public static inline var PARENTS : String = "parents";
    
    public static inline var CHILDREN : String = "children";
    
    public static inline var GET_APP_DATA : String = "getAppData";
    
    //POST requests.
    
    public static inline var ACTIVITY_POST : String = "activityPost";
    
    public static inline var USER_POST : String = "userPost";
    
    public static inline var TURN_IN_ASSIGNMENT : String = "turnInAssignment";
    
    public static inline var REGISTER_BADGE : String = "registerBadge";
    
    public static inline var AWARD_BADGE : String = "awardBadge";
    
    public static inline var REVOKE_BADGE : String = "revokeBadge";
    
    public static inline var NEW_GRADE : String = "newGrade";
    
    public static inline var SET_GRADE : String = "setGrade";
    
    public static inline var NEW_EVENT : String = "newEvent";
    
    public static inline var SET_APP_DATA : String = "setAppData";

    public function new()
    {
    }
}
