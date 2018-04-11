package cgs.pblabs.engine.debug;

import cgs.pblabs.engine.core.InputKey;
import cgs.pblabs.engine.core.Sprintf;
import cgs.utils.Error;

/**
* Simple, static hierarchical block profiler.
*
* Currently it is hardwired to start measuring when you press P, and dump
* results to the log when you let go of P. Eventually something more
* intelligent will be appropriate.
*
* Use it by calling Profiler.enter("CodeSectionName"); before the code you
* wish to measure, and Profiler.exit("CodeSectionName"); afterwards. Note
* that Enter/Exit calls must be matched - and if there are any branches, like
* an early return; statement, you will need to add a call to Profiler.exit()
* before the return.
*
* Min/Max/Average times are reported in milliseconds, while total and non-sub
* times (times including children and excluding children respectively) are
* reported in percentages of total observed time.
*/
class Profiler
{
    public static var enabled : Bool = false;
    public static var nameFieldWidth : Int = 50;
    public static var indentAmount : Int = 3;
    
    public static var profileEnabled : Bool = false;
    
    public static function startProfiling() : Void
    {
        profileEnabled = true;
    }
    
    public static function endProfiling() : Void
    {
        profileEnabled = false;
    }
    
    /**
       * Indicate we are entering a named execution block.
       */
    public static function enter(blockName : String) : Void
    {
        //if(!enabled) return;
        
        if (!_currentNode)
        {
            _rootNode = new ProfileInfo("Root");
            _currentNode = _rootNode;
        }
        
        // If we're at the root then we can update our internal enabled state.
        if (_stackDepth == 0)
        {
            // Hack - if they press, then release insert, start/stop and dump
            // the profiler.
            if (profileEnabled)
            {
                if (!enabled)
                {
                    _wantWipe = true;
                    enabled = true;
                }
            }
            else
            {
                if (enabled)
                {
                    _wantReport = true;
                    enabled = false;
                }
            }
            
            _reallyEnabled = enabled;
            
            if (_wantWipe)
            {
                doWipe();
            }
            
            if (_wantReport)
            {
                doReport();
            }
        }
        
        // Update stack depth and early out.
        _stackDepth++;
        if (!_reallyEnabled)
        {
            return;
        }
        
        // Look for child; create if absent.
        var newNode : ProfileInfo = _currentNode.children[blockName];
        if (newNode == null)
        {
            newNode = new ProfileInfo(blockName, _currentNode);
            _currentNode.children[blockName] = newNode;
        }
        
        // Push onto stack.
        _currentNode = newNode;
        
        // Start timing the child node. Too bad you can't QPC from Flash. ;)
        _currentNode.startTime = flash.utils.getTimer();
    }
    
    /**
       * Indicate we are exiting a named exection block.
       */
    public static function exit(blockName : String) : Void
    {
        //if(!enabled) return;
        // Update stack depth and early out.
        _stackDepth--;
        if (!_reallyEnabled)
        {
            return;
        }
        
        if (blockName != _currentNode.name)
        {
            throw new Error("Mismatched Profiler.enter/Profiler.exit calls, got '" + _currentNode.name + "' but was expecting '" + blockName + "'");
        }
        
        // Update stats for this node.
        var elapsedTime : Int = as3hx.Compat.parseInt(flash.utils.getTimer() - _currentNode.startTime);
        _currentNode.activations++;
        _currentNode.totalTime += elapsedTime;
        if (elapsedTime > _currentNode.maxTime)
        {
            _currentNode.maxTime = elapsedTime;
        }
        if (elapsedTime < _currentNode.minTime)
        {
            _currentNode.minTime = elapsedTime;
        }
        
        // Pop the stack.
        _currentNode = _currentNode.parent;
    }
    
    /**
       * Dumps statistics to the log next time we reach bottom of stack.
       */
    public static function report() : Void
    {
        if (_stackDepth)
        {
            _wantReport = true;
            return;
        }
        
        doReport();
    }
    
    /**
       * Reset all statistics to zero.
       */
    public static function wipe() : Void
    {
        if (_stackDepth)
        {
            _wantWipe = true;
            return;
        }
        
        doWipe();
    }
    
    /**
       * Call this outside of all Enter/Exit calls to make sure that things
       * have not gotten unbalanced. If all enter'ed blocks haven't been
       * exit'ed when this function has been called, it will give an error.
       *
       * Useful for ensuring that profiler statements aren't mismatched.
       */
    public static function ensureAtRoot() : Void
    {
        //if(!enabled) return;
        if (_stackDepth)
        {
            throw new Error("Not at root!");
        }
    }
    
    private static function doReport() : Void
    {
        _wantReport = false;
        
        var header : String = sprintf("%-" + nameFieldWidth + "s%-8s%-8s%-8s%-8s%-8s%-8s", "name", "Calls", "Total%", "NonSub%", "AvgMs", "MinMs", "MaxMs");
        Logger.print(Profiler, header);
        report_R(_rootNode, 0);
    }
    
    private static function report_R(pi : ProfileInfo, indent : Int) : Void
    {
        // Figure our display values.
        var selfTime : Float = pi.totalTime;
        
        var hasKids : Bool = false;
        var totalTime : Float = 0;
        for (childPi/* AS3HX WARNING could not determine type for var: childPi exp: EField(EIdent(pi),children) type: null */ in pi.children)
        {
            hasKids = true;
            selfTime -= childPi.totalTime;
            totalTime += childPi.totalTime;
        }
        
        // Fake it if we're root.
        if (pi.name == "Root")
        {
            pi.totalTime = totalTime;
        }
        
        var displayTime : Float = -1;
        if (pi.parent)
        {
            displayTime = as3hx.Compat.parseFloat(pi.totalTime) / as3hx.Compat.parseFloat(_rootNode.totalTime) * 100;
        }
        
        var displayNonSubTime : Float = -1;
        if (pi.parent)
        {
            displayNonSubTime = selfTime / as3hx.Compat.parseFloat(_rootNode.totalTime) * 100;
        }
        
        // Print us.
        var entry : String = null;
        if (indent == 0)
        {
            entry = "+Root";
        }
        else
        {
            entry = sprintf("%-" + (indent * indentAmount) + "s%-" + (nameFieldWidth - indent * indentAmount) + "s%-8s%-8s%-8s%-8s%-8s%-8s", "", 
                            ((hasKids) ? "+" : "-") + pi.name, pi.activations, as3hx.Compat.toFixed(displayTime, 2), as3hx.Compat.toFixed(displayNonSubTime, 2), (as3hx.Compat.parseFloat(pi.totalTime) / as3hx.Compat.parseFloat(pi.activations)).toFixed(1), pi.minTime, pi.maxTime
                );
        }
        Logger.print(Profiler, entry);
        
        // Sort and draw our kids.
        var tmpArray : Array<Dynamic> = new Array<Dynamic>();
        for (childPi/* AS3HX WARNING could not determine type for var: childPi exp: EField(EIdent(pi),children) type: null */ in pi.children)
        {
            tmpArray.push(childPi);
        }
        tmpArray.sortOn("totalTime", Array.NUMERIC | Array.DESCENDING);
        for (childPi in tmpArray)
        {
            report_R(childPi, indent + 1);
        }
    }
    
    private static function doWipe(pi : ProfileInfo = null) : Void
    {
        _wantWipe = false;
        
        if (pi == null)
        {
            doWipe(_rootNode);
            return;
        }
        
        pi.wipe();
        for (childPi/* AS3HX WARNING could not determine type for var: childPi exp: EField(EIdent(pi),children) type: null */ in pi.children)
        {
            doWipe(childPi);
        }
    }
    
    /**
       * Because we have to keep the stack balanced, we can only enabled/disable
       * when we return to the root node. So we keep an internal flag.
       */
    private static var _reallyEnabled : Bool = true;
    private static var _wantReport : Bool = false;private static var _wantWipe : Bool = false;
    private static var _stackDepth : Int = 0;
    
    private static var _rootNode : ProfileInfo;
    private static var _currentNode : ProfileInfo;

    public function new()
    {
    }
}


@:final class ProfileInfo
{
    public var name : String;
    public var children : Dynamic = { };
    public var parent : ProfileInfo;
    
    public var startTime : Int;public var totalTime : Int;public var activations : Int;
    public var maxTime : Int = as3hx.Compat.INT_MIN;
    public var minTime : Int = as3hx.Compat.INT_MAX;
    
    @:final public function new(n : String, p : ProfileInfo = null)
    {
        name = n;
        parent = p;
    }
    
    @:final public function wipe() : Void
    {
        startTime = totalTime = activations = 0;
        maxTime = as3hx.Compat.INT_MIN;
        minTime = as3hx.Compat.INT_MAX;
    }
}