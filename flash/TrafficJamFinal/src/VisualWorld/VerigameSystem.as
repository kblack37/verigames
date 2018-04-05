package VisualWorld
{
	
	import Events.CGSServerLocal;
	
	import GameScenes.*;
	
	import NetworkGraph.*;
	
	import Replay.ReplayController;
	import Replay.ReplayTimeline;
	
	import State.ParseReplayState;
	
	import System.*;
	
	import UserInterface.*;
	import UserInterface.Components.*;
	
	import Utilities.*;
	
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.CGSServerConstants;
	import cgs.server.logging.CGSServerProps;
	import cgs.server.logging.GameServerData;
	import cgs.server.logging.actions.ClientAction;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	
	import org.osmf.net.PortProtocol;
	
	import spark.components.ToggleButton;
	
	/**
	 * The main class to run and display the game.
	 */
	public class VerigameSystem extends Game
	{		
		/** True to log to the CGS server */
		public static var LOGGING_ON:Boolean = true;
		
		/** Set by flashVars */
		public static var DEBUG_MODE:Boolean = false;
		
		/** Set to true to print trace statements identifying the type of objects that are clicked on */
		public static var DEBUG_IDENTIFY_CLICKED_ELEMENTS_MODE:Boolean = false;
		
		/** True to not output any trace statements. */
		public static var SUPPRESS_TRACE_STATEMENTS:Boolean = true;
				
		/** Gray color of pipes that cannot be adjusted/clicked on */
		public static const UNADJUSTABLE_PIPE_COLOR:Number = 0xAAAAAA;
				
		/** Number of seconds between transition between boards (set to something small for quicker navigation) */
		public static var BOARD_TRANSITION_TIME:Number = 0.4;
		
		/** Width of game */
		public static var GAME_WIDTH:uint;// = 1024;
		
		/** Height of game */
		public static var GAME_HEIGHT:uint;// = 768;
		
		/** Amount of horizontal space between left side and active board */
		protected var LEFT_MARGIN:uint = 0;
		
		/** Amount of horizontal space between active board and right side */
		protected var RIGHT_MARGIN:uint = 0;
		
		/* Scale of world/level complete banner when maximized and displaying at the center */
		public var LEVEL_COMPLETE_MAX_SCALE:Number;
		
		/* Scale of world/level complete banner when minimized and displaying on the side */
		public var LEVEL_COMPLETE_MIN_SCALE:Number;
		
		/* X coord of world/level complete banner when minimized and displaying on the side */
		public var LEVEL_COMPLETE_MIN_X:Number;
		
		/* Y coord of world/level complete banner when minimized and displaying on the side */
		public var LEVEL_COMPLETE_MIN_Y:Number;
		
		/** For UI when Boards were displayed on the left instead of bottom, this was their width */
		protected var OLD_UI_BOARD_PANE_WIDTH:uint = 200;// this will be ~0.2*WIDTH
		
		/** Width of a wide ball */
		public const WIDE_BALL_RADIUS:uint = 18;// NOTE: this is just copied from the Pipe class - must be updated if that is changed
		
		// ### PIPE ALLOCATION CONSTANTS - USED TO LAYOUT PIPES ### \\
		/** Amount of space to leave on left hand side of board */
		public static const PIPE_CONSTANT_LEFT_EDGE:uint = 100;// note: this should be AT LEAST > 0.5*PIPE_CONSTANT_X_GRID_SIZE
		
		/** The space between top of board and incoming pipes */
		public static const PIPE_CONSTANT_TOP_MARGIN:uint = 0;
		
		/** Nodes using integer grids will use this to scale in X */
		public static const PIPE_CONSTANT_X_GRID_SIZE:uint = 80;// nodes x values 0,1,2 are translated to 0, 1*PIPE_CONSTANT_X_GRID_SIZE, 2*PIPE_CONSTANT_X_GRID_SIZE, etc
		
		/** Nodes using integer grids will use this to scale in Y */
		public static const PIPE_CONSTANT_Y_GRID_SIZE:uint = 100;// nodes y values 0,1,2 are translated to 0, 1*PIPE_CONSTANT_X_GRID_SIZE, 2*PIPE_CONSTANT_X_GRID_SIZE, etc
		// ### END PIPE ALLOCATION CONSTANTS ### \\
		
		/** The X coordinate to place the zoomed-in active board */
		private static var ACTIVE_BOARD_X:Number;
		
		/** The Y coordinate to place the zoomed-in active board */
		private static var ACTIVE_BOARD_Y:Number;
		
		/** The scaleX to place the zoomed-in active board */
		public static var ACTIVE_BOARD_SCALEX:Number;
		
		/** The scaleY to place the zoomed-in active board */
		public static var ACTIVE_BOARD_SCALEY:Number;
		
		// ### BALL_TYPES ### \\
		//renumbered so you can now BIT AND these together, as needed.
		//Now you can & STARRED with the other types
		//Left wide_and_narrow combination so I don't have to rework code
		public static const BALL_TYPE_NONE:uint 			= 0;
		public static const BALL_TYPE_NARROW:uint 			= 1;
		public static const BALL_TYPE_WIDE:uint 			= 2;
		public static const BALL_TYPE_WIDE_AND_NARROW:uint 	= 3;
		public static const BALL_TYPE_STARRED:uint 			= 4;
		public static const BALL_TYPE_UNDETERMINED:uint 	= 8;
		public static const BALL_TYPE_GHOST:uint 			= 16; // used for recursion
		// ### END BALL_TYPES ### \\
		

		/** Current level being played by the user */
		public var current_level:Level = null;
		
		/** Current world being played by the user */
		public var current_world_index:uint = 0;
		
		/** Current board being viewed (zoomed in) by the user */
		public var active_board:Board = null;
		
		/** All the worlds that have been loaded/created */
		public var worlds:Vector.<World> = new Vector.<World>();
		
		/** Order of boards that have been visited for back functionality */
		public var board_visit_history:Vector.<Board>;
		
		/** The system is loaded and ready to be drawn */
		public var ready_to_draw:Boolean = false;
		
		/** Button to drop balls on the active board (and possibly others) */
		//protected var drop_button:TextButton;
										
		/** True if a board is being animated/moved/zoomed to prevent further animations */
		public var selected_board_is_animating:Boolean = false;
		
		/** True if a level is actively being selected to prevent actions during this time */
		public var selecting_level:Boolean = false;
				
		/** Text field displaying the level title */
		protected var level_title:TextField;
		
		/** Rectangle used to view/select inactive boards */
		public var board_select_pane:Sprite;
		
		public var game_control_panel:GameControlPanel;
		public var game_panel:GamePanel;
		public var navigation_control_panel:NavigationPanel;
		
		public var replay_game_panel:GamePanel;
		protected var replayGameOverlay:RectangularObject;
		
		/** Current y location being viewed in the board_select_pane */
		protected var board_select_pane_current_y:int = 0;
		
		/** Background image for the game */
		protected var background_image:Sprite;
		
		/** Overlay used for people in the TRAFFIC theme */
		public var theme_overlay:Sprite;
		
		/** Image used for the drop button */
		protected var drop_button_image:Bitmap;
		
		/** Image used for the drop button when moused over */
		protected var drop_button_mouseover_image:Bitmap;
		
		/** Images used for boards of a given level (different colors, same texture) */
		public var level_background_images:Vector.<Bitmap>;
		
		/** All the clickable icons used to select a level */
		public var level_icons:Vector.<LevelIcon>;
		
		/** All the boards that need to be simulated due to changes */
		public var dirty_boards:Vector.<Board>;
		
		/** True if the world map is zoomed in */
		public var world_map_maximized:Boolean = true;
		
		/** True if the current world is ready to be played */
		protected var current_world_loaded:Boolean = false;
		
		/** True if any world is being played (as opposed to loaded) */
		protected var playing_world:Boolean = false;
		
		/** True if any world is being currently loaded */
		public var loading_world:Boolean = false;
		

		
		/** Text format used to show when score will be subtracted for the buzzsaw */
		protected var score_to_subtract_textformat:TextFormat;
		
		/** Text used to show when score will be subtracted for the buzzsaw */
		protected var score_to_subtract_textfield:TextField;
		

		
		/** Graphics asset showing level complete */
		protected var level_complete_banner:Sprite;
		
		/** Graphics asset showing world complete */
		protected var world_complete_banner:Sprite;
				
		/** True if euphoria is still going on for the level complete celebration */
		protected var celebrating_level:Boolean = false;
		
		/** True if euphoria is still going on for the world complete celebration */
		protected var celebrating_world:Boolean = false;
		
		/** True if the pipe jam title screen is up and blocking the game */
		protected var splash_screen_up:Boolean = true;
		
		/** Graphical object used to add things to the parent of this system */
		protected var uiComponent:UIComponent = new UIComponent();
		
		/** Text displaying "Loading..." to user */
		protected var loading_text:TextField = new TextField();
		
		/** User to blur the game when loading a new world */
		protected var blur_filters:Array;
		
		/** Used to allow user to navigate to a new world */
		protected var next_world_pane:Sprite;
		
		/** Button to allow user to go to new world */
		protected var next_world:TextButton;
		
		/** Button to allow user to go back to solved world */
		protected var prev_world:TextButton;
		
		/** Button to allow user to go back previous webgame screen */
		protected var save_and_quit:TextButton;
		
		/** Multiple fireworks (for world complete) */
		protected var fireworks:Vector.<Sprite>;
		
		/** Single fireworks instance (for level complete) */
		protected var fw:Sprite;
				
		//[Embed(source = '../../lib/assets/FireworksSlowMo.swf', symbol = 'FireworksSlowMo')]
		/** Animated fireworks display */
		[Embed(source = '../../lib/assets/Fireworks.swf', symbol = 'Fireworks')]
		public var Fireworks:Class;
		
		/** Buzzsaws used to float with mouse of user while finding a place to put it */
		public var buzzsaw_pair:Sprite;
		
		/** Topmost graphics object to put buzzsaws on so that they are always on top */
		protected var overpane:RectangularObject;
		
		/** True when user is actively adding buzzsaws */
		public var buzzing:Boolean = false;
		
		/** True when the subtracted score is being shown/fading away */
		protected var subtracting_score:Boolean = false;
		
		/** Pipe being moused over, used for buzzsaws to detect whether points will be subtracted (if this is non-null) or not (if this is null) */
		public var mouseover_pipe:Pipe;
		
		//could be used for various things, the first of which is adding stopped cars to pipes when there's room 
		public var gameTimer:Timer;
				
		public static var m_serverInitialized:Boolean = false;
		
		public var m_gameScene:VerigameSystemGameScene;
		
		public var world_map:WorldMap;
		
		public var m_shouldCelebrate:Boolean = false;
		
		public var replayController:ReplayController;
		
		public var localServer:CGSServerLocal;
		
		public var m_currentNetwork:Network;
		/**
		 * The main class to run and display the game.
		 * @param	_x X offset of the game
		 * @param	_y Y offset of the game
		 * @param	_width Width of the game
		 * @param	_height Height of the game
		 */
		public function VerigameSystem(_x:int, _y:int, _width:uint, _height:uint, gameScene:VerigameSystemGameScene)
		{
			//initialize this guy
			localServer = new CGSServerLocal(this);
			
			super(_x, _y, _width, _height);
			m_gameScene = gameScene;
			GAME_WIDTH = _width;
			GAME_HEIGHT = _height;
			board_visit_history = new Vector.<Board>();
			level_icons = new Vector.<LevelIcon>();
			dirty_boards = new Vector.<Board>();
			
			var tf:TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 100, 0x0033AA, true);
			loading_text.embedFonts = true;
			loading_text.text = "Loading...";
			loading_text.selectable = false;
			loading_text.width = GAME_WIDTH;
			loading_text.autoSize = TextFieldAutoSize.CENTER;
			loading_text.x = 0.5*GAME_WIDTH;
			loading_text.y = 400;
			loading_text.setTextFormat(tf);
			loading_text.name = "loading_text";
			uiComponent.addChild(loading_text);
			super.addChild(uiComponent);		
			
//			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveFunc);
//			function mouseMoveFunc(e:MouseEvent):void {
//				if (false) {
//					//level_complete_banner.x = stage.mouseX;
//					//level_complete_banner.y = stage.mouseY;
//					trace("Mouse:" + stage.mouseX + "," + stage.mouseY);
//				}
//				if (active_board) {
//					active_board.mouseMove(stage.mouseX, stage.mouseY);
//				}
//			}
			addEventListener(MouseEvent.MOUSE_UP, mouseUpFunc);
			function mouseUpFunc(e:MouseEvent):void {
				 //This is a good way to identify objects by clicking on them:
				if (DEBUG_IDENTIFY_CLICKED_ELEMENTS_MODE) {
					trace(e.target.name + " par:" + e.target.parent.name + " childindx:" + e.target.parent.getChildIndex(e.target));
					if (e.target.parent.parent) {
						trace("par par:" + e.target.parent.parent.name + " childindx:" + e.target.parent.parent.getChildIndex(e.target.parent));
						if (e.target.parent.parent.parent) {
							trace("par par par:" + e.target.parent.parent.parent.name);
						}
					}
				}
				if (active_board) {
					active_board.background_dragging_start_pt = null;
					if (e.target.name != StampSelector.NAME) {
						active_board.removeStampSelector();
					}
				}
			}
			
			if(!m_serverInitialized)
				initializeServer();
			
			initGame();
			if (DEBUG_MODE) {
				BOARD_TRANSITION_TIME = 0.0;
			}
			
			printDebug("Loading system...");
			gameTimer = new Timer(100); //some arbitrary firing interval
			gameTimer.addEventListener(TimerEvent.TIMER, gameTimerInterval);
			gameTimer.start();
		}
		
		public function initializeServer():void
		{
			m_serverInitialized = true;
				
			// Initialize logging
			if (LOGGING_ON) {
				
				var props:CGSServerProps = new CGSServerProps(
					VerigameServerConstants.VERIGAME_SKEY,
					GameServerData.NO_SKEY_HASH,
					VerigameServerConstants.VERIGAME_GAME_NAME,
					VerigameServerConstants.VERIGAME_GAME_ID,
					VerigameServerConstants.VERIGAME_VERSION_SEEDLING_BETA,
					VerigameServerConstants.VERIGAME_CATEGORY_SEEDLING_BETA,
					CGSServerConstants.DEV_URL
				);
				props.cacheUid = false;
				props.uidValidCallback = onUidSet;
				props.forceUid = "cgs_test_tdp";
				CGSServer.setup(props);
				var saveCacheToServer:Boolean = false;
				CGSServer.initialize(props, saveCacheToServer, onServerInit);
				
				function onServerInit(failed:Boolean):void {
					trace("onServerInit() failed=" + failed.toString());
				}
				
				function onUidSet(uid:String, failed:Boolean):void {
					trace("onUidSet() failed=" + failed.toString());
				}
				 
				
//				CGSServer.init(new CGSServerProps(VerigameServerConstants.VERIGAME_SKEY, GameServerData.NO_SKEY_HASH, VerigameServerConstants.VERIGAME_GAME_NAME
//				, VerigameServerConstants.VERIGAME_GAME_ID, VerigameServerConstants.VERIGAME_VERSION_SEEDLING_BETA, VerigameServerConstants.VERIGAME_CATEGORY_SEEDLING_BETA, CGSServerConstants.DEV_URL));
//				CGSServer.requestUid(null, false, "cgs_test_user_tdp");
				
			}
		}
		/**
		 * Run once to initialize the game
		 */
		public function initGame():void {
			
			this.scrollRect = new Rectangle(0, 0, GAME_WIDTH, GAME_HEIGHT);
			
			[Embed(source="../../lib/assets/buzz_saw.png")]
			var BuzzsawImageClass:Class;
			
			var filter:BitmapFilter = new BlurFilter(40, 40, BitmapFilterQuality.HIGH);
            blur_filters = new Array();
            blur_filters.push(filter);
			
	
						
			fw = new Fireworks();
			fw.x = 155;
			fw.y = 200;
			fw.name = "Fireworks:fw";
			
			fireworks = new Vector.<Sprite>();
			var fw1:Sprite = new Fireworks();
			fw1.x = 85;
			fw1.y = 200;
			fw1.name = "Fireworks:fw1";
			fireworks.push(fw1);
			var fw2:Sprite = new Fireworks();
			fw2.x = 155;
			fw2.y = 200;
			fw2.name = "Fireworks:fw2";
			fireworks.push(fw2);
			var fw3:Sprite = new Fireworks();
			fw3.x = 225;
			fw3.y = 200;
			fw3.name = "Fireworks:fw3";
			fireworks.push(fw3);
						
			/** The animated buzzsaw asset */
			[Embed(source = '../../lib/assets/buzz_saw_slow.swf', symbol = 'BuzzSawSlowMo')]
			var BuzzSaw:Class;
			
			/*
			var blur_filt:BlurFilter = new BlurFilter(128, 128, 4);
			var myFilters:Array = [blur_filt];
			overpane.filters = myFilters;
			*/
			
			/** The board background images */
			[Embed(source="../../lib/assets/BoardBackgroundGreen.png")]
			var BackgroundGreen:Class;/// usage: var pic:Bitmap = new BackgroundGreen();
			
			[Embed(source="../../lib/assets/BoardBackgroundPurple.png")]
			var BackgroundPurple:Class;/// usage: var pic:Bitmap = new BackgroundPurple();
			
			[Embed(source="../../lib/assets/BoardBackgroundTeal.png")]
			var BackgroundTeal:Class;/// usage: var pic:Bitmap = new BackgroundTeal();
			
			[Embed(source="../../lib/assets/BoardBackgroundBlue.png")]
			var BackgroundBlue:Class;/// usage: var pic:Bitmap = new BackgroundBlue();
			
			level_background_images = new Vector.<Bitmap>();
			
			[Embed(source="../../lib/assets/PipeJamUI.png")]
			var PipeJamUIClass:Class;
			
			[Embed(source="../../lib/assets/pawn.png")]
			var PawnImageClass:Class;
			
			[Embed(source="../../lib/assets/DropButton.png")]
			var DropButtonImageClass:Class;
			
			[Embed(source="../../lib/assets/DropButtonClick.png")]
			var DropButtonClickImageClass:Class;
			
			
			[Embed(source="../../lib/assets/PipeJamTitlescreenRevised.png")]
			var PipeJamTitlescreenImageClass:Class;
			
			[Embed(source="../../lib/assets/StartButton.png")]
			var StartButtonImageClass:Class;
			
			[Embed(source="../../lib/assets/StartButtonClick.png")]
			var StartButtonClickImageClass:Class;
						
			world_map_maximized = false;
			
			[Embed(source="../../lib/assets/level_icon_blue.png")]
			var LevelIconBlueClass:Class;
			
			[Embed(source="../../lib/assets/castle.png")]
			var HomeIconClass:Class;

			LEFT_MARGIN = 0.2 * GAME_WIDTH;
			RIGHT_MARGIN = 0;
			ACTIVE_BOARD_SCALEX = 0.6;
			ACTIVE_BOARD_SCALEY = 0.6;

			ACTIVE_BOARD_X = GAME_WIDTH - ACTIVE_BOARD_SCALEX * GAME_WIDTH - RIGHT_MARGIN - 62;
			ACTIVE_BOARD_Y = 12;

			LEVEL_COMPLETE_MAX_SCALE = 1.75;
			LEVEL_COMPLETE_MIN_SCALE = 0.75;
			LEVEL_COMPLETE_MIN_X = 174;
			LEVEL_COMPLETE_MIN_Y = 170;
			
			var navigationPanelHeight:uint = 185;
			var bottomBorder:uint = 50;
			var gameControlPanelWidth:uint = 300;
			game_control_panel = new GameControlPanel(0, 0, gameControlPanelWidth, GAME_HEIGHT - navigationPanelHeight, this);
			game_control_panel.init();
			navigation_control_panel = new NavigationPanel(0, GAME_HEIGHT - navigationPanelHeight - bottomBorder, GAME_WIDTH, navigationPanelHeight, this);
			navigation_control_panel.init();
			game_panel = new GamePanel(game_control_panel.width, 0, GAME_WIDTH  - game_control_panel.width, navigation_control_panel.y, this);
			game_panel.init();
			score_to_subtract_textformat = new TextFormat(Fonts.FONT_FRACTION, 32, 0xFF0000, true, false, false, null, null, TextFormatAlign.CENTER);
			var merge_icon:MovieClip = new Art_SignConstructionMerge();
			merge_icon.scaleX = 0.5;
			merge_icon.scaleY = 0.5;
			
			buzzsaw_pair = new Sprite();
			buzzsaw_pair.addChild(merge_icon);
			buzzsaw_pair.mouseEnabled = false;
			buzzsaw_pair.mouseChildren = false;
			 
			overpane = new RectangularObject(0, 0, width, height);
			overpane.graphics.clear();
			overpane.graphics.beginFill(0x000000, 0.7);
			overpane.graphics.drawRect(0, 0, width, height);
			overpane.name = "overpane";
			var back_mc:MovieClip = new Art_MapBackground();
			var bd:BitmapData = new BitmapData(1024, 768);
			var bmp:Bitmap = new Bitmap(bd);
			bd.draw(back_mc);
			level_background_images.push(bmp);
			level_complete_banner = new Sprite();
			var lc_mc1:MovieClip = new Art_WinMessage();
			lc_mc1.scaleX = 0.5;
			lc_mc1.scaleY = 0.5;
			level_complete_banner.addChild(lc_mc1);
			level_complete_banner.name = "level_complete_banner";
			world_complete_banner = new Sprite();
			var wc_mc1:MovieClip = new WorldComplete();
			wc_mc1.gotoAndStop(1);
			world_complete_banner.addChild(wc_mc1);
			world_complete_banner.name = "world_complete_banner";
			background_image = new Art_Background();
			background_image.x = 0;
			background_image.y = 0;
			background_image.width = GAME_WIDTH;
			background_image.height = GAME_HEIGHT;
			theme_overlay = new Sprite();
			var people_mc:MovieClip = new Art_Workers();
			people_mc.x = 0.5 * GAME_WIDTH;
			people_mc.y = GAME_HEIGHT - 0.5 * people_mc.height;
			var people_scale:Number = GAME_WIDTH / people_mc.width;
			people_mc.scaleX = people_scale;
			people_mc.scaleY = people_scale;
			people_mc.gotoAndStop(1);
			theme_overlay.addChild(people_mc);

	
			//parts for the next world screen. Should eventually be spun off as a scene, but maybe even killed, as the Main Menu can do this.
			//The Return to World aspect won't happen as a scene (old scenes get lost) but celebrations could happen on the main game screen, and some random button
			//could control going to the next thing
			next_world_pane = new Sprite();
			next_world_pane.graphics.beginFill(0x0, 0.2);
			next_world_pane.graphics.drawRect(0, 0, GAME_WIDTH, GAME_HEIGHT);
			next_world_pane.graphics.endFill();
			
			next_world = new TextButton(0.5*(GAME_WIDTH - 300), 450, 300, 50, "Next World", loadNextWorld);
			next_world.fontSize = 32;
			next_world.centerVertically();
			next_world.name = "next_world";
			prev_world = new TextButton(0.5 * (GAME_WIDTH - 300), 550, 300, 50, "Return to World", showPrevWorld);
			prev_world.fontSize = 32;
			prev_world.centerVertically();
			prev_world.name = "prev_world";
			save_and_quit = new TextButton(0.5 * (GAME_WIDTH - 300), 650, 300, 50, "Save & Quit", onSaveAndQuit);
			save_and_quit.fontSize = 32;
			save_and_quit.centerVertically();
			save_and_quit.name = "save_and_quit";
			
			score_to_subtract_textfield = new TextField();
			score_to_subtract_textfield.embedFonts = true;
			score_to_subtract_textfield.text = "-50";
			score_to_subtract_textfield.setTextFormat(score_to_subtract_textformat);
			score_to_subtract_textfield.wordWrap = false;
			score_to_subtract_textfield.autoSize = TextFieldAutoSize.CENTER;
			score_to_subtract_textfield.selectable = false;
			score_to_subtract_textfield.width = score_to_subtract_textfield.textWidth;
			score_to_subtract_textfield.x = -100.0;
			score_to_subtract_textfield.y = -0.5 * score_to_subtract_textfield.textHeight;
			score_to_subtract_textfield.name = "score_to_subtract_textfield";
			delayedLoadWorldCall();
			
		}
		
		public function cleanUp():void
		{
			gameTimer.stop();
			gameTimer.removeEventListener(TimerEvent.TIMER, gameTimerInterval);
			gameTimer = null;
			
			worlds = null;
		}
		
		public function onBackToMainMenuButtonClick(e:MouseEvent):void {
			m_gameScene.backToMainMenu();
		}
		
		protected var replayTimeline:ReplayTimeline;
		public function onReplayButtonClick(e:MouseEvent):void {
			openReplayPanel(CGSServerLocal.m_replayActionObjects[0]);
		}
		
		public function onSaveButtonClick(e:MouseEvent):void {
			if (current_world) {
				current_world.outputXmlToJavascript();
			}
		}
		
		public function onSubmitButtonClick(e:MouseEvent):void {
			if (current_world) {
				current_world.outputXmlToJavascript();
			}
			showNextWorldScreen();
		}
		
		public function onBackButtonClick(e:MouseEvent):void {
			/*
			trace("----Visit history:----");
			for each (var myb:Board in board_visit_history) {
				trace(myb.board_name);
			}
			trace("----------------------");
			*/
			if (board_visit_history.length == 0) {
				e.target.disabled = true;
				return;
			}
			var board_to_return_to:Board;
			var found:Boolean = false;
			while ((board_visit_history.length > 0) && !found) {
				board_to_return_to = board_visit_history.pop();
				if (board_to_return_to != active_board) {
					found = true;
				}
			}
			if (board_visit_history.length == 0) {
				e.target.disabled = true;
			} else {
				e.target.disabled = false;
			}
			if (found) {
				selectBoard(board_to_return_to);
			}
		}
		
		public function setGameSize(fullScreen:Boolean = false):void
		{
			if(fullScreen)
			{
				game_control_panel.visible = false;
				navigation_control_panel.visible = false;
				game_panel.setGameSize(fullScreen);
			}
			else
			{
				game_control_panel.visible = true;
				navigation_control_panel.visible = true;
				game_panel.x = game_control_panel.width;
				game_panel.width = GAME_WIDTH  - game_control_panel.width;
				game_panel.height = navigation_control_panel.y;
				game_panel.setGameSize(fullScreen);

				
			}
		}
		
		/**
		 * Shows the next world to the user to be played
		 * @param	e Associated mouseEvent
		 */
		public function loadNextWorld(e:Event):void {
			//if we are currently playing, bail if there isn't a next
			if(playing_world)
				if (current_world_index >= (worlds.length - 1))
					return;
			
			if (next_world.parent == uiComponent)
				uiComponent.removeChild(next_world);	
			if (loading_text.parent != uiComponent)
				uiComponent.addChild(loading_text);	
			
			if(playing_world)
				current_world_index++;
			playing_world = false;
			current_world_loaded = true;
			delayedLoadWorldCall();
		}
		
		/**
		 * Called to load and play the next world, removing blur
		 */
		public function delayedLoadWorldCall():void {
			if (loading_world || playing_world || (!current_world_loaded)) {
				return;
			}
			loading_world = true;
			if (loading_text.parent != uiComponent) {
				uiComponent.addChild(loading_text);
			}
			if (parent == null) {
				if (uiComponent.parent != this) {
					addChild(uiComponent);
				}
			} else {
				if (uiComponent.parent != parent) {
					parent.addChild(uiComponent);
				}
			}
			filters = blur_filters;
			TweenLite.delayedCall(0.2, performDelayedWorldCall);
		}
		
		/**
		 * Called by delayedLoadWorldCall() after delay to remove blur and show the world
		 */
		protected function performDelayedWorldCall():void {
			playWorld();
			if (loading_text.parent == uiComponent) {
				uiComponent.removeChild(loading_text);
			}
			if ((parent == null) || (uiComponent.parent == this)) {
				if (uiComponent.parent == this) {
					removeChild(uiComponent);
				}
			} else {
				if (uiComponent.parent == parent) {
					parent.removeChild(uiComponent);
				}
			}
			filters = new Array();
			
			draw();
		}
		
		/**
		 * Called when the user clicks the buzzsaw button, displays two buzzsaws at the current mouse location
		 * @param	e Associated mouseEvent
		 */
		public function buzzsawButtonClick(e:MouseEvent):void {
			if (active_board == null) {
				return;
			}
			
			score_to_subtract_textfield.alpha = 1.0;	
			score_to_subtract_textfield.y = 120;//score_pane.y + 60;
			
			overpane.addEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
		//	overpane.addEventListener(MouseEvent.CLICK, buzzsawCancel);
			
			active_board.addEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			active_board.addEventListener(MouseEvent.CLICK, buzzsawClick);
			//Mouse.hide();
			
			buzzsaw_pair.addEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			score_to_subtract_textfield.addEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			
			buzzing = true;
			
			buzzsaw_pair.x = game_control_panel.buzzsaw_button.x + 0.5 * game_control_panel.buzzsaw_button.width;
			buzzsaw_pair.y = game_control_panel.buzzsaw_button.y + 0.5 * game_control_panel.buzzsaw_button.height;
			score_to_subtract_textfield.x = game_control_panel.buzzsaw_button.x + 0.5*game_control_panel.buzzsaw_button.width - 110;
			score_to_subtract_textfield.y = game_control_panel.buzzsaw_button.y + 0.5 * score_to_subtract_textfield.textHeight;
			draw();
		}
		

		/**
		 * Called after the buzzsaw button has been pressed to update the position of the buzzsaws the follow the mouse
		 * @param	e Associated mouseEvent
		 */
		public function buzzsawMouseMove(e:MouseEvent):void {
			buzzsaw_pair.x = e.stageX / scaleX;
			buzzsaw_pair.y = e.stageY / scaleY;
			
			if (mouseover_pipe) {
				addChild(score_to_subtract_textfield);
			} else if (score_to_subtract_textfield.parent == this) {
				removeChild(score_to_subtract_textfield);
			}
			score_to_subtract_textfield.x = e.stageX / scaleX - 110;
			score_to_subtract_textfield.y = e.stageY / scaleY - 0.5 * score_to_subtract_textfield.textHeight; 
		}
		
		/**
		 * Called to cancel placement of buzzsaws, removes buzzsaws from mouse location
		 * @param	e Associated mouseEvent
		 */
		public function buzzsawCancel(e:MouseEvent):void {
			overpane.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			overpane.removeEventListener(MouseEvent.CLICK, buzzsawClick);
			
			if (active_board) {
				active_board.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
				active_board.removeEventListener(MouseEvent.CLICK, buzzsawClick);
			}
			buzzsaw_pair.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			//Mouse.show();
			buzzing = false; 
			draw();
		}
		
		/**
		 * Called when the user attempts to place a buzzsaw
		 * @param	e Associated mouseEvent
		 */
		public function buzzsawClick(e:MouseEvent):void {
			//Mouse.show();
			overpane.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			overpane.removeEventListener(MouseEvent.CLICK, buzzsawClick);
			
			if (active_board) {
				active_board.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
				active_board.removeEventListener(MouseEvent.CLICK, buzzsawClick);
			}
			buzzsaw_pair.removeEventListener(MouseEvent.MOUSE_MOVE, buzzsawMouseMove);
			buzzing = false; 
			game_control_panel.buzzsaw_button.disabled = true;
			subtracting_score = true;
			draw();
			game_control_panel.updateScore();
			function oncomplete():void {
				subtracting_score = false;
				game_control_panel.buzzsaw_button.disabled = false;
			}
			var origx:Number = score_to_subtract_textfield.x;
			var origy:Number = score_to_subtract_textfield.y;
			TweenLite.to(score_to_subtract_textfield, 0.5, { y: (origy - 30.0), alpha: 0, onComplete:oncomplete } );
		}
		

		
		/**
		 * Calculates level dependencies to draw the world map, then displays current world to the user to be played
		 */
		public function playWorld():void {
			while (numChildren > 0) { removeChildAt(0); }
			
			board_visit_history = new Vector.<Board>();
			dirty_boards = new Vector.<Board>();

			current_level = null;
			active_board = null;
			
			if((m_gameScene.m_controller as TrafficJamSceneController).nextWorldIsFullView)
			{
				openWorldInFullView();
				world_map = null;
				selectLevel(m_gameScene.gameSystem.worlds[0].findLevel(0), false, false);
			}
			else
			{
				openWorldInFullView(false);
				world_map = new WorldMap(this, current_world, x, y, GAME_WIDTH, GAME_HEIGHT);
				
				//I don't know why we start at world.last - 1?? Tutorial needs to start at world.first, so do this in both places
				// set current level first in dependency map, and load those boards
				selectLevel(current_world.levels[current_world.levels.length - 1], false, false);
			}
			
			
				
				for each (var level_to_draw:Level in current_world.levels) {
					level_to_draw.level_has_been_solved_before = false; //turn this off, so when selected from map it celebrates
				//	for each (var board_to_draw:Board in level_to_draw.boards) {
				//		board_to_draw.draw();
				//	}
				}
				if (world_map && !world_map_maximized) {
					world_map.maximizeWorldMap( function():void { } );
				}
			//}
			
			// Log quest start
			if (LOGGING_ON) {
				var levelInfo:Object = new Object();
				levelInfo["world_name"] = current_world.world_name;
				levelInfo["world_xml_url"] = String(current_world.getUpdatedXML());
				
				CGSServerLocal.logQuestStart(VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, levelInfo, onLogQuestStart);
			}
			
			loading_world = false;
			ready_to_draw = true;
		}

		public function openWorldInFullView(expand:Boolean = true):void
		{

			
		}
		
		public function checkForCelebration():void
		{
			if (current_level && m_shouldCelebrate) {
				if (!current_level.failed && !celebrating_level && !celebrating_world) {
					level_complete_banner.x = LEVEL_COMPLETE_MIN_X;
					level_complete_banner.y = LEVEL_COMPLETE_MIN_Y;
					level_complete_banner.scaleX = LEVEL_COMPLETE_MIN_SCALE;
					level_complete_banner.scaleY = LEVEL_COMPLETE_MIN_SCALE;
					if (level_complete_banner.parent != this) {
						addChild(level_complete_banner);
					}
				} else if (current_level.failed && (level_complete_banner.parent == this)) {
					removeChild(level_complete_banner);
				}
			}
		}
		
		private function onLogQuestStart(dqid:String, failed:Boolean):void
		{
			printDebug("DQID: " + dqid);
		}
		
		/**
		 * Called to scroll up to see more boards
		 * @param	e Associated mouseEvent
		 */
		public function clickScrollUp(e:MouseEvent):void {
			for each (var b:Board in current_level.boards) {
				if (!b.active)
					b.y += 0.8*GAME_HEIGHT;
				b.original_y += 0.8*GAME_HEIGHT;
			}
		}
		
		/**
		 * Called to scroll down to see more boards
		 * @param	e Associated mouseEvent
		 */
		public function clickScrollDown(e:MouseEvent):void {
			for each (var b:Board in current_level.boards) {
				if (!b.active)
					b.y -= 0.8*GAME_HEIGHT;
				b.original_y -= 0.8*GAME_HEIGHT;
			}
		}
		

		/**
		 * Draw current graphics: background, UI, buzzsaws, etc
		 */
		public function draw():void {
			graphics.clear();
			uiComponent.scaleX = scaleX;
			uiComponent.scaleY = scaleY;
			if (ready_to_draw) {
				if (background_image.parent == this) {
					removeChild(background_image);
				}
				addChildAt(background_image, 0);
				
				graphics.lineStyle(5, 0xAAAAAA);
				if (current_level != null) {
					if (!current_level.failed) {
						graphics.lineStyle(6, 0x00FF00);
					}
				}
			//	graphics.drawRect(0, 0, GAME_WIDTH, GAME_HEIGHT);
				
				if (game_control_panel && game_control_panel.isInitialized()) {
					if (game_control_panel.parent != this) {
						addChild(game_control_panel);
						game_control_panel.draw();
					} else {
						setChildIndex(game_control_panel, numChildren - 1);
						game_control_panel.draw();
					}
				}		

				if (navigation_control_panel && navigation_control_panel.isInitialized()) {
					if (navigation_control_panel.parent != this) {
						addChild(navigation_control_panel);
						navigation_control_panel.draw();
					} else {
						setChildIndex(navigation_control_panel, numChildren - 1);
						navigation_control_panel.draw();
					}
				}
				
				if (game_panel && game_panel.isInitialized()) {
					if (game_panel.parent != this) {
						addChild(game_panel);
					} else {
						setChildIndex(game_panel, numChildren - 1);
					}
				}
				
			
				if (!loading_world) {
					if (loading_text && (loading_text.parent == uiComponent)) {
						uiComponent.removeChild(loading_text);
					}
					if (uiComponent) {
						if ((parent == null) || (uiComponent.parent == this)) {
							if (uiComponent.parent == this) {
								removeChild(uiComponent);
							}
						} else {
							if (uiComponent.parent == parent) {
								parent.removeChild(uiComponent);
							}
						}
					}
					filters = new Array();
				}
				
				if (theme_overlay.parent != this) {
					addChild(theme_overlay);
				} else {
					setChildIndex(theme_overlay, numChildren - 1);
				}
				
				if(world_map)
				{
					if (world_map.world_map_background.parent != this) {
						addChild(world_map.world_map_background);
					} else {
						setChildIndex(world_map.world_map_background, numChildren - 1);
					}
				}
				
				if (current_level != null) {
					if (!current_level.failed) {
						if (level_complete_banner.parent == this) {
							setChildIndex(level_complete_banner, numChildren - 1);
						}
					} else {
						if (level_complete_banner.parent == this) {
							removeChild(level_complete_banner);
						}
					}
				}
				
				if (current_world != null) {
					if (celebrating_world) {
						if (world_complete_banner.parent == this) {
							setChildIndex(world_complete_banner, numChildren - 1);
						}
					} else {
						if (world_complete_banner.parent == this) {
							removeChild(world_complete_banner);
						}
					}
				}
				
				if(world_map)
				{
					if (!celebrating_level && !celebrating_world) {
						if (world_map.world_map_background.parent != this) {
							addChild(world_map.world_map_background);
						} else {
							setChildIndex(world_map.world_map_background, numChildren - 1);
						}
					}
				}
				
				if (fw.parent == this) {
					removeChild(fw);
				}
				
				if (buzzsaw_pair.parent == this) {
					removeChild(buzzsaw_pair);
				}
				
				if (!buzzing && !subtracting_score && (score_to_subtract_textfield.parent == this)) {
					removeChild(score_to_subtract_textfield);
				}
					
				if (overpane.parent == this) {
					removeChild(overpane);
				}
			
				if (buzzing) {
					addChild(overpane);
					// add active board and map on top

					if (active_board != null) {
						if (game_panel.parent) {
							removeChild(game_panel);
						}
						addChild(game_panel);
					}
					addChild(buzzsaw_pair);
				}
				
				if (replay_game_panel) {
					if (replay_game_panel.parent != this) {
						addChild(replay_game_panel);
					} else {
						setChildIndex(replay_game_panel, numChildren - 1);
					}
				}	
	
			}
			
		}
		
		/**
		 * Displays a firework animation and level complete banner
		 */
		public function levelCompleteEuphoria():void {
			if (level_complete_banner.parent == this) {
				removeChild(level_complete_banner);
			}
			level_complete_banner.scaleX = LEVEL_COMPLETE_MAX_SCALE;
			level_complete_banner.scaleY = LEVEL_COMPLETE_MAX_SCALE;
			level_complete_banner.x = 0.5 * GAME_WIDTH;
			level_complete_banner.y = 0.5 * GAME_HEIGHT;
			addChild(level_complete_banner);
			switch (Theme.CURRENT_THEME) {
				case Theme.PIPES_THEME:
					if (fw.parent == this) {
						removeChild(fw)
					}
					addChild(fw);
				break;
				case Theme.TRAFFIC_THEME:
					(theme_overlay.getChildAt(0) as MovieClip).gotoAndStop(2);
				break;
			}
			celebrating_level = true;
			var ani:Animation = new Animation();
			ani.zoomInAndOut(level_complete_banner, LEVEL_COMPLETE_MAX_SCALE, 0.2, function():void { }, 0.5, 0.2, function():void {
				var ani1:Animation = new Animation();
				if(world_map)
					ani1.translateAndZoom(level_complete_banner, LEVEL_COMPLETE_MIN_X, LEVEL_COMPLETE_MIN_Y, LEVEL_COMPLETE_MIN_SCALE, LEVEL_COMPLETE_MIN_SCALE, 0.7, function():void { world_map.maximizeWorldMap(function():void { celebrating_level = false; }); } );
				else
					ani1.translateAndZoom(level_complete_banner, LEVEL_COMPLETE_MIN_X, LEVEL_COMPLETE_MIN_Y, LEVEL_COMPLETE_MIN_SCALE, LEVEL_COMPLETE_MIN_SCALE, 0.7, function():void { } );

			}, true );
		}
		
		/**
		 * Displays multiple fireworks animations and a world complete banner
		 */
		public function worldCompleteEuphoria():void {
			if (world_complete_banner.parent == this) {
				removeChild(world_complete_banner);
			}
			world_complete_banner.scaleX = LEVEL_COMPLETE_MAX_SCALE;
			world_complete_banner.scaleY = LEVEL_COMPLETE_MAX_SCALE;
			world_complete_banner.x = 0.5 * GAME_WIDTH;
			world_complete_banner.y = 0.5 * GAME_HEIGHT;
			world_complete_banner.alpha = 1.0;
			addChild(world_complete_banner);
			if (fw.parent == this) {
				removeChild(fw);
			}
			addChild(fw);
			celebrating_level = false;
			celebrating_world = true;
			draw();
			var ani:Animation = new Animation();
			ani.zoomInAndOut(world_complete_banner, LEVEL_COMPLETE_MAX_SCALE, 0.4, function():void { }, 0.75, 0.4, function():void {
				var ani1:Animation = new Animation();
				function onWorldIconComplete():void { 
					if(world_map)
					{
						world_map.maximizeWorldMap(function():void { 
						celebrating_world = false;
						draw();
						showNextWorldScreen();
						} );
					}
				}
				TweenLite.to(world_complete_banner, 0.75, { alpha:0.0, onComplete:onWorldIconComplete } );
			}, true );
		}
		
		/**
		 * Displays a blurred screen and a button to play the next world (if any) or "Thanks for playing!" if no next world
		 */
		public function showNextWorldScreen():void {
			this.filters = blur_filters;
			if (loading_text.parent == uiComponent) {
				uiComponent.removeChild(loading_text);
			}
			parent.addChild(uiComponent);
			save_and_quit.disabled = false;
			uiComponent.addChild(next_world_pane);
			if (next_world.parent == uiComponent) {
				uiComponent.removeChild(next_world);
			}
			uiComponent.addChild(prev_world);
			uiComponent.addChild(save_and_quit);
			if (current_world_index < worlds.length - 1) {
				uiComponent.addChild(next_world);
			} else {
				var tf:TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 100, 0x0033AA, true);
				var tb:TextField = new TextField();
				tb.embedFonts = true;
				tb.text = "Thanks for playing!";
				tb.selectable = false;
				tb.width = GAME_WIDTH;
				tb.autoSize = TextFieldAutoSize.CENTER;
				tb.x = 0.5*GAME_WIDTH;
				tb.y = 250;
				tb.setTextFormat(tf);
				uiComponent.addChild(tb);
			}
		}
		
		public function showPrevWorld(e:Event):void {
			this.filters = [];
			if (uiComponent.parent == parent) {
				parent.removeChild(uiComponent);
			}
		}
		
		public function onSaveAndQuit(e:Event):void {
			if (current_world) {
				save_and_quit.disabled = true;
				current_world.outputXmlToJavascript(true);
			} else {
				throw new Error("No current world found!");
			}
		}
		
		/**
		 * This function is called after the graph structure (Nodes, edges) has been read in from XML. It converts nodes/edges to a playable world.
		 * @param	_worldNodes
		 * @param	_world_xml
		 * @return
		 */
		public function createWorldFromNodes(_worldNodes:Network, _world_xml:XML):World {
			try {
				
				m_currentNetwork = _worldNodes;
				printDebug("Creating World...");
				var world:World = new World(0, 0, GAME_WIDTH, GAME_HEIGHT, _worldNodes.world_name, this, _world_xml);
				world.createWorld(_worldNodes.worldNodesDictionary, game_panel.getContentRectangle());
				
			} catch (error:Error) {
				throw new Error("ERROR: " + error.message + "\n" + (error as Error).getStackTrace());
				var debug:int = 0;
			}
			
			current_world_loaded = true;
			if (current_world_index == 0) {
				splash_screen_up = true;
				draw();
			}
			return world;
		}
		
	
		/**
		 * This selects a new level to be played and animates the pawn to move to the desired level (if _animate_map is true)
		 * @param	_level Level to be selected
		 * @param	_auto_board_select If true, this will load the last board played for this level (if any), if false it will load the first board
		 * @param	_animate_map True to move the pawn icon
		 */
		public function selectLevel(_level:Level, _auto_board_select:Boolean = false, _animate_map:Boolean = true):void {
			if (selecting_level) {
				return;
			}
			selecting_level = true;
			var old_level:Level = current_level;
			if (old_level) {
				for each (var board_to_remove:Board in old_level.boards) {
					if (board_to_remove.parent != null) {
						board_to_remove.parent.removeChild(board_to_remove);
					}
				}
			}
			current_level = _level;

			if (active_board != null) {
				active_board.deactivate();
				active_board.x = active_board.original_x;
				active_board.y = active_board.original_y;
				active_board.scaleX = NavigationPanel.INACTIVE_BOARD_SCALEX * active_board.original_scaleX;
				active_board.scaleY = NavigationPanel.INACTIVE_BOARD_SCALEY * active_board.original_scaleY;
			}
			active_board = null;
			if(current_level.boards && current_level.boards.length > 0)
				selectBoard(current_level.boards[0]);

			(theme_overlay.getChildAt(0) as MovieClip).gotoAndStop(1);
			
			navigation_control_panel.update();

			var new_x:Number, new_y:Number;
			if (_level.level_icon != null) {
				new_x = _level.level_icon.x;
				new_y = _level.level_icon.y;
				if (_animate_map && world_map)
					world_map.animatePawn(new_x, new_y, _auto_board_select);
					
			}
			_level.draw();
			_level.checkLevelForSuccess(false);
		}
		
		/**
		 * Called to select a board in the level, animating it to zoom in to the active board area
		 * @param	_board Board to be selected
		 */
		public function selectBoard(_board:Board):void {

			if (selected_board_is_animating)
				return;
			//drop_button.disabled = true;
			//reset_button.disabled = true;
			
			if(world_map)
				world_map.minimizeWorldMap(function ():void { } );
			
			if (board_visit_history.length > 0) {
				if (board_visit_history[board_visit_history.length - 1] != _board) {
					board_visit_history.push(_board);
					if (board_visit_history.length > 1) {
						if(game_control_panel.back_button)
							game_control_panel.back_button.disabled = false;
					} else {
						if(game_control_panel.back_button)
							game_control_panel.back_button.disabled = true;
					}
				}
			} else {
				board_visit_history.push(_board);
			}
			
			// if there is a current board, return to original location
			if (active_board != null) {
				active_board.deactivate();
				
//				var old_board:Board = active_board;
//				active_board.draw();
//				active_board.drawSubBoards(); 
//				var moveout_ani:Animation = new Animation();
//				moveout_ani.translateAndZoom(old_board, active_board.original_x, active_board.original_y, NavigationPanel.INACTIVE_BOARD_SCALEX * active_board.original_scaleX, NavigationPanel.INACTIVE_BOARD_SCALEY * active_board.original_scaleY, BOARD_TRANSITION_TIME
//				, function():void {} );
			}
			
			//does this ever happen??
			if (_board.level != current_level) {
				// switch levels
				selectLevel(_board.level);
			}
			active_board = _board;
		//	active_board.hideStaticView();
			
			_board.level.last_board_visited = _board;
			//ZZZZZZZ
			navigation_control_panel.replaceActiveBoardNavigationMap();
			
//			selected_board_is_animating = true;
			//to zoom out, get the global coordinates for the starting point and ending point
		//	var startPt:Point = new Point(_board.board_static_view.x, _board.board_static_view.y);
		//	var globalStartPt:Point = _board.board_static_view.parent.localToGlobal(startPt);
			
			var globalEndPt:Point = game_panel.globalToLocal(new Point(0,0));
			
//			var ani:Animation = new Animation();
//			ani.translateAndZoom(_board, globalEndPt.x, globalEndPt.y, ACTIVE_BOARD_SCALEX * _board.original_scaleX, ACTIVE_BOARD_SCALEY * _board.original_scaleY, BOARD_TRANSITION_TIME, function():void {
//				game_panel.update(active_board);
//
//				selected_board_is_animating = false;
//			});
			game_panel.update(active_board);
		}
		
		
		/**
		 * Gets the current world
		 */
		public function get current_world():World {
			return worlds[current_world_index];
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)"
		 * @param	_msg Text to print
		 */
		public static function printDebug(_msg:String):void {
			if (!SUPPRESS_TRACE_STATEMENTS) {
				trace(_msg);
				if (ExternalInterface.available) {
					//var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
					var reply:String = ExternalInterface.call("printDebug", _msg);
				}
			}
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)" - Specifically warnings that may be wanted even if other debug messages are not
		 * @param	_msg Warning text to print
		 */
		public static function printWarning(_msg:String):void {
			if (!SUPPRESS_TRACE_STATEMENTS) {
				trace(_msg);
				if (ExternalInterface.available) {
					//var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
					var reply:String = ExternalInterface.call("printDebug", _msg);
				}
			}
		}
		
		public static function nodeSpaceToBoardSpace(pt:Point):Point {
			return new Point (PIPE_CONSTANT_LEFT_EDGE + PIPE_CONSTANT_X_GRID_SIZE * pt.x, PIPE_CONSTANT_TOP_MARGIN + PIPE_CONSTANT_Y_GRID_SIZE * pt.y);
		}
		
		
		public function updateLinkedPipes(p:Pipe, isWide:Boolean):void
		{
			if(replay_game_panel && replay_game_panel.visible == true)
			{
				replay_game_panel.replayWorld.updateLinkedPipes(p, isWide);
				replay_game_panel.m_currentBoard.drawSubBoards();
			}
			else
			{
				for each (var world:World in worlds)
				{
					world.updateLinkedPipes(p, isWide);
				}
				active_board.drawSubBoards();
			}
		}
		
		public function gameTimerInterval(event:TimerEvent):void
		{
			if(active_board)
			{
				active_board.gameTimerInterval();
			}
		}
		
		public function replayAction(obj:ClientAction):void
		{
			if(obj.actionId == VerigameServerConstants.VERIGAME_ACTION_START)
			{
				openReplayPanel(obj);
			}
			else if(obj.actionId == VerigameServerConstants.VERIGAME_ACTION_SWITCH_BOARDS)
			{
				var boardName:String = obj.actionObject.detail[VerigameServerConstants.ACTION_PARAMETER_BOARD_NAME];
				var levelName:String = obj.actionObject.detail[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME];
				var displayedBoardName:String = replayNetwork.obfuscator.getBoardName(boardName, levelName);
				var displayedLevelName:String = replayNetwork.obfuscator.getLevelName(levelName);
				for each(var level:Level in replay_game_panel.replayWorld.levels)
				{
					if(level.level_name == displayedLevelName)
						for each(var board:Board in level.boards)
						{
							if(board.board_name == displayedBoardName)
							{
								replay_game_panel.update(board, false);
								return;
							}
						}
				}
				
			}
			else if(obj.actionId == VerigameServerConstants.VERIGAME_ACTION_CHANGE_PIPE_WIDTH)
			{
				var edgeID:String = obj.actionObject.detail[VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID];
				for each(var pipe:Pipe in replay_game_panel.m_currentBoard.pipes)
				{
					if(pipe.associated_edge.edge_id == edgeID)
					{
						pipe.pipeClick(null, false);
						return;
					}
				}
			}
			else if(obj.actionId == VerigameServerConstants.VERIGAME_ACTION_ADD_PIPE_BUZZSAW)
			{
				var edgeID1:String = obj.actionObject.detail[VerigameServerConstants.ACTION_PARAMETER_PIPE_EDGE_ID];
				for each(var pipe1:Pipe in replay_game_panel.m_currentBoard.pipes)
				{
					if(pipe1.associated_edge.edge_id == edgeID1)
					{
						buzzing = true;
						pipe1.pipeClick(null, false);
						buzzing = false;
						draw();
						return;
					} 
				}
			}
		}
		
		protected var replayXML:XML;
		protected var replayNetwork:Network;
		public function openReplayPanel(obj:ClientAction):void
		{
			if(obj.actionId == VerigameServerConstants.VERIGAME_ACTION_START)
			{
				var startInfo:Object = obj.actionObject.detail[VerigameServerConstants.ACTION_PARAMETER_START_INFO];
				var worldXML:String = startInfo["world_xml_url"];
				replayXML = new XML(worldXML);
				var nextParseState:ParseReplayState = new ParseReplayState(replayXML, this);
				nextParseState.stateLoad();
				replayNetwork = nextParseState.world_nodes;
			}
		}
		
		public function loadReplay(world_nodes:Network):void
		{
			if(replay_game_panel == null)
			{
				replay_game_panel = new GamePanel(50, 50, width - 100, height - 100, this);
				replay_game_panel.init();
				replay_game_panel.next_button.visible = false;
				replay_game_panel.exit_button.removeEventListener(MouseEvent.CLICK, onBackToMainMenuButtonClick);
				replay_game_panel.exit_button.addEventListener(MouseEvent.CLICK, closeReplayPanel);
				replay_game_panel.exit_button.y = replay_game_panel.height - 75;
				replay_game_panel.exit_button.x = replay_game_panel.width - 100;
			}
			else
				replay_game_panel.visible = true;
				
			if(replayGameOverlay == null)
			{
				var contentRect:RectangularObject = replay_game_panel.getContentRectangle();
				replayGameOverlay = new RectangularObject(contentRect.x, contentRect.y, contentRect.width, contentRect.height);
				replayGameOverlay.graphics.beginFill(0x000000, 0.0);
				replayGameOverlay.graphics.drawRect(0,0,replayGameOverlay.width, replayGameOverlay.height);
				replayGameOverlay.graphics.endFill();
			}
			
			if(replayTimeline == null)
			{
				replayTimeline = localServer.replayActions(replay_game_panel);
				replay_game_panel.addChild(replayTimeline);
			}
			
			var world:World = new World(0, 0, GAME_WIDTH, GAME_HEIGHT, world_nodes.world_name, this, replayXML);
			world.createWorld(world_nodes.worldNodesDictionary, replay_game_panel.getContentRectangle());
			replay_game_panel.replayWorld = world;
			replay_game_panel.graphics.beginFill(0x111111);
			replay_game_panel.graphics.drawRect(0,0,replay_game_panel.width, replay_game_panel.height);
			replay_game_panel.graphics.endFill();
			
			var boards_to_update:Vector.<BoardNodes> = world.simulateAllLevels();
			world.simulatorUpdateTroublePointsFS(PipeJamController.mainController.simulator, boards_to_update);
			replay_game_panel.update(world.levels[0].boards[0], false);
			replay_game_panel.m_currentBoard.title = null;
			replay_game_panel.addChild(replayGameOverlay);			
			addChild(replay_game_panel);
		}
		
		protected function closeReplayPanel(event:MouseEvent):void
		{
			replay_game_panel.visible = false;
		}
	}
}