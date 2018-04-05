package tasks;


class Task
{
    
    public var id : String;
    public var dependentTaskIds : Array<String>;
    public var complete : Bool = false;
    
    public function new(_id : String, _dependentTaskIds : Array<String> = null)
    {
        dependentTaskIds = _dependentTaskIds;
        if (dependentTaskIds == null)
        {
            dependentTaskIds = new Array<String>();
        }
        id = _id;
    }
    
    /* To be implemented by children */
    public function perform() : Void
    {
    }
}

