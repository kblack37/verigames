package server;

import haxe.Constraints.Function;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.net.URLRequestMethod;
import networking.NetworkConnection;

class MTurkAPI
{
    private static var m_instance : MTurkAPI;
    
    public var workerToken : String;
    public var taskId : String = "101";
    private var m_encryptedMessage : String;
    
    public static function getInstance() : MTurkAPI
    {
        if (m_instance == null)
        {
            m_instance = new MTurkAPI(new SingletonLock());
        }
        return m_instance;
    }
    
    
    
    public function new(lock : SingletonLock)
    {  // TODO: get time?  
        
    }
    
    public function onTaskBegin() : Void
    {
        var info : Dynamic = {};
        var url : String = NetworkConnection.productionInterop + "?function=mTurkTaskBegin&data_id=%7B\\\"workerToken\\\"%3A\\\"" + workerToken + "\\\"%7D&rand=" + (Math.round(Math.random() * 1000));
        var method : String = URLRequestMethod.GET;
        var thisCallback : Int->Event->Void = function(result : Int, e : Event) : Void
        {
            if (e == null)
            {
                if (ExternalInterface.available)
                {
                    ExternalInterface.call("console.log", "interop.php onTaskBegin bad response");
                }
            }
            m_encryptedMessage = Std.string(e.target.data);
            if (ExternalInterface.available)
            {
                ExternalInterface.call("console.log", "interop.php onTaskBegin msg:" + m_encryptedMessage + " result:" + result);
            }
        }
        if (ExternalInterface.available)
        {
            ExternalInterface.call("console.log", "calling " + url);
        }
        NetworkConnection.sendMessage(thisCallback, null, url, method, "");
    }
    
    public function onTaskComplete(callback : Function) : Void
    {
        var url : String = NetworkConnection.productionInterop + "?function=mTurkTaskComplete&data_id=" + m_encryptedMessage + "&rand=" + (Math.round(Math.random() * 1000));
        var method : String = URLRequestMethod.GET;
        var thisCallback : Int->Event->Void = function(result : Int, e : Event) : Void
        {
            if (e == null)
            {
                if (ExternalInterface.available)
                {
                    ExternalInterface.call("console.log", "interop.php mTurkTaskComplete bad response");
                }
                callback(null);
            }
            var code : String = Std.string(e.target.data);
            if (ExternalInterface.available)
            {
                ExternalInterface.call("console.log", "interop.php mTurkTaskComplete code:" + code + " result:" + result);
            }
            callback(code);
        }
        if (ExternalInterface.available)
        {
            ExternalInterface.call("console.log", "calling " + url);
        }
        NetworkConnection.sendMessage(thisCallback, null, url, method, "");
    }
}



class SingletonLock
{

    @:allow(server)
    private function new()
    {
    }
}  // to prevent outside construction of singleton  