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

import cgs.pblabs.engine.PBUtil;
import cgs.pblabs.engine.core.InputKey;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

//import com.pblabs.engine.PBE;
/**
 * Console UI, which shows console log activity in-game, and also accepts input from the user.
 */
class LogViewer extends Sprite implements ILogAppender
{
    public var maxLength(get, set) : Int;

    private var _messageQueue : Array<Dynamic> = [];
    private var _maxLength : Int = 200000;
    private var _truncating : Bool = false;
    
    private var _width : Int = 500;
    private var _height : Int = 150;
    
    private var _consoleHistory : Array<Dynamic> = [];
    private var _historyIndex : Int = 0;
    
    private var _output : TextField;
    private var _input : TextField;
    
    private var tabCompletionPrefix : String = "";
    private var tabCompletionCurrentStart : Int = 0;
    private var tabCompletionCurrentEnd : Int = 0;
    private var tabCompletionCurrentOffset : Int = 0;
    
    public function new()
    {
        super();
        layout();
        addListeners();
        
        name = "Console";
        Console.registerCommand("clear", onClearCommand, "Clears the console history.");
    }
    
    private function layout() : Void
    {
        if (_output == null)
        {
            createOutputField();
        }
        if (_input == null)
        {
            createInputField();
        }
        
        resize();
        
        addChild(_output);
        addChild(_input);
        
        graphics.clear();
        
        graphics.beginFill(0x666666, .95);
        graphics.drawRoundRect(0, 0, _width, _height, 5);
        graphics.endFill();
        
        graphics.beginFill(0xFFFFFF, 1);
        graphics.drawRoundRect(4, 4, _width - 8, _height - 30, 5);
        graphics.endFill();
    }
    
    private function addListeners() : Void
    {
        _input.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown, false, 1, true);
    }
    
    private function removeListeners() : Void
    {
        _input.removeEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
    }
    
    private function onClearCommand() : Void
    {
        _output.htmlText = "";
    }
    
    private function resize() : Void
    {
        _output.x = 5;
        _output.y = 0;
        _input.x = 5;
        
        if (stage != null)
        {
            _width = as3hx.Compat.parseInt(stage.stageWidth - 1);
            _height = as3hx.Compat.parseInt((stage.stageHeight / 3) * 2);
        }
        
        _output.height = _height - 30;
        _output.width = _width - 10;
        
        _input.height = 18;
        _input.width = _width - 10;
        
        _input.y = _output.height + 7;
    }
    
    private function createOutputField() : TextField
    {
        _output = new TextField();
        _output.type = TextFieldType.DYNAMIC;
        _output.multiline = true;
        _output.wordWrap = true;
        _output.condenseWhite = false;
        var format : TextFormat = _output.getTextFormat();
        format.font = "_typewriter";
        format.size = 11;
        format.color = 0x0;
        _output.setTextFormat(format);
        _output.defaultTextFormat = format;
        _output.htmlText = "";
        _output.embedFonts = false;
        _output.name = "ConsoleOutput";
        
        return _output;
    }
    
    private function createInputField() : TextField
    {
        _input = new TextField();
        _input.type = TextFieldType.INPUT;
        _input.border = true;
        _input.borderColor = 0xFFFFFF;
        _input.multiline = false;
        _input.wordWrap = false;
        _input.condenseWhite = false;
        _input.background = true;
        _input.backgroundColor = 0xFFFFFF;
        var format : TextFormat = _input.getTextFormat();
        format.font = "_typewriter";
        format.size = 11;
        format.color = 0x0;
        _input.setTextFormat(format);
        _input.defaultTextFormat = format;
        _input.restrict = "^`";  // Tilde's are not allowed in the input since they close the window  
        _input.name = "ConsoleInput";
        
        return _input;
    }
    
    private function setHistory(old : String) : Void
    {
        _input.text = old;
        //PBE.callLater(function():void {
        _input.setSelection(_input.length, _input.length);
    }
    
    private function onInputKeyDown(event : KeyboardEvent) : Void
    {
        // If this was a non-tab input, clear tab completion state.
        if (event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.SHIFT)
        {
            tabCompletionPrefix = _input.text;
            tabCompletionCurrentStart = -1;
            tabCompletionCurrentOffset = 0;
        }
        
        if (event.keyCode == Keyboard.ENTER)
        {
            // Execute an entered command.
            if (_input.text.length <= 0)
            {
                // display a blank line
                addLogMessage("CMD", ">", _input.text);
                return;
            }
            
            // If Enter was pressed, process the command
            processCommand();
        }
        else
        {
            if (event.keyCode == Keyboard.UP)
            {
                // Go to previous command.
                if (_historyIndex > 0)
                {
                    setHistory(_consoleHistory[--_historyIndex]);
                }
                else
                {
                    if (_consoleHistory.length > 0)
                    {
                        setHistory(_consoleHistory[0]);
                    }
                }
                
                event.preventDefault();
            }
            else
            {
                if (event.keyCode == Keyboard.DOWN)
                {
                    // Go to next command.
                    if (_historyIndex < _consoleHistory.length - 1)
                    {
                        setHistory(_consoleHistory[++_historyIndex]);
                    }
                    else
                    {
                        if (_historyIndex == _consoleHistory.length - 1)
                        {
                            _input.text = "";
                        }
                    }
                    
                    event.preventDefault();
                }
                else
                {
                    if (event.keyCode == Keyboard.PAGE_UP)
                    {
                        // Page the console view up.
                        _output.scrollV -= Math.floor(_output.height / _output.getLineMetrics(0).height);
                    }
                    else
                    {
                        if (event.keyCode == Keyboard.PAGE_DOWN)
                        {
                            // Page the console view down.
                            _output.scrollV += Math.floor(_output.height / _output.getLineMetrics(0).height);
                        }
                        else
                        {
                            if (event.keyCode == Keyboard.TAB)
                            {
                                // We are doing tab searching.
                                var list : Array<Dynamic> = Console.getCommandList();
                                
                                // Is this the first step?
                                var isFirst : Bool = false;
                                if (tabCompletionCurrentStart == -1)
                                {
                                    tabCompletionPrefix = _input.text.toLowerCase();
                                    tabCompletionCurrentStart = as3hx.Compat.INT_MAX;
                                    tabCompletionCurrentEnd = -1;
                                    
                                    for (i in 0...list.length)
                                    {
                                        // If we found a prefix match...
                                        if (list[i].name.substr(0, tabCompletionPrefix.length).toLowerCase() == tabCompletionPrefix)
                                        {
                                            // Note it.
                                            if (i < tabCompletionCurrentStart)
                                            {
                                                tabCompletionCurrentStart = i;
                                            }
                                            if (i > tabCompletionCurrentEnd)
                                            {
                                                tabCompletionCurrentEnd = i;
                                            }
                                            
                                            isFirst = true;
                                        }
                                    }
                                    
                                    tabCompletionCurrentOffset = tabCompletionCurrentStart;
                                }
                                
                                // If there is a match, tab complete.
                                if (tabCompletionCurrentEnd != -1)
                                {
                                    // Update offset if appropriate.
                                    if (!isFirst)
                                    {
                                        if (event.shiftKey)
                                        {
                                            tabCompletionCurrentOffset--;
                                        }
                                        else
                                        {
                                            tabCompletionCurrentOffset++;
                                        }
                                        
                                        // Wrap the offset.
                                        if (tabCompletionCurrentOffset < tabCompletionCurrentStart)
                                        {
                                            tabCompletionCurrentOffset = tabCompletionCurrentEnd;
                                        }
                                        else
                                        {
                                            if (tabCompletionCurrentOffset > tabCompletionCurrentEnd)
                                            {
                                                tabCompletionCurrentOffset = tabCompletionCurrentStart;
                                            }
                                        }
                                    }
                                    
                                    // Get the match.
                                    var potentialMatch : String = list[tabCompletionCurrentOffset].name;
                                    
                                    // Update the text with the current completion, caret at the end.
                                    _input.text = potentialMatch;
                                    _input.setSelection(potentialMatch.length + 1, potentialMatch.length + 1);
                                }
                                
                                // Make sure we keep focus. TODO: This is not ideal, it still flickers the yellow box.
                                var oldfr : Dynamic = stage.stageFocusRect;
                                stage.stageFocusRect = false;
                                //PBE.callLater(function():void {
                                stage.focus = _input;
                                stage.stageFocusRect = oldfr;
                            }
                            else
                            {
                                if (event.keyCode == InputKey.TILDE.keyCode && !event.ctrlKey)
                                {
                                    // Hide the console window, have to check here due to
                                    // propagation stop at end of function.
                                    parent.removeChild(this);
                                    deactivate();
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Keep console input from propagating up to the stage and messing up the game.
        event.stopImmediatePropagation();
    }
    
    private function truncateOutput() : Void
    {
        // Keep us from exceeding too great a size of displayed text.
        if (_output.text.length > maxLength)
        {
            _output.text = _output.text.slice(-maxLength);
            
            // Display helpful message that we have capped the log length.
            if (!_truncating)
            {
                _truncating = true;
                Logger.warn(this, "truncateOutput", "You have exceeded " + _maxLength + " characters in LogViewerAS. " +
                        "It will now only show the latest " + _maxLength + " characters of the log.");
            }
        }
    }
    
    private function processCommand() : Void
    {
        addLogMessage("CMD", ">", _input.text);
        Console.processLine(_input.text);
        _consoleHistory.push(_input.text);
        _historyIndex = _consoleHistory.length;
        _input.text = "";
    }
    
    public function addLogMessage(level : String, loggerName : String, message : String) : Void
    {
        var color : String = LogColor.getColor(level);
        
        // Cut down on the logger level if verbosity requests.
        if (Console.verbosity < 2)
        {
            var dotIdx : Int = loggerName.lastIndexOf("::");
            if (dotIdx != -1)
            {
                loggerName = loggerName.substr(dotIdx + 2);
            }
        }
        
        var text : String = (((Console.verbosity > 0)) ? level + ": " : "") + loggerName + " - " + message;
        
        if (_output != null)
        {
            //Profiler.enter("LogViewer.addLogMessage");
            
            var append : String = "<p><font size=\"" +
            _input.getTextFormat().size + "\" color=\"" +
            color + "\"><b>" +
            PBUtil.escapeHTMLText(text) + "</b></font></p>";
            
            // We should use appendText but it introduces formatting issues,
            // so we stick with htmlText for now. appendText should be good
            // speed up.
            _output.htmlText += append;
            truncateOutput();
            
            _output.scrollV = _output.maxScrollV;
        }
    }
    
    private function get_maxLength() : Int
    {
        return _maxLength;
    }
    
    private function set_maxLength(value : Int) : Int
    {
        _maxLength = value;
        truncateOutput();
        return value;
    }
    
    public function activate() : Void
    {
        layout();
        _input.text = "";
        addListeners();
        Logger.mainStage.focus = _input;
    }
    
    public function deactivate() : Void
    {
        removeListeners();
        Logger.mainStage.focus = null;
    }
}

