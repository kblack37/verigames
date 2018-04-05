package events;

import visualWorld.Pipe;
import flash.events.Event;

class PipeChangeEvent extends Event
{
    public var pipe : Pipe;
    public var m_pipeWidthChange : Bool;
    public var m_buzzSawChange : Bool;
    public var m_stampChange : Bool;
    
    public static inline var PIPE_CHANGE : String = "PIPE_CHANGE";
    
    public function new(p : Pipe, newPipeWidth : Bool = false, buzzSawChange : Bool = false)
    {
        m_pipeWidthChange = newPipeWidth;
        m_buzzSawChange = buzzSawChange;
        pipe = p;
        super(PIPE_CHANGE);
    }
    
    override public function clone() : Event
    {
        return new PipeChangeEvent(pipe);
    }
}

