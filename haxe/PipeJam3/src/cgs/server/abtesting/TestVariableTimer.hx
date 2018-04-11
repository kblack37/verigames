package cgs.server.abtesting;
import haxe.ds.StringMap;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class TestVariableTimer
{
    private var _timer : Timer;
    
    private var _timerDelay : Int = 200;
    
    private var _varTimers : StringMap<VariableTimer>;
    private var _timedVarCount : Int;
    
    public function new()
    {
        _varTimers = new StringMap<VariableTimer>();
    }
    
    public function startVariableTimer(varName : String) : Void
    {
        var varTimer : VariableTimer = _varTimers.get(varName);
        if (varTimer == null)
        {
            varTimer = addVariableTimer(varName);
        }
        
        varTimer.start();
    }
    
    private function addVariableTimer(varName : String) : VariableTimer
    {
        var varTimer : VariableTimer = new VariableTimer();
        _varTimers.set(varName, varTimer);
        
        if (_timedVarCount == 0)
        {
            start();
        }
        _timedVarCount++;
        
        return varTimer;
    }
    
    private function removeVariableTimer(varName : String) : VariableTimer
    {
    	var varTimer:VariableTimer = _varTimers.get(varName);
        if (varTimer != null)
        {
            _timedVarCount--;
	    _varTimers.remove(varName);
            
            if (_timedVarCount == 0)
            {
                stop();
            }
        }
        
        return varTimer;
    }
    
    public function pauseVariableTimer(varName : String) : Void
    {
        var varTimer : VariableTimer = _varTimers.get(varName);
        if (varTimer != null)
        {
            varTimer.pause();
        }
    }
    
    public function containsVariableTimer(varName : String) : Bool
    {
        return _varTimers.exists(varName);
    }
    
    /**
		 * End a variable timer and returns the run time of the variable timer.
		 */
    public function endVariableTimer(varName : String) : Float
    {
        var varTimer : VariableTimer = removeVariableTimer(varName);
        
        return (varTimer != null) ? varTimer.elapsedTime : 0;
    }
    
    //
    // Timer handling.
    //
    
    private function onTick(evt : TimerEvent) : Void
    {
        for (varTimer in _varTimers)
        {
            varTimer.onTick(_timerDelay);
        }
    }
    
    public function start() : Void
    {
        if (_timer == null)
        {
            _timer = new Timer(_timerDelay);
            _timer.addEventListener(TimerEvent.TIMER, onTick);
        }
        
        _timer.start();
    }
    
    public function stop() : Void
    {
        if (_timer != null)
        {
            _timer.stop();
	    _timer = null;
        }
    }
}


private class VariableTimer
{
    public var elapsedTime(get, never) : Float;

    private var _elapsedTime : Int;
    
    private var _running : Bool;
    
    @:allow(cgs.server.abtesting)
    private function new()
    {
        _elapsedTime = 0;
        _running = true;
    }
    
    public function onTick(delta : Int) : Void
    {
        if (_running)
        {
            _elapsedTime += delta;
        }
    }
    
    public function pause() : Void
    {
        _running = false;
    }
    
    public function start() : Void
    {
        _running = true;
    }
    
    public function reset() : Void
    {
        _elapsedTime = 0;
        _running = true;
    }
    
    private function get_elapsedTime() : Float
    {
        return _elapsedTime / 1000;
    }
}