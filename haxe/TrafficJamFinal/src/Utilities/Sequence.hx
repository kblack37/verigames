package utilities;

import haxe.Constraints.Function;
import flash.events.Event;
import mx.collections.ArrayCollection;

/**
	 * Class to perform functions in a set order
	 */
class Sequence extends ArrayCollection
{
    public static inline var SEQUENCE_ADVANCED : String = "SequenceAdvancedEvent";
    private var m_index : Int = -1;
    private var m_immediateScheduleIndex : Int = -1;
    
    /**
		 * Class to perform functions in a set order
		 */
    public function new()
    {
        super();
    }
    
    /**
		 * Schedule a function on the end of the sequence
		 * @param	f Function to schedule
		 * @param	... argumentArray Arguments to call the function with
		 */
    public function schedule(f : Function, argumentArray : Array<Dynamic> = null) : Void
    {
        var arguments : Array<Dynamic> = new Array<Dynamic>();
        //arguments.push(this);
        for (i in 0...argumentArray.length)
        {
            arguments.push(argumentArray[i]);
        }
        addItem(new Pair(f, arguments));
    }
    
    /**
		 * Starting scheduling functions ASAP
		 */
    public function beginSchedulingImmediately() : Void
    {
        m_immediateScheduleIndex = as3hx.Compat.parseInt(m_index + 1);
    }
    
    /**
		 * Schedule this function ASAP (before any other functions, but after previous "immediate" functions)
		 * @param	f
		 * @param	... argumentArray
		 */
    public function scheduleImmediately(f : Function, argumentArray : Array<Dynamic> = null) : Void
    {
        var arguments : Array<Dynamic> = new Array<Dynamic>();
        //arguments.push(this);
        for (i in 0...argumentArray.length)
        {
            arguments.push(argumentArray[i]);
        }
        addItemAt(new Pair(f, arguments), m_immediateScheduleIndex);
        m_immediateScheduleIndex++;
    }
    
    /**
		 * Current index to insert functions
		 * @return
		 */
    public function getIndex() : Int
    {
        return m_index;
    }
    
    /**
		 * Current index to insert functions
		 * @param	i
		 */
    public function setIndex(i : Int) : Void
    {
        m_index = i;
    }
    
    /**
		 * Start inserting at beginning
		 */
    public function resetIndex() : Void
    {
        m_index = -1;
    }
    
    /**
		 * Start inserting at beginning and erase any scheduled functions
		 */
    public function reset() : Void
    {
        removeAll();
        resetIndex();
    }
    
    /**
		 * Call the next function
		 */
    public function advance() : Void
    {
        if (m_index < length)
        {
            dispatchEvent(new Event(SEQUENCE_ADVANCED));
            m_index++;
            this[m_index].first.apply(this, this[m_index].second);
        }
    }
}
