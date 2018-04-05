package utils;

import flash.utils.Dictionary;
import flash.utils.Timer;

class DebugTimer
{
    public static var DEBUG_TIMER_ON : Bool = false;
    private static var m_timestamps : Dictionary = new Dictionary();
    private static var m_totalTimes : Dictionary = new Dictionary();
    private static var m_timesCalled : Dictionary = new Dictionary();
    
    public static function beginTiming(type : String) : Void
    {
        if (!DEBUG_TIMER_ON)
        {
            return;
        }
        Reflect.setField(m_totalTimes, type, 0.0);
        Reflect.setField(m_timesCalled, type, null);
        beginActivity(type);
    }
    
    public static function beginActivity(type : String) : Void
    {
        if (!DEBUG_TIMER_ON)
        {
            return;
        }
        Reflect.setField(m_timestamps, type, Date.now().time);
        if (Reflect.field(m_timesCalled, type) == null)
        {
            Reflect.setField(m_timesCalled, type, 0);
        }
        Reflect.field(m_timesCalled, type)++;
    }
    
    public static function endActivity(type : String) : Void
    {
        if (!DEBUG_TIMER_ON)
        {
            return;
        }
        if (Reflect.field(m_timestamps, type) != null)
        {
            if (Reflect.field(m_totalTimes, type) != null)
            {
                Reflect.field(m_totalTimes, type) += Date.now().time - Reflect.field(m_timestamps, type);
            }
            else
            {
                Reflect.setField(m_totalTimes, type, Date.now().time - Reflect.field(m_timestamps, type));
            }
            Reflect.setField(m_timestamps, type, null);
        }
    }
    
    public static function reportTime(type : String) : Void
    {
        if (!DEBUG_TIMER_ON)
        {
            return;
        }
        if (Reflect.field(m_timestamps, type) != null)
        {
            endActivity(type);
        }
        if (Reflect.field(m_totalTimes, type) == null)
        {
            return;
        }
        trace("~~~~~~~ " + type + " took " + Reflect.field(m_totalTimes, type) + " milliseconds to complete, and was called " + Reflect.field(m_timesCalled, type) + " times ~~~~~~~");
    }
    
    public static function reportAllTimes() : Void
    {
        if (!DEBUG_TIMER_ON)
        {
            return;
        }
        for (activity in Reflect.fields(m_totalTimes))
        {
            trace("~~~~~~~ " + activity + " took " + Reflect.field(m_totalTimes, activity) + " milliseconds to complete, and was called " + Reflect.field(m_timesCalled, activity) + " times ~~~~~~~");
        }
    }

    public function new()
    {
    }
}

