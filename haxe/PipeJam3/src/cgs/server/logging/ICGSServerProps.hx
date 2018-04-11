package cgs.server.logging;

import cgs.cache.ICGSCache;
import cgs.server.logging.IGameServerData.SkeyHashVersion;

/**
 * @author Ric Gray
 */

@:enum
abstract DataLevel(Int) from Int to Int
{
	var DELAYED_DATA_LEVEL = 0;
	var IMMEDIATE_DATA_LEVEL = 1;

	@:op(A > B) static function gt( a:DataLevel, b:DataLevel ) : Bool;	
	@:op(A >= B) static function gte( a:DataLevel, b:DataLevel ) : Bool;	
	@:op(A < B) static function lt( a:DataLevel, b:DataLevel ) : Bool;	
	@:op(A <= B) static function lte( a:DataLevel, b:DataLevel ) : Bool;	
	@:op(A == B) static function e( a:DataLevel, b:DataLevel ) : Bool;	

}

@:enum
abstract ServerType(String) from String to String
{
	var LOCAL_SERVER = "local";
	var DEVELOPMENT_SERVER = "dev";
	var STAGING_SERVER = "staging";
	var PRODUCTION_SERVER = "prd";
	var STUDY_SERVER = "school";
	var CUSTOM_SERVER = "custom";
	
	@:op(A == B) static function e( a:ServerType, b:ServerType ) : Bool;
}

@:enum
abstract LoggingVersion(Int) from Int to Int
{
    //Version of the logging code prior to sequence ids and client ts.
    var VERSION_DEV = 3;
    var VERSION1 = 1;
    
    //Logging includes sequence ids and client timestamp.
    var VERSION2 = 2;
    var CURRENT_VERSION = 2;
	
	@:op(A > B) static function gt( a:LoggingVersion, b:LoggingVersion ) : Bool;	
	@:op(A >= B) static function gte( a:LoggingVersion, b:LoggingVersion ) : Bool;	
	@:op(A < B) static function lt( a:LoggingVersion, b:LoggingVersion ) : Bool;	
	@:op(A <= B) static function lte( a:LoggingVersion, b:LoggingVersion ) : Bool;	
	@:op(A == B) static function e( a:LoggingVersion, b:LoggingVersion ) : Bool;	
}

interface ICGSServerProps 
{
    public var dataLevel(get, set) : Int;
    public var experimentId(get, set) : Int;
    public var serverVersion(get, never) : Int;
    public var pageLoadMultiplayerSequenceId(get, set) : Int;
    public var uidValidCallback(get, set) : Dynamic;
    public var forceUid(get, set) : String;
    public var cacheUid(get, set) : Bool;
    public var logPageLoad(get, set) : Bool;
    public var pageLoadDetails(get, set) : Dynamic;
    public var pageLoadCallback(get, set) : Dynamic;
    public var saveCacheDataToServer(get, set) : Bool;
    public var cgsCache(get, set) : ICGSCache;
    public var loadServerCacheDataByCid(get, set) : Bool;
    public var completeCallback(get, set) : Dynamic;
    public var skey(get, never) : String;
    public var loggingUrl(get, set) : String;
    public var isServerURLValid(get, never) : Bool;
    public var timeUrl(get, set) : String;
    public var serverURL(get, never) : String;
    public var isABTestingURLValid(get, never) : Bool;
    public var abTestingUrl(get, set) : String;
    public var isIntegrationURLValid(get, never) : Bool;
    public var integrationUrl(get, set) : String;
    public var serverTag(get, never) : String;
    public var useDevServer(get, never) : Bool;
    public var skeyHashVersion(get, never) : SkeyHashVersion;
    public var gameName(get, never) : String;
    public var gameID(get, never) : Int;
    public var versionID(get, never) : Int;
    public var categoryID(get, never) : Int;
    public var levelID(get, set) : Int;
    public var sessionID(get, set) : String;
    public var eventID(get, set) : Int;
    public var typeID(get, set) : Int;
    public var externalAppId(get, set) : Int;
    public var cacheActionForLaterCallback(get, set) : Dynamic;
    public var logPriority(get, set) : Int;

    /**
     * Important: If loading an application that uses a secure server, this must be set to true to avoid
     * mixed content errors.
     * 
     * This will tell various parts of the library to send https requests instead of regular http.
     * By default it is false.
     */
    public var useHttps : Bool;
    
    public function cloneServerProps() : CGSServerProps;
  
}