package cgs.teacherportal;
import cgs.teacherportal.IExternalComm;


/**
 * ...
 * @author Ric Gray
 */
class ExternalComm implements IExternalComm {
//#if js
//	private var myWindow: Window;
//	private var onMessage: Dynamic -> Void;
//	private var cmdMap:Map<String, Array<Dynamic> -> Void> = new Map();
//
//	public function new()
//	{
//		myWindow = Browser.window;
//		myWindow.onmessage = function (msg:Dynamic)
//		{
//			if (onMessage != null)
//			{
//				onMessage(msg.data);
//			}
//
//			if (cmdMap.exists(msg.data.command))
//			{
//				cmdMap.get(msg.data.command)(cast(msg.data.args, Array<Dynamic>));
//			}
//
//		}
//
//	}
//
//	public function setOnMessageCallback(onMessage:Dynamic -> Void):Void
//	{
//		this.onMessage = onMessage;
//	}
//
//	public function setMessageCallback(message:String, callback:Array<Dynamic>->Void):Void
//	{
//		if (callback != null)
//			cmdMap.set(message, callback);
//		else
//			cmdMap.remove(message);
//	}
//
//	public function sendMsgToParent(msg:ExternalCommuicationParentMessage, target:Targets=Targets.ALL_TARGETS):Void
//	{
//		myWindow.parent.postMessage(msg, target);
//	}
//#else

    //TODO: fix mockup implementation
    public function new()
    {


    }
    public function setMessageCallback(message:String, callback:Array<Dynamic> -> Void):Void {

    }

    public function sendMsgToParent(msg:ExternalCommuicationParentMessage, ?target:String):Void {

    }
//#end
}