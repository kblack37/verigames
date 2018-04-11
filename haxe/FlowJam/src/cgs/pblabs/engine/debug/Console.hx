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

import haxe.Constraints.Function;
import cgs.pblabs.engine.serialization.TypeUtility;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.system.Security;

/*import com.pblabs.engine.PBE;
import com.pblabs.engine.core.IPBObject;
import com.pblabs.engine.core.PBGroup;
import com.pblabs.engine.core.PBObject;
import com.pblabs.engine.core.PBSet;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;*/
/**
 * Process simple text commands from the user. Useful for debugging.
 */
class Console
{
    /**
     * The commands, indexed by name. 
     */
    private static var commands : Dynamic = { };
    
    /**
     * Alphabetically ordered list of commands.
     */
    private static var commandList : Array<Dynamic> = [];
    private static var commandListOrdered : Bool = false;
    
    private static var _stats : Stats;
    
    public static var verbosity : Int = 0;
    
    
    /**
     * Register a command which the user can execute via the console.
     * 
     * <p>Arguments are parsed and cast to match the arguments in the user's
     * function. Command names must be alphanumeric plus underscore with no
     * spaces.</p>
     *  
     * @param name The name of the command as it will be typed by the user. No spaces.
     * @param callback The function that will be called. Can be anonymous.
     * @param docs A description of what the command does, its arguments, etc.
     * 
     */
    public static function registerCommand(name : String, callback : Function, docs : String = null) : Void
    {
        // Sanity checks.
        if (callback == null)
        {
            Logger.error(Console, "registerCommand", "Command '" + name + "' has no callback!");
        }
        
        if (name == null || name.length == 0)
        {
            Logger.error(Console, "registerCommand", "Command has no name!");
        }
        
        if (name.indexOf(" ") != -1)
        {
            Logger.error(Console, "registerCommand", "Command '" + name + "' has a space in it, it will not work.");
        }
        
        // Fill in description.
        var c : ConsoleCommand = new ConsoleCommand();
        c.name = name;
        c.callback = callback;
        c.docs = docs;
        
        if (Reflect.field(commands, Std.string(name.toLowerCase())) != null)
        {
            Logger.warn(Console, "registerCommand", "Replacing existing command '" + name + "'.");
        }
        
        // Set it.
        Reflect.setField(commands, Std.string(name.toLowerCase()), c);
        
        // Update the list.
        commandList.push(c);
        commandListOrdered = false;
    }
    
    /**
     * @return An alphabetically sorted list of all the console commands.
     */
    public static function getCommandList() : Array<Dynamic>
    {
        ensureCommandsOrdered();
        
        return commandList;
    }
    
    /**
     * Take a line of console input and process it, executing any command.
     * @param line String to parse for command.
     */
    public static function processLine(line : String) : Void
    {
        // Make sure everything is in order.
        ensureCommandsOrdered();
        
        // Split it by spaces.
        var args : Array<Dynamic> = line.split(" ");
        
        // Look up the command.
        if (args.length == 0)
        {
            return;
        }
        var potentialCommand : ConsoleCommand = Reflect.field(commands, Std.string(Std.string(args[0]).toLowerCase()));
        
        if (potentialCommand == null)
        {
            Logger.warn(Console, "processLine", "No such command '" + Std.string(args[0]) + "'!");
            return;
        }
        
        // Now call the command.
        try
        {
            potentialCommand.callback.apply(null, args.slice(1));
        }
        catch (e)
        {
            Logger.error(Console, args[0], "Error: " + Std.string(e) + " - " + e.getStackTrace());
        }
    }
    
    /**
     * Internal initialization, this will get called on its own. 
     */
    public static function init() : Void
    {
        registerCommand("help", function(prefix : String = null) : Void
                {
                    // Get commands in alphabetical order.
                    ensureCommandsOrdered();
                    
                    Logger.print(Console, "Keyboard shortcuts: ");
                    Logger.print(Console, "[SHIFT]-TAB - Cycle through autocompleted commands.");
                    Logger.print(Console, "PGUP/PGDN   - Page log view up/down a page.");
                    Logger.print(Console, "");
                    
                    // Display results.
                    Logger.print(Console, "Commands:");
                    for (i in 0...commandList.length)
                    {
                        var cc : ConsoleCommand = try cast(commandList[i], ConsoleCommand) catch(e:Dynamic) null;
                        
                        // Do prefix filtering.
                        if (prefix != null && prefix.length > 0 && cc.name.substr(0, prefix.length) != prefix)
                        {
                            continue;
                        }
                        
                        Logger.print(Console, "   " + cc.name + " - " + ((cc.docs) ? cc.docs : ""));
                    }
                }, "[prefix] - List known commands, optionally filtering by prefix.");
        
        /*registerCommand("version", function():void
        {
        Logger.print(Console, PBE.versionDetails.toString());
        }, "Echo PushButton Engine version information.");*/
        
        registerCommand("fps", function() : Void
                {
                    if (_stats == null)
                    {
                        _stats = new Stats();
                        //PBE.mainStage.addChild(_stats);
                        Logger.print(Console, "Enabled FPS display.");
                    }
                    else
                    {
                        //PBE.mainStage.removeChild(_stats);
                        _stats = null;
                    }
                }, "Toggle an FPS/Memory usage indicator.");
        
        registerCommand("verbose", function(level : Int) : Void
                {
                    Console.verbosity = level;
                    Logger.print(Console, "Verbosity set to " + level);
                }, "Set verbosity level of console output.");
    }
    
    private static function ensureCommandsOrdered() : Void
    {
        // Avoid extra work.
        if (commandListOrdered == true)
        {
            return;
        }
        
        // Register default commands.
        if (commands.help == null)
        {
            init();
        }
        
        // Note we are done.
        commandListOrdered = true;
        
        // Do the sort.
        commandList.sort(function(a : ConsoleCommand, b : ConsoleCommand) : Int
                {
                    if (a.name > b.name)
                    {
                        return 1;
                    }
                    else
                    {
                        return -1;
                    }
                });
    }
    
    private static function _listDisplayObjects(current : DisplayObject, indent : Int) : Int
    {
        if (current == null)
        {
            return 0;
        }
        
        Logger.print(Console, 
                Console.generateIndent(indent) +
                current.name +
                " (" + current.x + "," + current.y + ") visible=" +
                current.visible
        );
        
        var parent : DisplayObjectContainer = try cast(current, DisplayObjectContainer) catch(e:Dynamic) null;
        if (parent == null)
        {
            return 1;
        }
        
        var sum : Int = 1;
        for (i in 0...parent.numChildren)
        {
            sum += _listDisplayObjects(parent.getChildAt(i), indent + 1);
        }
        return sum;
    }
    
    /*protected static function _listPBObjects(current:IPBObject, indent:int):int
    {
    if (!current)
    return 0;
    
    var type:String = " ("+ TypeUtility.getObjectClassName(current) +")";
    if(current.name || current.alias)
    {
    Logger.print(Console, 
    Console.generateIndent(indent) + 
    current.name + type + (current.alias != null ? " alias = " + current.alias : ""));
    }
    else
    {
    Logger.print(Console, 
    Console.generateIndent(indent) + 
    "[anonymous]" + type);                
    }
    
    // Recurse if it's a known type.
    var parentSet:PBSet = current as PBSet;
    var parentGroup:PBGroup = current as PBGroup;
    var parentEntity:IEntity = current as IEntity;
    
    var sum:int = 1;
			var i:int = 0;

    if(parentSet)
    {
    for(i=0; i<parentSet.length; i++)
    sum += _listPBObjects(parentSet.getItem(i), indent+1);
    }
    else if(parentGroup)
    {
    for(i=0; i<parentGroup.length; i++)
    sum += _listPBObjects(parentGroup.getItem(i), indent+1);
    }
    else if(parentEntity)
    {
    // Get all the components. Components don't count for the sum.
    var c:Array = parentEntity.lookupComponentsByType(IEntityComponent);
    for(i=0; i<c.length; i++)
    {
    var iec:IEntityComponent = c[i] as IEntityComponent;
    type = " ("+ TypeUtility.getObjectClassName(iec) +")";
    Logger.print(Console, Console.generateIndent(indent + 1) + iec.name + type);
    }
    }
    
    return sum;
    }*/
    
    private static function generateIndent(indent : Int) : String
    {
        var str : String = "";
        for (i in 0...indent)
        {
            // Add 2 spaces for indent
            str += "  ";
        }
        
        return str;
    }

    public function new()
    {
    }
}


@:final class ConsoleCommand
{
    public var name : String;
    public var callback : Function;
    public var docs : String;

    public function new()
    {
    }
}