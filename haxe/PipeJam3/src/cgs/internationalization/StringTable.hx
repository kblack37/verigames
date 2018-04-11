package cgs.internationalization;

import as3hx.Compat.Regex;
import haxe.xml.Fast;
import openfl.utils.Dictionary;
import cgs.internationalization.XXML;

class StringTable
{
    private static var DEBUG : Bool = false;
    
    private static var m_isMobile : Bool;
    private static var m_fixedDict : Dictionary<String, Dynamic>;
    private static var m_localeDicts : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
    private static var m_defaultLocaleDict : Dictionary<String, Dynamic>;
    private static var m_currentLocaleDict : Dictionary<String, Dynamic>;
    
    //Initializes the StringTable using the default dictionary (english)
    public static function initialize(defaultLocale : String, isMobile : Bool) : Void
    {
        m_isMobile = isMobile;
        m_defaultLocaleDict = loadDict(defaultLocale, true);
        
        if (DEBUG)
        {
            for (locale in Reflect.fields(m_localeDicts))
            {
                var checkDict : Dictionary<String, Dynamic> = m_localeDicts[locale];
                if (checkDict == m_defaultLocaleDict)
                {
                    trace(locale + ": DEFAULT");
                    continue;
                }

                var localeOk : Bool = true;
                for (id in Reflect.fields(m_defaultLocaleDict))
                {
                    if (checkDict[id] == null)
                    {
                        localeOk = false;
                        trace(locale + ": missing id " + id);
                    }
                }
                if (localeOk)
                {
                    trace(locale + ": OK");
                }
            }
        }
    }
    
    public static function loadLocale(locale : String) : Void
    {
        var dict : Dictionary<String, Dynamic> = loadDict(locale, false);
        if (m_defaultLocaleDict == null)
        {
            m_defaultLocaleDict = dict;
        }
    }
    
    //Passed in XML Class, and retrives all words/values from file and adds them to dictionary.
    private static function loadDict(xmlClassPath : String, isDefault : Bool) :  Dictionary<String, Dynamic>
    {
        var xml : Fast = XXML.xmlFromEmbeddedFile(xmlClassPath);
        xml = xml.node.Strings;
        var locale : String = xml.att.locale;
        
        // If this is a bad locale or it already exists then we will not load it
        if (locale == null || locale == "" || m_localeDicts[locale] != null)
        {
            return null;
        }
        
        //Checks if default dictionary is used, then uses the FixedStrings
        if (isDefault)
        {
            m_fixedDict = new Dictionary<String, Dynamic>();
            for (fixedStr in xml.nodes.FixedString)
            {
                addMapping(m_fixedDict, fixedStr.att.id, fixedStr.att.val);
            }
        }
        
        //Adds all values from XML file to dictionary
        var dict : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
        for (str in xml.nodes.String)
        {
            if (m_isMobile)
            {
                //if file contains mob attribute
                if (str.has.mob)
                {
                    addMapping(dict, str.att.id, str.att.mob);
                }
                else
                {
                    addMapping(dict, str.att.id, str.att.val);
                }
            }
            else
            {
                addMapping(dict, str.att.id, str.att.val);
            }
        }
        
        m_localeDicts[locale] = dict;
        return dict;
    }
    
    //Adds words taken from XML language file to dictionary, so as to read them from Keys
    private static function addMapping(dict : Dictionary<String, Dynamic>, id : String, val : String) : Void
    {
        // If a bad ID is given, or the ID already exists in the dictionary, or the ID exists in the fixed dict, skip
        if (id == null || dict[id] != null || m_fixedDict[id] != null)
        {
            return;
        }
        
        // If a bad VAL is given, use the ID as the val
        if (val == null)
        {
            val = "{" + id + "}";
        }

        //TODO: check
        var rg:EReg=  new EReg('\\\\n', "g");
        dict[id] = rg.replace(val, "\n");
    }
    
    //Passed in Key, returns XML's value for that key, which is stored in dictionary.
    public static function lookup(id : String) : String
    {
        var ret : String = null;
        
        //If value is in fixed dictionary, returns that value first.
        if (m_fixedDict != null)
        {
            ret = m_fixedDict[id];
            if (ret != null)
            {
                return ret;
            }
        }
        
        //Then looks in the current dictionary. If the value is there, it returns it.
        if (m_currentLocaleDict != null)
        {
            ret = m_currentLocaleDict[id];
            if (ret != null)
            {
                return ret;
            }
        }
        
        //If the value is not in the current dictionary, returns value from default (english)
        if (m_defaultLocaleDict != null)
        {
            ret = m_defaultLocaleDict[id];
            if (ret != null)
            {
                return ret;
            }
        }
        
        //If word is not found any any of the three dictionaries, returns NO_STRING
        return "{" + id + "}";
    }
    
    public static function setLocale(locale : String) : Void
    {
        m_currentLocaleDict = m_localeDicts[locale];
    }

    public function new()
    {
    }
}

