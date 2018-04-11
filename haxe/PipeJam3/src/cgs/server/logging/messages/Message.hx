package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.IGameServerData.SkeyHashVersion;
import cgs.server.utils.INtpTime;

/**
 * ...
 * @author Dmitri/Yun-En/Aaron
 *
 * Message class contains a list of header variables (logging schema specific) and an optional action buffer.
 * You'll need to set gid, cid, and qid yourself.
 *   Gid will be the same for each game, always; look in the database to find yours.
 *   Cid will be set by you to whatever you want, although it will probably change for new events or releases.
 *   Qid depends on what quest in the game you're currently playing.
 *
 * You may also want to use vid, although cid most likely suffices.
 *
 * In general you'll call CGSClient's setUser to set the uid, and setDqid to set the dqid.
 * You also probably don't care about the optional fields.
 *
 * What is cid, you ask?  It's typically used when you want to segregate data from some particular real-life event.
 * For instance, you ask 50 people to playtest your game.  It's going to be a pain to look through the database
 * for those exact 50 people.  However, if you compile a version of the game with a new cid, you can simply
 * do one database call to get every action with cid 5.  Then you can bump cid again for new builds.
 *
 * What's the difference between vid and cid, then?
 * Vid is conceptually the version of your game; new versions may have new levels or mechanics.
 * You might use the same vid for several different real life events, each with their own cid.
 * It's also possible that you'd have different versions of the game for the same cid -
 * imagine playtesting three different versions of the game at once.
 * That being said, as long as you write down what each cid is, you can probably do everything just
 * by bumping cids for each version, in which case you can ignore vid and just let it default to 0.
 *
 * NOTE:
 * If you are using JSON encoding, do not create getters protected/private properties that you do not want to encode.
 *
 */
class Message
{
    public var serverTime(never, set) : INtpTime;
    public var serverData(get, set) : IGameServerData;
    public var messageObject(get, never) : Dynamic;
    private var uid(get, never) : String;
    public var clientTimestamp(get, never) : Float;
    public var requireSessionId(never, set) : Bool;

    private var _messageObject : Dynamic;
    
    private var _gameServerData : IGameServerData;
    
    private var _serverTime : INtpTime;
    
    private var _localTimeStamp : Float;
    private var _timestamp : Float;
    private var _timeStampValid : Bool;
    private var _requiresTimeStamp : Bool;
    
    private var _requireSessionId : Bool;
    
    /**
     * @param serverData this value must be set if you are not using the CGSServer singleton instance.
     */
    public function new(serverData : IGameServerData = null, time : INtpTime = null)
    {
        _messageObject = { };
        
        _gameServerData = serverData;
        _serverTime = time;
    }
    
    private function set_serverTime(time : INtpTime) : INtpTime
    {
        _serverTime = time;
        return time;
    }
    
    private function set_serverData(data : IGameServerData) : IGameServerData
    {
        _gameServerData = data;
        return data;
    }
    
    private function get_serverData() : IGameServerData
    {
        return _gameServerData;
    }
    
    /**
     * Add a property to the message object to be sent to the server.
     */
    public function addProperty(key : String, value : Dynamic) : Void
    {
        Reflect.setField(_messageObject, key, value);
    }
    
    public function addProperties(propObject : Dynamic) : Void
    {
        for (key in Reflect.fields(propObject))
        {
            Reflect.setField(_messageObject, key, Reflect.field(propObject, key));
        }
    }
    
    /**
     * Get the object which will be encoded to JSON and sent the server.
     */
    private function get_messageObject() : Dynamic
    {
        return _messageObject;
    }
    
    private function get_uid() : String
    {
        return _gameServerData.uid;
    }
    
    /**
     * Inject the SKEY into the message.
     */
    public function injectSKEY() : Void
    {
        //Add data that is required for all messages to the server.
        var skeyHashType : SkeyHashVersion = _gameServerData.skeyHashVersion;
        if (skeyHashType == UUID_SKEY_HASH)
        {
            //Skey should be cached once the user id is set.
            _messageObject.skey = _gameServerData.createSkeyHash(uid);
        }
        else
        {
            if (skeyHashType == NO_SKEY_HASH)
            {
                _messageObject.skey = _gameServerData.skey;
            }
        }
    }
    
    /**
     * Adds the game name and game id parameters to the message. These
     * parameters are required for all requests/messages sent to the server.
     */
    public function injectGameParams() : Void
    {
        _messageObject.g_name = _gameServerData.g_name;
        _messageObject.gid = _gameServerData.gid;
        _messageObject.vid = _gameServerData.vid;
        
        if (!_gameServerData.legacyMode)
        {
            _messageObject.svid = _gameServerData.svid;
        }
    }
    
    public function injectGameId() : Void
    {
        _messageObject.gid = _gameServerData.gid;
    }
    
    /**
     * Inject the external app id and source id into the message.
     * This will only work if the user has been authenticated.
     */
    public function injectExternalParams() : Void
    {
        _messageObject.ext_s_id = _gameServerData.externalSourceId;
        _messageObject.ext_app_id = _gameServerData.externalAppId;
    }
    
    /**
     * Adds required parameters to the message. Injects the skey as well if required.
     */
    public function injectParams() : Void
    {
        injectGameParams();
        
        _messageObject.uid = uid;
        _messageObject.cid = _gameServerData.cid;
        
        injectSKEY();
    }
    
    public function injectCategoryId() : Void
    {
        _messageObject.cid = _gameServerData.cid;
    }
    
    public function injectUserName() : Void
    {
        _messageObject.uname = _gameServerData.userName;
    }
    
    public function injectConditionId() : Void
    {
        if (_gameServerData.isConditionIdValid)
        {
            _messageObject.cd_id = _gameServerData.conditionId;
        }
    }
    
    /**
     * Injects an event id into the message. If event id has not been set, event id is assumed to be 0.
     */
    public function injectEventID(required : Bool) : Void
    {
        if (required || _gameServerData.isEventIDValid)
        {
            _messageObject.eid = (_gameServerData.isEventIDValid) ? _gameServerData.eid : 0;
        }
    }
    
    /**
     *
     */
    public function injectTypeID(required : Bool) : Void
    {
        if (required || _gameServerData.isTypeIDValid)
        {
            _messageObject.tid = (_gameServerData.isTypeIDValid) ? _gameServerData.tid : 0;
        }
    }
    
    public function injectLevelID(required : Bool) : Void
    {
        if (required || _gameServerData.isLevelIDValid)
        {
            _messageObject.lid = (_gameServerData.isLevelIDValid) ? _gameServerData.lid : 0;
        }
    }
    
    //
    // Client time stamp handling.
    //
    
    public function hasClientTimeStamp() : Bool
    {
        return _requiresTimeStamp;
    }
    
    public function injectClientTimeStamp() : Void
    {
        _requiresTimeStamp = true;
        if (_serverTime.isTimeValid)
        {
            _timeStampValid = true;
            _timestamp = getClientTimestamp();
            addProperty("client_ts", _timestamp);
        }
        else
        {
            _localTimeStamp = _serverTime.clientTimeStamp;
        }
    }
    
    public function updateClientTimeStamp() : Void
    {
        if (_timeStampValid)
        {
            return;
        }
        
        _timestamp = (_localTimeStamp > 0) ? 
                _serverTime.getOffsetClientTimeStamp(_localTimeStamp) : 
                getClientTimestamp();
        addProperty("client_ts", _timestamp);
    }
    
    private function get_clientTimestamp() : Float
    {
        return (_timeStampValid) ? _timestamp : _localTimeStamp;
    }
    
    private function getClientTimestamp() : Float
    {
        if (_serverTime == null)
        {
            return 0;
        }
        
        return _serverTime.clientTimeStamp;
    }
    
    public function injectExperimentId() : Void
    {
        if (serverData == null)
        {
            return;
        }
        
        if (serverData.isExperimentIdValid)
        {
            addProperty("exper_id", serverData.experimentId);
        }
    }
    
    //
    // Session id handling.
    //
    
    private function set_requireSessionId(value : Bool) : Bool
    {
        _requireSessionId = value;
        return value;
    }
    
    public function hasSessionId() : Bool
    {
        return _requireSessionId;
    }
    
    public function injectSessionId() : Void
    {
        addProperty("sessionid", _gameServerData.sessionId);
    }
    
    @:meta(depracated())

    public function injectSessionID(required : Bool) : Void
    {
        if (required || _gameServerData.isSessionIDValid)
        {
            _messageObject.sid = (_gameServerData.isSessionIDValid) ? _gameServerData.sid : "0";
        }
    }
}
