package cgs.server.logging.gamedata
{
	public class UserDataChunk
	{
		private var _dataKey:String;
		
		private var _data:*;
		
		public function UserDataChunk(key:String, data:*)
		{
			_dataKey = key;
			_data = data;
		}
		
		public function get key():String
		{
			return _dataKey;
		}
		
		public function get data():*
		{
			return _data;
		}
	}
}