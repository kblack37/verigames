package cgs.server.data;

import cgs.homeplays.data.UserHomeplaysData;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

/**
	 * Contains cached data for users and groups that has been returned from the server.
	 */
class UserDataManager
{
    //Mapping of user data. Key = uid.
    private var _userData : StringMap<UserData>;
    
    //Mapping of user data. Key = ext_id.
    private var _extUserData : StringMap<UserData>;
    
    //Mapping of user homeplay data to uid.
    private var _userHomeplayData : StringMap<UserHomeplaysData>;
    
    //Mapping of group data. Key = groupId.
    private var _groupData : IntMap<GroupData>;
    
    public function new()
    {
        _userData = new StringMap<UserData>();
        _extUserData = new StringMap<UserData>();
        _userHomeplayData = new StringMap<UserHomeplaysData>();
        _groupData = new IntMap<GroupData>();
    }
    
    public function containsUser(uid : String) : Bool
    {
        return _userData.get(uid) != null;
    }
    
    public function containsUserWithExternalId(id : String) : Bool
    {
        return _extUserData.get(id) != null;
    }
    
    public function getUserData(uid : String) : UserData
    {
        return _userData.get(uid);
    }
    
    public function getUserDataByExternalId(id : String) : UserData
    {
        return _extUserData.get(id);
    }
    
    public function addUserData(data : UserData) : Void
    {
        _userData.set(data.uid, data);
        _extUserData.set(data.externalId, data);
    }
    
    public function addUserHomeplayData(data : UserHomeplaysData, userUid : String) : Void
    {
        if (data == null)
        {
            return;
        }
        
        _userHomeplayData.set(userUid, data);
    }
    
    public function getUserHomeplayData(uid : String) : UserHomeplaysData
    {
        return _userHomeplayData.get(uid);
    }
    
    public function addGroupData(data : GroupData) : Void
    {
        _groupData.set(data.id, data);
    }
    
    public function getGroupData(id : Int) : GroupData
    {
        return _groupData.get(id);
    }
}
