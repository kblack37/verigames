package cgs.logger;

import flash.external.ExternalInterface;

class Logger
{
    public static var canLog : Bool = true;
    
    public function new()
    {
    }
    
    public static function log(message : String) : Void
    {
        if (ExternalInterface.available && canLog)
        {
            try
            {
                ExternalInterface.call("console.log", message);
            }
            catch (e : Dynamic)
            {
                canLog = false;
            }
        }
    }
}
