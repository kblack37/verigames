package cgs.server.data;

import flash.utils.ByteArray;
import haxe.crypto.Md5;

/**
	 * Data for a single terms of service.
	 */
class TosItemData
{
    public var body(get, never) : String;
    public var md5Hash(get, never) : String;
    private var hashString(get, never) : String;
    public var hasHeader(get, never) : Bool;
    public var header(get, never) : String;
    public var hasFooter(get, never) : Bool;
    public var footer(get, never) : String;
    public var htmlHeader(get, never) : String;
    public var htmlBody(get, never) : String;
    public var htmlFooter(get, never) : String;
    public var hasTosLink(get, never) : Bool;
    public var linkTosKey(get, never) : String;
    public var linkText(get, never) : String;
    public var isLatestVersion(get, never) : Bool;
    public var key(get, never) : String;
    public var version(get, never) : Int;
    public var languageCode(get, never) : String;

    //Indicates the latest version of the terms.
    private var _latestVersion : Int;
    
    private var _key : String;
    
    //Link to different terms.
    private var _linkKey : String;
    private var _linkText : String;
    
    private var _version : Int;
    
    private var _termsHeader : String;
    private var _terms : String;
    private var _termsFooter : String;
    
    private var _htmlTermsHeader : String;
    private var _htmlTerms : String;
    private var _htmlTermsFooter : String;
    
    private var _lanCode : String;
    
    private function get_body() : String
    {
        return _terms;
    }
    
    private function get_md5Hash() : String
    {
		return Md5.encode(hashString);

    }
    
    private function get_hashString() : String
    {
        var value : String = "";
        if (hasHeader)
        {
            value += _termsHeader;
        }
        value += _terms;
        if (hasFooter)
        {
            value += _termsFooter;
        }
        
        return value;
    }
    
    private function get_hasHeader() : Bool
    {
        if (_termsHeader == null)
        {
            return false;
        }
        
        return _termsHeader.length > 0;
    }
    
    private function get_header() : String
    {
        return _termsHeader;
    }
    
    private function get_hasFooter() : Bool
    {
        if (_termsFooter == null)
        {
            return false;
        }
        
        return _termsFooter.length > 0;
    }
    
    private function get_footer() : String
    {
        return _termsFooter;
    }
    
    private function get_htmlHeader() : String
    {
        return _htmlTermsHeader;
    }
    
    private function get_htmlBody() : String
    {
        return _htmlTerms;
    }
    
    private function get_htmlFooter() : String
    {
        return _htmlTermsFooter;
    }
    
    private function get_hasTosLink() : Bool
    {
        return _linkKey != null;
    }
    
    private function get_linkTosKey() : String
    {
        return _linkKey;
    }
    
    private function get_linkText() : String
    {
        return _linkText;
    }
    
    private function get_isLatestVersion() : Bool
    {
        return _version == _latestVersion;
    }
    
    private function get_key() : String
    {
        return _key;
    }
    
    private function get_version() : Int
    {
        return _version;
    }
    
    private function get_languageCode() : String
    {
        return _lanCode;
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {
        _key = data.tos_key;
        _version = data.version;
        _lanCode = data.language_code;
        
        _termsHeader = data.header;
        _terms = data.body;
        _termsFooter = data.footer;
        
        _htmlTermsHeader = data.html_header;
        _htmlTerms = data.html_body;
        _htmlTermsFooter = data.html_footer;
        
        if (Reflect.hasField(data, "latest_version"))
        {
            _latestVersion = data.latest_version;
        }
        if (Reflect.hasField(data, "link_tos_key"))
        {
            _linkKey = data.link_tos_key;
        }
        if (Reflect.hasField(data, "link_text"))
        {
            _linkText = data.link_text;
        }
    }

    public function new()
    {
    }
}
