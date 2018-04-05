package server 
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLRequestMethod;
	
	import networking.NetworkConnection;
	
	public class MTurkAPI 
	{
		private static var m_instance:MTurkAPI;
		
		public var workerToken:String;
		public var taskId:String = "101";
		private var m_encryptedMessage:String;
		
		public static function getInstance():MTurkAPI
		{
			if (m_instance == null) {
				m_instance = new MTurkAPI(new SingletonLock());
			}
			return m_instance;
		}
		
		
		
		public function MTurkAPI(lock:SingletonLock) 
		{
			// TODO: get time?
		}
		
		public function onTaskBegin():void
		{
			var info:Object = new Object();
			var url:String = NetworkConnection.productionInterop + "?function=mTurkTaskBegin&data_id=%7B\\\"workerToken\\\"%3A\\\"" + workerToken + "\\\"%7D&rand=" + (Math.round(Math.random()*1000));;
			var method:String = URLRequestMethod.GET;
			function thisCallback(result:int, e:Event):void
			{
				if (e == null)
				{
					if (ExternalInterface.available) ExternalInterface.call("console.log", "interop.php onTaskBegin bad response");
				}
				m_encryptedMessage = e.target.data as String;
				if (ExternalInterface.available) ExternalInterface.call("console.log", "interop.php onTaskBegin msg:" + m_encryptedMessage + " result:" + result);
			}
			if (ExternalInterface.available) ExternalInterface.call("console.log", "calling " + url);
			NetworkConnection.sendMessage(thisCallback, null, url, method, "");
		}
		
		public function onTaskComplete(callback:Function):void
		{
			var url:String = NetworkConnection.productionInterop + "?function=mTurkTaskComplete&data_id=" + m_encryptedMessage + "&rand=" + (Math.round(Math.random()*1000));
			var method:String = URLRequestMethod.GET;
			function thisCallback(result:int, e:Event):void
			{
				if (e == null)
				{
					if (ExternalInterface.available) ExternalInterface.call("console.log", "interop.php mTurkTaskComplete bad response");
					callback(null);
				}
				var code:String = e.target.data as String;
				if (ExternalInterface.available) ExternalInterface.call("console.log", "interop.php mTurkTaskComplete code:" + code + " result:" + result);
				callback(code);
			}
			if (ExternalInterface.available) ExternalInterface.call("console.log", "calling " + url);
			NetworkConnection.sendMessage(thisCallback, null, url, method, "");
		}
		
	}

}

internal class SingletonLock {} // to prevent outside construction of singleton