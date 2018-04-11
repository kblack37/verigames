package cgs.audio;


/**
	 * Properties and functions for MusicTypes
	 * 
	 * @author Gordon
	 **/
class MusicTypes
{
    public var types(get, set) : Array<MusicType>;
    public var usePanning(get, set) : Bool;

    //The type of background music matched to symbols to play
    private var _types : Array<MusicType>;
    
    //Whether to pan the sounds left/right depending on stage position
    private var _usePanning : Bool;
    
    public function new()
    {
        _types = new Array<MusicType>();
    }
    
    //
    // Getters and setters.
    //
    
    private function get_types() : Array<MusicType>
    {
        return _types;
    }
    
    private function set_types(value : Array<MusicType>) : Array<MusicType>
    {
        _types = value;
        return value;
    }
    
    private function get_usePanning() : Bool
    {
        return _usePanning;
    }
    
    private function set_usePanning(value : Bool) : Bool
    {
        _usePanning = value;
        return value;
    }
}
