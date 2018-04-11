package cgs.server.logging.responses;


class ScoreRequestResponse implements IServerResponse
{
    public var data(never, set) : Dynamic;

    public function new()
    {
    }
    
    private function set_data(value : Dynamic) : Dynamic
    {
        return value;
    }
}
