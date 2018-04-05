package scenes.game.components
{
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import scenes.game.PipeJamGameScene;
	import starling.display.DisplayObject;
	import utils.XMath;
	
	import assets.AssetInterface;
	import assets.AssetsFont;
	
	import display.BasicButton;
	import display.FullScreenButton;
	import display.NineSliceButton;
	import display.NineSliceToggleButton;
	import display.RadioButton;
	import display.RadioButtonGroup;
	import display.SoundButton;
	import display.ZoomInButton;
	import display.ZoomOutButton;
	
	import events.MenuEvent;
	import events.NavigationEvent;
	import events.SelectionEvent;
	
	import networking.HTTPCookies;
	import networking.PlayerValidation;
	
	import scenes.BaseComponent;
	import scenes.game.display.Level;
	import scenes.game.display.TutorialLevelManager;
	import scenes.game.display.World;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.XSprite;
	
	public class SideControlPanel extends BaseComponent
	{
		protected var WIDTH:Number;
		protected var HEIGHT:Number;
		
		public static const OVERLAP:Number = 2;
		
		/** Button to bring the up the menu */
		private var m_menuButton:NineSliceButton;
		private var m_turkFinishButton:NineSliceButton;
		
		protected var scoreCircleMiddleImage:Image;
		protected var scoreCircleFrontImage:Image;
		protected var scoreImageCenter:Point;
		
		/** Navigation buttons */
		private var m_zoomInButton:BasicButton;
		private var m_zoomOutButton:BasicButton;
		private var m_fullScreenButton:BasicButton;
		
		protected var m_solver1Brush:NineSliceToggleButton;
		protected var m_solver2Brush:NineSliceToggleButton;
		protected var m_widenBrush:NineSliceToggleButton;
		protected var m_narrowBrush:NineSliceToggleButton;
		protected var m_brushButtonGroup:RadioButtonGroup;
		
		/** Text showing current score */
		private var m_scoreTextfield:TextFieldWrapper;

		/** Text showing best score */
		private var m_bestTextfield:TextFieldWrapper;
		
		/** Text showing the target percentage score */
		private var m_targetPercentTextfield:TextFieldWrapper;
		
		/** display control variables */
		private var m_panZoomAllowed:Boolean;
		
		private var addSolverArray:Array = [1,0,1,1];
		public static const OPTIMIZER1_BRUSH_CONTROL:int = 0;
		public static const OPTIMIZER2_BRUSH_CONTROL:int = 1;
		public static const WIDE_BRUSH_CONTROL:int = 2;
		public static const NARROW_BRUSH_CONTROL:int = 3;
		
		public function SideControlPanel( _width:Number, _height:Number)
		{
			WIDTH = _width;
			HEIGHT = _height;
			
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			
			var scoreCircleBackTexture:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleBack);
			var scoreCircleMiddleTexture:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleMiddle);
			var scoreCircleFrontTexture:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleFront);
			
			var scoreCircleBackImage:Image = new Image(scoreCircleBackTexture);
			scoreCircleBackImage.scaleX = scoreCircleBackImage.scaleY = 0.5;
			scoreCircleBackImage.x = 6.25;
			scoreCircleBackImage.y = 18.75;
			addChild(scoreCircleBackImage);
			
			scoreCircleMiddleImage = new Image(scoreCircleMiddleTexture);
			scoreCircleMiddleImage.x = 6.25;
			scoreCircleMiddleImage.y = 18.75;
			scoreCircleMiddleImage.scaleX = scoreCircleMiddleImage.scaleY = 0.5;
			addChild(scoreCircleMiddleImage);
			
			scoreCircleFrontImage = new Image(scoreCircleFrontTexture);
			scoreCircleFrontImage.x = 19;
			scoreCircleFrontImage.y = 32.5;
			scoreCircleFrontImage.scaleX = scoreCircleFrontImage.scaleY = 0.5;
			addChild(scoreCircleFrontImage);
			
			scoreImageCenter = new Point(scoreCircleFrontImage.x + scoreCircleFrontImage.width/2, 
												scoreCircleFrontImage.y + scoreCircleFrontImage.height/2)
			
			var background:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_Sidebar);
			var backgroundImage:Image = new Image(background);
			backgroundImage.scaleX = backgroundImage.scaleY = 0.5;
			addChild(backgroundImage);
			
			m_menuButton = ButtonFactory.getInstance().createButton(PipeJam3.TUTORIAL_DEMO ? "Level Select" : "Menu", 44, 14, 8, 8, "Return to the main menu");
			m_menuButton.addEventListener(starling.events.Event.TRIGGERED, onMenuButtonTriggered);
			m_menuButton.x = 59;
			m_menuButton.y = 23;
			m_menuButton.scaleX = .8;
			//m_menuButton.scaleY = .8;
			
			if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				m_turkFinishButton = ButtonFactory.getInstance().createButton("Finish", 44, 14, 8, 8, "Finish this task and receive confirmation code");
				m_turkFinishButton.addEventListener(starling.events.Event.TRIGGERED, onTurkFinishButtonTriggered);
				m_turkFinishButton.x = 59;
				m_turkFinishButton.y = 23;
				m_turkFinishButton.scaleX = .8;
			}
			
			var logo:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ParadoxLogoWhiteSmall);
			var logoImage:Image = new Image(logo);
			logoImage.x = m_menuButton.x;
			logoImage.y = 5;
			logoImage.width = m_menuButton.width;
			logoImage.scaleY = logoImage.scaleX;
			addChild(logoImage);
			
			m_scoreTextfield = TextFactory.getInstance().createTextField("0%", AssetsFont.FONT_UBUNTU, 50, 2.0 * 20, 30, 0xFFFFFF);
			m_scoreTextfield.touchable = false;
			m_scoreTextfield.x = 44;
			m_scoreTextfield.y = 44;
			TextFactory.getInstance().updateAlign(m_scoreTextfield, 2, 1);
			addChild(m_scoreTextfield);
			
			m_targetPercentTextfield = TextFactory.getInstance().createTextField("Target:\n0.00%", AssetsFont.FONT_UBUNTU, 30, 25, 25, 0xB1ACAA);
			m_targetPercentTextfield.touchable = false;
			m_targetPercentTextfield.x = 60;
			m_targetPercentTextfield.y = 90;
			TextFactory.getInstance().updateAlign(m_targetPercentTextfield, 2, 1);
			addChild(m_targetPercentTextfield);
			
			m_zoomInButton = new ZoomInButton();
			m_zoomInButton.addEventListener(starling.events.Event.TRIGGERED, onZoomInButtonTriggered);
			m_zoomInButton.scaleX = m_zoomInButton.scaleY = 0.6;
			XSprite.setPivotCenter(m_zoomInButton);
			m_zoomInButton.x = 24;
			m_zoomInButton.y = MiniMap.TOP_Y + 4.5;
			
			m_zoomOutButton = new ZoomOutButton();
			m_zoomOutButton.addEventListener(starling.events.Event.TRIGGERED, onZoomOutButtonTriggered);
			m_zoomOutButton.scaleX = m_zoomOutButton.scaleY = m_zoomInButton.scaleX;
			XSprite.setPivotCenter(m_zoomOutButton);
			m_zoomOutButton.x = m_zoomInButton.x;
			m_zoomOutButton.y = m_zoomInButton.y + m_zoomInButton.height + 5;
			
			
			// Note: this button is for display only, we listen for native touch events below on the stage and
			// see whether this button was clicked because Flash requires native MouseEvents to trigger fullScreen
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, checkForTriggerFullScreen);
			m_fullScreenButton = new FullScreenButton();
			m_fullScreenButton.addEventListener(starling.events.Event.TRIGGERED, onFullScreenButtonTriggered);
			m_fullScreenButton.scaleX = m_fullScreenButton.scaleY = m_zoomInButton.scaleX;
			XSprite.setPivotCenter(m_fullScreenButton);
			m_fullScreenButton.x = m_zoomOutButton.x;
			m_fullScreenButton.y = m_zoomOutButton.y + m_zoomOutButton.height + 5;
			
			m_brushButtonGroup = new RadioButtonGroup();
			addChild(m_brushButtonGroup);
			m_brushButtonGroup.y = 130;
			m_brushButtonGroup.x = 65;
			
			m_solver1Brush = createPaintBrushButton(GridViewPanel.SOLVER1_BRUSH, changeCurrentBrush, "Optimize") as NineSliceToggleButton;
		//	m_solver2Brush = createPaintBrushButton(GridViewPanel.SOLVER2_BRUSH, changeCurrentBrush, "Optimize") as NineSliceToggleButton;
			m_widenBrush = createPaintBrushButton(GridViewPanel.WIDEN_BRUSH, changeCurrentBrush, "Make Wide") as NineSliceToggleButton;
			m_narrowBrush = createPaintBrushButton(GridViewPanel.NARROW_BRUSH, changeCurrentBrush, "Make Narrow") as NineSliceToggleButton;

			m_widenBrush.y = 00;
			m_narrowBrush.y = 30;
			m_solver1Brush.y = 60;
			
			m_solver1Brush.visible = false;
			if(addSolverArray[OPTIMIZER1_BRUSH_CONTROL] == 1)
			{
				m_brushButtonGroup.addChild(m_solver1Brush);
				GridViewPanel.FIRST_SOLVER_BRUSH = GridViewPanel.SOLVER1_BRUSH;
				m_brushButtonGroup.makeActive(m_solver1Brush);
			}
			else
				GridViewPanel.FIRST_SOLVER_BRUSH = GridViewPanel.SOLVER2_BRUSH;
			
			m_widenBrush.visible = false;
			if(addSolverArray[WIDE_BRUSH_CONTROL] == 1)
			{
				m_brushButtonGroup.addChild(m_widenBrush);
			}

			m_narrowBrush.visible = false;
			if(addSolverArray[NARROW_BRUSH_CONTROL] == 1)
				m_brushButtonGroup.addChild(m_narrowBrush);
			
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			//
		}
		
		private function showTurkFinishButton():void
		{
			addChild(m_turkFinishButton);
		}
		
		public function addedToStage(event:starling.events.Event):void
		{
			if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				if (!PipeJamGameScene.inTutorial) Starling.juggler.delayCall(showTurkFinishButton, 5*60); // show after 5 minutes
			}
			else
			{
				addChild(m_menuButton);
			}
			addChild(m_zoomInButton);
			addChild(m_zoomOutButton);
		//	addChild(m_fullScreenButton); not quite ready. Next Tutorials don't draw, occasional 'too big' crashes
			addEventListener(TouchEvent.TOUCH, onTouch);
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		public function addSoundButton(m_sfxButton:SoundButton):void
		{
			m_sfxButton.scaleX = m_sfxButton.scaleY = m_zoomInButton.scaleX;
			m_sfxButton.x = m_zoomInButton.x - 3.5;
			m_sfxButton.y = m_zoomOutButton.y + m_zoomOutButton.height + 3.5;
			var test:Point = localToGlobal(new Point(m_sfxButton.x, m_sfxButton.y));
			addChild(m_sfxButton);
		}
		
		//min scale == max zoom
		public function onMaxZoomReached():void
		{
			if (m_zoomInButton) m_zoomInButton.enabled = true && m_panZoomAllowed;
			if (m_zoomOutButton) m_zoomOutButton.enabled = false && m_panZoomAllowed;
		}
		
		public function onMinZoomReached():void
		{
			if (m_zoomInButton) m_zoomInButton.enabled = false && m_panZoomAllowed;
			if (m_zoomOutButton) m_zoomOutButton.enabled = true && m_panZoomAllowed;
		}
		
		public function onZoomReset():void
		{
			if (m_zoomInButton) m_zoomInButton.enabled = true && m_panZoomAllowed;
			if (m_zoomOutButton) m_zoomOutButton.enabled = true && m_panZoomAllowed;
		}
		
		public function newLevelSelected(level:Level):void 
		{
//			m_currentLevel = level;
//			updateScore(level, true);
//			TextFactory.getInstance().updateText(m_levelNameTextfield, level.level_name);
//			TextFactory.getInstance().updateAlign(m_levelNameTextfield, 1, 1);
//			setNavigationButtonVisibility(level.getPanZoomAllowed());
//			setSolveButtonsVisibility(level.getAutoSolveAllowed());
//			updateNumNodesSelectedDisplay();
			
			m_brushButtonGroup.resetGroup();
			
			m_panZoomAllowed = level.getPanZoomAllowed();
			// NOTE: this assumes you start at a zoom that is not the min or max zoom!
			if (m_zoomInButton) m_zoomInButton.enabled = m_panZoomAllowed;
			if (m_zoomOutButton) m_zoomOutButton.enabled = m_panZoomAllowed;
		}
		
		public function removedFromStage(event:starling.events.Event):void
		{
			removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, checkForTriggerFullScreen);
		}

		public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			if (forTouch && (!visible || !touchable))
			{
				return null;
			}

			if ((localPoint.x < 18 || (localPoint.x < 51 && localPoint.y < 250)) && (XMath.square(localPoint.x - 51) + XMath.square(localPoint.y - 64) > 50 * 50))
			{
				return null;
			}
			
			return super.hitTest(localPoint, forTouch);
		}

		override protected function onTouch(event:TouchEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.MOUSE_OVER_CONTROL_PANEL));
		}
		
		private function onMenuButtonTriggered():void
		{
			if (PipeJam3.TUTORIAL_DEMO) {
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
			} else {
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
			}
		}
		
		private function onTurkFinishButtonTriggered():void
		{
			dispatchEvent(new MenuEvent(MenuEvent.TURK_FINISH));
		}
		
		private function onZoomInButtonTriggered():void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ZOOM_IN));
		}
		
		private function onZoomOutButtonTriggered():void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ZOOM_OUT));
		}
		
		protected function checkForTriggerFullScreen(event:MouseEvent):void
		{
			if (!m_fullScreenButton) return;
			if (!m_fullScreenButton.parent) return;
			var buttonTopLeft:Point = m_fullScreenButton.parent.localToGlobal(new Point(m_fullScreenButton.x - 0.5 * m_fullScreenButton.width, m_fullScreenButton.y - 0.5 * m_fullScreenButton.height));
			var buttonBottomRight:Point = m_fullScreenButton.parent.localToGlobal(new Point(m_fullScreenButton.x + 0.5 * m_fullScreenButton.width, m_fullScreenButton.y + 0.5 * m_fullScreenButton.height));
			// Need to use viewport to convert to native stage
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "buttonTopLeft:" + buttonTopLeft);
				ExternalInterface.call("console.log", "buttonBottomRight:" + buttonBottomRight);
				ExternalInterface.call("console.log", "Starling.contentScaleFactor:" + Starling.contentScaleFactor);
				ExternalInterface.call("console.log", "Starling.current.viewPort:" + Starling.current.viewPort);
				ExternalInterface.call("console.log", "event.stageX,Y:" + event.stageX + ", " + event.stageY);
			}
			buttonTopLeft.x *= Starling.contentScaleFactor;
			buttonBottomRight.x *= Starling.contentScaleFactor;
			buttonTopLeft.y *= Starling.contentScaleFactor;
			buttonBottomRight.y *= Starling.contentScaleFactor;
			buttonTopLeft.x += Starling.current.viewPort.x;
			buttonBottomRight.x += Starling.current.viewPort.x;
			buttonTopLeft.y += Starling.current.viewPort.y;
			buttonBottomRight.y += Starling.current.viewPort.y;
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", "adjbuttonTopLeft:" + buttonTopLeft);
				ExternalInterface.call("console.log", "adjbuttonBottomRight:" + buttonBottomRight);
			}
			if (event.stageX >= buttonTopLeft.x && event.stageX <= buttonBottomRight.x && event.stageY >= buttonTopLeft.y && event.stageY <= buttonBottomRight.y)
			{
				//need to mark that we are doing this, so we don't lose the selection
				World.changingFullScreenState = true;
				
				if(Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN)
				{
					Starling.current.nativeStage.displayState = StageDisplayState.FULL_SCREEN;
				}
				else
				{
					Starling.current.nativeStage.displayState = StageDisplayState.NORMAL;
					
				}
			}
		}
		
		//ignore what this does, as I handle it in the above method
		private function onFullScreenButtonTriggered(event:Event):void
		{
		}
		
		/**
		 * Updates the score on the screen
		 */
		public function updateScore(level:Level, skipAnimatons:Boolean):Number 
		{
			var maxConflicts:int = level.maxScore;
			var currentConflicts:int = MiniMap.numConflicts;
			var score:Number = ((maxConflicts-currentConflicts)/maxConflicts)*100;
			var integerPart:int = Math.floor(score);
			var decimalPart:int = (score - integerPart) * 100;
			
			var currentScore:String = score.toFixed(2) + '%';
			trace("conflict count", maxConflicts, currentConflicts, currentScore);
			
			TextFactory.getInstance().updateText(m_scoreTextfield, currentScore);
			TextFactory.getInstance().updateAlign(m_scoreTextfield, 2, 1);
			
			var integerRotation:Number = -(100-integerPart)*1.8; //180/100
			var decimalRotation:Number = -(100-decimalPart)*1.8;
			rotateToDegree(scoreCircleMiddleImage, scoreImageCenter, integerRotation);
			rotateToDegree(scoreCircleFrontImage, scoreImageCenter, decimalRotation);
			
			return score;
		}
		
		/**
		 * Updates the target percentage on the screen
		 */
		public function targetPercent(level:Level):Number
		{
			var maxConflicts:int = level.maxScore;
			var targetScore:int = level.getTargetScore();
			var targetPercentage:Number = (targetScore / maxConflicts) * 100;
			var score:Number = ((maxConflicts - MiniMap.numConflicts) / maxConflicts) * 100;
			
			var currentTarget:String = targetPercentage.toFixed(2) + '%';
			
			TextFactory.getInstance().updateText(m_targetPercentTextfield, "Target:\n" + currentTarget);
			TextFactory.getInstance().updateAlign(m_targetPercentTextfield, 2, 1);
			if (score >= targetPercentage) {
				TextFactory.getInstance().updateColor(m_targetPercentTextfield, 0x00FF00);
			} else {
				TextFactory.getInstance().updateColor(m_targetPercentTextfield, 0xB1ACAA);
			}
			
			return targetPercentage;
		}
		
		private function changeCurrentBrush(evt:starling.events.Event):void
		{
			m_brushButtonGroup.makeActive(evt.target as NineSliceToggleButton);
			dispatchEvent(new SelectionEvent(SelectionEvent.BRUSH_CHANGED, evt.target, null));
		}
		
		public function changeSelectedBrush(brush:String):void
		{
			switch(brush)
			{
				case GridViewPanel.SOLVER1_BRUSH:
					m_brushButtonGroup.makeActive(m_solver1Brush);
					break;
				case GridViewPanel.SOLVER2_BRUSH:
					m_brushButtonGroup.makeActive(m_solver2Brush);
					break;
				case GridViewPanel.WIDEN_BRUSH:
					m_brushButtonGroup.makeActive(m_widenBrush);
					break;
				case GridViewPanel.NARROW_BRUSH:
					m_brushButtonGroup.makeActive(m_narrowBrush);
					break;
			}
		}
		
		public function showVisibleBrushes(visibleBrushes:int):void
		{
			var count:int = 0;
			m_solver1Brush.visible = visibleBrushes & TutorialLevelManager.SOLVER_BRUSH ? true : false;
			if(m_solver1Brush.visible) count++;
		//	m_solver2Brush.visible = visibleBrushes & TutorialLevelManager.SOLVER_BRUSH ? true : false;
		//	if(m_solver2Brush.visible) count++;
			m_narrowBrush.visible = visibleBrushes & TutorialLevelManager.WIDEN_BRUSH ? true : false;
			if(m_narrowBrush.visible) count++;
			m_widenBrush.visible = visibleBrushes & TutorialLevelManager.NARROW_BRUSH ? true : false;
			if(m_widenBrush.visible) count++;
			
			//if only one shows, hide them all
			if(count == 1)
				m_solver1Brush.visible = m_narrowBrush.visible = m_widenBrush.visible = false;
		}
		
		public function emphasizeBrushes(emphasizeBrushes:int):void
		{
			m_narrowBrush.deemphasize();
			m_widenBrush.deemphasize();
			m_solver1Brush.deemphasize();
			if (emphasizeBrushes & TutorialLevelManager.NARROW_BRUSH)
			{
				m_narrowBrush.emphasize();
			}
			if (emphasizeBrushes & TutorialLevelManager.WIDEN_BRUSH)
			{
				m_widenBrush.emphasize();
			}
			if (emphasizeBrushes & TutorialLevelManager.SOLVER_BRUSH)
			{
				m_solver1Brush.emphasize();
			}
		}
		
//		private function onTouchHighScore(evt:TouchEvent):void
//		{
//			if (!m_bestScoreLine) return;
//			if (evt.getTouches(m_bestScoreLine, TouchPhase.ENDED).length) {
//				// Clicked, load best score!
//				dispatchEvent(new MenuEvent(MenuEvent.LOAD_HIGH_SCORE));
//			} else if (evt.getTouches(m_bestScoreLine, TouchPhase.HOVER).length) {
//				// Hover over
//				m_bestScoreLine.alpha = 1;
//			} else {
//				// Hover out
//				m_bestScoreLine.alpha = 0.8;
//			}
//		}
		
		public function setHighScores(highScoreArray:Array):void
		{
			var level:Level = World.m_world.active_level;
			if(level != null && highScoreArray != null)
			{
				var htmlString:String = "";
				var count:int = 1;
				var scoreObjArray:Array = new Array;
				var highScoreObjArray:Array = new Array;
				for each(var scoreInstance:Object in highScoreArray)
				{
					var scoreObj:Object = new Object;
					scoreObj['name'] = PlayerValidation.getUserName(scoreInstance[1], count);
					scoreObj['score'] = scoreInstance[0];
					scoreObj['assignmentsID'] = scoreInstance[2];
					scoreObj['score_improvement'] = scoreInstance[3];
					var maxConflicts:int = level.maxScore;
					var intScore:int = maxConflicts - int(scoreInstance[0]);
					var value:Number = ((maxConflicts-intScore)/maxConflicts)*100;
					if(maxConflicts != 0 && value < 101)
						scoreObj['percent'] = value.toFixed(2) + '%';
					else
						scoreObj['percent'] = "Calculating...";
					if(scoreInstance[1] == PlayerValidation.playerID)
						scoreObj.activePlayer = 1;
					else
						scoreObj.activePlayer = 0;
					
					scoreObjArray.push(scoreObj);
					highScoreObjArray.push(scoreObj);
					count++;
				}
				if(scoreObjArray.length > 0)
				{
					scoreObjArray.sort(orderHighScoresByScore);
					var scoreStr:String = JSON.stringify(scoreObjArray);
					HTTPCookies.addHighScores(scoreStr);
					
					highScoreObjArray.sort(orderHighScoresByDifference);
					var scoreStr1:String = JSON.stringify(highScoreObjArray);
					HTTPCookies.addScoreImprovementTotals(scoreStr1);
				}
				else
				{
					var nonScoreObj:Object = new Object;
					nonScoreObj['name'] = 'Not played yet';
					nonScoreObj['score'] = "";
					nonScoreObj['assignmentsID'] = "";
					nonScoreObj['score_improvement'] = "";
					nonScoreObj.activePlayer = 0;
					
					scoreObjArray.push(nonScoreObj);
					var scoreStr2:String = JSON.stringify(scoreObjArray);
					HTTPCookies.addHighScores(scoreStr2);
					scoreObjArray[0]['name'] = "";
					var scoreStr3:String = JSON.stringify(scoreObjArray)
					HTTPCookies.addScoreImprovementTotals(scoreStr3);
					
				}
				
				var currentScore:int = level.currentScore;
				var bestScore:int = level.bestScore;
				var targetScore:int = level.getTargetScore();
				var maxScoreShown:Number = Math.max(currentScore, targetScore);
				var score:String = "0";
				if(highScoreArray.length > 0)
					score = highScoreArray[0].current_score;
				
				
//				if (!m_bestScoreLine) {
//					m_bestScoreLine = new TargetScoreDisplay(score, 0.05 * GameControlPanel.SCORE_PANEL_AREA.height, Constants.RED, Constants.RED, "High Score");
//					m_bestScoreLine.addEventListener(TouchEvent.TOUCH, onTouchHighScore);
//				} else {
//					m_bestScoreLine.update(score);
//				}
//				m_bestScoreLine.x = (SCORE_PANEL_AREA.width * 2.0 / 3.0) * parseInt(score) / maxScoreShown;
//				m_scoreBarContainer.addChild(m_bestScoreLine);
			}
		}
		
		static public function orderHighScoresByScore(a:Object, b:Object):int 
		{ 
			var score1:int = parseInt(a['score']); 
			var score2:int = parseInt(b['score']); 
			if (score1 < score2) 
			{ 
				return 1; 
			} 
			else if (score1 > score2) 
			{ 
				return -1; 
			} 
			else 
			{ 
				return 0; 
			} 
		} 
		
		static public function orderHighScoresByDifference(a:Object, b:Object):int 
		{ 
			var score1:int = parseInt(a['score_improvement']); 
			var score2:int = parseInt(b['score_improvement']); 
			if (score1 < score2) 
			{ 
				return 1; 
			} 
			else if (score1 > score2) 
			{ 
				return -1; 
			} 
			else 
			{ 
				return 0; 
			} 
		}
	}
}