package cgs.user;
import cgs.server.abtesting.IUserAbTester;
import cgs.server.logging.ICGSServerProps;

/**
 * @author Ric Gray
 */

interface ICgsUserProperties extends ICGSServerProps

{
    public var authenticateCachedStudent(get, set) : Bool;
    public var loadAbTests(get, never) : Bool;
    public var loadHomeplays(get, set) : Bool;
    public var loadExistingAbTests(get, never) : Bool;
    public var abTester(get, set) : IUserAbTester;
    public var serverCacheVersion(get, never) : Int;
    public var cacheSaveKey(get, never) : String;
    public var defaultUsername(get, set) : String;
    public var tosKey(get, set) : String;
    public var tosExempt(get, never) : Bool;
    public var languageCode(get, set) : String;
    public var tosServerVersion(get, never) : Int;
    public var lessonId(get, set) : String;
	
	public function cloneUserProperties() : ICgsUserProperties;
}