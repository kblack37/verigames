package cgs.server.logging.actions;

import flash.events.TimerEvent;
import flash.utils.Timer;

class DefaultActionBufferHandler implements IActionBufferHandler
{
    public var listener(never, set) : IActionBufferListener;

    private var _timer : Timer;
    
    private var _listener : IActionBufferListener;
    
    private var _elapsedTime : Float;
    
    //Time used at the start of the buffer handler for a level.
    private var _minTime : Float;
    
    //Time used to send actions after the ramp time has elapsed.
    private var _maxTime : Float;
    
    //Time it takes to change from the min time for sending actions to the max time.
    private var _rampTime : Float;
    
    public function new()
    {
        _elapsedTime = 0;
    }
    
    /**
		 * Set the timing properties for the action buffer handler.
		 * 
		 * @param startBufferTime time (ms) it takes for actions to be flushed at start of quest.
		 * @param endBufferTime time (ms) it takes for actions to be flushed at end of ramp time.
		 * @param rampTime time (ms) it takes to change from start buffer time to end time.
		 */
    public function setProperties(startBufferTime : Float, endBufferTime : Float, rampTime : Float) : Void
    {
        _minTime = startBufferTime;
        _maxTime = endBufferTime;
        _rampTime = rampTime;
    }
    
    //Handle flushing actions and reseting the timer to flush actions again.
    private function handleTimer(evt : TimerEvent) : Void
    {
        if (_listener != null)
        {
            _listener.flushActions();
        }
        
        if (_elapsedTime < _rampTime)
        {
            _elapsedTime += _timer.delay;
            if (_elapsedTime > _rampTime)
            {
                _elapsedTime = _rampTime;
            }
        }
        _timer.reset();
        _timer.delay = getNextFlushTime();
        //trace("Starting new buffer flush timer with time: " + _timer.delay + " (ms)");
        _timer.start();
    }
    
    //Get the time it should take for the next flush of user actions.
    private function getNextFlushTime() : Float
    {
        if (_rampTime == 0)
        {
            return _maxTime;
        }
        
        return ((_elapsedTime / _rampTime) * (_maxTime - _minTime)) + _minTime;
    }
    
    //
    // Interface methods.
    //
    
    /**
		 * @inheritDoc
		 */
    private function set_listener(value : IActionBufferListener) : IActionBufferListener
    {
        _listener = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		 */
    public function start() : Void
    {
        if (_timer == null)
        {
            _timer = new Timer(getNextFlushTime(), 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimer);
        }
        
        //trace("Starting buffer flush timer with time: " + _timer.delay + " (ms)");
        _timer.start();
    }
    
    /**
		 * @inheritDoc
		 */
    public function stop() : Void
    {
        if (_timer != null)
        {
            _timer.stop();
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        _elapsedTime = 0;
        if (_timer != null)
        {
            _timer.reset();
            _timer.delay = getNextFlushTime();
        }
    }
    
    //Not used.
    public function onTick(delta : Float) : Void
    {
    }
}
