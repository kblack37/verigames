package cgs.server.logging.messages;

import cgs.server.logging.GameServerData;
import cgs.server.utils.INtpTime;

class UserFeedbackMessage extends Message
{
    //Possible gender values which can be specified by the user.
    public static inline var MALE : String = "m";
    public static inline var FEMALE : String = "f";
    public static inline var NOT_SPECIFIED : String = "n";
    
    //Valid education levels for the user.
    
    /**
		 * Create a user feed back message to be sent to the server.
		 *
		 * @param age numeric age of the player in years.
		 * @param gender of the player.
		 * @param education level of education for the player.
		 * @param feedback feedback of the player, limited to 255 characters.
		 */
    public function new(
            age : Int, gender : String, education : String, feedback : String = null,
            serverData : GameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        addProperty("age", age);
        addProperty("gender", gender);
        addProperty("edu", education);
        
        if (feedback != null)
        {
            addProperty("feedback", feedback);
        }
    }
}
