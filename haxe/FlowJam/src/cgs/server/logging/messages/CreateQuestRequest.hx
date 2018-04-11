package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.utils.INtpTime;

class CreateQuestRequest extends Message
{
    public function new(name : String, typeID : Int,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        addProperty("q_name", name);
        addProperty("q_type_id", typeID);
    }
}
