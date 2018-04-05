package scenes.levelselectscene
{
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import assets.AssetInterface;
	import assets.AssetsFont;
	
	import display.BasicButton;
	import display.NineSliceBatch;
	import display.NineSliceButton;
	import display.NineSliceToggleButton;
	
	import events.MenuEvent;
	import events.MouseWheelEvent;
	import events.NavigationEvent;
	
	import feathers.controls.List;
	
	import networking.GameFileHandler;
	import networking.NetworkConnection;
	import networking.PlayerValidation;
	import networking.TutorialController;
	
	import particle.ErrorParticleSystem;
	
	import scenes.Scene;
	import scenes.game.PipeJamGameScene;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	
	public class LevelSelectScene extends Scene
	{		
		protected var background:Image;
		
		protected var levelSelectBackground:NineSliceBatch;
		protected var levelSelectInfoPanel:NineSliceBatch;
		
		protected var levelList:List = null;
		protected var matchArrayObjects:Array = null;
		protected var matchArrayMetadata:Array = null;
		protected var savedLevelsArrayMetadata:Array = null;
		
		protected var tutorial_levels_button:NineSliceToggleButton;
		protected var new_levels_button:NineSliceToggleButton;
		protected var saved_levels_button:NineSliceToggleButton;
		
		protected var select_button:NineSliceButton;
		protected var cancel_button:NineSliceButton;
		
		protected var tutorialListBox:SelectLevelList;
		protected var newLevelListBox:SelectLevelList;
		protected var savedLevelsListBox:SelectLevelList;
		protected var currentVisibleListBox:SelectLevelList;
		
		//for the info panel
		protected var infoLabel:TextFieldWrapper;
		protected var nameText:TextFieldWrapper;
		protected var numNodesText:TextFieldWrapper;
		protected var numEdgesText:TextFieldWrapper;
		protected var numConflictsText:TextFieldWrapper;
		protected var scoreText:TextFieldWrapper;
		protected var leaderText:TextFieldWrapper;
		
		public function LevelSelectScene(game:PipeJamGame)
		{
			super(game);
		}
		
		protected override function addedToStage(event:starling.events.Event):void
		{
			super.addedToStage(event);
			
			background = new Image(AssetInterface.getTexture("Game", "Background0Class"));
			background.scaleX = stage.stageWidth/background.width;
			background.scaleY = stage.stageHeight/background.height;
			background.blendMode = BlendMode.NONE;
			addChild(background);
			
			var levelSelectWidth:Number = 305;
			var levelSelectHeight:Number =  320;
			levelSelectBackground = new NineSliceBatch(levelSelectWidth, levelSelectHeight, levelSelectWidth /6.0, levelSelectHeight / 6.0, "Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML", "LevelSelectWindow");
			levelSelectBackground.x = 10;
			levelSelectBackground.y = 5;
			addChild(levelSelectBackground);
			
			var levelSelectInfoWidth:Number = 150;
			var levelSelectInfoHeight:Number =  320;
			levelSelectInfoPanel = new NineSliceBatch(levelSelectInfoWidth, levelSelectInfoHeight, levelSelectInfoWidth /6.0, levelSelectInfoHeight / 6.0, "Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML", "LevelSelectWindow");
			levelSelectInfoPanel.x = width - levelSelectInfoWidth - 10;
			levelSelectInfoPanel.y = 5;
			addChild(levelSelectInfoPanel);
			
			//select side widgets
			var buttonPadding:int = 7;
			var buttonWidth:Number = (levelSelectWidth - 2*buttonPadding)/3 - buttonPadding;
			var buttonHeight:Number = 25;
			var buttonY:Number = 30;
			
			var label:TextFieldWrapper = TextFactory.getInstance().createTextField("Select Level", AssetsFont.FONT_UBUNTU, 120, 30, 24, 0xFFFFFF);
			TextFactory.getInstance().updateAlign(label, 1, 1);
			addChild(label);
			label.x = (levelSelectWidth - label.width)/2 + levelSelectBackground.x;
			label.y = 10;
			
			infoLabel = TextFactory.getInstance().createTextField("Level Info", AssetsFont.FONT_UBUNTU, 80, 24, 18, 0xFFFFFF);
			TextFactory.getInstance().updateAlign(infoLabel, 1, 1);
			addChild(infoLabel);
			infoLabel.x = (levelSelectInfoWidth - infoLabel.width)/2 + levelSelectInfoPanel.x;
			infoLabel.y = buttonY + label.y;
			
			tutorial_levels_button = ButtonFactory.getInstance().createTabButton("Intro", buttonWidth, buttonHeight, 6, 6);
			tutorial_levels_button.addEventListener(starling.events.Event.TRIGGERED, onTutorialButtonTriggered);
			addChild(tutorial_levels_button);
			tutorial_levels_button.x = buttonPadding+12;
			tutorial_levels_button.y = buttonY + label.y;
			
			new_levels_button = ButtonFactory.getInstance().createTabButton("Current", buttonWidth, buttonHeight, 6, 6);
			new_levels_button.addEventListener(starling.events.Event.TRIGGERED, onNewButtonTriggered);
			addChild(new_levels_button);
			new_levels_button.x = tutorial_levels_button.x+buttonWidth+buttonPadding;
			new_levels_button.y = buttonY + label.y;
			
			saved_levels_button = ButtonFactory.getInstance().createTabButton("Saved", buttonWidth, buttonHeight, 6, 6);
			saved_levels_button.addEventListener(starling.events.Event.TRIGGERED, onSavedButtonTriggered);
			//addChild(saved_levels_button);
			saved_levels_button.x = new_levels_button.x+buttonWidth+buttonPadding;
			saved_levels_button.y = buttonY + label.y;
			
			select_button = ButtonFactory.getInstance().createDefaultButton("Select", 50, 18);
			select_button.addEventListener(starling.events.Event.TRIGGERED, onSelectButtonTriggered);
			addChild(select_button);
			select_button.x = levelSelectWidth-50-buttonPadding;
			select_button.y = levelSelectHeight - select_button.height - 12;	
			
			cancel_button = ButtonFactory.getInstance().createDefaultButton("Cancel", 50, 18);
			cancel_button.addEventListener(starling.events.Event.TRIGGERED, onCancelButtonTriggered);
			addChild(cancel_button);
			cancel_button.x = select_button.x - cancel_button.width - buttonPadding;
			cancel_button.y = levelSelectHeight - cancel_button.height - 12;
			
			tutorialListBox = new SelectLevelList(levelSelectWidth - 3*buttonPadding - 4, levelSelectHeight - label.height - tutorial_levels_button.height - cancel_button.height - 4*buttonPadding - 2);
			tutorialListBox.y = tutorial_levels_button.y + tutorial_levels_button.height + buttonPadding - 2;
			tutorialListBox.x = (levelSelectWidth - tutorialListBox.width)/2+levelSelectBackground.x+2;
			addChild(tutorialListBox);
			
			newLevelListBox = new SelectLevelList(levelSelectWidth - 3*buttonPadding - 4, levelSelectHeight - label.height - tutorial_levels_button.height - cancel_button.height - 4*buttonPadding - 2);
			newLevelListBox.y = tutorialListBox.y;
			newLevelListBox.x = tutorialListBox.x;
			addChild(newLevelListBox);
			
			savedLevelsListBox = new SelectLevelList(levelSelectWidth - 3*buttonPadding - 4, levelSelectHeight - label.height - tutorial_levels_button.height - cancel_button.height - 4*buttonPadding - 2);
			savedLevelsListBox.y = tutorialListBox.y;
			savedLevelsListBox.x = tutorialListBox.x;
			addChild(savedLevelsListBox);
			
			initialize();
		}
		
		protected  override function removedFromStage(event:Event):void
		{
			removeEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		public function initialize():void
		{
			tutorialListBox.setClipRect();
			savedLevelsListBox.setClipRect();
			newLevelListBox.setClipRect();
			
			if(PlayerValidation.playerLoggedIn)
			{
				savedLevelsListBox.startBusyAnimation(savedLevelsListBox);
				newLevelListBox.startBusyAnimation(newLevelListBox);
				
				GameFileHandler.levelInfoVector = null;
				GameFileHandler.completedLevelVector = null;
				GameFileHandler.savedMatchArrayObjects = null;
				GameFileHandler.getLevelMetadata(onRequestLevels);
			//	GameFileHandler.getCompletedLevels(onRequestLevels);
			//	GameFileHandler.getSavedLevels(onRequestSavedLevels);
			}
			else
			{
				new_levels_button.alphaValue = 0.9;
				saved_levels_button.alphaValue = 0.9;
				new_levels_button.enabled = false;
				saved_levels_button.enabled = false;
			}
			
			setTutorialFile(TutorialController.tutorialObj);
			
			if(!TutorialController.getTutorialController().isTutorialDone() || !PlayerValidation.playerLoggedIn)
				onTutorialButtonTriggered(null);
			else
				onNewButtonTriggered(null);
			
			addEventListener(Event.TRIGGERED, updateSelectedLevelInfo);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, false);
		}
		
		private function onTutorialButtonTriggered(e:Event):void
		{
			tutorialListBox.visible = true;
			savedLevelsListBox.visible = false;
			newLevelListBox.visible = false;
			
			tutorial_levels_button.setToggleState(true);
			new_levels_button.setToggleState(false);
			saved_levels_button.setToggleState(false);
			
			currentVisibleListBox = tutorialListBox;
			updateSelectedLevelInfo();
		}
		
		private function onNewButtonTriggered(e:Event):void
		{
			tutorialListBox.visible = false;
			savedLevelsListBox.visible = false;
			newLevelListBox.visible = true;
			
			tutorial_levels_button.setToggleState(false);
			new_levels_button.setToggleState(true);
			saved_levels_button.setToggleState(false);	
			
			currentVisibleListBox = newLevelListBox;
			updateSelectedLevelInfo();
		}
		
		private function onSavedButtonTriggered(e:Event):void
		{
			tutorialListBox.visible = false;
			savedLevelsListBox.visible = true;
			newLevelListBox.visible = false;
			
			tutorial_levels_button.setToggleState(false);
			new_levels_button.setToggleState(false);
			saved_levels_button.setToggleState(true);
			
			currentVisibleListBox = savedLevelsListBox;
			updateSelectedLevelInfo();
		}
		
		public function updateSelectedLevelInfo(e:Event = null):void
		{
			var nextTextBoxYPos:Number = tutorialListBox.y;
			if(currentVisibleListBox.currentSelection && currentVisibleListBox.currentSelection.data)
			{
				var currentSelectedLevel:Object = currentVisibleListBox.currentSelection.data;
				
				removeChild(nameText);
				if(currentSelectedLevel.hasOwnProperty("name"))
				{
					nameText = TextFactory.getInstance().createTextField("Name: " + currentSelectedLevel.name, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(nameText, 0, 1);
					addChild(nameText);
					nameText.x = levelSelectInfoPanel.x+ 10;
					nameText.y = nextTextBoxYPos; //line up with list box
					nextTextBoxYPos += 20;
				}
				
				removeChild(numNodesText);
				removeChild(numEdgesText);
				removeChild(numConflictsText);
				removeChild(scoreText);
				removeChild(leaderText);
				
				if(currentSelectedLevel.hasOwnProperty("widgets"))
				{
					numNodesText = TextFactory.getInstance().createTextField("Widgets: " + currentSelectedLevel.widgets, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(numNodesText, 0, 1);
					addChild(numNodesText);
					numNodesText.x = levelSelectInfoPanel.x + 10;
					numNodesText.y = nextTextBoxYPos; 
					nextTextBoxYPos += 20;
					
					numEdgesText = TextFactory.getInstance().createTextField("Links: " + currentSelectedLevel.links, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(numEdgesText, 0, 1);
					addChild(numEdgesText);
					numEdgesText.x = levelSelectInfoPanel.x + 10;
					numEdgesText.y = nextTextBoxYPos; 
					nextTextBoxYPos += 20;
					
					numConflictsText = TextFactory.getInstance().createTextField("Jams: " + currentSelectedLevel.conflicts, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(numConflictsText, 0, 1);
					addChild(numConflictsText);
					numConflictsText.x = levelSelectInfoPanel.x + 10;
					numConflictsText.y = nextTextBoxYPos;
					nextTextBoxYPos += 20;
					
					scoreText = TextFactory.getInstance().createTextField("Score: " + currentSelectedLevel.current_score, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(scoreText, 0, 1);
					addChild(scoreText);
					scoreText.x = levelSelectInfoPanel.x + 10;
					scoreText.y = nextTextBoxYPos; 
					nextTextBoxYPos += 20;
					
					leaderText = TextFactory.getInstance().createTextField("Leader: " + currentSelectedLevel.leader, AssetsFont.FONT_UBUNTU, 140, 18, 12, 0xFFFFFF);
					TextFactory.getInstance().updateAlign(leaderText, 0, 1);
					addChild(leaderText);
					leaderText.x = levelSelectInfoPanel.x + 10;
					leaderText.y = nextTextBoxYPos;
					nextTextBoxYPos += 20;
				}

					if(e && e.data && e.data.hasOwnProperty("tapCount") && e.data.tapCount == 2)
					onSelectButtonTriggered(e);
			}
		}
		
		protected function onMouseWheel(event:MouseEvent):void
		{
			var delta:Number = event.delta;
			currentVisibleListBox.scrollPanel(-delta);
		}
		
		private function onCancelButtonTriggered(e:Event):void
		{
			dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
		}
		
		private function onSelectButtonTriggered(ev:Event):void
		{
			var dataObj:Object = currentVisibleListBox.currentSelection.data;
			dispatchEventWith(MenuEvent.TOGGLE_SOUND_CONTROL, true, true);
			
			if(currentVisibleListBox == tutorialListBox)
			{
				TutorialController.getTutorialController().fromLevelSelectList = true;
				PipeJamGameScene.inTutorial = true;
			}
			else
				PipeJamGameScene.inTutorial = false;
			
			if (dataObj) {
				if (dataObj.hasOwnProperty("levelId") && PipeJamGameScene.inTutorial) {
					//PipeJamGameScene.inDemo = false;
					PipeJamGame.levelInfo.name = dataObj.name;
					PipeJamGame.levelInfo.id = dataObj.levelId;
					PipeJamGame.levelInfo.tutorialLevelID = dataObj.levelId;
					dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
				}
			}
		}
		
		protected function onRequestLevels(result:int, o:Object = null):void
		{
			try{
				if(result == NetworkConnection.EVENT_COMPLETE)
				{
					GameFileHandler.completedLevelVector = new Vector.<Object>;
					
					if(GameFileHandler.levelInfoVector != null && GameFileHandler.completedLevelVector != null)
						onGetLevelMetadataComplete();
				}
			}
			catch(err:Error) //probably a parse error in trying to decode the RA response
			{
				trace("ERROR: failure in loading levels " + err);
				newLevelListBox.stopBusyAnimation();
			}
		}
		
		protected function onRequestSavedLevels(result:int):void
		{
			try{
				if(result == NetworkConnection.EVENT_COMPLETE)
				{
					if(GameFileHandler.savedMatchArrayObjects != null)
						onGetSavedLevelsComplete();
				}
			}
			catch(err:Error) //probably a parse error in trying to decode the RA response
			{
				trace("ERROR: failure in loading levels " + err);
				savedLevelsListBox.stopBusyAnimation();
			}
		}
		
		protected function onGetLevelMetadataComplete():void
		{
			matchArrayMetadata = new Array;
			var i:int = 0;
			var completedLevelDictionary:Dictionary = new Dictionary();
			for(i = 0; i<GameFileHandler.completedLevelVector.length; i++)
			{
				var completedLevel:Object = GameFileHandler.completedLevelVector[i];
				completedLevelDictionary[completedLevel.levelID] = completedLevel;
			}
			
			for(i = 0; i<GameFileHandler.levelInfoVector.length; i++)
			{
				var match:Object = GameFileHandler.levelInfoVector[i];
				matchArrayMetadata.push(match);
				match.unlocked = true;
				if(completedLevelDictionary[match.xmlID] != null)
					match.checked = true;
			}
			
			//alphabetize array
			matchArrayMetadata.sortOn('name');
			setNewLevelInfo(matchArrayMetadata); 
			
			onRequestLevelsComplete();
		}
		
		protected function onGetSavedLevelsComplete():void
		{		
			savedLevelsArrayMetadata = new Array;
			for(var i:int = 0; i<GameFileHandler.savedMatchArrayObjects.length; i++)
			{
				var match:Object = GameFileHandler.savedMatchArrayObjects[i];
				savedLevelsArrayMetadata.push(match);
				match.unlocked = true;
			}
			
			setSavedLevelsInfo(savedLevelsArrayMetadata);
			
			onRequestLevelsComplete();
		}
		
		protected function onRequestLevelsComplete():void
		{
			if(GameFileHandler.levelInfoVector != null && GameFileHandler.completedLevelVector != null && newLevelListBox != null)
				newLevelListBox.stopBusyAnimation();
			
			if(GameFileHandler.savedMatchArrayObjects != null && savedLevelsListBox != null)
				savedLevelsListBox.stopBusyAnimation();
		}
		
		protected static var levelCount:int = 1;
		protected function fileLevelNameFromMatch(match:Object, levelMetadataVector:Vector.<Object>, savedObjArray:Array):Object
		{
			//find the level record based on id, and then find the levelID match
			var levelNotFound:Boolean = true;
			var index:int = 0;
			var foundObj:Object;
			
			var objID:String;
			var matchID:String;
			if(match.levelId is String)
				matchID = match.levelId;
			else if(match.emptorId is String) //work around for hopefully temporary bug in RA
				matchID = match.emptorId;
			else
				matchID = match.levelId.$oid;
			
			while(levelNotFound)
			{
				if(index >= levelMetadataVector.length)
					break;
				
				foundObj = levelMetadataVector[index];
				if(foundObj.levelId is String)
					objID = foundObj.levelId;
				else
					objID = foundObj.levelId.$oid;
				
				if(matchID == objID)
				{
					levelNotFound = false;
					break;
				}
				index++;
			}
			if(levelNotFound)
			{
				//TODO -report error? or just skip?
				return null;
			}
			
			if(foundObj.levelId is String)
				objID = foundObj.levelId;
			else
				objID = foundObj.levelId.$oid;
			
			for(var i:int=0; i<levelMetadataVector.length;i++)
			{
				var levelObj:Object = levelMetadataVector[i];
				//we don't want ourselves
				//	if(levelObj == foundObj) there was a time when the RA info was stored here too, and as such we needed to skip this
				//		continue;
				var levelObjID:String;
				if(levelObj.levelId is String)
					levelObjID = levelObj.levelId;
				else
					levelObjID = levelObj.levelId.$oid;
				
				if(objID == levelObjID)
				{
					savedObjArray.push(levelObj);
					return levelObj;
				}
			}
			
			return null;
		}
		
		protected function onLevelSelected(e:starling.events.Event):void
		{
			PipeJamGame.levelInfo = new matchArrayMetadata[levelList.selectedIndex];
			
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		public function setNewLevelInfo(_newLevelInfo:Array):void
		{
			this.newLevelListBox.setButtonArray(_newLevelInfo, false);
		}
		
		public function setSavedLevelsInfo(_savedLevelInfo:Array):void
		{
			this.savedLevelsListBox.setButtonArray(_savedLevelInfo, true);
		}
		
		public function setTutorialFile(tutorialObj:Object):void
		{
			var tutorialLevels:Array = tutorialObj["levels"];
			var tutorialController:TutorialController = TutorialController.getTutorialController();
			var tutorialArray:Array = new Array;
			for (var i:int = 0; i < tutorialLevels.length; i++)
			{
				var levelObj:Object = tutorialLevels[i];
				var obj:Object = new Object;
				obj.levelId = levelObj["qid"].toString();
				obj.name = levelObj["id"].toString();
				
				//unlock all that user should be able play, check the ones they have played
				if(PipeJam3.RELEASE_BUILD)
				{
					obj.unlocked = tutorialController.tutorialShouldBeUnlocked(obj.levelId);
					obj.checked = tutorialController.isTutorialLevelCompleted(obj.levelId);
				}
				else
				{
					obj.unlocked = true;
					obj.checked = true;
					
				}
				tutorialArray.push(obj);
			}
			tutorialListBox.setButtonArray(tutorialArray, false);
		}
	}
}

