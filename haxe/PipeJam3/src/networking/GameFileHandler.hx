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
import server.MTurkAPI;
//import deng.fzip.FZip;
//import deng.fzip.FZipFile;
import events.NavigationEvent;
import scenes.Scene;
import scenes.game.PipeJamGameScene;
import scenes.game.display.World;
import starling.events.Event;
import utils.Base64Decoder;
import utils.Base64Encoder;
import utils.XMath;

/** How to use:
	 * In most cases, there's a static function that will do what you want, and call a callback when done.
	 * 	internally, this creates a GameFileHandler object and carries out the request.
	 *  occasionally, you might need to create your own object
	 *   	but in cases like these, you might just want to add a new static interface.
	 */
class GameFileHandler
{
    public static var GET_ALL_LEVEL_METADATA : Int = 2;
    public static var SAVE_LEVEL : Int = 3;
    public static var GET_LEVEL : Int = 4;
    public static var REPORT_LEADERBOARD_SCORE : Int = 5;
    public static var GET_HIGH_SCORES_FOR_LEVEL : Int = 6;
    
    public static var USE_LOCAL : Int = 1;
    public static var USE_DATABASE : Int = 2;
    public static var USE_URL : Int = 3;
    
    public static var levelInfoVector : Array<Dynamic> = null;
    
    //not currently used in version 2
    public static var completedLevelVector : Array<Dynamic> = null;
    
    public static var numLevels : Int = 10;
    
    //divide levels into three set of hardness, based on numConstraint range values
    public static var level1TopRangeNumConstraint : Int = 200;
    public static var level1TopRangeLevelIndex : Int = 0;
    public static var level2TopRangeNumConstraint : Int = 600;
    public static var level2TopRangeLevelIndex : Int = 0;
    
    public static var range1PlayerActivityMarker : Int = 5;
    public static var range2PlayerActivityMarker : Int = 10;
    
    private static var m_name : String;
    private static var m_loadCallback : Function;
    
    
    private var m_callback : Function;
    private var fzip : FZip;
    
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
        fileHandler.sendMessage(GET_LEVEL, fileHandler.defaultJSONCallback, null, id);
    }
    
    public static function loadLevelInfoFromID(id : String, callback : Function) : Void
    //look up name in metadata list
    {
        
        if (levelInfoVector != null)
        {
            PipeJamGame.levelInfo = findLevelObject(id);
            PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
        }
        else
        {
            GameFileHandler.m_name = id;
            GameFileHandler.m_loadCallback = callback;
            //set a timer, and try again
            var timer : Timer = new Timer(250, 1);
            timer.addEventListener(TimerEvent.TIMER, getLevelCallback);
            timer.start();
        }
    }
    
    public static function getLevelCallback(e : TimerEvent = null) : Void
    {
        GameFileHandler.loadLevelInfoFromID(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
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
            timer.addEventListener(TimerEvent.TIMER, getLevelFromNameCallback);
            timer.start();
        }
    }
    
    
    public static function getLevelFromNameCallback(e : TimerEvent = null) : Void
    {
        GameFileHandler.loadLevelInfoFromName(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
    }
    
    
    public static function getFileByID(id : String, callback : Function) : Void
    {
        var fileURL : String = getFileURL + "&data_id=\"" + id + "\"";
        
        loadFile(callback, USE_DATABASE, fileURL);
    }
    
    public static function getHighScoresForLevel(callback : Function, levelID : String) : Void
    {
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(GET_HIGH_SCORES_FOR_LEVEL, fileHandler.defaultJSONCallback, null, levelID);
    }
    
    
    public static function retrieveLevelMetadata() : Void
    {
        GameFileHandler.getLevelMetadata(null);
    }
    
    public static function findLevelObject(id : String) : Dynamic
    {
        for (level in levelInfoVector)
        {
            if (level.levelID == id)
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
    
    public static var levelPlayedDict : Dictionary;
    public static function getRandomLevelObject() : Dynamic
    {
        var currentIndex : Int;
        var i : Int = 0;
        if (levelInfoVector != null && levelInfoVector.length > 0 && PlayerValidation.playerActivity != null)
        {
            var levelPlayedArray : Array<Dynamic> = PlayerValidation.playerActivity["completed_boards"];
            if (levelPlayedArray == null)
            {
                levelPlayedArray = new Array<Dynamic>();
            }
            if (levelPlayedDict == null)
            {
                levelPlayedDict = new Dictionary();
                for (i in 0...levelPlayedArray.length)
                {
                    Reflect.setField(levelPlayedDict, Std.string(levelPlayedArray[i]), 1);
                }
            }
            
            var topRange : Int;
            var bottomRange : Int;
            if (levelPlayedArray.length >= range2PlayerActivityMarker)
            {
                bottomRange = as3hx.Compat.parseInt(level2TopRangeLevelIndex + 1);
                topRange = as3hx.Compat.parseInt(levelInfoVector.length - 1);
                PlayerValidation.currentActivityLevel = 3;
            }
            else if (levelPlayedArray.length >= range1PlayerActivityMarker)
            {
                bottomRange = as3hx.Compat.parseInt(level1TopRangeLevelIndex + 1);
                topRange = level2TopRangeLevelIndex;
                PlayerValidation.currentActivityLevel = 2;
            }
            else
            {
                bottomRange = 0;
                topRange = level1TopRangeLevelIndex;
                PlayerValidation.currentActivityLevel = 1;
            }
            
            //grab a random unplayed one from the specified interval
            var found : Bool = false;
            var levelInfo : Dynamic;
            for (i in 0...20)
            {
                currentIndex = XMath.randomInt(bottomRange, topRange);
                levelInfo = levelInfoVector[currentIndex];
                if (levelPlayedDict[levelInfo.levelID] != 1)
                {
                    found = true;
                    break;
                }
            }
            
            //if we didn't find an unplayed one, expand the range downward, and try again
            if (found == false)
            {
                for (i in 0...20)
                {
                    currentIndex = XMath.randomInt(0, topRange);
                    levelInfo = levelInfoVector[currentIndex];
                    if (levelPlayedDict[levelInfo.levelID] != 1)
                    {
                        found = true;
                        break;
                    }
                }
            }
            
            //didn't find unplayed one in our ranges, so just grab one
            if (found == false)
            {
                currentIndex = XMath.randomInt(0, levelInfoVector.length - 1);
                levelInfo = levelInfoVector[currentIndex];
            }
            
            //mark this one played, too
            levelPlayedDict[levelInfo.levelID] = 1;
            return levelInfoVector[currentIndex];
        }
        else if (PipeJam3.RELEASE_BUILD == false)
        {
        //this is for local debugguing, non-release build
            
            currentIndex = XMath.randomInt(0, levelInfoVector.length - 1);
            return levelInfoVector[currentIndex];
        }
        else
        {
            return null;
        }
    }
    
    //connect to the db and get a list of all levels
    public static function getLevelMetadata(callback : Function) : Void
    {
        levelInfoVector = null;
        var fileHandler : GameFileHandler = new GameFileHandler(callback);
        fileHandler.sendMessage(GET_ALL_LEVEL_METADATA, fileHandler.setLevelMetadataFromCurrent);
    }
    
    public static function submitLevel(_levelFilesString : String, saveType : String, fileType : Int = 1) : Void
    {
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
        fileHandler.sendMessage(REPORT_LEADERBOARD_SCORE, null);
    }
    
    public static function loadGameFiles(worldFileLoadedCallback : Function, layoutFileLoadedCallback : Function, assignmentsFileLoadedCallback : Function) : Void
    {
        var gameFileHandler : GameFileHandler;
        //do this so I can debug the object...
        var levelInformation : Dynamic = PipeJamGame.levelInfo;
        
        Scene.m_gameSystem.dispatchEvent(new starling.events.Event(Constants.START_BUSY_ANIMATION, true));
        
        var m_id : Int = 100000;
        if (PipeJamGame.levelInfo && PipeJamGame.levelInfo.exists("id") && PipeJamGame.levelInfo.id.length < 5)
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
        if (PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP && !PipeJam3.RELEASE_BUILD)
        {
        //load the zip file from it's location
            
            loadType = USE_URL;
            gameFileHandler = new GameFileHandler(worldFileLoadedCallback);
            gameFileHandler.loadFile(USE_LOCAL, PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP, gameFileHandler.zipLoaded);
        }
        else if (PipeJamGameScene.inTutorial)
        {
            layoutFileLoadedCallback(TutorialController.tutorialLayoutObj);
            assignmentsFileLoadedCallback(TutorialController.tutorialAssignmentsObj);
            worldFileLoadedCallback(TutorialController.tutorialObj);
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
                        loadFile(worldFileLoadedCallback, loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.assignmentsID + "\"");
                    }
                    else
                    {
                        var levelInfo : Dynamic = PipeJamGame.levelInfo;
                        // TODO: probably rename from /xml and /constraints to /level and /assignments
                        trace(getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.levelID + "\"");
                        loadFile(worldFileLoadedCallback, loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.levelID + "\"");
                        loadFile(layoutFileLoadedCallback, loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.layoutID + "\"");
                        loadFile(assignmentsFileLoadedCallback, loadType, getFileURL + "&data_id=\"" + PipeJamGame.levelInfo.assignmentsID + "\"");
                    }
                }
            }
            else if (fileName != null && fileName.length > 0)
            {
                if (fileName.indexOf("cnf") == -1)
                {
                //check for which form we are loading, try loading one, and if it works, continue...
                    
                    loadFile(worldFileLoadedCallback, loadType, fileName + ".zip");
                    loadFile(layoutFileLoadedCallback, loadType, fileName + "Layout.zip");
                    loadFile(assignmentsFileLoadedCallback, loadType, fileName + "Assignments.zip");
                }
                else
                {
                    loadFile(worldFileLoadedCallback, loadType, fileName + ".zip");
                    var index : Int = fileName.lastIndexOf(".");
                    var fileNameRoot : String = fileName.substring(0, index);
                    loadFile(layoutFileLoadedCallback, loadType, fileNameRoot + ".plain.zip");
                }
            }
        }
    }
    
    public static function loadFile(callback : Function, loadType : Int, url : String) : Void
    {
        var fileLoader : GameFileHandler = new GameFileHandler(callback);
        fileLoader.loadFile(loadType, url);
    }
    
    /************************ End of static functions *********************************/
    
    public function new(callback : Function = null)
    {
        m_callback = callback;
    }
    
    
    //load files from disk or database
    public function loadFile(loadType : Int, fileName : String, callback : Function = null) : Void
    {
        fzip = new FZip();
        fzip.addEventListener(flash.events.Event.COMPLETE, zipLoaded);
        //fzip.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        
        var loader : URLLoader = new URLLoader();
        switch (loadType)
        {
            case USE_DATABASE:
            {
                
                //	fzip.load(new URLRequest(fileName));
                loader.addEventListener(flash.events.Event.COMPLETE, fileLoadCallback);
                loader.load(new URLRequest(fileName));
            }
            case USE_LOCAL:
            {
                fzip.load(new URLRequest(fileName + "?version=" + Math.round(1000000 * Math.random())));
            }
            case USE_URL:
            {
                loader.addEventListener(flash.events.Event.COMPLETE, callback);
                loader.load(new URLRequest(fileName + "?version=" + Math.round(1000000 * Math.random())));
            }
        }
    }
    
    private function ioErrorHandler(event : IOErrorEvent) : Void
    {
        trace("ioErrorHandler: " + event);
    }
    
    private function fileLoadCallback(e : flash.events.Event) : Void
    {
        var s : String = e.target.data;
        var decodedString : Base64Decoder = new Base64Decoder();
        decodedString.decode(s);
        var z : FZip = new FZip();
        z.loadBytes(decodedString.toByteArray());
        zipLoaded(null, z);
    }
    
    private function zipLoaded(e : flash.events.Event = null, z : FZip = null) : Void
    {
        if (z == null)
        {
            fzip.removeEventListener(flash.events.Event.COMPLETE, zipLoaded);
        }
        else
        {
            fzip = z;
        }
        var zipFile : FZipFile;
        if (fzip.getFileCount() == 3)
        {
            var parsedFileArray : Array<Dynamic> = new Array<Dynamic>(3);
            for (i in 0...fzip.getFileCount())
            {
                zipFile = fzip.getFileAt(i);
                if (zipFile.filename.toLowerCase().indexOf("layout") > -1)
                {
                    parsedFileArray[2] = haxe.Json.parse(Std.string(zipFile.content));
                }
                else if (zipFile.filename.toLowerCase().indexOf("assignments") > -1)
                {
                    parsedFileArray[1] = haxe.Json.parse(Std.string(zipFile.content));
                }
                else
                {
                    parsedFileArray[0] = haxe.Json.parse(Std.string(zipFile.content));
                }
            }
            m_callback(parsedFileArray);
        }
        else
        {
            zipFile = fzip.getFileAt(0);
            var contentsStr : String = Std.string(zipFile.content);
            if (zipFile.filename.indexOf("cnf") == -1 && zipFile.filename.indexOf("plain") == -1)
            {
                var containerObj : Dynamic = haxe.Json.parse(contentsStr);
                var assignmentsObj : Dynamic = Reflect.field(containerObj, "assignments");
                var layoutObj : Dynamic = Reflect.field(containerObj, "layout");
                if (assignmentsObj != null && layoutObj != null)
                {
                    var containerArray : Array<Dynamic> = new Array<Dynamic>(3);
                    containerArray[0] = containerObj;
                    containerArray[1] = assignmentsObj;
                    containerArray[2] = layoutObj;
                    trace("loaded world file: " + zipFile.filename);
                    m_callback(containerArray);
                }
                else
                {
                    trace("loaded individual file: " + zipFile.filename);
                    zipFile = fzip.getFileAt(0);
                    m_callback(containerObj);
                }
            }
            else
            {
                trace("loaded individual file: " + zipFile.filename);
                zipFile = fzip.getFileAt(0);
                m_callback(zipFile);
            }
        }
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
        var message : String = Std.string(e.target.data);
        var vec : Array<Dynamic> = new Array<Dynamic>();
        if (message.length > 0)
        {
            var obj : Dynamic = haxe.Json.parse(message);
            for (entry in obj)
            {
                vec.push(entry);
            }
        }
        
        if (m_callback != null)
        {
            m_callback(result, vec);
        }
    }
    
    
    //called when level metadata is loaded
    public function setLevelMetadataFromCurrent(result : Int, e : flash.events.Event) : Void
    //don't directly fill levelInfoVector until we are all done
    {
        
        levelInfoVector = null;
        var vector : Array<Dynamic> = new Array<Dynamic>();
        if (e != null && e.target && e.target.data)
        {
            var message : String = Std.string(e.target.data);
            var obj : Dynamic = haxe.Json.parse(message);
            for (entry in obj)
            {
            //swiitching to using actual Mongo objects makes the id field appear different. Fix that...
                
                if (!entry.exists("id"))
                {
                    if (entry.exists("_id"))
                    {
                        if (entry._id.exists("$oid"))
                        {
                            entry.id = entry._id.__DOLLAR__oid;
                        }
                    }
                }
                var lastUnderscore : Int = (Std.string(entry.name)).lastIndexOf("_");
                var firstUnderscore : Int = (Std.string(entry.name)).indexOf("_");
                if (lastUnderscore != -1 && firstUnderscore != lastUnderscore)
                {
                    var countString : String = (Std.string(entry.name)).substring(firstUnderscore + 1, lastUnderscore);
                    var constraintCount : Int = as3hx.Compat.parseInt(countString);
                    if (constraintCount > 0)
                    {
                        Reflect.setField(entry, "constraintCount", constraintCount);
                    }
                    else
                    {
                        Reflect.setField(entry, "constraintCount", 0);
                    }
                }
                
                vector.push(entry);
            }
        }
        vector.sort(sortOnConstraints);
        levelInfoVector = vector;
        
        //now that they are sorted, figure out the ranges
        for (index in 0...levelInfoVector.length)
        {
            var levelInfo : Dynamic = levelInfoVector[index];
            if (levelInfo.constraintCount < level1TopRangeNumConstraint)
            {
                level1TopRangeLevelIndex++;
                level2TopRangeLevelIndex++;
            }
            else if (levelInfo.constraintCount < level2TopRangeNumConstraint)
            {
                level2TopRangeLevelIndex++;
            }
            else
            {
                break;
            }
        }
        
        if (m_callback != null)
        {
            m_callback(result);
        }
    }
    
    private function sortOnConstraints(itemA : Dynamic, itemB : Dynamic) : Float
    {
        if (Reflect.field(itemA, "constraintCount") < Reflect.field(itemB, "constraintCount"))
        {
            return -1;
        }
        else if (Reflect.field(itemA, "constraintCount") > Reflect.field(itemB, "constraintCount"))
        {
            return 1;
        }
        else
        {
            return 0;
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
        if (PipeJam3.RELEASE_BUILD)
        {
            sendMessage(SAVE_LEVEL, onLevelSaved, saveType, m_levelFilesString);
        }
    }
    
    public function onLevelSaved(result : Int, e : flash.events.Event) : Void
    {
        World.m_world.dispatchEvent(new NavigationEvent(NavigationEvent.UPDATE_HIGH_SCORES, null));
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
        var url : String = null;
        var messages : Array<Dynamic> = new Array<Dynamic>();
        var data_id : String;
        
        
        switch (type)
        {
            case GET_HIGH_SCORES_FOR_LEVEL:
                url = NetworkConnection.productionInterop + "?function=getHighScoresForLevel2&data_id=" + data;
            case GET_ALL_LEVEL_METADATA:
                url = NetworkConnection.productionInterop + "?function=getActiveLevels2&data_id=foo";
            case SAVE_LEVEL:
                var solutionInfo : Dynamic = PipeJamGame.levelInfo;
                solutionInfo.current_score = Std.string(World.m_world.active_level.currentScore);
                solutionInfo.target_score = Std.string(World.m_world.active_level.currentScore);
                solutionInfo.max_score = Std.string(World.m_world.active_level.maxScore);
                solutionInfo.prev_score = Std.string(World.m_world.active_level.oldScore);
                solutionInfo.max_score = Std.string(World.m_world.active_level.maxScore);
                solutionInfo.revision = Std.string(as3hx.Compat.parseInt(PipeJamGame.levelInfo.revision) + 1);
                if (PipeJam3.ASSET_SUFFIX == "Turk")
                {
                    solutionInfo.turkToken = MTurkAPI.getInstance().workerToken;
                    solutionInfo.playerID = "turk";
                    solutionInfo.username = "turk";
                }
                else
                {
                    solutionInfo.playerID = PlayerValidation.playerID;
                    solutionInfo.username = PlayerValidation.userNames[PlayerValidation.playerID];
                }
                Reflect.deleteField(solutionInfo, "id");  //need to remove this or else successive saves won't work
                Reflect.deleteField(solutionInfo, "_id");  //need to remove this or else successive saves won't work
                PipeJamGame.levelInfo.revision = solutionInfo.revision;
                //current time in seconds
                var currentDate : Date = Date.now();
                var dateUTC : Float = currentDate.getTime() + currentDate.getTimezoneOffset();
                solutionInfo.submitted_date = as3hx.Compat.parseInt(dateUTC / 1000);
                //save, delete, stringify, and then restore highscore vector (not really needed, and they might contain an id property)
                var savedHighScoreArray : Array<Dynamic> = solutionInfo.highScores;
                Reflect.deleteField(solutionInfo, "highScores");
                data_id = haxe.Json.stringify(solutionInfo);
                solutionInfo.highScores = savedHighScoreArray;
                if (data.length > 75000)
                {
                //just a guess as to what doesn't pass well between php and python on the server. 130K doesn't work
                    
                    url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&file=" + Std.string(Math.round(Math.random() * 10000)) + "&data_id='" + data_id + "'";
                }
                else
                {
                    url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&data_id='" + data_id + "'";
                }
            case REPORT_LEADERBOARD_SCORE:
                if (PlayerValidation.playerID == "")
                {
                    return;
                }
                var scoreDifference : Float = World.m_world.active_level.currentScore - World.m_world.active_level.oldScore;
                var levelID : String;
                var percent : Float = World.m_world.currentPercent;
                if (World.m_world.currentPercent >= 100)
                {
                    levelID = PipeJamGame.levelInfo.levelID;
                }
                
                PlayerValidation.validationObject.setPlayerActivityInfo(scoreDifference, levelID);
                
                var playerID : String = PlayerValidation.playerID;
                //report to website scoreDifference + starting count
                var total : Int = as3hx.Compat.parseInt(scoreDifference);
                for (person in PipeJamGame.levelInfo.highScores)
                {
                    if (person[1] == PlayerValidation.playerID)
                    {
                        total = as3hx.Compat.parseInt(total + person[3]);
                        break;
                    }
                }
                var leaderboardScore : Int = 1;
                var levelScore : Int = World.m_world.active_level.currentScore;
                var targetScore : Int = PipeJamGame.levelInfo.targetScore;
                if (levelScore > targetScore)
                {
                    leaderboardScore = 2;
                }
                url = NetworkConnection.productionInterop + "?function=jsonPOST&data_id='/api/score'&data2='" + PlayerValidation.accessToken + "'";
                var dataObj : Dynamic = {};
                dataObj.playerId = PlayerValidation.playerID;
                dataObj.gameId = PipeJam3.GAME_ID;
                dataObj.levelId = PipeJamGame.levelInfo.levelID;
                var parameters : Array<Dynamic> = new Array<Dynamic>();
                var paramScoreObj : Dynamic = {};
                paramScoreObj.name = "points";
                paramScoreObj.value = total;
                parameters.push(paramScoreObj);
                dataObj.parameter = parameters;
                data = haxe.Json.stringify(dataObj);
        }
        
        NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
    }
}
