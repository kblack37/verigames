package networking
{	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import events.MenuEvent;
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
	public class GameFileHandler
	{
		public static var GET_COMPLETED_LEVELS:int = 1;
		public static var GET_ALL_LEVEL_METADATA:int = 2;
		public static var SAVE_LAYOUT:int = 3;
		public static var REQUEST_LAYOUT_LIST:int = 5;
		public static var SAVE_LEVEL:int = 7;
		public static var GET_ALL_SAVED_LEVELS:int = 8;
		public static var GET_SAVED_LEVEL:int = 15;
		public static var DELETE_SAVED_LEVEL:int = 9;
		public static var REPORT_PLAYER_RATING:int = 12;
		public static var REPORT_LEADERBOARD_SCORE:int = 13;
		public static var GET_HIGH_SCORES_FOR_LEVEL:int = 14;
		public static var USE_LOCAL:int = 1;
		public static var USE_DATABASE:int = 2;
		public static var USE_URL:int = 3;
		
		static public var GET_COMPLETED_LEVELS_REQUEST:String = "/level/completed";
		static public var METADATA_GET_ALL_REQUEST:String = "/level/metadata/get/all";
		static public var LAYOUTS_GET_ALL_REQUEST:String = "/layout/get/all/";
		
		static public var levelInfoVector:Vector.<Object> = null;
		
		//not currently used in version 2
		static public var completedLevelVector:Vector.<Object> = null;
		static public var savedMatchArrayObjects:Vector.<Object> = null;
		
		static public var numLevels:int = 10;
		
		static protected var m_name:String;
		static protected var m_loadCallback:Function;
		
		
		protected var m_callback:Function;
		protected var fzip:FZip;
		
		protected var m_saveType:String
		protected var m_fileType:int;
		protected var m_levelFilesString:String;
		
		public var m_assignmentsSaved:Boolean = false;
		public var m_levelCreated:Boolean = false;
		public var m_levelSubmitted:Boolean = false;
		
		public static var getFileURL:String = NetworkConnection.productionInterop + "?function=getFile2";
		
		static public function loadLevelInfoFromObjectID(id:String, callback:Function):void
		{
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_SAVED_LEVEL, fileHandler.defaultJSONCallback, null, id);
		}
		
		static public function loadLevelInfoFromName(name:String, callback:Function):void
		{
			//look up name in metadata list
			if(levelInfoVector)
			{
				PipeJamGame.levelInfo = findLevelObjectByName(name);
				PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
				
			}
			else
			{
				GameFileHandler.m_name = name;
				GameFileHandler.m_loadCallback = callback;
				//set a timer, and try again
				var timer:Timer = new Timer(250, 1);
				timer.addEventListener(TimerEvent.TIMER, getLevelCallback);
				timer.start();
			}
		}
		
		public static function getLevelCallback(e:TimerEvent = null):void
		{
			GameFileHandler.loadLevelInfoFromName(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
		}
		
		
		static public function getFileByID(id:String, callback:Function):void
		{
			var fileURL:String = getFileURL + "&data_id=\"" + id + "\"";
			
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.loadFile(USE_DATABASE, fileURL);
		}
		
		static public function saveLayoutFile(callback:Function, _layoutAsString:String):void
		{
			var layoutDescription:String = PipeJamGame.levelInfo.layoutName + "::" + PipeJamGame.levelInfo.layoutDescription;
			
			var encodedLayoutDescription:String = encodeURIComponent(layoutDescription);
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(SAVE_LAYOUT, callback, encodedLayoutDescription, _layoutAsString);
		}
		
		static public function getHighScoresForLevel(callback:Function, levelID:String):void
		{
			
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_HIGH_SCORES_FOR_LEVEL, fileHandler.defaultJSONCallback, null, levelID);

		}
		
		static public function deleteSavedLevel(_levelIDString:String):void
		{
			var fileHandler:GameFileHandler = new GameFileHandler();
			fileHandler.sendMessage(DELETE_SAVED_LEVEL, null, _levelIDString);
		}
		
		static public function retrieveLevels():void
		{
			GameFileHandler.getLevelMetadata(null);
		}
		
		static public function findLevelObject(id:String):Object
		{
			for each(var level:Object in levelInfoVector)
			{
				if(level.id == id)
				{
					return level;
				}
			}
			return null;
		}
		
		//names are not guaranteed to be unique
		static public function findLevelObjectByName(name:String):Object
		{
			for each(var level:Object in levelInfoVector)
			{
				if(level.name == name)
				{
					return level;
				}
			}
			return null;
		}
		
		static public function getRandomLevelObject():Object
		{
			if(levelInfoVector != null && levelInfoVector.length >0)
			{
				var randNum:int = XMath.randomInt(0, levelInfoVector.length-1);
				return levelInfoVector[randNum];
			}
			else
				return null;
		}
				
		static public function reportPlayerPreference(preference:String):void
		{
			PipeJamGame.levelInfo.preference = preference;
			var fileHandler:GameFileHandler = new GameFileHandler();
			fileHandler.sendMessage(REPORT_PLAYER_RATING, fileHandler.defaultJSONCallback, null);
		}
		
		//connect to the db and get a list of all levels
		static public function getLevelMetadata(callback:Function):void
		{
			levelInfoVector = null;
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_ALL_LEVEL_METADATA, fileHandler.setLevelMetadataFromCurrent);
		}
		
		//connect to the db and get a list of all completed levels
		static public function getCompletedLevels(callback:Function):void
		{
			levelInfoVector = null;
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_COMPLETED_LEVELS, fileHandler.setCompletedLevels);
		}
		
		//connect to the db and get a list of all saved levels
		static public function getSavedLevels(callback:Function):void
		{
			savedMatchArrayObjects = null;
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_ALL_SAVED_LEVELS, fileHandler.onRequestSavedLevelsFinished);
		}
		
		//request a list of layouts associated with current levelObject levelID
		static public function getLayoutList(callback:Function):void
		{
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(REQUEST_LAYOUT_LIST, fileHandler.defaultJSONCallback);
		}
		
		static public function submitLevel(_levelFilesString:String, saveType:String, fileType:int = 1):void
		{
			//this involves:
			//saving the level (layout and constraints, on either save or submit/share)
			//saving the score, level and player info
			//reporting the player performance/preference
			var fileHandler:GameFileHandler = new GameFileHandler();
			fileHandler.m_fileType = fileType;
			fileHandler.m_saveType = saveType;
			fileHandler.m_levelFilesString = _levelFilesString;
			fileHandler.saveLevel(saveType);
			GameFileHandler.reportScore();
		}	
		
		static public function reportScore():void
		{
			var fileHandler:GameFileHandler = new GameFileHandler();
			fileHandler.sendMessage(REPORT_LEADERBOARD_SCORE, null);
		}
		
		static public function loadGameFiles(worldFileLoadedCallback:Function, layoutFileLoadedCallback:Function, assignmentsFileLoadedCallback:Function):void
		{
			var gameFileHandler:GameFileHandler;
			//do this so I can debug the object...
			var levelInformation:Object = PipeJamGame.levelInfo;
			
			Scene.m_gameSystem.dispatchEvent(new starling.events.Event(Game.START_BUSY_ANIMATION,true));
			
			var m_id:int = 100000;
			if(PipeJamGame.levelInfo && PipeJamGame.levelInfo.hasOwnProperty("id") && PipeJamGame.levelInfo.id.length < 5)
				m_id = parseInt(PipeJamGame.levelInfo.id);
			if(m_id < 1000) // in the tutorial if a low level id
			{
				PipeJamGameScene.inTutorial = true;
				PipeJamGameScene.inDemo = false;
				//				fileName = "tutorial";
			}
			if (PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP && !PipeJam3.RELEASE_BUILD)
			{
				//load the zip file from it's location
				loadType = USE_URL;
				gameFileHandler = new GameFileHandler(worldFileLoadedCallback);
				gameFileHandler.loadFile(USE_LOCAL, PipeJamGameScene.DEBUG_PLAY_WORLD_ZIP, gameFileHandler.zipLoaded);
			}
			else if(PipeJamGameScene.inTutorial)
			{
				
				layoutFileLoadedCallback(TutorialController.tutorialLayoutObj);
				assignmentsFileLoadedCallback(TutorialController.tutorialAssignmentsObj);
				worldFileLoadedCallback(TutorialController.tutorialObj);
			}
			else
			{
				var loadType:int = USE_LOCAL;
				
				var fileName:String;
				if(PipeJamGame.levelInfo && PipeJamGame.levelInfo.baseFileName)
					fileName = PipeJamGame.levelInfo.baseFileName;
				else
					fileName = PipeJamGame.m_pipeJamGame.m_fileName;
				
				
				if(PipeJamGame.levelInfo && PipeJamGame.levelInfo.assignmentsID != null && !PipeJamGameScene.inTutorial) //load from MongoDB
				{
					loadType = USE_DATABASE;
					//is this an all in one file?
					var version:int = 0;
					if(PipeJamGame.levelInfo.version)
						version = PipeJamGame.levelInfo.version;
					if(version == PipeJamGame.ALL_IN_ONE)
					{
						gameFileHandler = new GameFileHandler(worldFileLoadedCallback);
						gameFileHandler.loadFile(loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.assignmentsID+"\"");
					}
					else
					{
						var levelInfo:Object = PipeJamGame.levelInfo;
						// TODO: probably rename from /xml and /constraints to /level and /assignments
						trace(getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.levelID+"\"");
						var worldFileHandler:GameFileHandler = new GameFileHandler(worldFileLoadedCallback);
						worldFileHandler.loadFile(loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.levelID+"\"");
						var layoutFileHandler:GameFileHandler = new GameFileHandler(layoutFileLoadedCallback);
						layoutFileHandler.loadFile(loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.layoutID+"\"");
						var assignmentsFileHandler:GameFileHandler = new GameFileHandler(assignmentsFileLoadedCallback);
						assignmentsFileHandler.loadFile(loadType,  getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.assignmentsID+"\"");	
					}
				}
				else if(fileName && fileName.length > 0)
				{
					var worldFileHandler1:GameFileHandler = new GameFileHandler(worldFileLoadedCallback);
					worldFileHandler1.loadFile(loadType, fileName+".zip");
					var layoutFileHandler1:GameFileHandler = new GameFileHandler(layoutFileLoadedCallback);
					layoutFileHandler1.loadFile(loadType, fileName+"Layout.zip");
					var assignmentsFileHandler1:GameFileHandler = new GameFileHandler(assignmentsFileLoadedCallback);
					assignmentsFileHandler1.loadFile(loadType, fileName+"Assignments.zip");
				}
			}
		}
		
		/************************ End of static functions *********************************/
		
		public function GameFileHandler(callback:Function =  null)
		{
			m_callback = callback;
		}
		
		
		//load files from disk or database
		public function loadFile(loadType:int,fileName:String, callback:Function = null):void
		{
			fzip = new FZip();
			fzip.addEventListener(flash.events.Event.COMPLETE, zipLoaded);
			fzip.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var loader:URLLoader = new URLLoader();
			switch(loadType)
			{
				case USE_DATABASE:
				{
					
					//	fzip.load(new URLRequest(fileName));
					loader.addEventListener(flash.events.Event.COMPLETE, fileLoadCallback);
					loader.load(new URLRequest(fileName));
					break;
				}
				case USE_LOCAL:
				{
					fzip.load(new URLRequest(fileName + "?version=" + Math.round(1000000*Math.random())));
					break;
				}
				case USE_URL:
				{
					loader.addEventListener(flash.events.Event.COMPLETE, callback);
					loader.load(new URLRequest(fileName + "?version=" + Math.round(1000000*Math.random())));
					break;
				}
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		private function fileLoadCallback(e:flash.events.Event):void {
			
			var s:String = e.target.data;
			var decodedString:Base64Decoder = new Base64Decoder();
			decodedString.decode(s);
			var z:FZip = new FZip();
			z.loadBytes(decodedString.toByteArray());
			zipLoaded(null, z);
		}
		
		private function zipLoaded(e:flash.events.Event = null, z:FZip = null):void {
			if(z == null)
				fzip.removeEventListener(flash.events.Event.COMPLETE, zipLoaded);
			else
				fzip = z;
			var zipFile:FZipFile;
			if(fzip.getFileCount() == 3)
			{
				var parsedFileArray:Array = new Array(3);
				for (var i:int = 0; i < fzip.getFileCount(); i++) {
					zipFile = fzip.getFileAt(i);
					if (zipFile.filename.toLowerCase().indexOf("layout") > -1) {
						parsedFileArray[2] = JSON.parse(zipFile.content as String);
					} else if (zipFile.filename.toLowerCase().indexOf("assignments") > -1) {
						parsedFileArray[1] = JSON.parse(zipFile.content as String);
					} else {
						parsedFileArray[0] = JSON.parse(zipFile.content as String);
					}
				}
				m_callback(parsedFileArray);
				
			}
			else
			{
				zipFile = fzip.getFileAt(0);
				var contentsStr:String = zipFile.content.toString();
				var containerObj:Object = JSON.parse(contentsStr);
				var assignmentsObj:Object = containerObj["assignments"];
				var layoutObj:Object = containerObj["layout"];
				if (assignmentsObj && layoutObj)
				{
					var containerArray:Array = new Array(3);
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
		}
		
		//just pass results on to the real callback
		public function defaultCallback(result:int, e:flash.events.Event):void
		{
			if(m_callback != null)
				m_callback(result, e);
		}
		
		//decode results and pass on
		public function defaultJSONCallback(result:int, e:flash.events.Event):void
		{
			var message:String = e.target.data as String;
			var vec:Vector.<Object> = new Vector.<Object>;
			var obj:Object = JSON.parse(message);
			for each(var entry:Object in obj)
				vec.push(entry);

			if(m_callback != null)
				m_callback(result, vec);
		}
		
		public function onRequestSavedLevelsFinished(result:int, layoutObjects:Vector.<Object>):void
		{
			savedMatchArrayObjects = layoutObjects;
			m_callback(result);
		}
		
		//called when level metadata is loaded 
		public function setLevelMetadataFromCurrent(result:int, e:flash.events.Event):void
		{
			//don't directly fill levelInfoVector until we are all done
			levelInfoVector = null;
			var vector:Vector.<Object> = new Vector.<Object>();
			if(e && e.target && e.target.data)
			{
				var message:String = e.target.data as String;
				var obj:Object = JSON.parse(message);
				for each(var entry:Object in obj)
				{
					//swiitching to using actual Mongo objects makes the id field appear different. Fix that...
					if(!entry.hasOwnProperty("id"))
					{
						if(entry.hasOwnProperty("_id"))
						{
							if(entry._id.hasOwnProperty("$oid"))
								entry.id = entry._id.$oid;
						}
					}
					vector.push(entry);
				}
			}

			levelInfoVector = vector;
			if(m_callback != null)
				m_callback(result);
		}
		
		//called when level metadata is loaded 
		public function setCompletedLevels(result:int, levelObjects:Vector.<Object>):void
		{
			completedLevelVector = levelObjects;
			m_callback(result);
		}
		
		public function saveLevel(saveType:String):void
		{
			sendMessage(SAVE_LEVEL, onLevelSubmitted, saveType, m_levelFilesString);
		}
		
		public function onLevelSubmitted(result:int, e:flash.events.Event):void
		{
			var obj:Object = JSON.parse(e.target.data);
			//save new file ID and clear stored updates
			PipeJam3.m_savedCurrentLevel.data.assignmentsID = obj["assignmentsID"];
			PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = new Object();
			//post a dialog
		//	World.m_world.dispatchEvent(new MenuEvent(MenuEvent.LEVEL_SUBMITTED));
		}
		
		public function onDBLevelCreated():void
		{
			//need the constraints file id and the level id to create a db level (reuse the current levelID and layoutID)
			//also should add user id, so we can track who did what
			if(m_assignmentsSaved == true && m_levelCreated == true)
			{
				//	sendMessage(CREATE_DB_LEVEL, null, ??????);
			}
		}
		
		public function sendMessage(type:int, callback:Function, info:String = null, data:String = null):void
		{
			var request:String;
			var method:String;
			var url:String = null;
			var usePython:Boolean = true;
			var messages:Array = new Array (); 
			var data_id:String;
			
			
			switch(type)
			{
				case GET_HIGH_SCORES_FOR_LEVEL:
					url = NetworkConnection.productionInterop  + "?function=getHighScoresForLevel2&data_id=" + data;
					break;
				case REPORT_PLAYER_RATING:
					if(PlayerValidation.playerID == "")
						return;
					messages.push ({'playerID': PlayerValidation.playerID,'levelID': PipeJamGame.levelInfo.levelID,'preference': PipeJamGame.levelInfo.preference});
					data_id = JSON.stringify(messages);
					url = NetworkConnection.productionInterop + "?function=reportPlayerRating2&data_id='"+data_id+"'";
					break;
				case GET_ALL_LEVEL_METADATA:
					url = NetworkConnection.productionInterop + "?function=getActiveLevels2&data_id=foo";
					break;
				case SAVE_LEVEL:
					if(PlayerValidation.playerID == "")
							return;
					//update number of conflicts in level
					World.m_world.active_level.getNextConflict(true);
					
					var solutionInfo:Object = PipeJamGame.levelInfo;
					solutionInfo.current_score =  String(World.m_world.active_level.currentScore);
					solutionInfo.prev_score =  String(World.m_world.active_level.oldScore);
					solutionInfo.revision =  String(int(PipeJamGame.levelInfo.revision) + 1);
					solutionInfo.playerID =  PlayerValidation.playerID;
					solutionInfo.username = PlayerValidation.playerUserName; 
					delete solutionInfo["id"]; //need to remove this or else successive saves won't work
					delete solutionInfo["_id"]; //need to remove this or else successive saves won't work
					PipeJamGame.levelInfo.revision = solutionInfo.revision;
					//current time in seconds
					var currentDate:Date = new Date();
					var dateUTC:Number = currentDate.getTime() + currentDate.getTimezoneOffset();
					solutionInfo.submitted_date = int(dateUTC/1000);
					//save, delete, stringify, and then restore highscore vector (not really needed, and they might contain an id property)
					var savedHighScoreArray:Array = solutionInfo.highScores;
					delete solutionInfo["highScores"];
					data_id = JSON.stringify(solutionInfo);
					solutionInfo.highScores = savedHighScoreArray;
					url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&data_id='"+data_id+"'";
					break;
				case REPORT_LEADERBOARD_SCORE:
					if(PlayerValidation.playerID == "")
						return;
					var leaderboardScore:int = 1;
					var levelScore:int = World.m_world.active_level.currentScore;
					var targetScore:int = PipeJamGame.levelInfo.targetScore;
					if(levelScore > targetScore)
						leaderboardScore = 2;
					request = "/api/score&method=URL";
					url = NetworkConnection.productionInterop + "?function=passURLPOST2&data_id='/api/score'";
					var dataObj:Object = new Object;
					dataObj.playerId = PlayerValidation.playerID;
					dataObj.gameId = PipeJam3.GAME_ID;
					var i:Object = PipeJamGame.levelInfo;
					dataObj.levelId = PipeJamGame.levelInfo.levelID;
					var parameters:Array = new Array;
					var paramScoreObj:Object = new Object;
					paramScoreObj.name = "score";
					paramScoreObj.value = levelScore;
					var paramLeaderScoreObj:Object = new Object;
					paramLeaderScoreObj.name = "leaderboardScore";
					paramLeaderScoreObj.value = leaderboardScore;
					parameters.push(paramScoreObj);
					parameters.push(paramLeaderScoreObj);
					dataObj.parameter = parameters;
					data = JSON.stringify(dataObj);
					break;
			}
			
			NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
		}
	}
}