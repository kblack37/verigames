package cgs.teacherportal;
import cgs.teacherportal.ICgsCopilotProperties;


/**
 * ...
 * @author Rich
 */
class CgsCopilotProperties implements ICgsCopilotProperties
{
    // Required Callbacks
    public var startCallback(get, set) : StartGameCallback;
    public var stopCallback(get, set) : StopGameCallback;
    public var pauseCallback(get, set) : PauseGameCallback;
    public var userAddedCallback(get, set) : UserAddedCallback;
    public var userRemovedCallback(get, set) : UserRemovedCallback;
    public var commandToWidgetCallback(get, set) : CommandToWidgetCallback;
    public var exceptionCallback(get, set) : ExceptionCallback;

    // Required Callbacks
    private var _startCallback : StartGameCallback;
    private var _stopCallback : StopGameCallback;
    private var _pauseCallback : PauseGameCallback;
    private var _userAddedCallback : UserAddedCallback;
    private var _userRemovedCallback : UserRemovedCallback;
    private var _commandToWidgetCallback : CommandToWidgetCallback;
    
    // Optional Callbacks
    private var _exceptionCallback : ExceptionCallback;
    
    /**
     * Constructor
     * @param startCallback - called when the widget recieves startActivity command
     *          Signature: (onCompleteCallback:Function, activityDefinition:Object, details:Object)
     * @param stopCallback - called when widget recieves stopActivity command
     *          Signature: (onCompleteCallback:Function, details:Object)
     * @param pauseCallback - called when widget recieves pause command
     *          Signature: (onCompleteCallback:Function, paused:Boolean, details:Object)
     * @param userAddedCallback - called when widget recieves addUser command
     *          Signature: (onCompleteCallback:Function, user:ICgsUser, details:Object)
     * @param userRemovedCallback - called when widget recieves removeUser command
     *          Signature: (onCompleteCallback:Function, user:ICgsUser, details:Object)
     * @param commandToWidgetCallback - called when widget recieves commandToWidget command
     *          Signature: (onCompleteCallback:Function, command:String, args:String)
     */
    public function new(
            startCallback : StartGameCallback, stopCallback : StopGameCallback, pauseCallback : PauseGameCallback,
            userAddedCallback : UserAddedCallback, userRemovedCallback : UserRemovedCallback, commandToWidgetCallback : CommandToWidgetCallback)
    {
        //set required callbacks
        _startCallback = startCallback;
        _stopCallback = stopCallback;
        _pauseCallback = pauseCallback;
        _userAddedCallback = userAddedCallback;
        _userRemovedCallback = userRemovedCallback;
        _commandToWidgetCallback = commandToWidgetCallback;
        
        //set optional callbacks
        _exceptionCallback = null;
    }
    
    /**
     * ---------------------------------------------------------------------------------------------------------------------------
     * Required Callbacks
     * ---------------------------------------------------------------------------------------------------------------------------
    **/
    
    /**
     * Returns the start game callback.
     */
    private function get_startCallback() : StartGameCallback
    {
        return _startCallback;
    }
    
    /**
     * Sets the start game callback to be the given value (cannot be null).
     * Function should have the following signature: (onCompleteCallback:Function, activityDefinition:Object, details:Object)
     */
    private function set_startCallback(value : StartGameCallback) : StartGameCallback
    {
        if (value != null)
        {
            _startCallback = value;
        }
        return value;
    }
    
    /**
     * Returns the stop game callback.
     */
    private function get_stopCallback() : StopGameCallback
    {
        return _stopCallback;
    }
    
    /**
     * Sets the stop game callback to be the given value (cannot be null).
     * Function should have the following signature: (onCompleteCallback:Function, details:Object)
     */
    private function set_stopCallback(value : StopGameCallback) : StopGameCallback
    {
        if (value != null)
        {
            _stopCallback = value;
        }
        return value;
    }
    
    /**
     * Returns the pause game callback.
     */
    private function get_pauseCallback() : PauseGameCallback
    {
        return _pauseCallback;
    }
    
    /**
     * Sets the pause game callback to be the given value (cannot be null).
     * Function should have the following signature: (onCompleteCallback:Function, paused:Boolean, details:Object)
     */
    private function set_pauseCallback(value : PauseGameCallback) : PauseGameCallback
    {
        if (value != null)
        {
            _pauseCallback = value;
        }
        return value;
    }
    
    /**
     * Returns the user added callback.
     */
    private function get_userAddedCallback() : UserAddedCallback
    {
        return _userAddedCallback;
    }
    
    /**
     * Sets the user added callback to be the given value.
     * Function should have the following signature: (onCompleteCallback:Function, user:ICgsUser, details:Object)
     */
    private function set_userAddedCallback(value : UserAddedCallback) : UserAddedCallback
    {
        _userAddedCallback = value;
        return value;
    }
    
    /**
     * Returns the user removed callback.
     */
    private function get_userRemovedCallback() : UserRemovedCallback
    {
        return _userRemovedCallback;
    }
    
    /**
     * Sets the user removed callback to be the given value.
     * Function should have the following signature: (onCompleteCallback:Function, user:ICgsUser, details:Object)
     */
    private function set_userRemovedCallback(value : UserRemovedCallback) : UserRemovedCallback
    {
        _userRemovedCallback = value;
        return value;
    }
    
    /**
     * Returns the command callback.
     */
    private function get_commandToWidgetCallback() : CommandToWidgetCallback
    {
        return _commandToWidgetCallback;
    }
    
    /**
     * Sets the command callback to be the given value.
     * Function should have the following signature: (onCompleteCallback:Function, command:String, args:String)
     */
    private function set_commandToWidgetCallback(value : CommandToWidgetCallback) : CommandToWidgetCallback
    {
        _commandToWidgetCallback = value;
        return value;
    }
    
    /**
     * ---------------------------------------------------------------------------------------------------------------------------
     * Optional Callbacks
     * ---------------------------------------------------------------------------------------------------------------------------
    **/
    
    /**
     * Returns the exception callback
     */
    private function get_exceptionCallback() : ExceptionCallback
    {
        return _exceptionCallback;
    }
    
    /**
     * Sets the exception callback to the given value
     * Function should have the following signature: (error:Error)
     */
    private function set_exceptionCallback(value : ExceptionCallback) : ExceptionCallback
    {
        _exceptionCallback = value;
        return value;
    }
}
