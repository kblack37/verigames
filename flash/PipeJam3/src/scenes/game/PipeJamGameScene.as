package scenes.game
{
	import flash.utils.Dictionary;
	
	import deng.fzip.FZipFile;
	
	import networking.GameFileHandler;
	
	import scenes.Scene;
	import scenes.game.display.ReplayWorld;
	import scenes.game.display.World;
	
	import starling.display.Button;
	import starling.events.Event;
	
	import state.LoadingState;
	import state.ParseConstraintGraphState;
	
	public class PipeJamGameScene extends Scene
	{
		protected var nextParseState:LoadingState;
		
		//takes a partial path to the files, using the base file name. -.json, -Layout.json and -Constraints.json will be assumed
		//we could obviously change it back, but this is the standard use case
		static public var demoArray:Array = new Array(
		"../SampleWorlds/p_000108_v246839"//p_000267_00011256" //L1_V4"//p_002186_00001014"
			
		);
		
		static public const DEBUG_PLAY_WORLD_ZIP:String = "";// "../lib/levels/bonus/bonus.zip";
				
		static public var inTutorial:Boolean = false;
		static public var inDemo:Boolean = false;
		static public var levelContinued:Boolean = false;
		
		
		protected var m_worldObj:Object;
		protected var m_layoutObj:Object;
		protected var m_assignmentsObj:Object;
		
		protected var m_layoutLoaded:Boolean = false;
		protected var m_assignmentsLoaded:Boolean = false;
		protected var m_worldLoaded:Boolean = false;
		
		protected var m_currentFileName:String;
		
		/** Start button image */
		protected var start_button:Button;
		private var active_world:World;
		private var m_worldGraphDict:Dictionary
		
		public static var startLoadTime:Number;
		
		public function PipeJamGameScene(game:PipeJamGame)
		{
			super(game);
		}
		
		protected override function addedToStage(event:starling.events.Event):void
		{
			super.addedToStage(event);
			m_layoutLoaded = m_worldLoaded = m_assignmentsLoaded = false;
			startLoadTime = new Date().getTime();
			GameFileHandler.loadGameFiles(onWorldLoaded, onLayoutLoaded, onConstraintsLoaded);
		}
		
		protected  override function removedFromStage(event:starling.events.Event):void
		{
			removeChildren(0, -1, true);
			active_world = null;
		}
		
		private function onLayoutLoaded(_layoutObj:Object):void
		{
			if(_layoutObj is FZipFile)
			{
				m_layoutObj = (_layoutObj as FZipFile).content.toString();
			}
			else
				m_layoutObj = _layoutObj; 
			m_layoutLoaded = true;
			checkTasksComplete();
		}
		
		private function onConstraintsLoaded(_assignmentsObj:Object):void
		{
			m_assignmentsObj = _assignmentsObj;
			m_assignmentsLoaded = true;
			checkTasksComplete();
		}
		
		//might be a single xml file, or maybe an array of three xml files
		private function onWorldLoaded(obj:Object):void
		{ 
			if(obj is Array)
			{
				m_worldObj = (obj as Array)[0];
				m_assignmentsObj = (obj as Array)[1];
				m_layoutObj = (obj as Array)[2];
				m_assignmentsLoaded = true;
				m_layoutLoaded = true;
			} else {
				m_worldObj = obj;
			}
			
			if(obj is FZipFile)
			{
				m_assignmentsLoaded = true;
				m_currentFileName = (obj as FZipFile).filename;
				m_worldObj = (obj as FZipFile).content.toString();
			}
			m_worldLoaded = true;
			checkTasksComplete();
		}
		
		
		public function parseCNF():void
		{
			parseWorldFile();
			parseLayoutFile();
		}
		
		protected function parseWorldFile():void
		{
			var lineArray:Array = m_worldObj.split('\n');
			var currentLine:int = 0;
			while((lineArray[currentLine] as String).charAt(0) == 'c')
				currentLine++;
			var countArray:Array = lineArray[currentLine].split(' ');
			var numVars:int = parseInt(countArray[2]);
			var clauseCount:int = parseInt(countArray[3]);
			var weighted:Boolean = false;
			if(countArray[1].charAt[0] == 'w')
				weighted = true;

			m_worldObj = {"id": "L10823_V16",
				"version": 1,
				"scoring": {"variables": {"type:0": 0, "type:1": 1}, "constraints": 100},
				"variables":{
				},
				"constraints":[ ]
			};
			
			var constraintsArray:Array = m_worldObj.constraints;
			for(var index:int = currentLine+1; index<lineArray.length; index++)
			{
				var clauseArray:Array = lineArray[index].split(' ');
				var lineIndex:int = 0;
				var weight:int = 100;
				if(weighted)
					weight = parseInt(clauseArray[lineIndex]);
				
				
			}
		}
		
		protected function parseLayoutFile():void
		{
			
		}
		 
		public function parseJson():void
		{
			
			if(nextParseState)
				nextParseState.removeFromParent();
			nextParseState = new ParseConstraintGraphState(m_worldObj);
			addChild(nextParseState); //to allow done parsing event to be caught
	
			this.addEventListener(ParseConstraintGraphState.WORLD_PARSED, worldComplete);
			nextParseState.stateLoad();
		}
		
		public function worldComplete(event:starling.events.Event):void
		{
			m_worldGraphDict = event.data as Dictionary;
			m_worldLoaded = true;
			this.removeEventListener(ParseConstraintGraphState.WORLD_PARSED, worldComplete);
			onWorldParsed();
		}
		
		public function checkTasksComplete():void
		{
			if(m_layoutLoaded && m_worldLoaded && m_assignmentsLoaded)
			{
				if(m_worldObj is String)
					parseCNF();
				else
					parseJson();
			}
		}
		
		protected function onWorldParsed():void
		{
			if (nextParseState) nextParseState.removeFromParent();
			try {
				PipeJamGame.printDebug("Creating World...");
				if (PipeJam3.REPLAY_DQID) {
					active_world = new ReplayWorld(m_worldGraphDict, m_worldObj, m_layoutObj, m_assignmentsObj);
				} else {
					active_world = new World(m_worldGraphDict, m_worldObj, m_layoutObj, m_assignmentsObj);
				}
			} catch (error:Error) {
				throw new Error("ERROR: " + error.message + "\n" + (error as Error).getStackTrace());
			}
			addChild(active_world);
			trace("Load Time", new Date().getTime() - startLoadTime);
		}
	}
}