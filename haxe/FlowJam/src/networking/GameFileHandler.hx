package networking;

import haxe.Constraints.Function;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.utils.Dictionary;
import flash.utils.Timer;
//import deng.fzip.FZip;
//import deng.fzip.FZipFile;
import events.MenuEvent;
import events.NavigationEvent;
import scenes.Scene;
import scenes.game.PipeJamGameScene;
import scenes.game.display.World;
import starling.events.Event;
//import utils.Base64Decoder;
//import utils.Base64Encoder;
import utils.XMath;

/** How to use:
	 * In most cases, there's a static function that will do what you want, and call a callback when done.
	 * 	internally, this creates a GameFileHandler object and carries out the request.
	 *  occasionally, you might need to create your own object
	 *   	but in cases like these, you might just want to add a new static interface.
	 */
class GameFileHandler
{
    public static var GET_COMPLETED_LEVELS : Int = 1;
    public static var get_all_level_metadata : Int = 2;
    public static var SAVE_LAYOUT : Int = 3;
    public static var REQUEST_LAYOUT_LIST : Int = 5;
    public static var save_level : Int = 7;
    public static var GET_ALL_SAVED_LEVELS : Int = 8;
    public static var GET_SAVED_LEVEL : Int = 15;
    public static var DELETE_SAVED_LEVEL : Int = 9;
    public static var report_player_rating : Int = 12;
    public static var report_leaderboard_score : Int = 13;
    public static var get_high_scores_for_level : Int = 14;
    public static var USE_LOCAL : Int = 1;
    public static var USE_DATABASE : Int = 2;
    public static var USE_URL : Int = 3;
    
    public static var GET_COMPLETED_LEVELS_REQUEST : String = "/level/completed";
    public static var METADATA_GET_ALL_REQUEST : String = "/level/metadata/get/all";
    public static var LAYOUTS_GET_ALL_REQUEST : String = "/layout/get/all/";
    
    public static var levelInfoVector : Array<Dynamic> = null;
    
    //not currently used in version 2
    public static var completedLevelVector : Array<Dynamic> = null;
    public static var savedMatchArrayObjects : Array<Dynamic> = null;
    
    public static var numLevels : Int = 10;
    
    private static var m_name : String;
    private static var m_loadCallback : Function;
    
    
    private var m_callback : Function;
    //private var fzip : FZip;
    
    private var m_saveType : String;
    private var m_fileType : Int;
    private var m_levelFilesString : String;
    
    public var m_assignmentsSaved : Bool = false;
    public var m_levelCreated : Bool = false;
    public var m_levelSubmitted : Bool = false;
    
    public static var getFileURL : String = NetworkConnection.productionInterop + "?function=getFile2";
    
    public static function loadLevelInfoFromObjectID(id : String, callback : Function) : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(GET_SAVED_LEVEL, fileHandler.defaultJSONCallback, null, id);
    }
    
    public static function loadLevelInfoFromName(name : String, callback : Function) : Void
    //look up name in metadata list
    {
        if (levelInfoVector != null)
        {
            PipeJamGame.levelInfo = findLevelObjectByName(name);
            PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
        }
        else
        {
            GameFileHandler.m_name = name;
            GameFileHandler.m_loadCallback = callback;
            //set a timer, and try again
            var timer : Timer = new Timer(250, 1);
            timer.addEventListener(TimerEvent.TIMER, getLevelCallback);
            timer.start();
        }
    }
    
    public static function getLevelCallback(e : TimerEvent = null) : Void
    {
        GameFileHandler.loadLevelInfoFromName(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
    }
    
    
    public static function getFileByID(id : String, callback : Function) : Void
    {
        var fileURL : String = getFileURL + "&data_id=\"" + id + "\"";
        
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.loadFile(USE_DATABASE, fileURL);
    }
    
    public static function saveLayoutFile(callback : Function, _layoutAsString : String) : Void
    {
        var layoutDescription : String = PipeJamGame.levelInfo.layoutName + "::" + PipeJamGame.levelInfo.layoutDescription;
        
        var encodedLayoutDescription : String = layoutDescription;
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(SAVE_LAYOUT, callback, encodedLayoutDescription, _layoutAsString);
    }
    
    public static function getHighScoresForLevel(callback : Function, levelID : String) : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(get_high_scores_for_level, fileHandler.defaultJSONCallback, null, levelID);
    }
    
    public static function deleteSavedLevel(_levelIDString : String) : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler();
        fileHandler.sendMessage(DELETE_SAVED_LEVEL, null, _levelIDString);
    }
    
    public static function retrieveLevels() : Void
    {
        GameFileHandler.getLevelMetadata(null);
    }
    
    public static function findLevelObject(id : String) : Dynamic
    {
        for (level in levelInfoVector)
        {
            if (level.id == id)
            {
                return level;
            }
        }
        return null;
    }
    
    //names are not guaranteed to be unique
    public static function findLevelObjectByName(name : String) : Dynamic
    {
        for (level in levelInfoVector)
        {
            if (level.name == name)
            {
                return level;
            }
        }
        return null;
    }
    
    public static function getRandomLevelObject() : Dynamic
    {
        if (levelInfoVector != null && levelInfoVector.length > 0)
        {
            var randNum : Int = XMath.randomInt(0, levelInfoVector.length - 1);
            return levelInfoVector[randNum];
        }
        else
        {
            return null;
        }
    }
    
    public static function reportPlayerPreference(preference : String) : Void
    {
        PipeJamGame.levelInfo.preference = preference;
        var fileHandler : GameFileHandler = new GameFileHandler();
        fileHandler.sendMessage(report_player_rating, fileHandler.defaultJSONCallback, null);
    }
    
    //connect to the db and get a list of all levels
    public static function getLevelMetadata(callback : Function) : Void
    {
        levelInfoVector = null;
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(get_all_level_metadata, fileHandler.setLevelMetadataFromCurrent);
    }
    
    //connect to the db and get a list of all completed levels
    public static function getCompletedLevels(callback : Function) : Void
    {
        levelInfoVector = null;
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(GET_COMPLETED_LEVELS, fileHandler.setCompletedLevels);
    }
    
    //connect to the db and get a list of all saved levels
    public static function getSavedLevels(callback : Function) : Void
    {
        savedMatchArrayObjects = null;
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(GET_ALL_SAVED_LEVELS, fileHandler.onRequestSavedLevelsFinished);
    }
    
    //request a list of layouts associated with current levelObject levelID
    public static function getLayoutList(callback : Function) : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(REQUEST_LAYOUT_LIST, fileHandler.defaultJSONCallback);
    }
    
    public static function submitLevel(_levelFilesString : String, saveType : String, fileType : Int = 1) : Void
    //this involves:
    {
        
        //saving the level (layout and constraints, on either save or submit/share)
        //saving the score, level and player info
        //reporting the player performance/preference
        var fileHandler : GameFileHandler = new GameFileHandler();
        fileHandler.m_fileType = fileType;
        fileHandler.m_saveType = saveType;
        fileHandler.m_levelFilesString = _levelFilesString;
        fileHandler.saveLevel(saveType);
        GameFileHandler.reportScore();
    }
    
    public static function reportScore() : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler();
        fileHandler.sendMessage(report_leaderboard_score, null);
    }
    
    public static function loadGameFiles(worldFileLoadedCallback : Function, layoutFileLoadedCallback : Function, assignmentsFileLoadedCallback : Function) : Void
    {
        var gameFileHandler : GameFileHandler;
        //do this so I can debug the object...
        var levelInformation : Dynamic = PipeJamGame.levelInfo;
        
        Scene.m_gameSystem.dispatchEvent(new starling.events.Event(Game.START_BUSY_ANIMATION, true));
        
        var m_id : Int = 100000;
        if (PipeJamGame.levelInfo && Reflect.PipeJamGame.levelInfo.exists("id") && PipeJamGame.levelInfo.id.length < 5)
        {
            m_id = as3hx.Compat.parseInt(PipeJamGame.levelInfo.id);
        }
        if (m_id < 1000)
        {
        // in the tutorial if a low level id
            
            {
                PipeJamGameScene.inTutorial = true;
                PipeJamGameScene.inDemo = false;
            }
        }
        if (PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP != null && PipeJam3.RELEASE_BUILD == null)
        {
        //load the zip file from it's location
            
            var loadType : Int = USE_URL;
            gameFileHandler = new GameFileHandler(worldFileLoadedCallback);
            gameFileHandler.loadFile(USE_LOCAL, PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP, gameFileHandler.zipLoaded);
        }
        else if (PipeJamGameScene.inTutorial)
        {
			var tutorialController : TutorialController = TutorialController.getTutorialController();
			
            layoutFileLoadedCallback(tutorialController.tutorialLayoutObj);
            assignmentsFileLoadedCallback(tutorialController.tutorialAssignmentsObj);
            worldFileLoadedCallback(tutorialController.tutorialObj);
        }
        else
        {
            var loadType : Int = USE_LOCAL;
            
            var fileName : String;
            if (PipeJamGame.levelInfo && PipeJamGame.levelInfo.baseFileName)
            {
                fileName = PipeJamGame.levelInfo.baseFileName;
            }
            else
            {
                fileName = PipeJamGame.m_pipeJamGame.m_fileName;
            }
            
            
            if (PipeJamGame.levelInfo && PipeJamGame.levelInfo.assignmentsID != null && !PipeJamGameScene.inTutorial)
            {
            //load from MongoDB
                
                {
                    loadType = USE_DATABASE;
                    //is this an all in one file?
                    var version : Int = 0;
                    if (PipeJamGame.levelInfo.version)
                    {
                        version = PipeJamGame.levelInfo.version;
                    }
                    if (version == PipeJamGame.ALL_IN_ONE)
                    {
                        gameFileHandler = new GameFileHandler(worldFileLoadedCallback);
                        gameFileHandler.loadFile(loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.assignmentsID + "\"");
                    }
                    else
                    {
                        var levelInfo : Dynamic = PipeJamGame.levelInfo;
                        // TODO: probably rename from /xml and /constraints to /level and /assignments
                        trace(getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.levelID + "\"");
                        var worldFileHandler : GameFileHandler = new GameFileHandler(worldFileLoadedCallback);
                        worldFileHandler.loadFile(loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.levelID + "\"");
                        var layoutFileHandler : GameFileHandler = new GameFileHandler(layoutFileLoadedCallback);
                        layoutFileHandler.loadFile(loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.layoutID + "\"");
                        var assignmentsFileHandler : GameFileHandler = new GameFileHandler(assignmentsFileLoadedCallback);
                        assignmentsFileHandler.loadFile(loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.assignmentsID + "\"");
                    }
                }
            }
            else if (fileName != null && fileName.length > 0)
            {
                var worldFileHandler1 : GameFileHandler = new GameFileHandler(worldFileLoadedCallback);
                worldFileHandler1.loadFile(loadType, fileName + ".zip");
                var layoutFileHandler1 : GameFileHandler = new GameFileHandler(layoutFileLoadedCallback);
                layoutFileHandler1.loadFile(loadType, fileName + "Layout.zip");
                var assignmentsFileHandler1 : GameFileHandler = new GameFileHandler(assignmentsFileLoadedCallback);
                assignmentsFileHandler1.loadFile(loadType, fileName + "Assignments.zip");
            }
        }
    }
    
    /************************ End of static functions *********************************/
    
    public function new(callback : Function = null)
    {
        m_callback = callback;
    }
    
    
    //load files from disk or database
    public function loadFile(loadType : Int, fileName : String, callback : Function = null) : Void
    {
        //fzip = new FZip();
        //fzip.addEventListener(flash.events.Event.COMPLETE, zipLoaded);
        //fzip.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        //
        //var loader : URLLoader = new URLLoader();
        //switch (loadType)
        //{
            //case USE_DATABASE:
            //{
                //
                ////	fzip.load(new URLRequest(fileName));
                //loader.addEventListener(flash.events.Event.COMPLETE, fileLoadCallback);
                //loader.load(new URLRequest(fileName));
            //}
            //case USE_LOCAL:
            //{
                //fzip.load(new URLRequest(fileName + "?version=" + Math.round(1000000 * Math.random())));
            //}
            //case USE_URL:
            //{
                //loader.addEventListener(flash.events.Event.COMPLETE, callback);
                //loader.load(new URLRequest(fileName + "?version=" + Math.round(1000000 * Math.random())));
            //}
        //}
    }
    
    private function ioErrorHandler(event : IOErrorEvent) : Void
    {
        trace("ioErrorHandler: " + event);
    }
    
    private function fileLoadCallback(e : flash.events.Event) : Void
    {
        //var s : String = e.target.data;
        //var decodedString : Base64Decoder = new Base64Decoder();
        //decodedString.decode(s);
        //var z : FZip = new FZip();
        //z.loadBytes(decodedString.toByteArray());
        //zipLoaded(null, z);
    }
    
    private function zipLoaded(e : flash.events.Event = null/*, z : FZip = null*/) : Void
    {
        //if (z == null)
        //{
            //fzip.removeEventListener(flash.events.Event.COMPLETE, zipLoaded);
        //}
        //else
        //{
            //fzip = z;
        //}
        //var zipFile : FZipFile;
        //if (fzip.getFileCount() == 3)
        //{
            //var parsedFileArray : Array<Dynamic> = new Array<Dynamic>(3);
            //for (i in 0...fzip.getFileCount())
            //{
                //zipFile = fzip.getFileAt(i);
                //if (zipFile.filename.toLowerCase().indexOf("layout") > -1)
                //{
                    //parsedFileArray[2] = haxe.Json.parse(Std.string(zipFile.content));
                //}
                //else if (zipFile.filename.toLowerCase().indexOf("assignments") > -1)
                //{
                    //parsedFileArray[1] = haxe.Json.parse(Std.string(zipFile.content));
                //}
                //else
                //{
                    //parsedFileArray[0] = haxe.Json.parse(Std.string(zipFile.content));
                //}
            //}
            //m_callback(parsedFileArray);
        //}
        //else
        //{
            //zipFile = fzip.getFileAt(0);
            //var contentsStr : String = Std.string(zipFile.content);
            //var containerObj : Dynamic = haxe.Json.parse(contentsStr);
            //var assignmentsObj : Dynamic = Reflect.field(containerObj, "assignments");
            //var layoutObj : Dynamic = Reflect.field(containerObj, "layout");
            //if (assignmentsObj != null && layoutObj != null)
            //{
                //var containerArray : Array<Dynamic> = new Array<Dynamic>(3);
                //containerArray[0] = containerObj;
                //containerArray[1] = assignmentsObj;
                //containerArray[2] = layoutObj;
                //trace("loaded world file: " + zipFile.filename);
                //m_callback(containerArray);
            //}
            //else
            //{
                //trace("loaded individual file: " + zipFile.filename);
                //zipFile = fzip.getFileAt(0);
                //m_callback(containerObj);
            //}
        //}
    }
    
    //just pass results on to the real callback
    public function defaultCallback(result : Int, e : flash.events.Event) : Void
    {
        if (m_callback != null)
        {
            m_callback(result, e);
        }
    }
    
    //decode results and pass on
    public function defaultJSONCallback(result : Int, e : flash.events.Event) : Void
    {
        //var message : String = Std.string(e.target.data);
        //var vec : Array<Dynamic> = new Array<Dynamic>();
        //var obj : Dynamic = haxe.Json.parse(message);
        //for (entry in obj)
        //{
            //vec.push(entry);
        //}
        //
        //if (m_callback != null)
        //{
            //m_callback(result, vec);
        //}
    }
    
    public function onRequestSavedLevelsFinished(result : Int, layoutObjects : Array<Dynamic>) : Void
    {
        savedMatchArrayObjects = layoutObjects;
        m_callback(result);
    }
    
    //called when level metadata is loaded
    public function setLevelMetadataFromCurrent(result : Int, e : flash.events.Event) : Void
    //don't directly fill levelInfoVector until we are all done
    {
        
        levelInfoVector = null;
        var vector : Array<Dynamic> = new Array<Dynamic>();
        if (e != null && e.target != null && Reflect.field(e.target, "data") != null)
        {
            var message : String = Std.string(Reflect.field(e.target, "data"));
            var obj : Dynamic = haxe.Json.parse(message);
            for (id in Reflect.fields(obj))
            {
            //swiitching to using actual Mongo objects makes the id field appear different. Fix that...
                var entry = Reflect.field(obj, id);
                if (!Reflect.hasField(entry, "id"))
                {
                    if (Reflect.hasField(entry, "_id"))
                    {
                        if (Reflect.hasField(entry._id, "$oid"))
                        {
                            entry.id = entry._id.__DOLLAR__oid;
                        }
                    }
                }
                vector.push(entry);
            }
        }
        
        levelInfoVector = vector;
        if (m_callback != null)
        {
            m_callback(result);
        }
    }
    
    //called when level metadata is loaded
    public function setCompletedLevels(result : Int, levelObjects : Array<Dynamic>) : Void
    {
        completedLevelVector = levelObjects;
        m_callback(result);
    }
    
    public function saveLevel(saveType : String) : Void
    {
        sendMessage(save_level, onLevelSubmitted, saveType, m_levelFilesString);
    }
    
    public function onLevelSubmitted(result : Int, e : flash.events.Event) : Void
    {
        var obj : Dynamic = haxe.Json.parse(Reflect.field(e.target, "data"));
        //save new file ID and clear stored updates
        PipeJam3.m_savedCurrentLevel.data.assignmentsID = Reflect.field(obj, "assignmentsID");
        PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = {};
    }
    
    public function onDBLevelCreated() : Void
    //need the constraints file id and the level id to create a db level (reuse the current levelID and layoutID)
    {
        
        //also should add user id, so we can track who did what
        if (m_assignmentsSaved == true && m_levelCreated == true)
        {  //	sendMessage(CREATE_DB_LEVEL, null, ??????);  
            
        }
    }
    
    public function sendMessage(type : Int, callback : Function, info : String = null, data : String = null) : Void
    {
        var request : String;
        var method : String;
        var url : String = null;
        var usePython : Bool = true;
        var messages : Array<Dynamic> = new Array<Dynamic>();
        var data_id : String;
        
        
        switch (type)
        {
            case get_high_scores_for_level:
                url = NetworkConnection.productionInterop + "?function=getHighScoresForLevel2&data_id=" + data;
            case report_player_rating:
                if (PlayerValidation.playerID == "")
                {
                    return;
                }
                messages.push({
                            playerID : PlayerValidation.playerID,
                            levelID : PipeJamGame.levelInfo.levelID,
                            preference : PipeJamGame.levelInfo.preference
                        });
                data_id = haxe.Json.stringify(messages);
                url = NetworkConnection.productionInterop + "?function=reportPlayerRating2&data_id='" + data_id + "'";
            case get_all_level_metadata:
                url = NetworkConnection.productionInterop + "?function=getActiveLevels2&data_id=foo";
            case save_level:
                if (PlayerValidation.playerID == "")
                {
                    return;
                }
                //update number of conflicts in level
                World.m_world.active_level.getNextConflict(true);
                
                var solutionInfo : Dynamic = PipeJamGame.levelInfo;
                solutionInfo.current_score = Std.string(World.m_world.active_level.currentScore);
                solutionInfo.prev_score = Std.string(World.m_world.active_level.oldScore);
                solutionInfo.revision = Std.string(as3hx.Compat.parseInt(PipeJamGame.levelInfo.revision) + 1);
                solutionInfo.playerID = PlayerValidation.playerID;
                solutionInfo.username = PlayerValidation.playerUserName;
                Reflect.deleteField(solutionInfo, "id");  //need to remove this or else successive saves won't work  ;
                Reflect.deleteField(solutionInfo, "_id");  //need to remove this or else successive saves won't work  ;
                PipeJamGame.levelInfo.revision = solutionInfo.revision;
                //current time in seconds
                var currentDate : Date = Date.now();
                var dateUTC : Float = currentDate.getTime();
                solutionInfo.submitted_date = Std.int(dateUTC / 1000);
                //save, delete, stringify, and then restore highscore vector (not really needed, and they might contain an id property)
                var savedHighScoreArray : Array<Dynamic> = solutionInfo.highScores;
                Reflect.deleteField(solutionInfo, "highScores");
                data_id = haxe.Json.stringify(solutionInfo);
                solutionInfo.highScores = savedHighScoreArray;
                url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&data_id='" + data_id + "'";
            case report_leaderboard_score:
                if (PlayerValidation.playerID == "")
                {
                    return;
                }
                var leaderboardScore : Int = 1;
                var levelScore : Int = World.m_world.active_level.currentScore;
                var targetScore : Int = PipeJamGame.levelInfo.targetScore;
                if (levelScore > targetScore)
                {
                    leaderboardScore = 2;
                }
                request = "/api/score&method=URL";
                url = NetworkConnection.productionInterop + "?function=passURLPOST2&data_id='/api/score'";
                var dataObj : Dynamic = {};
                dataObj.playerId = PlayerValidation.playerID;
                dataObj.gameId = PipeJam3.GAME_ID;
                var i : Dynamic = PipeJamGame.levelInfo;
                dataObj.levelId = PipeJamGame.levelInfo.levelID;
                var parameters : Array<Dynamic> = new Array<Dynamic>();
                var paramScoreObj : Dynamic = {};
                paramScoreObj.name = "score";
                paramScoreObj.value = levelScore;
                var paramLeaderScoreObj : Dynamic = {};
                paramLeaderScoreObj.name = "leaderboardScore";
                paramLeaderScoreObj.value = leaderboardScore;
                parameters.push(paramScoreObj);
                parameters.push(paramLeaderScoreObj);
                dataObj.parameter = parameters;
                data = haxe.Json.stringify(dataObj);
        }
        
        NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
    }
}
