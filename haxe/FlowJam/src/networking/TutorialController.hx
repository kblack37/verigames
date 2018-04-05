package networking;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.events.Event;
import flash.net.URLRequestMethod;
import flash.utils.Dictionary;
import scenes.loadingscreen.LoadingScreenScene;
import starling.display.Sprite;

class TutorialController extends Sprite
{
    @:meta(Embed(source="../../lib/levels/tutorial/tutorial.json",mimeType="application/octet-stream"))

    public static var tutorialFileClass : Class<Dynamic>;
    public static var tutorialJson : String = Type.createInstance(tutorialFileClass, []);
    public static var tutorialObj : Dynamic = haxe.Json.parse(tutorialJson);
    
    @:meta(Embed(source="../../lib/levels/tutorial/tutorialLayout.json",mimeType="application/octet-stream"))

    public static var tutorialLayoutFileClass : Class<Dynamic>;
    public static var tutorialLayoutJson : String = Type.createInstance(tutorialLayoutFileClass, []);
    public static var tutorialLayoutObj : Dynamic = haxe.Json.parse(tutorialLayoutJson);
    
    @:meta(Embed(source="../../lib/levels/tutorial/tutorialAssignments.json",mimeType="application/octet-stream"))

    public static var tutorialAssignmentsFileClass : Class<Dynamic>;
    public static var tutorialAssignmentsJson : String = Type.createInstance(tutorialAssignmentsFileClass, []);
    public static var tutorialAssignmentsObj : Dynamic = haxe.Json.parse(tutorialAssignmentsJson);
    
    public static var TUTORIAL_LEVEL_COMPLETE : Int = 0;
    public static var GET_COMPLETED_TUTORIAL_LEVELS : Int = 1;
    
    public static var TUTORIALS_COMPLETED_STRING : String = "tutorials_completed";
    
    //used as a ordered array of order values containing all tutorial orders
    private var tutorialOrderedList : Array<Float>;
    
    //these are tutorial level lookups for all tutorials
    private var orderToTutorialDictionary : Dictionary;
    private var qidToTutorialDictionary : Dictionary;
    
    //lookup by qid, if not null, has been completed
    public var completedTutorialDictionary : Dictionary;
    
    private static var tutorialController : TutorialController;
    
    public var fromLevelSelectList : Bool = false;
    
    private var levelCompletedQID : String;
    
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
            var nextName : String = Reflect.field(orderToTutorialDictionary, Std.string(order))["name"];
            
            if (nextName == name)
            {
                return Reflect.field(orderToTutorialDictionary, Std.string(order))["qid"];
            }
        }
        return "0";
    }
    
    public function getTutorialsCompletedByPlayer() : Void
    {
        sendMessage(GET_COMPLETED_TUTORIAL_LEVELS, getTutorialsCompleted);
    }
    
    private function getTutorialsCompleted(result : Int, e : flash.events.Event) : Void
    {
        if (completedTutorialDictionary == null)
        {
            completedTutorialDictionary = new Dictionary();
        }
        if (e != null && e.target && e.target.data)
        {
            var message : String = Std.string(e.target.data);
            var obj : Dynamic = haxe.Json.parse(message);
            for (entry/* AS3HX WARNING could not determine type for var: entry exp: EIdent(obj) type: Dynamic */ in obj)
            {
                completedTutorialDictionary[entry.levelID] = entry;
            }
        }
        //also check cookies for levels played when not logged in
        getTutorialsCompletedFromCookieString();
    }
    
    public function getTutorialsCompletedFromCookieString() : Void
    {
        if (completedTutorialDictionary == null)
        {
            completedTutorialDictionary = new Dictionary();
        }
        
        var tutorialsCompleted : String = HTTPCookies.getCookie(TutorialController.TUTORIALS_COMPLETED_STRING);
        if (tutorialsCompleted != null)
        {
            var tutorialListArray : Array<Dynamic> = tutorialsCompleted.split(",");
            for (tutorial in tutorialListArray)
            {
                Reflect.setField(completedTutorialDictionary, Std.string(tutorial), tutorial);
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
                completedTutorialDictionary = new Dictionary();
            }
            var currentLevel : Int = as3hx.Compat.parseInt(PipeJamGame.levelInfo.tutorialLevelID);
            if (completedTutorialDictionary[currentLevel] == null)
            {
                var newTutorialObj : TutorialController = new TutorialController();
                newTutorialObj.levelCompletedQID = PipeJamGame.levelInfo.tutorialLevelID;
                completedTutorialDictionary[currentLevel] = newTutorialObj;
                newTutorialObj.post();
            }
        }
    }
    public function post() : Void
    {
        if (PlayerValidation.playerLoggedIn)
        {
            sendMessage(TUTORIAL_LEVEL_COMPLETE, postMessage);
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
        return (completedTutorialDictionary && (Reflect.field(completedTutorialDictionary, tutorialQID) != null));
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
                var nextQID : String = Reflect.field(orderToTutorialDictionary, Std.string(order))["qid"];
                
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
        var order : Float = tutorialOrderedList[0];
        return Reflect.field(orderToTutorialDictionary, Std.string(order))["qid"];
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
        currentLevelQID = as3hx.Compat.parseInt(PipeJamGame.levelInfo.tutorialLevelID);
        
        var currentLevel : Dynamic = qidToTutorialDictionary[currentLevelQID];
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
            
            var nextQID : Int = orderToTutorialDictionary[nextPosition]["qid"];
            
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
        tutorialOrderedList = new Array<Float>();
        orderToTutorialDictionary = new Dictionary();
        qidToTutorialDictionary = new Dictionary();
        //order the levels and store the order
        for (i in 0...levels.length)
        {
            var levelObj : Dynamic = levels[i];
            var qid : Float = as3hx.Compat.parseFloat(Reflect.field(levelObj, "qid"));
            Reflect.setField(qidToTutorialDictionary, Std.string(qid), levelObj);
            orderToTutorialDictionary[i] = levelObj;
            Reflect.setField(levelObj, "position", i);
            tutorialOrderedList.push(i);
        }
    }
    
    public function clearPlayedTutorials() : Void
    {
        completedTutorialDictionary = new Dictionary();
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
            case TUTORIAL_LEVEL_COMPLETE:
                messages.push({
                            playerID : PlayerValidation.playerID,
                            levelID : PipeJamGame.levelInfo.tutorialLevelID
                        });
                var data_id : String = haxe.Json.stringify(messages);
                url = NetworkConnection.productionInterop + "?function=reportPlayedTutorial2&data_id='" + data_id + "'";
                method = URLRequestMethod.POST;
            case GET_COMPLETED_TUTORIAL_LEVELS:
                url = NetworkConnection.productionInterop + "?function=findPlayedTutorials2&data_id=" + PlayerValidation.playerID;
                method = URLRequestMethod.POST;
        }
        
        NetworkConnection.sendMessage(callback, null, url, method, "");
    }

    public function new()
    {
        super();
    }
}
