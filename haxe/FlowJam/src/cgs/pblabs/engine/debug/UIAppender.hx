/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine.debug;

import cgs.pblabs.engine.core.InputKey;
import openfl.display.DisplayObjectContainer;
import openfl.events.KeyboardEvent;

/**
	 * LogAppender for displaying log messages in a LogViewer. The LogViewer will be
 * attached and detached from the main view when the defined hot key is pressed. The tilde (~) key 
	 * is the default hot key.
	 */
class UIAppender implements ILogAppender
{
    public static var hotKey(never, set) : Int;

    private static var _hotKey : Int;
    
    private var _logViewer : LogViewer;
    
    public function new()
    {
        //PBE.inputManager.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        Logger.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        
        _hotKey = InputKey.TILDE.keyCode;
        _logViewer = new LogViewer();
    }
    
    private function onKeyDown(event : KeyboardEvent) : Void
    {
        if (event.keyCode != _hotKey || event.ctrlKey)
        {
            return;
        }
        
        if (_logViewer != null)
        {
            if (_logViewer.parent)
            {
                _logViewer.parent.removeChild(_logViewer);
                _logViewer.deactivate();
            }
            else
            {
                Logger.mainStage.addChild(_logViewer);
                _logViewer.activate();
            }
        }
    }
    
    public function addLogMessage(level : String, loggerName : String, message : String) : Void
    {
        if (_logViewer != null)
        {
            _logViewer.addLogMessage(level, loggerName, message);
        }
    }
    
    /**
		 * The keycode to toggle the UIAppender interface.
		 */
    private static function set_hotKey(value : Int) : Int
    {
        Logger.print(UIAppender, "Setting hotKey to: " + value);
        _hotKey = value;
        return value;
    }
}
