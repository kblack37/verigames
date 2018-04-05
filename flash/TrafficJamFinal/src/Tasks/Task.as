package Tasks 
{
	
	public class Task 
	{
		
		public var id:String;
		public var dependentTaskIds:Vector.<String>;
		public var complete:Boolean = false;
		
		public function Task(_id:String, _dependentTaskIds:Vector.<String> = null) 
		{
			dependentTaskIds = _dependentTaskIds;
			if (dependentTaskIds == null) {
				dependentTaskIds = new Vector.<String>();
			}
			id = _id;
		}
		
		/* To be implemented by children */
		public function perform():void {
			
		}
		
	}

}