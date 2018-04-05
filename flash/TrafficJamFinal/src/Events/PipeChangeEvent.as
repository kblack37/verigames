package Events 
{
	import VisualWorld.Pipe;
	
	import flash.events.Event;
	
	public class PipeChangeEvent extends Event 
	{
		public var pipe:Pipe;
		public var m_pipeWidthChange:Boolean;
		public var m_buzzSawChange:Boolean;
		public var m_stampChange:Boolean;
		
		public static const PIPE_CHANGE:String = "PIPE_CHANGE";
		
		public function PipeChangeEvent(p:Pipe, newPipeWidth:Boolean = false, buzzSawChange:Boolean = false) 
		{
			m_pipeWidthChange = newPipeWidth;
			m_buzzSawChange = buzzSawChange;
			pipe = p;
			super(PIPE_CHANGE);
		}
		
		public override function clone():Event
		{
			return new PipeChangeEvent(pipe);
		}
	}

}