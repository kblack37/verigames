package UserInterface
{
	import Events.CGSServerLocal;
	
	import System.VerigameServerConstants;
	
	import UserInterface.Components.BitmapButton;
	import UserInterface.Components.ImageButton;
	import UserInterface.Components.RectangularObject;
	
	import Utilities.Fonts;
	
	import VisualWorld.Board;
	import VisualWorld.VerigameSystem;
	import VisualWorld.World;
	
	import cgs.server.logging.actions.ClientAction;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.text.TextField;
	
	public class GamePanel extends RectangularObject
	{
		protected var m_gameSystem:VerigameSystem;
		protected var m_initialized:Boolean = false;
		public var m_currentBoard:Board = null;
		
		protected var m_currentLevel:uint = 0;
		
		public var m_gameSurface:RectangularObject;
		protected var m_gameSurfaceBorder:uint = 25;
		
		protected var back_button:BitmapButton;
		public var next_button:BitmapButton;
		public var exit_button:BitmapButton;
		
		protected var textFieldVector:Vector.<TextField> = null;
		
		/** The animated buzzsaw asset */
		[Embed(source = '../../lib/assets/NextButtonUp.png')]
		protected var NextLevelButtonClass:Class;

		[Embed(source = '../../lib/assets/NextButtonOver.png')]
		protected var NextLevelClickButtonClass:Class;

		/** The animated buzzsaw asset */
		[Embed(source = '../../lib/assets/BackButtonUp.png')]
		protected var BackLevelButtonClass:Class;

		[Embed(source = '../../lib/assets/BackButtonOver.png')]
		protected var BackLevelClickButtonClass:Class;
		
		[Embed(source = '../../lib/assets/ExitButton.png')]
		protected var ExitButtonClass:Class;
		
		[Embed(source = '../../lib/assets/ExitButtonClick.png')]
		protected var ExitClickButtonClass:Class;
		
		protected var nextButtonBottomOffset:int;
		protected var backButtonBottomOffset:int;
		protected var buttomBottomBorder:int = 60;
		
		protected var buzzsaw_button:ImageButton;
		public var replayWorld:World;
		
		public function GamePanel(_x:int, _y:int, _width:uint, _height:uint, gameSystem:VerigameSystem)
		{
			super(_x, _y, _width, _height);
			m_gameSystem = gameSystem;
			
			m_gameSurface = new RectangularObject(m_gameSurfaceBorder, m_gameSurfaceBorder, width-(2*m_gameSurfaceBorder), height-(2*m_gameSurfaceBorder) - Board.ACTIVE_FONT_SIZE - m_gameSurfaceBorder);
			addChild(m_gameSurface);
			
			var back_button_image:Bitmap = new BackLevelButtonClass();
			var back_button_roll_image:Bitmap = new BackLevelClickButtonClass();
			backButtonBottomOffset = back_button_image.height + buttomBottomBorder;
			back_button = new BitmapButton(10, m_gameSurface.height - back_button_image.height - 60, back_button_image.width, back_button_image.height,
										back_button_image, back_button_roll_image, onBackButtonClickEvent);
			back_button.name = "back_button";
			back_button.visible = false;
			m_gameSurface.addChild(back_button);
			
			var next_button_image:Bitmap = new NextLevelButtonClass();
			var next_button_roll_image:Bitmap = new NextLevelClickButtonClass();
			nextButtonBottomOffset = next_button_image.height + buttomBottomBorder;
			next_button = new BitmapButton(m_gameSurface.width-next_button_image.width - 10, m_gameSurface.height - nextButtonBottomOffset,
				next_button_image.width, next_button_image.height, next_button_image, next_button_roll_image, onNextButtonClickEvent);
			next_button.name = "next_button";
			next_button.visible = true;
			m_gameSurface.addChild(next_button);
			
			var exit_button_image:Bitmap = new ExitButtonClass();
			var exit_button_roll_image:Bitmap = new ExitClickButtonClass();
			exit_button = new BitmapButton(10, 10, exit_button_image.width, exit_button_image.height, exit_button_image, exit_button_roll_image, m_gameSystem.onBackToMainMenuButtonClick);
			exit_button.name = "exit_button";
			m_gameSurface.addChild(exit_button);
			
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
			buzzsaw_button = new ImageButton(10, m_gameSurface.height/2, 100, 100, buzz_button_parent, buzz_roll_button_parent, m_gameSystem.buzzsawButtonClick);
			buzzsaw_button.name = "buzzsaw_button";
			m_gameSurface.addChild(buzzsaw_button);
		}
		
		protected function onBackButtonClickEvent(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(m_currentLevel > 0)
			{
				m_gameSystem.selecting_level = false;
				m_currentLevel--;
				m_gameSystem.selectLevel(m_gameSystem.worlds[0].findLevel(m_currentLevel));
	
				if(m_gameSystem.worlds[0].levels.length > m_currentLevel+1)
					next_button.visible = true;
				if( m_currentLevel == 0)
					back_button.visible = false;
			}
			
			//make sure this is in the right place
			// if you get to the last screen and then go back, you need to move this
			exit_button.x = 10;
			exit_button.y = 10;

			
			m_gameSystem.selecting_level = false;
		}
		
		protected function onNextButtonClickEvent(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(m_currentLevel+1 < m_gameSystem.worlds[0].levels.length)
			{
			
				m_gameSystem.selecting_level = false;
				m_currentLevel++;
				m_gameSystem.selectLevel(m_gameSystem.worlds[0].findLevel(m_currentLevel));

				//hide until level completed
				if(m_gameSystem.active_board.level.failed == true)
					next_button.visible = false;
					
				if(m_gameSystem.worlds[0].levels.length == m_currentLevel+1)
					next_button.visible = false;
				
				if( m_currentLevel > 0)
					back_button.visible = true;		
			}
			
			m_gameSystem.selecting_level = false;
		}
	
		
		public function init():void
		{
			m_initialized = true;
			
		}
		
		public function isInitialized():Boolean
		{
			return m_initialized;
		}
		
		public function getContentRectangle():RectangularObject
		{
			return m_gameSurface;
		}
		
		public function setGameSize(fullScreen:Boolean = false):void
		{
			m_currentLevel = 0;
			
			if(fullScreen)
			{
				this.x = 0;
				this.y = 0;
				this.width = VerigameSystem.GAME_WIDTH;
				this.height = VerigameSystem.GAME_HEIGHT;
				m_gameSurface.width =  width-(2*m_gameSurfaceBorder);
				m_gameSurface.height = height-(2*m_gameSurfaceBorder) - 2*Board.ACTIVE_FONT_SIZE - m_gameSurfaceBorder;
				next_button.visible = false;
				exit_button.visible = true;
			}
			else
			{
				next_button.visible = false;
				back_button.visible = false;
				exit_button.visible = false;
			}
		}
		
		public function levelCompleted():void
		{
			if(m_gameSystem.worlds[0].levels.length > m_currentLevel+1)
				next_button.visible = true;
			else
			{
				exit_button.x = next_button.x;
				exit_button.y = next_button.y;
			}
		}
		
		//logEvent = false if this is a replay event
		public function update(board:Board, logEvent:Boolean = true):void
		{
			if(!m_initialized)
				return;
			
			if (VerigameSystem.LOGGING_ON && logEvent) {
				var switchBoardAction:ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_SWITCH_BOARDS);
				switchBoardAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_BOARD_NAME, this.m_gameSystem.m_currentNetwork.obfuscator.getReverseBoardName(board.board_name));
				switchBoardAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME, this.m_gameSystem.m_currentNetwork.obfuscator.getReverseLevelName(board.level.level_name));
				CGSServerLocal.logQuestAction(switchBoardAction);
			}
			
			if(m_currentBoard)
			{
				if(m_currentBoard.parent)
					m_currentBoard.parent.removeChild(m_currentBoard);
			}
			m_currentBoard = board;
			
			if(m_currentBoard)
			{
				buzzsaw_button.visible = false;
				
				//get rid of old and create new
				if(textFieldVector)
				{
					while(textFieldVector.length > 0)
					{
						var textFieldItem:TextField = textFieldVector.pop();
						if(textFieldItem.parent)
							textFieldItem.parent.removeChild(textFieldItem);
					}
				}
				textFieldVector = new Vector.<TextField>;
					
				var displayMetadata:XML = m_currentBoard.m_boardNodes.metadata["display"];
				
				if(displayMetadata)
				{
					displayTextMetadata(displayMetadata);
					
					
					for each (var buzzsawBlock:XML in displayMetadata["buzzsaw"])
					{
						var visibilityCheck:Boolean = buzzsawBlock.attribute["visible"];
						buzzsaw_button.visible = visibilityCheck;
					}
				}
				m_currentBoard.x = 0;
				m_currentBoard.y = 0;
				m_currentBoard.scaleX = m_gameSurface.width/m_currentBoard.width;
				if(m_currentBoard.scaleX < .2)
					m_currentBoard.scaleX = .2; //completely arbitrary, currently
				//m_currentBoard.scaleY = m_currentBoard.scaleX;
				m_currentBoard.scaleY = m_gameSurface.height/m_currentBoard.height;
				m_gameSurface.addChild(m_currentBoard);
				m_currentBoard.activate();
				draw();
			}
		}
		
		public function displayTextMetadata(textParent:XML):void
		{
			for each (var textBlock:XML in textParent["text-block"])
			{
				var textList:XMLList = textBlock["text"];
				var textField:TextField = new TextField();
				textField.text = textList[0]; //should only be one
				textField.x = textBlock.attribute("x");
				textField.y = textBlock.attribute("y");
				textField.autoSize = TextFieldAutoSize.LEFT;
				if(textBlock["font"])
				{
					var fontInfo:XML = textBlock["font"][0];
					
					var fontSize:uint = 10;
					if(fontInfo.attribute("size").length() > 0)
						fontSize = fontInfo.attribute("size");
					
					var fontFace:String = Fonts.FONT_DEFAULT;
					if(fontInfo.attribute("face").length() > 0)
						fontFace = fontInfo.attribute("face");
					
					var color:Number =  0xFFFFFF;
					if(fontInfo.attribute("color").length() > 0)
						color = fontInfo.attribute("color");
					
					var tf:TextFormat = new TextFormat(fontFace, fontSize, color);
					textField.setTextFormat(tf);
				}
				textFieldVector.push(textField);
			}
		}
		
		public function draw():void
		{
			m_currentBoard.draw();
			m_currentBoard.drawSubBoards();
			
			if(next_button.parent == m_gameSurface)
				m_gameSurface.removeChild(next_button);
			m_gameSurface.addChild(next_button);
			
			next_button.x = m_gameSurface.width-next_button.width - 10;
			next_button.y = m_gameSurface.height - nextButtonBottomOffset;
			
			if(back_button.parent == m_gameSurface)
				m_gameSurface.removeChild(back_button);
			m_gameSurface.addChild(back_button);
			
			back_button.y = m_gameSurface.height - backButtonBottomOffset;
			
			if(exit_button.parent == m_gameSurface)
				m_gameSurface.removeChild(exit_button);
			m_gameSurface.addChild(exit_button);
			
			if(buzzsaw_button.parent == m_gameSurface)
				m_gameSurface.removeChild(buzzsaw_button);
			m_gameSurface.addChild(buzzsaw_button);
			
			for each(var tf:TextField in textFieldVector)
			{
				if(tf.parent)
					tf.parent.removeChild(tf);
				m_gameSurface.addChild(tf);
			}
		}
	}
}