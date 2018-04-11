package cgs.server.abtesting.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.messages.Message;
import cgs.server.utils.INtpTime;
import haxe.Json;

class TestStatusMessage extends Message
{
    public function new(
            testID : Int, conditionID : Int,
            start : Bool = true, detail : Dynamic = null,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        addProperty("test_id", testID);
        addProperty("cond_id", conditionID);
        addProperty("start", (start) ? 1 : 0);
        
        if (detail != null)
        {
            addProperty("detail", Json.stringify(detail));
        }
    }
}
