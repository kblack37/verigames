package cgs.teacherportal;
import cgs.server.logging.IGameServerData.SkeyHashVersion;

/**
 * @author Ric Gray
 */

typedef ExternalCommuicationParentMessage =
{
	command:String,
	args:Array<Dynamic>
}

@:enum 
abstract Targets(String) from String to String
{
	var ALL_TARGETS = "*";
}

interface IExternalComm 
{
	public function setMessageCallback(message:String, callback:Array<Dynamic>->Void):Void;
	
	public function sendMsgToParent(msg:ExternalCommuicationParentMessage, ?target:String):Void;  
}