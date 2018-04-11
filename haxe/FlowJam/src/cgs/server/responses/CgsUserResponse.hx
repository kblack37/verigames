package cgs.server.responses;

import cgs.server.logging.IGameServerData;
import cgs.user.CgsUser;
import cgs.user.ICgsUser;

class CgsUserResponse extends CgsResponseStatus
{
    public var registrationResponse(never, set) : ResponseStatus;
    public var pageloadResponse(never, set) : ResponseStatus;
    public var pageloadSuccess(get, never) : Bool;
    public var dataLoadResponse(never, set) : ResponseStatus;
    public var dataLoadSuccess(get, never) : Bool;
    public var abTestingResponse(never, set) : CgsResponseStatus;
    public var authorizationResponse(never, set) : CgsResponseStatus;
    public var uidResponse(never, set) : UidResponseStatus;
    public var homeplaysResponse(get, set) : HomeplayResponse;
    public var cgsUser(get, never) : ICgsUser;

    private var _cgsUser : ICgsUser;
    private var _cgsUserPreInitialized : Bool;
    
    private var _abTestingResponse : ResponseStatus;
    private var _pageloadResponse : ResponseStatus;
    private var _dataLoadResponse : ResponseStatus;
    
    //Response status for retrieving an anonymous uid.
    private var _userResponse : UidResponseStatus;
    
    //Response status for user login.
    private var _userAuthResponse : CgsResponseStatus;
    
    //Response for user registration. Will be null if registration succeeded.
    private var _registrationResponse : ResponseStatus;
    
    private var _homeplays : HomeplayResponse;
    
    public function new(
            cgsUser : ICgsUser, serverData : IGameServerData = null, userPreInitialized : Bool = false)
    {
        super(serverData);
        
        _cgsUser = cgsUser;
        _cgsUserPreInitialized = userPreInitialized;
    }
    
    /**
     * Indicates whether or not the user initialize succeeded. This will be true
     * if the user is initialized with all required data. Pageload failure will
     * not change the value of this parameter. If cache data or ab tests
     * were requested and failed it will cause this to return false.
     */
    override private function get_success() : Bool
    {
        var requestSuccess : Bool = false;
        if (_cgsUserPreInitialized)
        {
            requestSuccess = true;
        }
        else
        {
            if (_userResponse != null)
            {
                requestSuccess = _userResponse.success;
            }
            else
            {
                if (_userAuthResponse != null)
                {
                    requestSuccess = _userAuthResponse.success;
                }
            }
            
            if (_dataLoadResponse != null)
            {
                requestSuccess = requestSuccess && _dataLoadResponse.success;
            }
            
            if (_abTestingResponse != null)
            {
                requestSuccess = requestSuccess && _abTestingResponse.success;
            }
        }
        
        return requestSuccess;
    }
    
    private function set_registrationResponse(response : ResponseStatus) : ResponseStatus
    {
        _registrationResponse = response;
        return response;
    }
    
    private function set_pageloadResponse(response : ResponseStatus) : ResponseStatus
    {
        _pageloadResponse = response;
        return response;
    }
    
    /**
     * Indicates if the pageload was successfully handled.
     *
     * @return true if the pageload request succeeded. Will return false if no
     * pageload was requested for the user.
     */
    private function get_pageloadSuccess() : Bool
    {
        return (_pageloadResponse != null) ? _pageloadResponse.success : false;
    }
    
    private function set_dataLoadResponse(response : ResponseStatus) : ResponseStatus
    {
        _dataLoadResponse = response;
        return response;
    }
    
    private function get_dataLoadSuccess() : Bool
    {
        return (_dataLoadResponse != null) ? _dataLoadResponse.success : false;
    }
    
    private function set_abTestingResponse(response : CgsResponseStatus) : CgsResponseStatus
    {
        _abTestingResponse = response;
        return response;
    }
    
    private function set_authorizationResponse(response : CgsResponseStatus) : CgsResponseStatus
    {
        _userAuthResponse = response;
        return response;
    }
    
    private function set_uidResponse(response : UidResponseStatus) : UidResponseStatus
    {
        _userResponse = response;
        return response;
    }
    
    private function set_homeplaysResponse(response : HomeplayResponse) : HomeplayResponse
    {
        _homeplays = response;
        return response;
    }
    
    private function get_homeplaysResponse() : HomeplayResponse
    {
        return _homeplays;
    }
    
    /**
     * Get the user instance that has been initialized. This is the same
     * user instance returned from CgsApi call to initialize user.
     */
    private function get_cgsUser() : ICgsUser
    {
        return _cgsUser;
    }
    
    //
    // User auth error handling.
    //
    
    /**
     * @inheritDoc
     */
    override private function get_userRegistrationError() : Bool
    {
        return (_userAuthResponse != null) ? 
        _userAuthResponse.userRegistrationError : false;
    }
    
    /**
     * @inheritDoc
     */
    override private function get_userAuthenticationError() : Bool
    {
        return (_userAuthResponse != null) ? 
        _userAuthResponse.userAuthenticationError : false;
    }
    
    /**
     * @inheritDoc
     */
    override private function get_studentSignupLocked() : Bool
    {
        return (_userAuthResponse != null) ? 
        _userAuthResponse.studentSignupLocked : false;
    }
}
