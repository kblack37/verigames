package scenes.game.display
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import hints.HintController;
	import server.MTurkAPI;
	
	import assets.AssetInterface;
	import assets.AssetsAudio;
	import assets.AssetsFont;
	
	import audio.AudioManager;
	
	import constraints.ConstraintGraph;
	import constraints.events.ErrorEvent;
	
	import dialogs.SimpleAlertDialog;
	
	import display.SoundButton;
	import display.TextBubble;
	import display.ToolTipText;
	
	import events.MenuEvent;
	import events.MiniMapEvent;
	import events.MoveEvent;
	import events.NavigationEvent;
	import events.SelectionEvent;
	import events.ToolTipEvent;
	import events.UndoEvent;
	import events.WidgetChangeEvent;
	
	import networking.Achievements;
	import networking.GameFileHandler;
	import networking.PlayerValidation;
	import networking.TutorialController;
	
	import scenes.BaseComponent;
	import scenes.game.PipeJamGameScene;
	import scenes.game.components.GridViewPanel;
	import scenes.game.components.MiniMap;
	import scenes.game.components.SideControlPanel;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	import system.VerigameServerConstants;
	
	/**
	 * World that contains levels that each contain boards that each contain pipes
	 */
	public class World extends BaseComponent
	{
		public var edgeSetGraphViewPanel:GridViewPanel;
		public var sideControlPanel:SideControlPanel;
		protected var miniMap:MiniMap;
		protected var m_backgroundLayer:Sprite;
		protected var m_foregroundLayer:Sprite;
		protected var m_splashLayer:Sprite;
		
		/** All the levels in this world */
		public var levels:Vector.<Level> = new Vector.<Level>();
		
		/** Current level being played by the user */
		public var active_level:Level = null;
		
		//shim to make it start with a level until we get servers up
		protected var firstLevel:Level = null;
		
		protected var m_currentLevelNumber:int;
		public var currentPercent:Number;
		public var targetPercent:Number;
		
		protected var undoStack:Vector.<UndoEvent>;
		protected var redoStack:Vector.<UndoEvent>;
		
		private var m_worldGraphDict:Dictionary;
		/** Original JSON used for this world */
		private var m_worldObj:Object;
		private var m_layoutObj:Object;
		private var m_assignmentsObj:Object;
		
		protected var solvingImage:Image;
		
		static public var changingFullScreenState:Boolean = false;
		
		// TODO: Circular dependency - remove this reference, children should send events to parents not depend on World
		static public var m_world:World;
		private var m_activeToolTip:TextBubble;
		private var m_confirmationCodeGiven:String = "";
		
		protected var m_backgroundImage:Image;
		protected var m_backgroundImageSolving:Image;
		
		static protected var m_numWidgetsClicked:int = 0;
		
		static public var altKeyDown:Boolean;
		
		public var updateTimer1:Timer;
		public var updateTimer2:Timer;
		
		public function World(_worldGraphDict:Dictionary, _worldObj:Object, _layout:Object, _assignments:Object)
		{
			m_worldGraphDict = _worldGraphDict;
			m_worldObj = _worldObj;
			m_layoutObj = _layout;
			m_assignmentsObj = _assignments;
			
			m_world = this;
			undoStack = new Vector.<UndoEvent>();
			redoStack = new Vector.<UndoEvent>();
			
			var allLevels:Array = m_worldObj["levels"];
			if (!allLevels) allLevels = [m_worldObj];
			// create World
			for (var level_index:int = 0; level_index < allLevels.length; level_index++) {
				var levelObj:Object = allLevels[level_index];
				var levelId:String = levelObj["id"];
				var levelDisplayName:String = levelId;
				if (levelObj.hasOwnProperty("display_name") && !(PipeJam3.ASSET_SUFFIX == "Turk")) levelDisplayName = levelObj["display_name"];
				var levelLayoutObj:Object = findLevelFile(levelId, m_layoutObj);
				var levelAssignmentsObj:Object = findLevelFile(levelId, m_assignmentsObj);
				// if we didn't find the level, assume this is a global constraints file
				if(levelAssignmentsObj == null) levelAssignmentsObj = m_assignmentsObj;
				
				var levelNameFound:String = levelId;
				if (!PipeJamGameScene.inTutorial && PipeJamGame.levelInfo && PipeJamGame.levelInfo.name) {
					levelNameFound = PipeJamGame.levelInfo.name;
				}
				if (!m_worldGraphDict.hasOwnProperty(levelObj["id"])) {
					throw new Error("World level found without constraint graph:" + levelObj["id"]);
				}
				var levelGraph:ConstraintGraph = m_worldGraphDict[levelObj["id"]] as ConstraintGraph;
				var my_level:Level = new Level(levelDisplayName, levelGraph, levelObj, levelLayoutObj, levelAssignmentsObj, levelNameFound);
				levels.push(my_level);
				
				if (!firstLevel) {
					firstLevel = my_level; //grab first one..
				}
			}
			//trace("Done creating World...");
			addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(flash.events.Event.REMOVED_FROM_STAGE, onRemovedFromStage);	
		}
		
		
		
		private var m_initQueue:Vector.<Function> = new Vector.<Function>();
		protected function onAddedToStage(event:starling.events.Event):void
		{
			//trace("Start Init Time", new Date().getTime() - PipeJamGameScene.startLoadTime);
			m_initQueue = new Vector.<Function>();
			m_initQueue.push(initBackground);
			m_initQueue.push(initGridViewPanel);
			m_initQueue.push(initForeground);
			//m_initQueue.push(initGameControlPanel);
			m_initQueue.push(initSideControlPanel);
			m_initQueue.push(initMiniMap);
			m_initQueue.push(initTutorial);
			m_initQueue.push(initHintController);
			m_initQueue.push(initLevel);
			m_initQueue.push(initScoring);
			m_initQueue.push(initEventListeners);
			m_initQueue.push(initMusic);
			initUpdateTimers();
			addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
		}
		
		//used by stats, so leave public
		public static var loadTime:Number;
		protected function onEnterFrame(evt:EnterFrameEvent):void
		{
			if(m_initQueue.length == 0)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
				loadTime = new Date().getTime() - PipeJamGameScene.startLoadTime;
				//trace("Complete Time", loadTime);
				if(miniMap && !active_level.tutorialManager)
				{
					miniMap.centerMap();
				}
			}
			else if (m_initQueue.length > 0) {
				var time1:Number = new Date().getTime();
				var func:Function = m_initQueue.shift();
				
				func.call();
				//trace("init", new Date().getTime() - time1);
			}
		}
		
		private function initGridViewPanel():void {
			//trace("Initializing GridViewPanel...");
			edgeSetGraphViewPanel = new GridViewPanel(this);
			addChild(edgeSetGraphViewPanel);
			//trace("Done initializing GridViewPanel.");
		}
		
		public function showSolverState(running:Boolean):void
		{
			if(running)
			{
	//			edgeSetGraphViewPanel.filter = new ColorMatrixFilter;
	//			(edgeSetGraphViewPanel.filter as ColorMatrixFilter).adjustHue(.22);
	//			gameControlPanel.startSolveAnimation();
			}
			else
			{
	//			edgeSetGraphViewPanel.filter = null;
	//			gameControlPanel.stopSolveAnimation();
			}
		}
		
		private function initSideControlPanel():void {
			//trace("Initializing SideControlPanel...");
			
			sideControlPanel = new SideControlPanel(Constants.RightPanelWidth, Starling.current.nativeStage.stageHeight);
			sideControlPanel.x = 480 - Constants.RightPanelWidth;
			addChild(sideControlPanel);
			dispatchEvent(new starling.events.Event(PipeJamGame.SET_SOUNDBUTTON_PARENT, true, sideControlPanel));
			
			addEventListener(SelectionEvent.BRUSH_CHANGED, changeBrush);
			
			//trace("Done initializing SideControlPanel.");
		}
		
		private function changeBrush(event:SelectionEvent):void
		{
			edgeSetGraphViewPanel.changeBrush(event.component.name);
		}
		
		private function initMiniMap():void {
			//trace("Initializing Minimap....");
			miniMap = new MiniMap();
			miniMap.x = Constants.GameWidth - MiniMap.WIDTH - 3;
			miniMap.y = MiniMap.TOP_Y;
			edgeSetGraphViewPanel.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, miniMap.onViewspaceChanged);
		//	miniMap.visible = false;
			addChild(miniMap);
			//trace("Done initializing Minimap.");
		}
		
		private function initScoring():void {
			//trace("Initializing score...");
			var time1:Number = new Date().getTime();
			onWidgetChange(); //update score
			//trace("Done initializing score.", new Date().getTime()-time1);
		}
		
		private function initTutorial():void {
			//trace("Initializing TutorialController...");
			var time1:Number = new Date().getTime();
			if(PipeJamGameScene.inTutorial && levels && levels.length > 0)
			{
				var obj:Object;
				if(PipeJam3.TUTORIAL_DEMO)
					obj = PipeJamGame.levelInfo;
				var tutorialController:TutorialController = TutorialController.getTutorialController();
				var nextLevelQID:int;
				if(!obj)
				{
					obj = new Object();
					PipeJamGame.levelInfo = obj;
					obj.tutorialLevelID = String(tutorialController.getFirstTutorialLevel());
					if(!tutorialController.isTutorialLevelCompleted(obj.tutorialLevelID))
						nextLevelQID = parseInt(obj.tutorialLevelID);
					else
						nextLevelQID = tutorialController.getNextUnplayedTutorial();
				}
				else
					nextLevelQID = parseInt(obj.tutorialLevelID);
				
				for each(var level:Level in levels)
				{
					if(level.m_levelQID == String(nextLevelQID))
					{
						firstLevel = level;
						obj.tutorialLevelID = String(nextLevelQID);
						break;
					}
				}
			}
			//trace("Done initializing TutorialController.", new Date().getTime()-time1);
		}
		
		private function initHintController():void
		{
			if (edgeSetGraphViewPanel == null) throw new Error("GridViewPanel hint layer has not been initialized! Make sure that initGridViewPanel is called before initHintController.");
			HintController.getInstance().hintLayer = edgeSetGraphViewPanel.hintLayer;
		}
		
		private function initLevel():void {
			//trace("Initializing Level...");
			var time1:Number = new Date().getTime();
			selectLevel(firstLevel);
			//trace("Done initializing Level.", new Date().getTime()-time1);
		}
		
		public function initBackground(isWide:Boolean = false, newWidth:Number = 0, newHeight:Number = 0):void
		{
			if(m_backgroundLayer == null)
			{
				m_backgroundLayer = new starling.display.Sprite;
				addChildAt(m_backgroundLayer, 0);
			}
			
			m_backgroundLayer.removeChildren();
			var seed:int = 0;
			if(active_level)
			{
				seed = active_level.levelGraph.qid;
				if (seed < 0) {
					seed = 0;
					for (var c:int = 0; c < active_level.level_name.length; c++) {
						var code:Number = active_level.level_name.charCodeAt(c);
						if (isNaN(code)) {
							seed += c;
						} else {
							seed += Math.max(Math.round(code), 1);
						}
					}
				}
			}
			var backMod:int = seed % Constants.NUM_BACKGROUNDS;
			var background:Texture = AssetInterface.getTexture("Game", "ParadoxBackgroundClass");
			m_backgroundImage = new Image(background);
			var backgroundDark:Texture = AssetInterface.getTexture("Game", "ParadoxBackgroundDarkClass");
			m_backgroundImageSolving = new Image(backgroundDark);
			
			if(Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
			{
				m_backgroundImage.width = m_backgroundImageSolving.width = 480;
				m_backgroundImage.height = m_backgroundImageSolving.height = 320;

			}
			else
			{
				if(newWidth != 0)
					m_backgroundImage.width = m_backgroundImageSolving.width = newWidth;
				if(newHeight != 0)
					m_backgroundImage.height = m_backgroundImageSolving.height = newHeight;
			}
			
			m_backgroundImage.blendMode = m_backgroundImageSolving.blendMode = BlendMode.NONE;
			if (m_backgroundLayer) m_backgroundLayer.addChild(m_backgroundImage);
		}
		
		public function initForeground(seed:int = 0, isWide:Boolean = false):void
		{
			//add border
			
		}
		
		private function initEventListeners():void
		{
			//trace("Initializing event listeners...");
			addEventListener(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, onWidgetChange);
			addEventListener(MoveEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
			addEventListener(NavigationEvent.SHOW_GAME_MENU, onShowGameMenuEvent);
			addEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);
			
			addEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);
			
			addEventListener(MenuEvent.POST_DIALOG, postDialog);
			addEventListener(MenuEvent.ACHIEVEMENT_ADDED, achievementAdded);
			addEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
			addEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
			
			addEventListener(MenuEvent.ZOOM_IN, onZoomIn);
			addEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
			
			addEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
			addEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
			addEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
			addEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
			addEventListener(MenuEvent.STOP_SOLVER, onStopSolving);
			
			addEventListener(MenuEvent.MOUSE_OVER_CONTROL_PANEL, overControlPanelHandler);
			
			addEventListener(MenuEvent.TURK_FINISH, onTurkFinishButtonPressed);
			
			addEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
			addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
			addEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			addEventListener(UndoEvent.UNDO_EVENT, saveEvent);
			
			addEventListener(MoveEvent.MOVE_TO_POINT, onMoveToPointEvent);
			
			addEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
			addEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
			
			addEventListener(SelectionEvent.NUM_SELECTED_NODES_CHANGED, onNumSelectedNodesChanged);
			
			//trace("Done initializing event listeners.");
		}
		
		private function onTurkFinishButtonPressed(event:starling.events.Event):void
		{
			if (!m_confirmationCodeGiven)
			{
				MTurkAPI.getInstance().onTaskComplete(displayConfirmationCodeScreen);
			}
			else
			{
				displayConfirmationCodeScreen(m_confirmationCodeGiven);
			}
		}
		
		private function overControlPanelHandler(event:starling.events.Event):void
		{
			edgeSetGraphViewPanel.mouseOverControlPanel();
		}
		
		public function loadAssignmentFile(assignmentID:String):void
		{
			GameFileHandler.loadFile(assignmentsFileLoadedCallback, GameFileHandler.USE_DATABASE,  GameFileHandler.getFileURL +"&data_id=\"" + assignmentID +"\"");
		}
		
		public function assignmentsFileLoadedCallback(obj:Object):void
		{
			this.active_level.loadAssignmentsConfiguration(obj);
			active_level.levelGraph.startingScore = active_level.currentScore;
		}
		
		private function onSolveSelection(event:MenuEvent):void
		{
			//do this first as they might be removed by solveSelection if nothing relevant selected

			if(active_level && active_level.selectedNodes)
			{
				if(event.data == GridViewPanel.SOLVER1_BRUSH || event.data == GridViewPanel.SOLVER2_BRUSH)
				{
					// Only allow autosolve if conflicts are selected, give user feedback if not
					var continueWithAutosolve:Boolean = HintController.getInstance().checkAutosolveSelection(active_level);
					if(Level.debugSolver)
						continueWithAutosolve = true;
					if (continueWithAutosolve)
					{
						if (m_backgroundLayer) m_backgroundLayer.addChild(m_backgroundImageSolving);
						if (m_backgroundImage) m_backgroundImage.removeFromParent();	
						
						waitIconDisplayed = false;
						
						if (PipeJam3.logging)
						{
							var details:Object = new Object();
							//details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = newLevel.original_level_name;
							if (PipeJamGame.levelInfo) {
								var jsonString:String = JSON.stringify(PipeJamGame.levelInfo);
								var newObject:Object =  JSON.parse(jsonString);
								details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] = newObject;
							}
							var qid:int = (active_level.levelGraph.qid == -1) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : active_level.levelGraph.qid;
							//PipeJam3.logging.logQuestAction(, details, active_level.getTimeMs());
						}
						
						active_level.solveSelection(solverUpdateCallback, solverDoneCallback, event.data as String);
					}
					else
						active_level.unselectAll();
				}
				else if(event.data == GridViewPanel.NARROW_BRUSH)
				{
					active_level.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_NARROW);
				}
				else if(event.data == GridViewPanel.WIDEN_BRUSH)
				{
					active_level.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_WIDE);
				}
			}

		}
		
		protected var waitIconDisplayed:Boolean;
		protected function solverUpdateCallback(vars:Array, unsat_weight:int):void
		{
			//start on first update to make sure we are actually solving
			if(active_level.m_inSolver)
			{
				if(waitIconDisplayed == false)
				{
					//busyAnimationMovieClip = new MovieClip(waitAnimationImages, 4);
					//addChild(busyAnimationMovieClip);
					//Starling.juggler.add(this.busyAnimationMovieClip);
					waitIconDisplayed = true;
//					var borderTexture:Texture = AssetInterface.getTexture("Game", "Wait1Class");
//					solvingImage = new Image(borderTexture);
//					solvingImage.alpha = .6;
					//busyAnimationMovieClip.scaleX = busyAnimationMovieClip.scaleY = 4;
					//busyAnimationMovieClip.x = 240 - busyAnimationMovieClip.width/2;
					//busyAnimationMovieClip.y = 110;
//					addChild(solvingImage);
				}
				if(active_level)
					active_level.solverUpdate(vars, unsat_weight);
			}
		}
		
		private function onStopSolving():void
		{
			solverDoneCallback("");
		}
		
		public function solverDoneCallback(errMsg:String):void
		{
			if(active_level)
				active_level.solverDone(errMsg);
			if(waitIconDisplayed)
				removeChild(solvingImage);
			if(busyAnimationMovieClip)
			{
				removeChild(busyAnimationMovieClip);
				Starling.juggler.remove(this.busyAnimationMovieClip);
				
				busyAnimationMovieClip.dispose();
				busyAnimationMovieClip = null;
			}
			if (m_backgroundLayer) m_backgroundLayer.addChild(m_backgroundImage);
			if (m_backgroundImageSolving) m_backgroundImageSolving.removeFromParent();
			showSolverState(false);
		}
		
		private function initMusic():void {
			AudioManager.getInstance().reset();
			AudioManager.getInstance().playMusic(AssetsAudio.MUSIC_FIELD_SONG);
			//trace("Playing music...");
		}
		
		private function initUpdateTimers():void {
			//once every ten seconds, maybe?
			if(PipeJam3.RELEASE_BUILD) //don't annoy tim by having this update every 10 seconds
			{
				//start at 1 second to get quick initial info update into panel, then switch to 10 seconds afterwards
				updateTimer1 = new Timer(1000, 9);
				updateTimer1.addEventListener(TimerEvent.TIMER, updateHighScores);
				updateTimer1.start();
				
				updateTimer2 = new Timer(10000, 0);
				updateTimer2.addEventListener(TimerEvent.TIMER, updateHighScores);
				updateTimer2.start();
			}
		}
		
		private function updateHighScores(event:TimerEvent):void
		{
			dispatchEvent(new NavigationEvent(NavigationEvent.UPDATE_HIGH_SCORES, null));
		}
		
		private function removeUpdateTimers():void
		{
			if(PipeJam3.RELEASE_BUILD) 
			{
				if(updateTimer1)
					updateTimer1.stop();
				if(updateTimer2)
					updateTimer2.stop();
			}
			
		}
		
		public function changeFullScreen(newWidth:Number, newHeight:Number):void
		{
			//backgrounds get scaled by the AssetInterface content scale factor, so change scale before setting a new background
			if(Starling.current.nativeStage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
			{
				initBackground(true, newWidth, newHeight);
				m_backgroundLayer.scaleX /= newWidth/480;
				m_backgroundLayer.scaleY /= newHeight/320;
			}
			else
			{
				initBackground(false, newWidth, newHeight);
				m_backgroundLayer.scaleX = 1;
				m_backgroundLayer.scaleY = 1;
			}	
			edgeSetGraphViewPanel.adjustSize(newWidth, newHeight);
		//	gameControlPanel.adjustSize(newWidth, newHeight);
		}
		
		public function onPutLevelInDatabase(event:MenuEvent):void
		{
			//type:String, currentScore:int = event.type, currentScore
			if(active_level != null)
			{
				//update and collect all xml, and then bundle, zip, and upload
				var outputObj:Object = updateAssignments();
				active_level.updateLevelObj();
				
				var newAssignments:Object = active_level.m_levelAssignmentsObj;
				
				var zip:ByteArray = active_level.zipJsonFile(newAssignments, "assignments");
				var zipEncodedString:String = active_level.encodeBytes(zip);
				
				GameFileHandler.submitLevel(zipEncodedString, event.type, PipeJamGame.SEPARATE_FILES);	
				
				if (PipeJam3.logging) {
					var details:Object = new Object();
					details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = active_level.original_level_name; // yes, we can get this from the quest data but include it here for convenience
					details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = active_level.currentScore;
					details[VerigameServerConstants.ACTION_PARAMETER_START_SCORE] = active_level.startingScore;
					details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = active_level.m_targetScore;
					PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_SUBMIT_SCORE, details, active_level.getTimeMs());
				}
			}
		}
		
		public function postDialog(event:MenuEvent):void
		{
			var dialogText:String = event.data as String;
			var dialogWidth:Number = 160;
			var dialogHeight:Number = 60;
			
			var dialog:SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, null, null);
			addChild(dialog);
		}
		
		public function achievementAdded(event:MenuEvent):void
		{
			var achievement:Achievements = event.data as Achievements;
			var dialogText:String = achievement.m_message;
			var achievementID:String = achievement.m_id;
			var dialogWidth:Number = 160;
			var dialogHeight:Number = 60;
			var socialText:String = "";
			
			var alert:SimpleAlertDialog;
			if(achievementID == Achievements.TUTORIAL_FINISHED_ID)
				alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, onShowGameMenuEvent);
			else
				alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
			addChild(alert);
		}
		
		private function loadBestScore(event:MenuEvent):void
		{
			if (active_level) active_level.loadBestScoringConfiguration();
		}
		
		private function loadHighScore(event:MenuEvent):void
		{
			var highScoreAssignmentsID:String = PipeJamGame.levelInfo.highScores[0].assignmentsID;
			GameFileHandler.getFileByID(highScoreAssignmentsID, loadAssignmentsFile);
		}
		
		protected function loadAssignmentsFile(assignmentsObject:Object):void
		{
			if(active_level)
				active_level.loadAssignmentsConfiguration(assignmentsObject);
		}
		
		protected function switchToLevelSelect():void
		{
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
		}
		
		protected function onShowGameMenuEvent(evt:NavigationEvent = null):void
		{
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
		}
		
		public function updateAssignments(currentLevelOnly:Boolean = false):Object
		{
			// TODO: think about this more, when do we update WORLD assignments? Real-time or in this method?
			if (currentLevelOnly) {
				if (active_level) return m_worldObj["levels"][active_level.name]["assignments"];
				return { };
			}
			return m_assignmentsObj;
		}
		
		public function onZoomIn(event:MenuEvent):void
		{
			edgeSetGraphViewPanel.zoomInDiscrete();
		}
		
		public function onZoomOut(event:MenuEvent):void
		{
			edgeSetGraphViewPanel.zoomOutDiscrete();
		}
		
		public function onMaxZoomReached(event:events.MenuEvent):void
		{
			if (sideControlPanel) sideControlPanel.onMaxZoomReached();
		}
		
		public function onMinZoomReached(event:events.MenuEvent):void
		{
			if (sideControlPanel) sideControlPanel.onMinZoomReached();
		}
		
		public function onZoomReset(event:events.MenuEvent):void
		{
			if (sideControlPanel) sideControlPanel.onZoomReset();
		}
		
		public function onErrorsMoved(event:MiniMapEvent):void
		{
			if (miniMap) miniMap.isDirty = true;
		}
		
		public function onLevelResized(event:MiniMapEvent):void
		{
			if (miniMap) miniMap.isDirty = true;
		}
		
		public function onViewspaceChanged(event:MiniMapEvent):void
		{
			miniMap.onViewspaceChanged(event);
		}
		
		private function displayConfirmationCodeScreen(confCode:String):void {
			var nativeText:TextField = new TextField();
			nativeText.backgroundColor = 0xFFFFFF;
			nativeText.background = true;
			nativeText.selectable = true;
			nativeText.width = Constants.GameWidth;
			nativeText.height = Constants.GameHeight;
			if (confCode == "0") {
				active_level.targetScoreReached = false;
				nativeText.text = "This task was expected to take at least 2 minutes.\n\nThis page will update automatically in 30 seconds to retry the confirmation code."
				Starling.juggler.delayCall(onWidgetChange, 30, new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, active_level, null)); // if time isn't up, wait a bit
			} else {
				m_confirmationCodeGiven = confCode;
				nativeText.text = "Thanks for playing!\n\nTask complete.\nYour confirmation code is:\n\n" + confCode;
			}
			nativeText.wordWrap = true;
			nativeText.setTextFormat(new TextFormat(null, 32, 0x0, null, null, null, null, null, TextFormatAlign.CENTER));
			Starling.current.nativeOverlay.addChild(nativeText);
		}
		
		public function onWidgetChange(evt:WidgetChangeEvent = null):void
		{
			var level_changed:Level = evt ? (evt.level ? evt.level : active_level) : active_level;
			if (level_changed != active_level) return;
			
			if (miniMap)
			{
				miniMap.isDirty = true;
				miniMap.imageIsDirty = true;
			}
			
			var oldScore:int = active_level.prevScore;
			var newScore:int = active_level.currentScore;
			if (evt) {
				// TODO: Fanfare for non-tutorial levels? We may want to encourage the players to keep optimizing
				if (newScore >= active_level.getTargetScore()) {
					if (!active_level.targetScoreReached) {
						active_level.targetScoreReached = true;
						//if(active_level.m_inSolver)
						//	solverDoneCallback("");
						if (PipeJam3.ASSET_SUFFIX == "Turk" && active_level && (!PipeJamGameScene.inTutorial || (active_level.m_levelQID == "2006")))
						{
							if (!m_confirmationCodeGiven)
							{
								MTurkAPI.getInstance().onTaskComplete(displayConfirmationCodeScreen);
							}
							else
							{
								displayConfirmationCodeScreen(m_confirmationCodeGiven);
							}
						}
						else
						{
							var continueDelay:Number = 0;
							var showFanfare:Boolean = true;
							if (active_level && active_level.tutorialManager) {
								continueDelay = active_level.tutorialManager.continueButtonDelay();
								showFanfare = active_level.tutorialManager.showFanfare();
							}
							Starling.juggler.delayCall(edgeSetGraphViewPanel.displayContinueButton, continueDelay, true, showFanfare);
						}
					}
				} else {
					edgeSetGraphViewPanel.hideContinueButton();
				}
				if (oldScore != newScore && evt.pt != null) {
					var thisPt:Point = globalToLocal(evt.pt);
					TextPopup.popupText(evt.target as DisplayObjectContainer, thisPt, (newScore > oldScore ? "+" : "") + (newScore - oldScore).toString(), newScore > oldScore ? 0x008000 : 0x800000);
				}
				if (PipeJam3.logging) {
					var details:Object = new Object();
					details[VerigameServerConstants.ACTION_PARAMETER_SCORE_CHANGE] = newScore - oldScore;
					details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = active_level.currentScore;
					details[VerigameServerConstants.ACTION_PARAMETER_START_SCORE] = active_level.startingScore;
					details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = active_level.m_targetScore;
					// TODO logging: PipeJam3.logging.logQuestAction(VerigameServerConstants.verigame_ac, details, active_level.getTimeMs());
				}
			}
			currentPercent = sideControlPanel.updateScore(active_level, false);
			targetPercent = sideControlPanel.targetPercent(active_level);
						
			if(currentPercent >= 100)
			{
				if(!PipeJamGameScene.inTutorial && PlayerValidation.playerActivity != null)
				{
					if(PipeJam3.RELEASE_BUILD)
					{
						GameFileHandler.reportScore();
						var levelPlayedArray:Array = PlayerValidation.playerActivity['completed_boards'];
						edgeSetGraphViewPanel.showProgressDialog(levelPlayedArray.length);
					}
				}
			}
			if(!PipeJamGameScene.inTutorial && evt)
			{
				//beat the target score?
				if(newScore  > active_level.getTargetScore())
				{
					Achievements.checkAchievements(Achievements.BEAT_THE_TARGET_ID, 0);
				}
				
				Achievements.checkAchievements(Achievements.CHECK_SCORE, newScore - active_level.startingScore);

			}
		}
		
		private function onCenterOnComponentEvent(evt:MoveEvent):void
		{
			var component:Object = evt.component;
			if(component)
			{
				edgeSetGraphViewPanel.centerOnComponent(component);
			}
		}
		
		private function onNextLevel(evt:NavigationEvent):void
		{
			var prevLevelNumber:Number = parseInt(PipeJamGame.levelInfo.RaLevelID);
			if(PipeJamGameScene.inTutorial)
			{
				var tutorialController:TutorialController = TutorialController.getTutorialController();
				if (active_level) {
					// If using in-menu "Next Level" debug button, mark the current level as complete in order to move on. Don't mark as completed
					tutorialController.addCompletedTutorial(active_level.m_tutorialTag, false);
				}
				
				//should check if we are from the level select screen...
				var tutorialsDone:Boolean = tutorialController.isTutorialDone();
				//if there are no more unplayed levels, check next if we are in levelselect screen choice
				if(tutorialsDone == true && tutorialController.fromLevelSelectList)
				{
					//and if so, set to false, unless at the end of the tutorials
					var currentLevelId:int = tutorialController.getNextUnplayedTutorial();
					if(currentLevelId != 0)
						tutorialsDone = false;
					
				}
				
				//if this is the first time we've completed these, post the achievement, else just move on
				if(tutorialsDone)
				{
					if(!Achievements.checkAchievements(Achievements.TUTORIAL_FINISHED_ID))
						if(PipeJam3.TUTORIAL_DEMO)
							switchToLevelSelect();
						else
							onShowGameMenuEvent();
					return;
				}
				else if (tutorialController.isLastTutorialLevel())
				{
					if(PipeJam3.TUTORIAL_DEMO)
						switchToLevelSelect();
					else
						onShowGameMenuEvent();
					return;
				}
				else
				{
					//get the next level to show, set the levelID, and currentLevelNumber
					var obj:Object = PipeJamGame.levelInfo;
					obj.tutorialLevelID = String(tutorialController.getNextUnplayedTutorial());
					
					m_currentLevelNumber = 0;
					for each(var level:Level in levels)
					{
						if(level.m_levelQID == obj.tutorialLevelID)
							break;
						
						m_currentLevelNumber++;
					}
					m_currentLevelNumber = m_currentLevelNumber % levels.length;
				}
			}
			else {
				m_currentLevelNumber = (m_currentLevelNumber + 1) % levels.length;
				updateAssignments(); // save world progress
			}
			var callback:Function =
				function():void
				{
					selectLevel(levels[m_currentLevelNumber]);
				};
			dispatchEvent(new NavigationEvent(NavigationEvent.FADE_SCREEN, "", null, callback));
		}
		
		public function onErrorAdded(event:ErrorEvent):void
		{
			if (active_level) {
				//if (miniMap) miniMap.errorConstraintAdded(edgeLayout);
			}
		}
		
		public function onErrorRemoved(event:ErrorEvent):void
		{
			if (active_level) {
				//if (miniMap) miniMap.errorRemoved(edgeLayout);
			}
		}
		
		private function onMoveToPointEvent(evt:MoveEvent):void
		{
			edgeSetGraphViewPanel.moveToPoint(evt.startLoc);
		}
		
		private function saveEvent(evt:UndoEvent):void
		{
			if (evt.eventsToUndo.length == 0) {
				return;
			}
			//sometimes we need to remove the last event to add a complex event that includes that one
			//addToLastSimilar adds to the last event if they are of the same type (i.e. successive mouse wheel events should all undo at the same time)
			//addToLast adds to last event in any case (undo move node event also should put edges back where they were)
			var lastEvent:UndoEvent;
			if(evt.addToSimilar)
			{
				lastEvent = undoStack.pop();
				if(lastEvent && (lastEvent.eventsToUndo.length > 0))
				{
					if(lastEvent.eventsToUndo[0].type == evt.eventsToUndo[0].type)
					{
						// Add these to end of lastEvent's list of events to undo
						lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
					}
					else //no match, just push, adding back lastEvent also
					{
						undoStack.push(lastEvent);
						undoStack.push(evt);
					}
				}
				else
					undoStack.push(evt);
			}
			else if(evt.addToLast)
			{
				lastEvent = undoStack.pop();
				if(lastEvent)
				{
					// Add these to end of lastEvent's list of events to undo
					lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
				}
				else
					undoStack.push(evt);
			}
			else
				undoStack.push(evt);
			//when we build on the undoStack, clear out the redoStack
			redoStack = new Vector.<UndoEvent>();
		}
		public function handleKeyDown(event:starling.events.KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.S)
				altKeyDown = true;
		}
		
		public function handleKeyUp(event:starling.events.KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.S)
				altKeyDown = false;
			
			if(event.ctrlKey)
			{
				switch(event.keyCode)
				{
					case 90: //'z'
					{
						if ((undoStack.length > 0) && !PipeJam3.RELEASE_BUILD)//high risk item, don't allow undo/redo until well tested
						{
							var undoDataEvent:UndoEvent = undoStack.pop();
							handleUndoRedoEvent(undoDataEvent, true);
						}
						break;
					}
					case 82: //'r'
					case 89: //'y'
					{
						if ((redoStack.length > 0) && !PipeJam3.RELEASE_BUILD)//high risk item, don't allow undo/redo until well tested
						{
							var redoDataEvent:UndoEvent = redoStack.pop();
							handleUndoRedoEvent(redoDataEvent, false);
						}
						break;
					}
					case 76: //'l' for copy layout
						if(this.active_level != null)// && !PipeJam3.RELEASE_BUILD)
						{
							System.setClipboard(JSON.stringify(active_level.m_levelLayoutObjWrapper));
						}
						break;
					case 66: //'b' for load Best scoring config
						if(this.active_level != null)// && !PipeJam3.RELEASE_BUILD)
						{
							active_level.loadBestScoringConfiguration(); 
						}
						break;
					case 67: //'c' for copy constraints
						if(this.active_level != null && !PipeJam3.RELEASE_BUILD)
						{
							active_level.updateAssignmentsObj();
							System.setClipboard(JSON.stringify(active_level.m_levelAssignmentsObj));
						}
						break;
					case 65: //'a' for copy of ALL (world)
						if(this.active_level != null && !PipeJam3.RELEASE_BUILD)
						{
							var worldObj:Object = updateAssignments();
							System.setClipboard(JSON.stringify(worldObj));
						}
						break;
					case 88: //'x' for copy of level
						if(this.active_level != null && !PipeJam3.RELEASE_BUILD)
						{
							var levelObj:Object = updateAssignments(true);
							System.setClipboard(JSON.stringify(levelObj));
						}
						break;
				}
			}
		}
		
		 protected function handleUndoRedoEvent(event:UndoEvent, isUndo:Boolean):void
		{
			//added newest at the end, so start at the end
			for(var i:int = event.eventsToUndo.length-1; i>=0; i--)
			{
				var eventObj:starling.events.Event = event.eventsToUndo[i];
				handleUndoRedoEventObject(eventObj, isUndo, event.levelEvent, event.component);
			}
			if(isUndo)
				redoStack.push(event);
			else
				undoStack.push(event);
		}
		
		protected function handleUndoRedoEventObject(evt:starling.events.Event, isUndo:Boolean, levelEvent:Boolean, component:BaseComponent):void
		{
			if (active_level && levelEvent)
			{
				active_level.handleUndoEvent(evt, isUndo);
			}
			else if (component)
			{
				component.handleUndoEvent(evt, isUndo);
			}
		}
		
		protected function selectLevel(newLevel:Level):void
		{
			if (!newLevel) {
				return;
			}
			if (PipeJam3.logging) {
				var details:Object, qid:int;
				if (active_level) {
					details = new Object();
					details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = active_level.original_level_name;
					details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = active_level.currentScore;
					details[VerigameServerConstants.ACTION_PARAMETER_START_SCORE] = active_level.startingScore;
					details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = active_level.m_targetScore;
					qid = (active_level.levelGraph.qid == -1) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : active_level.levelGraph.qid;
					//if (PipeJamGame.levelInfo) {
					//	details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] = PipeJamGame.levelInfo.createLevelObject();
					//}
					PipeJam3.logging.logQuestEnd(qid, details);
					active_level.removeEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
				}
				details = new Object();
				details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = newLevel.original_level_name;
				details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = newLevel.currentScore;
				details[VerigameServerConstants.ACTION_PARAMETER_START_SCORE] = newLevel.startingScore;
				details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = newLevel.m_targetScore;
				if (PipeJamGame.levelInfo) {
					var jsonString:String = JSON.stringify(PipeJamGame.levelInfo);
					var newObject:Object =  JSON.parse(jsonString);
					details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] = newObject;
				}
				qid = (newLevel.levelGraph.qid == -1) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : newLevel.levelGraph.qid;
				PipeJam3.logging.logQuestStart(qid, details);
			}
			if (active_level) {
				active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
				active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
				active_level.dispose();
			}
			if (m_splashLayer) {
				m_splashLayer.removeChildren(0, -1, true);
				m_splashLayer.removeFromParent();
			}
			
			if (m_activeToolTip) {
				m_activeToolTip.removeFromParent(true);
				m_activeToolTip = null;
			}
			
			active_level = newLevel;
			
			if(miniMap)
			{
				miniMap.imageIsDirty = true;
			}
			
			if (active_level.tutorialManager) {
				miniMap.visible = active_level.tutorialManager.getMiniMapShown();
			} else {
				miniMap.visible = true;
			}
			if (miniMap) miniMap.setLevel(active_level);
					
			active_level.addEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
			active_level.initialize();
			showVisibleBrushes();
			showCurrentBrush();
			var brushesToEmphasize:int = active_level.emphasizeBrushes();
			sideControlPanel.emphasizeBrushes(brushesToEmphasize);
		}
		
		private function onLevelLoaded(evt:MenuEvent):void
		{
			active_level.removeEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
			//called later by initScoring
			//onWidgetChange();
			var levelSplash:Image;
			if (active_level.tutorialManager) levelSplash = active_level.tutorialManager.getSplashScreen();
			if (levelSplash) {
				if (!m_splashLayer) {
					m_splashLayer = new Sprite();
					m_splashLayer.addEventListener(TouchEvent.TOUCH, onTouchSplashScreen);
				} else {
					m_splashLayer.removeChildren(0, -1, true);
				}
				var backQ:Quad = new Quad(Constants.GameWidth, Constants.GameHeight, 0x0);
				backQ.alpha = 0.9;
				m_splashLayer.addChild(backQ);
				levelSplash.x = 0.5 * (Constants.GameWidth - levelSplash.width);
				levelSplash.y = 0.5 * (Constants.GameHeight - levelSplash.height);
				m_splashLayer.addChild(levelSplash);
				var splashText:TextFieldWrapper = TextFactory.getInstance().createDefaultTextField("Click anywhere to continue...", Constants.GameWidth, 12, 8, Constants.GOLD);
				splashText.y = Constants.GameHeight - 12;
				m_splashLayer.addChild(splashText);
				addChild(m_splashLayer);
			}
			
			//trace("edgeSetGraphViewPanel.loadLevel()");
			edgeSetGraphViewPanel.setupLevel(active_level);
			if (edgeSetGraphViewPanel.atMaxZoom()) {
				sideControlPanel.onMaxZoomReached();
			} else if (edgeSetGraphViewPanel.atMinZoom()) {
				sideControlPanel.onMinZoomReached();
			} else {
				sideControlPanel.onZoomReset();
			}

			//trace("onScoreChange()");
			active_level.onScoreChange();
			active_level.resetBestScore();
			setHighScores();
			
			//trace("sideControlPanel.newLevelSelected");
			sideControlPanel.newLevelSelected(active_level);
			miniMap.isDirty = true;

			//trace("World.onLevelLoaded complete");
		}
		
		private function onTouchSplashScreen(evt:TouchEvent):void
		{
			if (evt.getTouches(this, TouchPhase.BEGAN).length && m_splashLayer)
			{
				// Touch screen pressed, remove it
				m_splashLayer.removeChildren(0, -1, true);
				m_splashLayer.removeFromParent();
			}
		}
		
		private function onRemovedFromStage():void
		{
			AudioManager.getInstance().reset();
			
			if (m_activeToolTip) {
				m_activeToolTip.removeFromParent(true);
				m_activeToolTip = null;
			}
						
			removeEventListener(MoveEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
			removeEventListener(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, onWidgetChange);
			removeEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);

			removeEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);

			removeEventListener(MenuEvent.POST_DIALOG, postDialog);
			removeEventListener(MenuEvent.ACHIEVEMENT_ADDED, achievementAdded);
			removeEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
			removeEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
			removeEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
			removeEventListener(MenuEvent.TURK_FINISH, onTurkFinishButtonPressed);
			
			removeEventListener(UndoEvent.UNDO_EVENT, saveEvent);
			removeEventListener(MenuEvent.ZOOM_IN, onZoomIn);
			removeEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
			removeEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
			removeEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
			removeEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
			removeEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
			removeEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
			removeEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
			removeEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
			removeEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
			
			stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			
			removeUpdateTimers();
			
			if(active_level)
				removeChild(active_level, true);
			m_worldObj = null;
			m_layoutObj = null;
		}
		
		public function findLevelFile(name:String, fileObj:Object):Object
		{
			var levels:Array = fileObj["levels"];
			if (!levels) return fileObj; // if no levels, assume global file
			for (var i:int = 0; i < levels.length; i++) {
				var levelName:String = levels[i]["id"];
				if (levelName == name) return levels[i];
			}
			return null;
		}
		
		
		private function onToolTipAdded(evt:ToolTipEvent):void
		{
			if (evt.text && evt.text.length && evt.component && active_level && !m_activeToolTip) {
				function pointAt(lev:Level):DisplayObject {
					return evt.component;
				}
				var pointFrom:String = Constants.TOP_LEFT;
				var onTop:Boolean = evt.point.y < 80;
				var onLeft:Boolean = evt.point.x < 80;
				if (onTop && onLeft) {
					// If in top left corner, move to bottom right
					pointFrom = Constants.BOTTOM_RIGHT;
				} else if (onLeft) {
					// If on left, move to top right
					pointFrom = Constants.TOP_RIGHT;
				} else if (onTop) {
					// If on top, move to bottom left
					pointFrom = Constants.BOTTOM_LEFT;
				}
				m_activeToolTip = new ToolTipText(evt.text, active_level, false, pointAt, pointFrom);
				if (evt.point) m_activeToolTip.setGlobalToPoint(evt.point.clone());
				addChild(m_activeToolTip);
			}
		}
		
		private function onToolTipCleared(evt:ToolTipEvent):void
		{
			if (m_activeToolTip) m_activeToolTip.removeFromParent(true);
			m_activeToolTip = null;
		}
		
		private function onNumSelectedNodesChanged(evt:SelectionEvent):void
		{
			if (edgeSetGraphViewPanel) edgeSetGraphViewPanel.updateNumNodesSelectedDisplay();
		}
		
		public function setHighScores():void
		{
			if(PipeJamGame.levelInfo && PipeJamGame.levelInfo.highScores)
				sideControlPanel.setHighScores(PipeJamGame.levelInfo.highScores);
		}
		
		public function showVisibleBrushes():void
		{
			if(active_level && active_level.tutorialManager) 
			{
				var visibleBrushes:int = active_level.tutorialManager.getVisibleBrushes();
				sideControlPanel.showVisibleBrushes(visibleBrushes);
			}
			else
				sideControlPanel.showVisibleBrushes(active_level.brushesToActivate);
		}
		
		public function showCurrentBrush():void
		{
			if(active_level && active_level.tutorialManager) 
			{
				var visibleBrushes:int = active_level.tutorialManager.getVisibleBrushes();
				setFirstBrush(visibleBrushes);
			}
			else
				setFirstBrush(active_level.brushesToActivate);
		}
		
		public function setFirstBrush(visibleBrushes:int):void
		{
			var brushInt2Str:Dictionary = new Dictionary();
			brushInt2Str[TutorialLevelManager.SOLVER_BRUSH] = GridViewPanel.FIRST_SOLVER_BRUSH;
			brushInt2Str[TutorialLevelManager.WIDEN_BRUSH] = GridViewPanel.WIDEN_BRUSH;
			brushInt2Str[TutorialLevelManager.NARROW_BRUSH] = GridViewPanel.NARROW_BRUSH;
			
			// This determines the default for which brush is activated first (if visible)
			var brushOrder:Array = [
									TutorialLevelManager.SOLVER_BRUSH,
									TutorialLevelManager.WIDEN_BRUSH,
									TutorialLevelManager.NARROW_BRUSH
			];
			// If a tutorial specifically wants one brush to be selected to start, put
			// this at the beginning of the list of brushes to check for visibility
			if (active_level.tutorialManager != null)
			{
				var firstBrush:Number = active_level.tutorialManager.getStartingBrush();
				if (!isNaN(firstBrush))
				{
					brushOrder.unshift(firstBrush);
				}
			}
			
			// Activate the first brush that's visible in the brushOrder array
			for (var i:int = 0; i < brushOrder.length; i++)
			{
				if(visibleBrushes & brushOrder[i])
				{
					edgeSetGraphViewPanel.changeBrush(brushInt2Str[brushOrder[i]]);
					sideControlPanel.changeSelectedBrush(brushInt2Str[brushOrder[i]]);
					return;
				}
			}
		}
	}
}
