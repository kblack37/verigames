package UserInterface
{
	import UserInterface.Components.*;
	import flash.text.*;
	import Utilities.Fonts;
	import VisualWorld.*;
	import NetworkGraph.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;

	
	public class GameControlPanel extends RectangularObject
	{
		/** Graphical object showing user's score */
		protected var score_pane:RectangularObject;
		
		/** Text label for SCORE */
		protected var score_title_textfield:TextField;
		
		/** Text showing current score on score_pane */
		protected var score_textfield:TextField;
		
		/** Text font, etc associated with the title "SCORE" */
		protected var score_title_textformat:TextFormat;
		
		/** Text font, etc associated with the score */
		protected var score_textformat:TextFormat;
		
		/** Button allowing user to place a buzzsaw on the current board */
		public var buzzsaw_button:ImageButton;
		
		/** Button to bring the user back to the previous board */
		public var back_button:BitmapButton;
		
		/** Button to save to XML */
		protected var exit_button:BitmapButton;
		
		/** Button to replay last level */
		protected var replay_button:BitmapButton;
		
		/** Button to save to XML */
		protected var save_button:BitmapButton;
		
		/** Button to save XML and return to end to end system */
		protected var submit_button:BitmapButton;
				
		/** Score of the player */
		protected var current_score:int = 0;
		
		/** Most recent score of the player (could be used to animate between the two, but currently is not) */
		protected var prev_score:int = 0;
		
		
		[Embed(source="../../lib/assets/ExitButton.png")]
		public var ExitButtonImageClass:Class;
		[Embed(source="../../lib/assets/ExitButtonClick.png")]
		public var ExitButtonClickImageClass:Class;
		
		[Embed(source="../../lib/assets/ReplayButton.png")]
		public var ReplayButtonImageClass:Class;
		[Embed(source="../../lib/assets/ReplayButtonClick.png")]
		public var ReplayButtonClickImageClass:Class;
		
		[Embed(source="../../lib/assets/SaveButton.png")]
		public var SaveButtonImageClass:Class;
		[Embed(source="../../lib/assets/SaveButtonClick.png")]
		public var SaveButtonClickImageClass:Class;
		
		[Embed(source="../../lib/assets/SubmitButton.png")]
		protected var SubmitButtonImageClass:Class;
		[Embed(source="../../lib/assets/SubmitButtonClick.png")]
		protected var SubmitButtonClickImageClass:Class;
		
		[Embed(source="../../lib/assets/BackButton.png")]
		protected var BackButtonImageClass:Class;
		[Embed(source="../../lib/assets/BackButtonClick.png")]
		protected var BackButtonClickImageClass:Class;
		
		protected var m_gameSystem:VerigameSystem;
		protected var m_initialized:Boolean = false;
		
		public function GameControlPanel(_x:int, _y:int, _width:uint, _height:uint, gameSystem:VerigameSystem)
		{
			super(_x, _y, _width, _height);
			m_gameSystem = gameSystem;
		}
		
		public function init():void
		{
			score_title_textfield = new TextField();
			score_textfield = new TextField();
			score_pane = new RectangularObject(0, 200, 330, 84);
			score_title_textformat = new TextFormat(Fonts.FONT_DEFAULT, 18, 0xFFFFFF, true, false, false, null, null, TextFormatAlign.CENTER);
			score_textformat = new TextFormat(Fonts.FONT_FRACTION, 45, 0x00CCFF, true, false, false, null, null, TextFormatAlign.CENTER);

			score_title_textfield.x = 0;
			score_title_textfield.y = 4;
			
			score_pane.graphics.clear();
			score_pane.graphics.beginFill(0x0, 0.0);
			score_pane.graphics.lineStyle(1.0, 0x0, 0.0);
			score_pane.graphics.drawRect(0, 0, 200, 80);
			score_pane.graphics.endFill();
			score_pane.name = "score_pane";
			score_title_textfield.embedFonts = true;
			score_title_textfield.text = "SCORE";
			score_title_textfield.setTextFormat(score_title_textformat);
			score_title_textfield.wordWrap = true;
			score_title_textfield.width = score_pane.width;
			score_title_textfield.autoSize = TextFieldAutoSize.CENTER;
			score_title_textfield.selectable = false;
			score_title_textfield.name = "score_title";
			score_pane.addChild(score_title_textfield);
			score_textfield.embedFonts = true;
			score_textfield.text = "0";
			score_textfield.setTextFormat(score_textformat);
			score_textfield.wordWrap = true;
			score_textfield.width = score_pane.width;
			score_textfield.x = 0;
			score_textfield.autoSize = TextFieldAutoSize.CENTER;
			score_textfield.y = 24;
			score_textfield.selectable = false;
			score_textfield.name = "score_textfield";
			score_pane.addChild(score_textfield);

			var merge_mc:MovieClip = new Art_SignConstructionMergeIcon();
			merge_mc.x = 0.5 * merge_mc.width;
			merge_mc.y = 0.5 * merge_mc.height;
			var buzz_button_parent:Sprite = new Sprite();
			buzz_button_parent.addChild(merge_mc);
			var merge_roll_mc:MovieClip = new Art_SignConstructionMerge();
			merge_roll_mc.x = 0.5 * merge_roll_mc.width;
			merge_roll_mc.y = 0.5 * merge_roll_mc.height;
			var buzz_roll_button_parent:Sprite = new Sprite();
			buzz_roll_button_parent.addChild(merge_roll_mc);
			buzzsaw_button = new ImageButton(65, 300, 200, 200, buzz_button_parent, buzz_roll_button_parent, m_gameSystem.buzzsawButtonClick);
			buzzsaw_button.name = "buzzsaw_button";

			var exit_button_image:Bitmap = new ExitButtonImageClass();
			var exit_button_roll_image:Bitmap = new ExitButtonClickImageClass();
			exit_button = new BitmapButton(10, 10, 80, 80, exit_button_image, exit_button_roll_image, m_gameSystem.onBackToMainMenuButtonClick);
			exit_button.name = "exit_button";
			
			var replay_button_image:Bitmap = new ReplayButtonImageClass();
			var replay_button_roll_image:Bitmap = new ReplayButtonClickImageClass();
			replay_button = new BitmapButton(90, 10, 80, 80, replay_button_image, replay_button_roll_image, m_gameSystem.onReplayButtonClick);
			replay_button.name = "replay_button";
			
			var save_button_image:Bitmap = new SaveButtonImageClass();
			var save_button_roll_image:Bitmap = new SaveButtonClickImageClass();
			save_button = new BitmapButton(10, 40, 80, 80, save_button_image, save_button_roll_image, m_gameSystem.onSaveButtonClick);
			save_button.name = "save_button";
			//		addChild(save_button);
			var submit_button_image:Bitmap = new SubmitButtonImageClass();
			var submit_button_roll_image:Bitmap = new SubmitButtonClickImageClass();
			submit_button = new BitmapButton(10, 70, 80, 80, submit_button_image, submit_button_roll_image, m_gameSystem.onSubmitButtonClick);
			submit_button.name = "submit_button";
			//		addChild(submit_button);
			var back_button_image:Bitmap = new BackButtonImageClass();
			var back_button_roll_image:Bitmap = new BackButtonClickImageClass();
			back_button = new BitmapButton(90, 55, 80, 80, back_button_image, back_button_roll_image, m_gameSystem.onBackButtonClick);
			back_button.name = "back_button";
			//		addChild(back_button);
			back_button.disabled = true;
			
			m_initialized = true;

		}
		
		public function isInitialized():Boolean
		{
			return m_initialized;
		}
		
		/**
		 * Re-calculates score and updates the score on the screen
		 */
		public function updateScore():void {
			
			/* Current scoring:
			* 
			For pipes:
			No points for any red pipe.
			For green pipes:
			10 points for every wide input pipe
			5 points for every narrow input pipe
			10 points for every narrow output pipe
			5 points for every wide output pipe
			1 point for every internal pipe, no matter what its width
			
			For solving the game:
			30 points per board solved
			- Changed this to 30 from 10 = original
			
			100 points per level solved
			1000 points per world solved
			
			For each exception to the laws of physics:
			-50 points
			*/
			
			var currentWorld:World = m_gameSystem.current_world;
			
			prev_score = current_score;
			var my_score:int = 0;
			for each (var my_level:Level in currentWorld.levels) {
				if (!my_level.failed) {
					my_score += 100;
				}
				for each (var my_board:Board in my_level.boards) {
					if (my_board.trouble_points.length == 0) {
						my_score += 30;
					}
					for each (var my_pipe:Pipe in my_board.pipes) {
						if (my_pipe.has_buzzsaw) {
							my_score -= 50;
						}
						if (!my_pipe.failed) {
							my_score += 1;
							
							var is_input:Boolean = false;
							if (my_pipe.associated_edge.from_node.kind == NodeTypes.INCOMING) {
								is_input = true;
							}
							
							var is_output:Boolean = false;
							if (my_pipe.associated_edge.to_node.kind == NodeTypes.OUTGOING) {
								is_output = true;
							}
							
							if (is_input && (my_pipe.is_wide)) {
								my_score += 10;
							} else if (is_input && (!my_pipe.is_wide)) {
								my_score += 5;
							}
							
							if (is_output && (my_pipe.is_wide)) {
								my_score += 5;
							} else if (is_output && (!my_pipe.is_wide)) {
								my_score += 10;
							}
						}
					}
				}
			}
			
			current_score = my_score;
			
			score_textfield.text = current_score.toString();
			score_textfield.setTextFormat(score_textformat);
			if (score_textfield.parent == score_pane)
				score_pane.removeChild(score_textfield);
			score_pane.addChild(score_textfield);
			
			// TODO: animate away the old score - translate up and alpha out
			
			draw();
		}
		
		
		/**
		 * Draw current graphics: background, UI, buzzsaws, etc
		 */
		public function draw():void {
			graphics.clear();
			
		
			if (score_pane.parent == this) {
				removeChild(score_pane);
			}
			addChild(score_pane);
		
			if (exit_button.parent == this) {
				setChildIndex(exit_button, numChildren - 1);
			} else {
				addChild(exit_button);
			}
			if (replay_button.parent == this) {
				setChildIndex(replay_button, numChildren - 1);
			} else {
				addChild(replay_button);
			}
			if (save_button.parent == this) {
				setChildIndex(save_button, numChildren - 1);
			} else {
				addChild(save_button);
			}
			if (submit_button.parent == this) {
				setChildIndex(submit_button, numChildren - 1);
			} else {
				addChild(submit_button);
			}
			if (back_button.parent == this) {
				setChildIndex(back_button, numChildren - 1);
			} else {
				addChild(back_button);
			}
			
			if (buzzsaw_button.parent != this) {
				addChild(buzzsaw_button);
			} else {
				setChildIndex(buzzsaw_button, numChildren - 1);
			}

			
	
		}
	}
}