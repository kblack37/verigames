package cgs.cache;
import haxe.ds.StringMap;
import openfl.utils.Dictionary;

/**
	 * Contains information regarding the status of a flush request.
	 */
class CacheFlushStatus
{
    public var localFlushStatus(never, set) : Bool;

    //Callback called on completion of all saves.
    private var _completeCallback : Dynamic;
    
    private var _localFlushSucceeded : Bool;
    
    //Save id associated with a flush of data to the server.
    private var _saveId : Int;
    private var _saveCount : Int;
    
    //Mapping of data ids to save status.
    private var _dataIds : Array<String>;
    private var _dataResponses : StringMap<Bool>;
    
    public function new(saveId : Int, dataSaveCount : Int, completeCallback : Dynamic)
    {
        _saveId = saveId;
        _saveCount = dataSaveCount;
        _completeCallback = completeCallback;
        _dataIds = new Array<String>();
        _dataResponses = new StringMap<Bool>();
    }
    
    public function makeCompleteCallback() : Void
    {
        if (_completeCallback != null)
        {
            _completeCallback(this);
            _completeCallback = null;
        }
    }
    
    public function completed() : Bool
    {
        var responseCount : Int = 0;
        for (dataKey in _dataResponses)
        {
            responseCount++;
        }
        
        return responseCount == _saveCount;
    }
    
    private function set_localFlushStatus(succeeded : Bool) : Bool
    {
        _localFlushSucceeded = succeeded;
        return succeeded;
    }
    
    public function localFlushSucceedded() : Bool
    {
        return _localFlushSucceeded;
    }
    
    /**
		 * Indicates if all data saved as part of a flush was
		 * successfully saved to the server.
		 */
    public function flushSucceeded() : Bool
    {
        for (dataKey in _dataResponses.keys())
        {
            if (_dataResponses.get(dataKey) == null)
            {
                return false;
            }
        }
        return true;
    }
    
    /**
		 * Indicates if the data with the given key was successfully saved
		 * on the server.
		 */
    public function dataSaved(key : String) : Bool
    {
        var saved : Bool = false;

		saved = _dataResponses.get(key) == null ? false :  _dataResponses.get(key);
        return saved;
    }
    
    /**
		 * Indicates if a response has been received for the save request for
		 * the data with the given key.
		 */
    public function containsDataKey(key : String) : Bool
    {
        return _dataResponses.get(key) != null;
    }
    
    public function addDataKey(key : String) : Void
    {
        _dataIds.push(key);
    }
    
    /**
		 * Update the save status of given data key.
		 */
    public function updateDataSaveStatus(dataKey : String, saveSuccess : Bool) : Void
    {
        if (Lambda.indexOf(_dataIds, dataKey) >= 0)
        {
            _dataResponses.set(dataKey, saveSuccess);
        }
    }
}
