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

import cgs.pblabs.engine.serialization.TypeUtility;
import flash.display.Stage;
import haxe.CallStack;

/**
 * The Logger class provides mechanisms to print and listen for errors, warnings,
 * and general messages. The built in 'trace' command will output messages to the
 * console, but this allows you to differentiate between different types of
 * messages, give more detailed information about the origin of the message, and
 * listen for log events so they can be displayed in a UI component.
 * 
 * You can use Logger for localized logging by instantiating an instance and
 * referencing it. For instance:
 * 
 * <code>protected static var logger:Logger = new Logger(MyClass);
 * logger.print("Output for MyClass.");</code>
 *  
 * @see LogEntry
 */
class Logger
{
    private static var listeners : Array<Dynamic> = [];
    private static var started : Bool = false;
    private static var pendingEntries : Array<Dynamic> = [];
    private static var disabled : Bool = false;
    
    public static var mainStage : Stage = null;
    
    /**
     * Register a ILogAppender to be called back whenever log messages occur.
     */
    public static function registerListener(listener : ILogAppender) : Void
    {
        listeners.push(listener);
    }
    
    /**
     * Initialize the logging system.
		 * 
		 * @param stage the main stage which is used to display the log viewer.
     */
    public static function startup(stage : Stage) : Void
    {
        if (started)
        {
            return;
        }
        
        mainStage = stage;
        
        // Put default listeners into the list.
        registerListener(new TraceAppender());
        
        //if(!PBE.IS_SHIPPING_BUILD)
        registerListener(new UIAppender());
        
        // Process pending messages.
        started = true;
        for (i in 0...pendingEntries.length)
        {
            processEntry(pendingEntries[i]);
        }
        
        // Free up the pending entries memory.
        as3hx.Compat.setArrayLength(pendingEntries, 0);
        pendingEntries = null;
    }
    
    /**
     * Call to destructively disable logging. This is useful when going
     * to production, when you want to remove all logging overhead.
     */
    public static function disable() : Void
    {
        pendingEntries = null;
        started = false;
        listeners = null;
        disabled = true;
    }
    
    private static function processEntry(entry : LogEntry) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        // If we aren't started yet, just store it up for later processing.
        if (!started)
        {
            pendingEntries.push(entry);
            return;
        }
        
        // Let all the listeners process it.
        for (i in 0...listeners.length)
        {
            (try cast(listeners[i], ILogAppender) catch(e:Dynamic) null).addLogMessage(entry.type, TypeUtility.getObjectClassName(entry.reporter), entry.message);
        }
    }
    
    /**
     * Prints a general message to the log. Log entries created with this method
     * will have the MESSAGE type.
     * 
     * @param reporter The object that reported the message. This can be null.
     * @param message The message to print to the log.
     */
    public static function print(reporter : Dynamic, message : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.message = message;
        entry.type = LogEntry.MESSAGE;
        processEntry(entry);
    }
    
    /**
		 * Prints an info message to the log. Log entries created with this method
		 * will have the INFO type.
		 * 
		 * @param reporter The object that reported the warning. This can be null.
		 * @param method The name of the method that the warning was reported from.
		 * @param message The warning to print to the log.
		 */
    public static function info(reporter : Dynamic, method : String, message : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.method = method;
        entry.message = method + " - " + message;
        entry.type = LogEntry.INFO;
        processEntry(entry);
    }
    
    /**
		 * Prints a debug message to the log. Log entries created with this method
		 * will have the DEBUG type.
		 * 
		 * @param reporter The object that reported the debug message. This can be null.
		 * @param method The name of the method that the debug message was reported from.
		 * @param message The debug message to print to the log.
		 */
    public static function debug(reporter : Dynamic, method : String, message : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.method = method;
        entry.message = method + " - " + message;
        entry.type = LogEntry.DEBUG;
        processEntry(entry);
    }
    
    /**
     * Prints a warning message to the log. Log entries created with this method
     * will have the WARNING type.
     * 
     * @param reporter The object that reported the warning. This can be null.
     * @param method The name of the method that the warning was reported from.
     * @param message The warning to print to the log.
     */
    public static function warn(reporter : Dynamic, method : String, message : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.method = method;
        entry.message = method + " - " + message;
        entry.type = LogEntry.WARNING;
        processEntry(entry);
    }
    
    /**
     * Prints an error message to the log. Log entries created with this method
     * will have the ERROR type.
     * 
     * @param reporter The object that reported the error. This can be null.
     * @param method The name of the method that the error was reported from.
     * @param message The error to print to the log.
     */
    public static function error(reporter : Dynamic, method : String, message : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.method = method;
        entry.message = method + " - " + message;
        entry.type = LogEntry.ERROR;
        processEntry(entry);
    }
    
    /**
     * Prints a message to the log. Log enthries created with this method will have
     * the type specified in the 'type' parameter.
     * 
     * @param reporter The object that reported the message. This can be null.
     * @param method The name of the method that the error was reported from.
     * @param message The message to print to the log.
     * @param type The custom type to give the message.
     */
    public static function printCustom(reporter : Dynamic, method : String, message : String, type : String) : Void
    {
        // Early out if we are disabled.
        if (disabled)
        {
            return;
        }
        
        var entry : LogEntry = new LogEntry();
        entry.reporter = TypeUtility.getClass(reporter);
        entry.method = method;
        entry.message = method + " - " + message;
        entry.type = type;
        processEntry(entry);
    }
    
    /**
     * Utility function to get the current callstack. Only works in debug build.
     * Useful for noting who called what. Empty when in release build.
     */
    public static function getCallStack() : String
    {
		return CallStack.toString();
    }
    
    public static function printHeader(report : Dynamic, message : String) : Void
    {
        print(report, message);
    }
    
    public static function printFooter(report : Dynamic, message : String) : Void
    {
        print(report, message);
    }
    
    public var enabled : Bool;
    private var owner : Class<Dynamic>;
    
    public function new(_owner : Class<Dynamic>, defaultEnabled : Bool = true)
    {
        owner = _owner;
        enabled = defaultEnabled;
    }
    
    public function info(method : String, message : String) : Void
    {
        if (enabled)
        {
            Logger.info(owner, method, message);
        }
    }
    
    public function warn(method : String, message : String) : Void
    {
        if (enabled)
        {
            Logger.warn(owner, method, message);
        }
    }
    
    public function error(method : String, message : String) : Void
    {
        if (enabled)
        {
            Logger.error(owner, method, message);
        }
    }
    
    public function print(message : String) : Void
    {
        if (enabled)
        {
            Logger.print(owner, message);
        }
    }
}
