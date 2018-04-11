package cgs.server.logging.responses;

import cgs.server.logging.gamedata.UserDataChunk;
import haxe.Json;

class UserDataChunkResponse implements IServerResponse
{
    public var dataChunk(get, never) : UserDataChunk;
    public var data(never, set) : Dynamic;

    public static var SupportLegacyData : Bool = false;
    
    private var _dataChunk : UserDataChunk;
    
    public function new()
    {
    }
    
    private function get_dataChunk() : UserDataChunk
    {
        return _dataChunk;
    }
    
    private function set_data(value : Dynamic) : Dynamic
    {
        var dataArray : Array<Dynamic> = value;
        if (dataArray.length == 0)
        {
            return value;
        }
        
        var dataObj : Dynamic = dataArray[0];
        var rawData : Dynamic = dataObj.data_detail;
        var dataDetail : Dynamic = null;
        if (Std.is(rawData, String))
        {
            var stringData : String = rawData;
            if (stringData.toLowerCase() == "null")
            {
                dataDetail = null;
            }
            else
            {
                if (SupportLegacyData)
                {
                    if (stringData.length == 0)
                    {
                        dataDetail = stringData;
                    }
                    else
                    {
                        if (stringData.charAt(0) == "{" || stringData.charAt(0) == "[")
                        {
                            dataDetail = Json.parse(rawData);
                        }
                        else
                        {
                            dataDetail = stringData;
                        }
                    }
                }
                else
                {
                    dataDetail = stringData;
                }
            }
        }
        else
        {
            dataDetail = rawData;
        }
        _dataChunk = new UserDataChunk(dataObj.u_data_id, dataDetail);
        return value;
    }
}
