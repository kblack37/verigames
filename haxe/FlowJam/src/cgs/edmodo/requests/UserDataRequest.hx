package cgs.edmodo.requests;

import haxe.Constraints.Function;
import cgs.pblabs.engine.debug.Logger;
import cgs.server.logging.requests.CallbackRequest;

/**
	 * Manages loading all data for the user.
	 */
class UserDataRequest extends CallbackRequest
{
    public var userToken(get, never) : String;
    public var userGroupCount(never, set) : Int;
    public var loadGroupMembers(get, set) : Bool;
    public var allDataLoaded(get, never) : Bool;

    private var _userToken : String;
    
    private var _userDataLoaded : Bool;
    
    private var _classmatesLoaded : Bool;
    
    private var _teachersLoaded : Bool;
    
    private var _parentsLoaded : Bool;
    
    private var _groupsLoaded : Bool;
    
    private var _groupIdsLoaded : Bool;
    
    private var _groupMembersLoaded : Bool;
    
    private var _loadedGroupMembers : Int;
    private var _groupCount : Int;
    
    private var _loadGroupMemberData : Bool;
    
    public function new(userToken : String, callback : Function)
    {
        super(callback, null);
        
        _userToken = userToken;
    }
    
    private function get_userToken() : String
    {
        return _userToken;
    }
    
    private function set_userGroupCount(value : Int) : Int
    {
        _groupCount = value;
        return value;
    }
    
    private function set_loadGroupMembers(value : Bool) : Bool
    {
        _loadGroupMemberData = value;
        return value;
    }
    
    private function get_loadGroupMembers() : Bool
    {
        return _loadGroupMemberData;
    }
    
    public function userDataLoaded() : Void
    {
        Logger.print(this, "User data loaded");
        _userDataLoaded = true;
    }
    
    public function classmatesLoaded() : Void
    {
        Logger.print(this, "User classmates loaded");
        _classmatesLoaded = true;
    }
    
    public function teachersLoaded() : Void
    {
        Logger.print(this, "User teachers loaded");
        _teachersLoaded = true;
    }
    
    public function parentsLoaded() : Void
    {
        Logger.print(this, "User parents loaded");
        _parentsLoaded = true;
    }
    
    public function groupsLoaded() : Void
    {
        Logger.print(this, "User groups loaded");
        _groupsLoaded = true;
    }
    
    public function groupIdsLoaded() : Void
    {
        Logger.print(this, "Group ids loaded.");
        _groupIdsLoaded = true;
    }
    
    public function groupMembersLoaded() : Void
    {
        _loadedGroupMembers++;
        _groupMembersLoaded = _loadedGroupMembers >= _groupCount;
        Logger.print(this, "User groups members loaded count: " + _loadedGroupMembers);
    }
    
    private function get_allDataLoaded() : Bool
    {
        return _userDataLoaded && _classmatesLoaded && _teachersLoaded && _parentsLoaded && _groupsLoaded && _groupIdsLoaded && ((_loadGroupMemberData) ? _groupMembersLoaded : true);
    }
}
