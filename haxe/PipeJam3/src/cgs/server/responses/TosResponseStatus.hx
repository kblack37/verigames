package cgs.server.responses;

import cgs.server.data.IUserTosStatus;
import cgs.server.data.TosData;
import cgs.server.data.TosItemData;
import cgs.server.data.UserTosStatus;
import cgs.server.logging.IGameServerData;

class TosResponseStatus extends CgsResponseStatus
{
    public var containsTosData(get, never) : Bool;
    public var tosItemData(get, never) : Array<TosItemData>;

    private var _tosKey : String;
    
    private var _tosData : TosData;
    private var _tosStatus : IUserTosStatus;
    
    //Terms that have been loaded for the user to accept. Will be null
    //if user does not need to accept terms.
    private var _tosItemData : Array<TosItemData>;
    
    public function new(
            tosData : TosData, tosKey : String, serverData : IGameServerData)
    {
        super(serverData);
        
        _tosData = tosData;
        _tosKey = tosKey;
        _tosItemData = new Array<TosItemData>();
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        var userTos : TosItemData = null;
        if (Reflect.hasField(_data, "r_data"))
        {
            var tosData : Array<Dynamic> = _data.r_data;
            var tosItem : TosItemData;
            for (tosDataObj in tosData)
            {
                tosItem = new TosItemData();
                tosItem.parseObjectData(tosDataObj);
                
                if (tosItem.key == _tosKey)
                {
                    userTos = tosItem;
                }
                
                _tosItemData.push(tosItem);
            }
        }
        
        //TODO - Parse the data for the user. Should contain the latest
        //information regarding the user tos acceptance or decline.
        _tosStatus = new UserTosStatus(_tosData, userTos);
        _gameServerData.userTosStatus = _tosStatus;
    }
    
    private function get_containsTosData() : Bool
    {
        return _tosItemData.length > 0;
    }
    
    private function get_tosItemData() : Array<TosItemData>
    {
        return _tosItemData;
    }
}
