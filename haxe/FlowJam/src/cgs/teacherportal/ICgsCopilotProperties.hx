package cgs.teacherportal;

import cgs.user.ICgsUser;

/**
 * @author Ric Gray
 */

typedef ExceptionCallback = Bool->?Dynamic->Void;
typedef OnComplete = Bool->?Dynamic->Void;

typedef StartGameCallback 		= OnComplete -> Dynamic -> Dynamic -> Void; 
typedef StopGameCallback		= OnComplete->Dynamic->Void;
typedef PauseGameCallback		= OnComplete->Bool->Dynamic->Void;
typedef UserAddedCallback		= OnComplete->ICgsUser->Void;
typedef UserRemovedCallback 	= OnComplete->ICgsUser->Void;
typedef CommandToWidgetCallback = OnComplete->String->String->Void;

interface ICgsCopilotProperties 
{
    // Required Callbacks
    public var startCallback(get, set) : StartGameCallback;
    public var stopCallback(get, set) : StopGameCallback;
    public var pauseCallback(get, set) : PauseGameCallback;
    public var userAddedCallback(get, set) : UserAddedCallback;
    public var userRemovedCallback(get, set) : UserRemovedCallback;
    public var commandToWidgetCallback(get, set) : CommandToWidgetCallback;
    public var exceptionCallback(get, set) : ExceptionCallback;
  
}