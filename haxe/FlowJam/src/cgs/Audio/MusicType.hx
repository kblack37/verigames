package cgs.audio;


/**
	 * Properties and functions for a MusicType
	 * 
	 * @author Gordon
	 **/
class MusicType
{
    public var type(get, set) : String;
    public var symbols(get, set) : Array<Dynamic>;
    public var sounds(get, set) : Array<Dynamic>;
    public var urls(get, set) : Array<Dynamic>;
    public var volume(get, set) : Float;
    public var previewMuffle(get, set) : Bool;

    private var _type : String;
    
    // Array of the symbol names for each sound of this type
    private var _symbols : Array<Dynamic>;
    
    private var _volume : Float;
    
    // Whether the sound effect should be muffled during level preview
    private var _previewMuffle : Bool;
    
    // The actual sounds that get set when swf is loaded in audio.as
    private var _sounds : Array<Dynamic>;
    
    // The URLs of the sounds if they are streamed
    private var _urls : Array<Dynamic>;
    
    public function new()
    {
        _sounds = new Array<Dynamic>();
        _urls = new Array<Dynamic>();
    }
    
    //
    // Getters and setters.
    //
    
    private function get_type() : String
    {
        return _type;
    }
    
    private function set_type(value : String) : String
    {
        _type = value;
        return value;
    }
    
    private function get_symbols() : Array<Dynamic>
    {
        return _symbols;
    }
    
    private function set_symbols(value : Array<Dynamic>) : Array<Dynamic>
    {
        _symbols = value;
        return value;
    }
    
    private function get_sounds() : Array<Dynamic>
    {
        return _sounds;
    }
    
    private function set_sounds(value : Array<Dynamic>) : Array<Dynamic>
    {
        _sounds = value;
        return value;
    }
    
    private function get_urls() : Array<Dynamic>
    {
        return _urls;
    }
    
    private function set_urls(value : Array<Dynamic>) : Array<Dynamic>
    {
        _urls = value;
        return value;
    }
    
    private function get_volume() : Float
    {
        return _volume;
    }
    
    private function set_volume(value : Float) : Float
    {
        _volume = value;
        return value;
    }
    
    private function get_previewMuffle() : Bool
    {
        return _previewMuffle;
    }
    
    private function set_previewMuffle(value : Bool) : Bool
    {
        _previewMuffle = value;
        return value;
    }
}
