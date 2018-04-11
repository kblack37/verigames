package cgs.server.data;

import cgs.server.data.TosItemData;
import haxe.ds.IntMap;
import haxe.ds.StringMap;


/**
	 * Contains all of the loaded terms of service.
	 */
class TosData
{
    public static inline var EXEMPT_TERMS : String = "exempt";
    public static inline var NO_USER_NAME_TOS_40648_TERMS : String = "40648_nousername";
    public static inline var USER_NAME_TOS_40648_TERMS : String = "40648_username";
    public static inline var TEACHER_TOS_40648_TERMS : String = "40648_teacher";
    public static inline var THIRTEEN_OLDER_TOS_41035_TERMS : String = "41035_13up";
    public static inline var SEVEN_TO_TWELVE_TOS_41035_TERMS : String = "41035_7to12";
    public static inline var COPILOT_45954_TERMS : String = "45954_copilot";
    
    public static inline var ENGLISH_CODE : String = "en";
    
    /**
		 * Mapping of terms of service data items value = TosItems key = tos unique key.
		 */
    private var _terms : StringMap<TosLanguageItems>;
    
    public function new()
    {
        _terms = new StringMap<TosLanguageItems>();
    }
    
    /**
		 * 
		 */
    public function getTosData(tosKey : String, languageCode : String = ENGLISH_CODE, version : Int = -1) : TosItemData
    {
        var tos : TosItemData = null;
        if (_terms.exists(tosKey))
        {
            var tosLanData : TosLanguageItems = _terms.get(tosKey);
            tos = tosLanData.getTosData(languageCode, version);
        }
        
        return tos;
    }
    
    /**
		 * Indicates if the tos identified by the given properties has been loaded.
		 * 
		 * @param tosKey unique key to identify the tos.
		 * @param languageCode the language code of the terms. Default is english.
		 * @param version the version of the tos. Default is the latest version of the terms.
		 */
    public function containsTos(tosKey : String, languageCode : String = ENGLISH_CODE, version : Int = -1) : Bool
    {
        var containsTos : Bool = false;
        if (_terms.exists(tosKey))
        {
            var tosLanData : TosLanguageItems = _terms.get(tosKey);
            containsTos = tosLanData.containsTos(languageCode, version);
        }
        return containsTos;
    }
    
    public function addTosDataItems(items : Array<TosItemData>) : Void
    {
        for (item in items)
        {
            addTosItemData(item);
        }
    }
    
    /**
		 * Add a tos item to the collection of loaded tos items.
		 */
    public function addTosItemData(data : TosItemData) : Void
    {
        var tosKey : String = data.key;
        var lanTerms : TosLanguageItems = _terms.get(tosKey);
        if (lanTerms == null)
        {
            lanTerms = new TosLanguageItems();
            _terms.set(tosKey, lanTerms);
        }
        
        lanTerms.addTosItemData(data);
    }
}




//Would not be using classes if actionscript had generics.

/**
 * Contains all of the loaded terms for a given tos key.
 */
class TosLanguageItems
{
    /**
	 * Mapping of terms data items mapped by language code.
	 */
    private var _terms : StringMap<TosVersionItems>;
    
    @:allow(cgs.server.data)
    private function new()
    {
        _terms = new StringMap<TosVersionItems>();
    }
    
    public function getTosData(languageCode : String, version : Int) : TosItemData
    {
        var terms : TosItemData = null;
        if (_terms.exists(languageCode))
        {
            var versionTerms : TosVersionItems = _terms.get(languageCode);
            terms = versionTerms.getTosData(version);
        }
        
        return terms;
    }
    
    public function containsTos(languageCode : String, version : Int) : Bool
    {
        var containsTerms : Bool = false;
        if (_terms.exists(languageCode))
        {
            var versionTerms : TosVersionItems = _terms.get(languageCode);
            containsTerms = versionTerms.containsTos(version);
        }
        
        return containsTerms;
    }
    
    public function addTosItemData(data : TosItemData) : Void
    {
        var languageCode : String = data.languageCode;
        var termsVersion : TosVersionItems = _terms.get(languageCode);
        if (termsVersion == null)
        {
            termsVersion = new TosVersionItems();
            _terms.set(languageCode, termsVersion);
        }
        
        termsVersion.addTosItemData(data);
    }
}

class TosVersionItems
{
    //Map that actually contains the terms item data.
    private var _terms : IntMap<TosItemData>;
    
    private var _latestVersion : TosItemData;
    
    @:allow(cgs.server.data)
    private function new()
    {
        _terms = new IntMap<TosItemData>();
    }
    
    public function getTosData(version : Int) : TosItemData
    {
        if (version == -1)
        {
            return _latestVersion;
        }
        return _terms.get(version);
    }
    
    public function containsTos(version : Int) : Bool
    {
        if (version == -1)
        {
            return _latestVersion != null;
        }
        return _terms.exists(version);
    }
    
    public function addTosItemData(data : TosItemData) : Void
    {
        _terms.set(data.version, data);
        
        if (data.isLatestVersion)
        {
            _latestVersion = data;
        }
    }
}