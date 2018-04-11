package cgs.server.logging.gamedata;


class UserDataChunk
{
    public var key(get, never) : String;
    public var data(get, never) : Dynamic;

    private var _dataKey : String;
    
    private var _data : Dynamic;
    
    public function new(key : String, data : Dynamic)
    {
        _dataKey = key;
        _data = data;
    }
    
    private function get_key() : String
    {
        return _dataKey;
    }
    
    private function get_data() : Dynamic
    {
        return _data;
    }
}
