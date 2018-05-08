package networking;

import assets.AssetInterface;
import flash.errors.Error;
import haxe.Constraints.Function;
import flash.events.Event;
import flash.net.URLRequestMethod;
import flash.utils.Dictionary;

import openfl.Assets;
import lime.utils.AssetType;

import haxe.Json;

import scenes.loadingscreen.LoadingScreenScene;
import starling.display.Sprite;
import haxe.rtti.Meta;
import haxe.Resource;
class TutorialController extends Sprite
{
	//public static var tutorialObj : Dynamic = haxe.Json.parse(Resource.getString("Tutorial/tutorial.json"));
    
   // @:meta(Embed(source = "../../lib/levels/tutorial/tutorialLayout.json", mimeType = "application/octet-stream"))
	
   
    //public static var tutorialLayoutJson : String = Type.createInstance(tutorialLayoutFileClass, []);
    //public static var tutorialLayoutObj : Dynamic = haxe.Json.parse(tutorialLayoutJson);
	//public static var tutorialLayoutObj : Dynamic = haxe.Json.parse(Resource.getString("Tutorial/tutorialLayout.json"));

    public var tutorialObj : Dynamic;
    
    public var tutorialLayoutObj : Dynamic;


    //public static var tutorialAssignmentsObj : Dynamic = haxe.Json.parse(Resource.getString("Tutorial/tutorialAssignments.json"));
    public var tutorialAssignmentsObj : Dynamic;
    
    public static var tutorial_level_complete : Int = 0;
    public static var get_completed_tutorial_levels : Int = 1;
    
    public static var TUTORIALS_COMPLETED_STRING : String = "tutorials_completed";
    
    //used as a ordered array of order values containing all tutorial orders
    private var tutorialOrderedList : Array<Int>;
    
    //these are tutorial level lookups for all tutorials
    private var orderToTutorialDictionary : Map<Int, Dynamic>;
    private var qidToTutorialDictionary : Dynamic;
    
    //lookup by qid, if not null, has been completed
    public var completedTutorialDictionary : Dynamic;
    
    private static var tutorialController : TutorialController;
    
    public var fromLevelSelectList : Bool = false;
    
    private var levelCompletedQID : String;
	
	public function new()
    {
        super();
		
		this.tutorialObj = AssetInterface.getObject("levels/tutorial", "tutorial.json");
		this.tutorialLayoutObj = AssetInterface.getObject("levels/tutorial", "tutorialLayout.json");
		this.tutorialAssignmentsObj = AssetInterface.getObject("levels/tutorial", "tutorialAssignments.json");
    }
    
    public static function getTutorialController() : TutorialController
    {
        if (tutorialController == null)
        {
            tutorialController = new TutorialController();
        }
        
        return tutorialController;
    }
    
    
    public function getTutorialIDFromName(name : String) : String
    //find first next level to play, then compare with argument
    {
        
        var levelFound : Bool = false;
        for (order in tutorialOrderedList)
        {
            var nextName : String = Reflect.field(orderToTutorialDictionary[order], "name");
            
            if (nextName == name)
            {
                return Reflect.field(orderToTutorialDictionary[order], "qid");
            }
        }
        return "0";
    }
    
    public function getTutorialsCompletedByPlayer() : Void
    {
        sendMessage(get_completed_tutorial_levels, getTutorialsCompleted);
    }
    
    private function getTutorialsCompleted(result : Int, e : flash.events.Event) : Void
    {
        if (completedTutorialDictionary == null)
        {
            completedTutorialDictionary = {};
        }
        if (e != null && e.target != null && Reflect.hasField(e.target, "data"))
        {
            var message : String = Reflect.field(e.target, "data");
            var obj : Dynamic = haxe.Json.parse(message);
            for (id in Reflect.fields(obj))
            {
				var entry = Reflect.field(obj, id);
				Reflect.setField(completedTutorialDictionary, entry.levelID, entry);
            }
        }
        //also check cookies for levels played when not logged in
        getTutorialsCompletedFromCookieString();
    }
    
    public function getTutorialsCompletedFromCookieString() : Void
    {
        if (completedTutorialDictionary == null)
        {
            completedTutorialDictionary = {};
        }
        
        var tutorialsCompleted : String = HTTPCookies.getCookie(TutorialController.TUTORIALS_COMPLETED_STRING);
        if (tutorialsCompleted != null)
        {
            var tutorialListArray : Array<String> = tutorialsCompleted.split(",");
            for (tutorial in tutorialListArray)
            {
                Reflect.setField(completedTutorialDictionary, tutorial, tutorial);
            }
        }
        setTutorialObj(tutorialObj);
        
        LoadingScreenScene.getLoadingScreenScene().changeScene();
    }
    
    public function addCompletedTutorial(qid : String, markComplete : Bool) : Void
    {
        if (PipeJam3.RELEASE_BUILD)
        {
            if (!PipeJamGame.levelInfo)
            {
                return;
            }
            if (completedTutorialDictionary == null)
            {
                completedTutorialDictionary = {};
            }
            var currentLevel : Int = Std.int(PipeJamGame.levelInfo.tutorialLevelID);
            if (!Reflect.hasField(completedTutorialDictionary, Std.string(currentLevel)))
            {
                var newTutorialObj : TutorialController = new TutorialController();
                newTutorialObj.levelCompletedQID = PipeJamGame.levelInfo.tutorialLevelID;
                Reflect.setField(completedTutorialDictionary, Std.string(currentLevel), newTutorialObj);
                newTutorialObj.post();
            }
        }
    }
    public function post() : Void
    {
        if (PlayerValidation.playerLoggedIn)
        {
            sendMessage(tutorial_level_complete, postMessage);
        }
        //add to cookie string
        else
        {
            
            var tutorialsCompleted : String = HTTPCookies.getCookie(TUTORIALS_COMPLETED_STRING);
            tutorialsCompleted += "," + levelCompletedQID;
            HTTPCookies.setCookie(TUTORIALS_COMPLETED_STRING, tutorialsCompleted);
        }
    }
    
    private function postMessage(result : Int, e : Event) : Void
    {
    }
    
    public function isTutorialLevelCompleted(tutorialQID : String) : Bool
    {
        return (completedTutorialDictionary != null && (Reflect.field(completedTutorialDictionary, tutorialQID) != null));
    }
    
    
    //first tutorial should be unlocked
    //any played tutorials should be unlocked
    //first unplayed tutorial that immediately follows a completed tutorial should be unlocked
    public function tutorialShouldBeUnlocked(tutorialQID : String) : Bool
    {
        var tutorialQIDInt : Int = as3hx.Compat.parseInt(tutorialQID);
        
        if (tutorialQIDInt == getFirstTutorialLevel())
        {
            return true;
        }
        else if (completedTutorialDictionary != null && (Reflect.field(completedTutorialDictionary, tutorialQID) != null))
        {
            return true;
        }
        //find first next level to play, then compare with argument
        else
        {
            
            var levelFound : Bool = false;
            for (order in tutorialOrderedList)
            {
                var nextQID : String = Reflect.field(orderToTutorialDictionary[order], "qid");
                
                if (!isTutorialLevelCompleted(nextQID))
                {
                    if (nextQID == tutorialQID)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
        }
        return false;
    }
    
    //returns the first tutorial level qid in the sequence
    public function getFirstTutorialLevel() : Int
    {
        if (tutorialOrderedList == null)
        {
            return 0;
        }
        var order : Int = tutorialOrderedList[0];
        return Reflect.field(orderToTutorialDictionary[order], "qid");
    }
    
    //uses the current PipeJamGame.levelInfo.levelId to find the next level in sequence that hasn't been played
    //returns qid of next level to play, else 0
    public function getNextUnplayedTutorial() : Int
    {
        var currentLevelQID : Int;
        if (!PipeJamGame.levelInfo)
        {
            return 0;
        }
        currentLevelQID = Std.int(PipeJamGame.levelInfo.tutorialLevelID);
        
        var currentLevel : Dynamic = Reflect.field(qidToTutorialDictionary, Std.string(currentLevelQID));
        var currentPosition : Int = Reflect.field(currentLevel, "position");
        currentPosition++;
        var nextPosition : Int = currentPosition;
        
        var levelFound : Bool = false;
        while (!levelFound)
        {
            if (nextPosition == tutorialOrderedList.length)
            {
                return 0;
            }
            
            var nextQID : Int = Reflect.field(orderToTutorialDictionary[nextPosition], "qid");
            
            //if we chose the last level from the level select screen, assume we want to play in order, done or not
            if (fromLevelSelectList)
            {
                return nextQID;
            }
            
            if (completedTutorialDictionary[nextQID] == null)
            {
                return nextQID;
            }
            
            nextPosition++;
        }
        
        return 0;
    }
    
    public function setTutorialObj(m_worldObj : Dynamic) : Void
    {
        var levels : Array<Dynamic> = Reflect.field(m_worldObj, "levels");
        if (levels == null)
        {
            throw new Error("Expecting 'levels' Array in tutorial world JSON");
        }
        tutorialOrderedList = new Array<Int>();
        orderToTutorialDictionary = new Map<Int, Dynamic>();
        qidToTutorialDictionary = {};
        //order the levels and store the order
        for (i in 0...levels.length)
        {
            var levelObj : Dynamic = levels[i];
            var qid : Int = Reflect.field(levelObj, "qid");
            Reflect.setField(qidToTutorialDictionary, Std.string(qid), levelObj);
            orderToTutorialDictionary[i] = levelObj;
            Reflect.setField(levelObj, "position", i);
            tutorialOrderedList.push(i);
        }
    }
    
    public function clearPlayedTutorials() : Void
    {
        completedTutorialDictionary = {};
    }
    
    public function resetTutorialStatus() : Void
    {
        clearPlayedTutorials();
    }
    
    
    public function isTutorialDone() : Bool
    {
        if (tutorialOrderedList == null)
        {
            return false;
        }
        
        for (position in tutorialOrderedList)
        {
            var level : Dynamic = Reflect.field(orderToTutorialDictionary, Std.string(position));
            var qid : String = Reflect.field(level, "qid");
            
            if (isTutorialLevelCompleted(qid) == false)
            {
                return false;
            }
        }
        
        return true;
    }
    
    public function sendMessage(type : Int, callback : Function) : Void
    {
        var request : String;
        var method : String;
        var data : Dynamic;
        var url : String = null;
        
        var messages : Array<Dynamic> = new Array<Dynamic>();
        
        
        switch (type)
        {
            case tutorial_level_complete:
                messages.push({
                            playerID : PlayerValidation.playerID,
                            levelID : PipeJamGame.levelInfo.tutorialLevelID
                        });
                var data_id : String = haxe.Json.stringify(messages);
                url = NetworkConnection.productionInterop + "?function=reportPlayedTutorial2&data_id='" + data_id + "'";
                method = URLRequestMethod.POST;
            case get_completed_tutorial_levels:
                url = NetworkConnection.productionInterop + "?function=findPlayedTutorials2&data_id=" + PlayerValidation.playerID;
                method = URLRequestMethod.POST;
        }
        
        NetworkConnection.sendMessage(callback, null, url, method, "");
    }
}
