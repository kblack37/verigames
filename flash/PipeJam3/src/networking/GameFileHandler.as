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
	import server.MTurkAPI;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
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
		public static var GET_ALL_LEVEL_METADATA:int = 2;
		public static var SAVE_LEVEL:int = 3;
		public static var GET_LEVEL:int = 4;
		public static var REPORT_LEADERBOARD_SCORE:int = 5;
		public static var GET_HIGH_SCORES_FOR_LEVEL:int = 6;
		
		public static var USE_LOCAL:int = 1;
		public static var USE_DATABASE:int = 2;
		public static var USE_URL:int = 3;
		
		static public var levelInfoVector:Vector.<Object> = null;
		
		//not currently used in version 2
		static public var completedLevelVector:Vector.<Object> = null;
		
		static public var numLevels:int = 10;
		
		//divide levels into three set of hardness, based on numConstraint range values
		static public var level1TopRangeNumConstraint:int = 200;
		static public var level1TopRangeLevelIndex:int = 0;
		static public var level2TopRangeNumConstraint:int = 600;
		static public var level2TopRangeLevelIndex:int = 0;
		
		static public var range1PlayerActivityMarker:int = 5;
		static public var range2PlayerActivityMarker:int = 10;
		
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
			fileHandler.sendMessage(GET_LEVEL, fileHandler.defaultJSONCallback, null, id);
		}
		
		static public function loadLevelInfoFromID(id:String, callback:Function):void
		{
			//look up name in metadata list
			if(levelInfoVector)
			{
				PipeJamGame.levelInfo = findLevelObject(id);
				PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
				
			}
			else
			{
				GameFileHandler.m_name = id;
				GameFileHandler.m_loadCallback = callback;
				//set a timer, and try again
				var timer:Timer = new Timer(250, 1);
				timer.addEventListener(TimerEvent.TIMER, getLevelCallback);
				timer.start();
			}
		}
		
		public static function getLevelCallback(e:TimerEvent = null):void
		{
			GameFileHandler.loadLevelInfoFromID(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
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
				timer.addEventListener(TimerEvent.TIMER, getLevelFromNameCallback);
				timer.start();
			}
		}

				
		public static function getLevelFromNameCallback(e:TimerEvent = null):void
		{
			GameFileHandler.loadLevelInfoFromName(GameFileHandler.m_name, GameFileHandler.m_loadCallback);
		}
		
		
		static public function getFileByID(id:String, callback:Function):void
		{
			var fileURL:String = getFileURL + "&data_id=\"" + id + "\"";
			
			loadFile(callback, USE_DATABASE, fileURL);
		}
		
		static public function getHighScoresForLevel(callback:Function, levelID:String):void
		{
			
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_HIGH_SCORES_FOR_LEVEL, fileHandler.defaultJSONCallback, null, levelID);

		}
		
		
		static public function retrieveLevelMetadata():void
		{
			GameFileHandler.getLevelMetadata(null);
		}
		
		static public function findLevelObject(id:String):Object
		{
			for each(var level:Object in levelInfoVector)
			{
				if(level.levelID == id)
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
		
		static public var levelPlayedDict:Dictionary;
		static public function getRandomLevelObject():Object
		{
			var currentIndex:int;
			var i:int = 0;
			if(levelInfoVector != null && levelInfoVector.length >0 && PlayerValidation.playerActivity != null)
			{
				var levelPlayedArray:Array = PlayerValidation.playerActivity['completed_boards'];
				if(levelPlayedArray == null)
					levelPlayedArray = new Array;
				if(!levelPlayedDict)
				{
					levelPlayedDict = new Dictionary;
					for(i = 0; i<levelPlayedArray.length; i++)
					{
						levelPlayedDict[levelPlayedArray[i]] = 1;
					}
				}
				
				var topRange:int;
				var bottomRange:int;
				if(levelPlayedArray.length >= range2PlayerActivityMarker)
				{
					bottomRange = level2TopRangeLevelIndex + 1;
					topRange = levelInfoVector.length - 1;
					PlayerValidation.currentActivityLevel = 3;
				}
				else if (levelPlayedArray.length >= range1PlayerActivityMarker)
				{
					bottomRange = level1TopRangeLevelIndex + 1;
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
				var found:Boolean = false;
				var levelInfo:Object;
				for(i = 0; i < 20; i++)
				{
					currentIndex = XMath.randomInt(bottomRange, topRange);
					levelInfo = levelInfoVector[currentIndex];
					if(levelPlayedDict[levelInfo.levelID] != 1)
					{
						found = true;
						break;
					}
				}
				
				//if we didn't find an unplayed one, expand the range downward, and try again
				if(found == false)
				{
					for(i = 0; i < 20; i++)
					{
						currentIndex = XMath.randomInt(0, topRange);
						levelInfo = levelInfoVector[currentIndex];
						if(levelPlayedDict[levelInfo.levelID] != 1)
						{
							found = true;
							break;
						}
					}
				}
				
				//didn't find unplayed one in our ranges, so just grab one
				if(found == false)
				{
					currentIndex = XMath.randomInt(0, levelInfoVector.length-1);
					levelInfo = levelInfoVector[currentIndex];
				}
				
				//mark this one played, too
				levelPlayedDict[levelInfo.levelID] = 1;
				return levelInfoVector[currentIndex];
			}
			else if(PipeJam3.RELEASE_BUILD == false)
			{
				//this is for local debugguing, non-release build
				currentIndex = XMath.randomInt(0, levelInfoVector.length-1);
				return levelInfoVector[currentIndex];
			}
			else
				return null;
		}
		
		//connect to the db and get a list of all levels
		static public function getLevelMetadata(callback:Function):void
		{
			levelInfoVector = null;
			var fileHandler:GameFileHandler = new GameFileHandler(callback);
			fileHandler.sendMessage(GET_ALL_LEVEL_METADATA, fileHandler.setLevelMetadataFromCurrent);
		}
		
		static public function submitLevel(_levelFilesString:String, saveType:String, fileType:int = 1):void
		{
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
			
			Scene.m_gameSystem.dispatchEvent(new starling.events.Event(Constants.START_BUSY_ANIMATION,true));
			
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
						loadFile(worldFileLoadedCallback, loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.assignmentsID+"\"");
					}
					else
					{
						var levelInfo:Object = PipeJamGame.levelInfo;
						// TODO: probably rename from /xml and /constraints to /level and /assignments
						trace(getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.levelID+"\"");
						loadFile(worldFileLoadedCallback, loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.levelID+"\"");
						loadFile(layoutFileLoadedCallback, loadType, getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.layoutID+"\"");
						loadFile(assignmentsFileLoadedCallback, loadType,  getFileURL +"&data_id=\"" +PipeJamGame.levelInfo.assignmentsID+"\"");	
					}
				}
				else if(fileName && fileName.length > 0)
				{
					if(fileName.indexOf("cnf") == -1)
					{
						//check for which form we are loading, try loading one, and if it works, continue...
						loadFile(worldFileLoadedCallback, loadType, fileName+".zip");
						loadFile(layoutFileLoadedCallback, loadType, fileName+"Layout.zip");
						loadFile(assignmentsFileLoadedCallback, loadType, fileName+"Assignments.zip");
					}
					else
					{
						loadFile(worldFileLoadedCallback, loadType, fileName+".zip");
						var index:int = fileName.lastIndexOf('.');
						var fileNameRoot:String = fileName.substring(0, index);
						loadFile(layoutFileLoadedCallback, loadType, fileNameRoot+".plain.zip");
					}
				}
			}
		}
		
		static public function loadFile(callback:Function, loadType:int, url:String):void
		{
			var fileLoader:GameFileHandler = new GameFileHandler(callback);
			fileLoader.loadFile(loadType, url);
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
			//fzip.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
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
				if(zipFile.filename.indexOf("cnf") == -1 && zipFile.filename.indexOf("plain") == -1)
				{
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
				else
				{
					trace("loaded individual file: " + zipFile.filename);
					zipFile = fzip.getFileAt(0);
					m_callback(zipFile);
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
			if(message.length > 0)
			{
				var obj:Object = JSON.parse(message);
				for each(var entry:Object in obj)
					vec.push(entry);
			}

			if(m_callback != null)
				m_callback(result, vec);
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
					var lastUnderscore:int = (entry.name as String).lastIndexOf('_');
					var firstUnderscore:int = (entry.name as String).indexOf('_');
					if(lastUnderscore != -1 && firstUnderscore != lastUnderscore)
					{
						var countString:String = (entry.name as String).substring(firstUnderscore+1, lastUnderscore);
						var constraintCount:int = parseInt(countString);
						if(constraintCount > 0)
							entry['constraintCount'] = constraintCount;
						else
							entry['constraintCount'] = 0;
					}
					
					vector.push(entry);
				}
			}
			vector.sort(sortOnConstraints);
			levelInfoVector = vector;
			
			//now that they are sorted, figure out the ranges
			for(var index:int = 0; index<levelInfoVector.length;index++)
			{
				var levelInfo:Object = levelInfoVector[index];
				if(levelInfo.constraintCount < level1TopRangeNumConstraint)
				{
					level1TopRangeLevelIndex++;
					level2TopRangeLevelIndex++;
				}
				else if(levelInfo.constraintCount < level2TopRangeNumConstraint)
				{
					level2TopRangeLevelIndex++;
				}
				else
					break;
			}
			
			if(m_callback != null)
				m_callback(result);
		}
		
		protected function sortOnConstraints(itemA:Object, itemB:Object):Number
		{
			if (itemA['constraintCount'] < itemB['constraintCount']) 
				return -1; 
			else if (itemA['constraintCount'] > itemB['constraintCount'])
				return 1; 
			else return 0; 
		}
		
		//called when level metadata is loaded 
		public function setCompletedLevels(result:int, levelObjects:Vector.<Object>):void
		{
			completedLevelVector = levelObjects;
			m_callback(result);
		}
		
		public function saveLevel(saveType:String):void
		{
			if(PipeJam3.RELEASE_BUILD)
				sendMessage(SAVE_LEVEL, onLevelSaved, saveType, m_levelFilesString);
		}
		
		public function onLevelSaved(result:int, e:flash.events.Event):void
		{
			World.m_world.dispatchEvent(new NavigationEvent(NavigationEvent.UPDATE_HIGH_SCORES,null));
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
			var url:String = null;
			var messages:Array = new Array (); 
			var data_id:String;
			
			
			switch(type)
			{
				case GET_HIGH_SCORES_FOR_LEVEL:
					url = NetworkConnection.productionInterop  + "?function=getHighScoresForLevel2&data_id=" + data;
					break;
				case GET_ALL_LEVEL_METADATA:
					url = NetworkConnection.productionInterop + "?function=getActiveLevels2&data_id=foo";
					break;
				case SAVE_LEVEL:
					var solutionInfo:Object = PipeJamGame.levelInfo;
					solutionInfo.current_score =  String(World.m_world.active_level.currentScore);
					solutionInfo.target_score =  String(World.m_world.active_level.currentScore);
					solutionInfo.max_score =  String(World.m_world.active_level.maxScore);
					solutionInfo.prev_score =  String(World.m_world.active_level.oldScore);
					solutionInfo.max_score =  String(World.m_world.active_level.maxScore);
					solutionInfo.revision =  String(int(PipeJamGame.levelInfo.revision) + 1);
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
					if(data.length > 75000) //just a guess as to what doesn't pass well between php and python on the server. 130K doesn't work
						url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&file="+String(Math.round(Math.random()*10000))+"&data_id='"+data_id+"'";
					else
						url = NetworkConnection.productionInterop + "?function=submitLevelPOST2&data_id='"+data_id+"'";
					break;
				case REPORT_LEADERBOARD_SCORE:
					if(PlayerValidation.playerID == "")
						return;
					var scoreDifference:Number = World.m_world.active_level.currentScore - World.m_world.active_level.oldScore;
					var levelID:String;
					var percent:Number = World.m_world.currentPercent;
					if(World.m_world.currentPercent >=100)
						levelID = PipeJamGame.levelInfo.levelID;
						
					PlayerValidation.validationObject.setPlayerActivityInfo(scoreDifference, levelID);
					
					var playerID:String = PlayerValidation.playerID;
					//report to website scoreDifference + starting count
					var total:int = scoreDifference;
					for each(var person:Object in PipeJamGame.levelInfo.highScores)
					{
						if(person[1] == PlayerValidation.playerID)
						{
							total = total + person[3];
							break;
						}
					}
					var leaderboardScore:int = 1;
					var levelScore:int = World.m_world.active_level.currentScore;
					var targetScore:int = PipeJamGame.levelInfo.targetScore;
					if(levelScore > targetScore)
						leaderboardScore = 2;
					url = NetworkConnection.productionInterop + "?function=jsonPOST&data_id='/api/score'&data2='"+ PlayerValidation.accessToken + "'";
					var dataObj:Object = new Object;
					dataObj.playerId = PlayerValidation.playerID;
					dataObj.gameId = PipeJam3.GAME_ID;
					dataObj.levelId = PipeJamGame.levelInfo.levelID;
					var parameters:Array = new Array;
					var paramScoreObj:Object = new Object;
					paramScoreObj.name = "points";
					paramScoreObj.value = total;
					parameters.push(paramScoreObj);
					dataObj.parameter = parameters;
					data = JSON.stringify(dataObj);
					break;
			}
			
			NetworkConnection.sendMessage(callback, data, url, URLRequestMethod.POST, "");
		}
	}
}