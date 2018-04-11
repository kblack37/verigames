package cgs.server.data;


/**
	 * Data regarding the terms of service status for user.
	 */
class UserTosStatus implements IUserTosStatus
{
    public var tosData(never, set) : TosData;
    public var acceptanceRequired(get, never) : Bool;
    public var accepted(get, never) : Bool;
    public var hasTosLink(get, never) : Bool;
    public var tosKey(get, never) : String;
    public var tosVersion(get, never) : Int;
    public var linkTosText(get, never) : String;
    public var tosLanguageCode(get, never) : String;
    public var tosMd5Hash(get, never) : String;
    public var hasHeader(get, never) : Bool;
    public var hasFooter(get, never) : Bool;
    public var termsBody(get, never) : String;
    public var termsHeader(get, never) : String;
    public var termsFooter(get, never) : String;
    public var htmlTermsBody(get, never) : String;
    public var htmlTermsHeader(get, never) : String;
    public var htmlTermsFooter(get, never) : String;

    //message.addProperty("tos_hash", tosHash);
    
    //Reference to the tos data provider.
    private var _tosData : TosData;
    
    //Terms origingally shown to the user.
    private var _origAcceptTerms : TosItemData;
    
    //Terms currently being shown to the user.
    private var _acceptTerms : TosItemData;
    
    private var _accepted : Bool;
    
    public function new(tosData : TosData, acceptTerms : TosItemData = null)
    {
        _tosData = tosData;
        _acceptTerms = _origAcceptTerms = acceptTerms;
    }
    
    private function set_tosData(value : TosData) : TosData
    {
        _tosData = value;
        return value;
    }
    
    public function useLinkedTerms() : Void
    {
        if (hasTosLink)
        {
            var newAcceptTerms : TosItemData = 
            _tosData.getTosData(_acceptTerms.linkTosKey);
            _acceptTerms = newAcceptTerms;
        }
    }
    
    private function get_acceptanceRequired() : Bool
    {
        return _acceptTerms != null;
    }
    
    private function get_accepted() : Bool
    {
        return _accepted;
    }
    
    public function updateAcceptance(accept : Bool) : Void
    {
        _accepted = accept;
    }
    
    public function termsAccepted() : Void
    {
        _accepted = true;
    }
    
    public function termsDeclined() : Void
    {
        _accepted = false;
    }
    
    /**
		 * Indicates if the current tos has a link to another terms of service.
		 */
    private function get_hasTosLink() : Bool
    {
        return (_acceptTerms != null) ? _acceptTerms.hasTosLink : false;
    }
    
    //TODO - Add delegate methods for the terms. Terms data can not be accessed directly.
    
    private function get_tosKey() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.key : "";
    }
    
    private function get_tosVersion() : Int
    {
        return (_acceptTerms != null) ? _acceptTerms.version : 0;
    }
    
    private function get_linkTosText() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.linkText : null;
    }
    
    private function get_tosLanguageCode() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.languageCode : "";
    }
    
    /**
		 * Get the hash of the terms shown to the user.
		 */
    private function get_tosMd5Hash() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.md5Hash : "";
    }
    
    private function get_hasHeader() : Bool
    {
        return (_acceptTerms != null) ? _acceptTerms.hasHeader : false;
    }
    
    private function get_hasFooter() : Bool
    {
        return (_acceptTerms != null) ? _acceptTerms.hasFooter : false;
    }
    
    private function get_termsBody() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.body : "";
    }
    
    private function get_termsHeader() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.header : "";
    }
    
    private function get_termsFooter() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.footer : "";
    }
    
    private function get_htmlTermsBody() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.htmlBody : "";
    }
    
    private function get_htmlTermsHeader() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.htmlHeader : "";
    }
    
    private function get_htmlTermsFooter() : String
    {
        return (_acceptTerms != null) ? _acceptTerms.htmlFooter : "";
    }
}
