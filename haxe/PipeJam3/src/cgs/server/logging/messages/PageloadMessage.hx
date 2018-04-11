package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.utils.INtpTime;
import flash.system.Capabilities;
//import js.html.DataElement;

class PageloadMessage extends Message
{
    private var _plDetails : Dynamic;
    
    public function new(details : Dynamic = null,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        _plDetails = details;
        createDetails();
    }
    
    private function createDetails() : Void
    {
        if (_plDetails == null)
        {
            _plDetails = { };
        }
        
        //Add system parameters to page load message.
        _plDetails.os = Capabilities.os;
        _plDetails.resX = Capabilities.screenResolutionX;
        _plDetails.resY = Capabilities.screenResolutionY;
        _plDetails.dpi = Capabilities.screenDPI;
        _plDetails.flash = Capabilities.version;
        _plDetails.cpu = Capabilities.cpuArchitecture;
        _plDetails.pixelAspect = Capabilities.pixelAspectRatio;
        _plDetails.language = Capabilities.language;
        
#if (js || flash)
        //Add the timezone to the pageload.
        _plDetails.timezone = untyped Date.now().getTimezoneOffset();
#else
	#error  
#end
        
        //Add the domain if it has been set.
        var domain : String = serverData.swfDomain;
        if (domain != null)
        {
            if (_gameServerData.isVersion1)
            {
                _plDetails.domain = domain;
            }
            if (_gameServerData.atLeastVersion2)
            {
                addProperty("domain", domain);
            }
        }
        
        addProperty("pl_detail", _plDetails);
    }
}
