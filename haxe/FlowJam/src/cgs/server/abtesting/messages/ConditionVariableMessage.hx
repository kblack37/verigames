package cgs.server.abtesting.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.messages.Message;
import cgs.server.utils.INtpTime;
import haxe.Json;

class ConditionVariableMessage extends Message
{
    public function new(
            testID : Int, conditionID : Int, varID : Int, resultID : Int,
            start : Bool = false, time : Float = -1, detail : Dynamic = null,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        addProperty("test_id", testID);
        addProperty("cond_id", conditionID);
        addProperty("var_id", varID);
        addProperty("start", (start) ? 1 : 0);
        addProperty("result_id", resultID);
        
        if (time >= 0)
        {
            addProperty("time", time);
        }
        
        if (detail != null)
        {
            addProperty("detail", Json.stringify(detail));
        }
    }
}
