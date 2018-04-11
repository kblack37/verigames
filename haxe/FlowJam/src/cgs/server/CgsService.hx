package cgs.server;

import cgs.server.logging.CGSServerConstants;
import cgs.server.requests.IUrlRequestHandler;

/**
 * Service to handle all of the high level functions of communication with cgs
 * servers such as server time.
 */
class CgsService extends RemoteService
{
    public static inline var VERSION_DEV : Int = 3;
    public static inline var VERSION1 : Int = 1;
    public static inline var VERSION2 : Int = 2;
    
    /**
     * The version maps to another directory in the web server housing updated code for requests
     */
    public static inline var CURRENT_VERSION : Int = VERSION2;
    
    /**
     * To avoid mixed content errors in domain using https, we need to consistently append
     * the right http prefix to all requests
     * 
     * Set to true if we should use https
     */
    public var useHttps : Bool;
    
    private var _server : String;
    private var _version : Int;
    
    public function new(requestHandler : IUrlRequestHandler,
            serverTag : String,
            version : Int = CURRENT_VERSION,
            useHttps : Bool = false)
    {
        super(requestHandler);
        
        this.useHttps = useHttps;
        setServer(serverTag, version);
    }
    
    //Setup the urls for the service.
    private function setServer(tag : String, version : Int) : Void
    {
        _server = tag;
        _version = version;
        url = getUrl(tag, version);
    }
    
    /**
     * Override this function in subclasses to set the url to be
     * used for the service.
     */
    private function getUrl(server : String, version : Int) : String
    {
        return CGSServerConstants.GetBaseUrl(server, this.useHttps, version);
    }
}
