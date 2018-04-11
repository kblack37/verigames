package cgs.server.logging;
import cgs.cache.ICGSCache;
import cgs.server.data.IUserTosStatus;
import cgs.server.data.UserAuthData;

/**
 * @author Ric Gray
 */

@:enum 
abstract SkeyHashVersion(Int)
{
	var NO_SKEY_HASH = 0;
	var UUID_SKEY_HASH = 1;
	var DATA_SKEY_HASH = 2;
}

@:enum
abstract EncodingType(Int)
{
	var NO_DATA_ENCODING = 0;
	var BASE_64_ENCODING = 1;
}
interface IGameServerData 
{
    public var experimentId(get, set) : Int;
    public var isExperimentIdValid(get, never) : Bool;
    public var serverTag(get, set) : String;
    public var userTosStatus(get, set) : IUserTosStatus;
    public var containsUserTosStatus(get, never) : Bool;
    public var nextSessionSequenceId(get, never) : Int;
    public var nextQuestSequenceId(get, never) : Int;
    public var nextAssignmentSequenceId(get, never) : Int;
    public var userLoggingHandler(get, set) : UserLoggingHandler;
    public var uidCallback(get, set) : String->Bool->Void;
    public var hasUidCallback(get, never) : Bool;
    public var hasCacheForLaterCallback(get, never) : Bool;
    public var saveCacheDataToServer(get, set) : Bool;
    public var cgsCache(get, set) : ICGSCache;
    public var hasCgsCache(get, never) : Bool;
    public var authenticateCachedStudent(get, set) : Bool;
    public var userAuthentication(never, set) : UserAuthData;
    public var externalSourceId(get, never) : Int;
    public var externalAppId(get, set) : Int;
    public var serverVersion(get, set) : Int;
    public var isVersion1(get, never) : Bool;
    public var atLeastVersion1(get, never) : Bool;
    public var isVersion2(get, never) : Bool;
    public var atLeastVersion2(get, never) : Bool;
    public var legacyMode(get, set) : Bool;
    public var timeUrl(get, set) : String;
    public var serverURL(get, set) : String;
    public var abTestingURL(get, set) : String;
    public var integrationURL(get, set) : String;
    public var useDevelopmentServer(get, set) : Bool;
    public var skeyHashVersion(get, set) : SkeyHashVersion;
    public var dataEncoding(get, set) : EncodingType;
    public var dataLevel(get, set) : Int;
    public var logPriority(get, set) : Int;
    public var skey(get, set) : String;
    public var userName(get, set) : String;
    public var isConditionIdValid(get, never) : Bool;
    public var conditionId(get, set) : Int;
    public var userPlayCount(get, set) : Int;
    public var uid(get, set) : String;
    public var isUidValid(get, never) : Bool;
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, set) : String;
    public var g_name(get, set) : String;
    public var gid(get, set) : Int;
    public var svid(get, never) : SkeyHashVersion;
    public var vid(get, set) : Int;
    public var cid(get, set) : Int;
    public var isEventIDValid(get, never) : Bool;
    public var eid(get, set) : Int;
    public var isTypeIDValid(get, never) : Bool;
    public var tid(get, set) : Int;
    public var isLevelIDValid(get, never) : Bool;
    public var lid(get, set) : Int;
    public var isSessionIDValid(get, never) : Bool;
    public var sid(get, set) : String;
    public var lessonId(get, set) : String;
    public var tosServerVersion(get, set) : Int;
    public var isSWFDomainValid(get, never) : Bool;
    public var swfDomain(get, set) : String;
	
	/**
	 * Get the skey for the associated URL / uuid.
	 *
	 * @param value the string value which should be used to create the hashed skey.
	 * @return a hashed version of the server skey.
	 */
	public function createSkeyHash(value:String):String;


}