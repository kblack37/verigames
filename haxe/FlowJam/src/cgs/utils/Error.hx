package cgs.utils;

/**
 * ...
 * @author Ric Gray
 */
#if js

typedef Error = js.Error;

#elseif cs

abstract Error(cs.system.Exception) {
    public var message(get, never):String;
    public inline function new(message:String) this = new cs.system.Exception(message);
    inline function get_message():String return this.Message;
}

#else

abstract Error(String)
{
    public inline function new(message:String) this = message;
    public var message(get, never):String;
    private inline function get_message():String return this;
}

#end