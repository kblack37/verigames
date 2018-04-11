package cgs.server.data;


/**
	 * Data regarding the terms of service status for user.
	 */
interface IUserTosStatus
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

    public function useLinkedTerms() : Void;
    public function updateAcceptance(accept : Bool) : Void;
    public function termsAccepted() : Void;
    public function termsDeclined() : Void;
}
