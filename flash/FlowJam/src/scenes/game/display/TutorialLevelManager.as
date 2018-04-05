package scenes.game.display 
{
	import display.NineSliceBatch;
	import events.EdgeContainerEvent;
	import events.TutorialEvent;
	import graph.PropDictionary;
	import starling.core.Starling;
	import networking.TutorialController;
	
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class TutorialLevelManager extends EventDispatcher
	{
		// This is the order the tutorials appers in:
		public static const WIDGET_TUTORIAL:String = "widget";
		public static const WIDGET_PRACTICE_TUTORIAL:String = "widgetpractice";
		public static const LOCKED_TUTORIAL:String = "locked";
		public static const LINKS_TUTORIAL:String = "links";
		public static const JAMS_TUTORIAL:String = "jams";
		public static const WIDEN_TUTORIAL:String = "widen";
		public static const OPTIMIZE_TUTORIAL:String = "optimize";
		public static const ZOOM_PAN_TUTORIAL:String = "zoompan";
		public static const LAYOUT_TUTORIAL:String = "layout";
		public static const GROUP_SELECT_TUTORIAL:String = "groupselect";
		public static const CREATE_JOINT_TUTORIAL:String = "createjoint";
		public static const SKILLS_A_TUTORIAL:String = "skillsa";
		public static const SKILLS_B_TUTORIAL:String = "skillsb";
		// Not currently used:
		public static const COLOR_TUTORIAL:String = "color";
		
		private var m_tutorialTag:String;
		private var m_levelStarted:Boolean = false;
		private var m_levelFinished:Boolean = false;
		// If default text is ovewridden, store here (otherwise if null, use default text)
		private var m_currentTutorialText:TutorialManagerTextInfo;
		private var m_currentToolTipsText:Vector.<TutorialManagerTextInfo>;
		
		public function TutorialLevelManager(_tutorialTag:String)
		{
			m_tutorialTag = _tutorialTag;
			switch (m_tutorialTag) {
				case WIDGET_TUTORIAL:
				case WIDGET_PRACTICE_TUTORIAL:
				case LOCKED_TUTORIAL:
				case LINKS_TUTORIAL:
				case JAMS_TUTORIAL:
				case WIDEN_TUTORIAL:
				case OPTIMIZE_TUTORIAL:
				case ZOOM_PAN_TUTORIAL:
				case LAYOUT_TUTORIAL:
				case GROUP_SELECT_TUTORIAL:
				case CREATE_JOINT_TUTORIAL:
				case SKILLS_A_TUTORIAL:
				case SKILLS_B_TUTORIAL:
					break;
				default:
					throw new Error("Unknown Tutorial encountered: " + m_tutorialTag);
			}
		}
		
		override public function dispatchEvent(event:Event):void
        {
			// Don't allow events to dispatch if stopped playing level
			if (m_levelStarted) super.dispatchEvent(event);
		}
		
		public function startLevel():void
		{
			m_currentTutorialText = null;
			m_currentToolTipsText = null;
			m_levelFinished = false;
			m_levelStarted = true;
		}
		
		public function endLevel():void
		{
			m_currentTutorialText = null;
			m_currentToolTipsText = null;
			m_levelFinished = true;
			m_levelStarted = false;
		}
		
		public function onSegmentMoved(event:EdgeContainerEvent, textPointingAtSegment:Boolean = false):void
		{
			switch (m_tutorialTag) {
				case CREATE_JOINT_TUTORIAL:
					if (!m_levelFinished && textPointingAtSegment) {
						m_levelFinished = true;
						Starling.juggler.delayCall(function():void {
							dispatchEvent(new TutorialEvent(TutorialEvent.SHOW_CONTINUE));
						}, 0.5);
					}
				break;
			}
		}
		
		public function onJointCreated(event:EdgeContainerEvent):void
		{
			switch (m_tutorialTag) {
				case CREATE_JOINT_TUTORIAL:
					var toPos:String = (event.segment.m_endPt.y != 0) ? NineSliceBatch.LEFT : NineSliceBatch.TOP;
					m_currentTutorialText = new TutorialManagerTextInfo(
						"Drag the new Link segment",
						null,
						pointToEdgeSegment(event.container.m_id, event.segmentIndex),
						toPos, NineSliceBatch.CENTER);
					var txtVec:Vector.<TutorialManagerTextInfo> = new Vector.<TutorialManagerTextInfo>();
					txtVec.push(m_currentTutorialText);
					dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TUTORIAL_TEXT, "", true, txtVec));
					break;
			}
		}
		
		public function onWidgetChange(idChanged:String, propChanged:String, propValue:Boolean):void
		{
			var tips:Vector.<TutorialManagerTextInfo> = new Vector.<TutorialManagerTextInfo>();
			var tip:TutorialManagerTextInfo, widthTxt:String;
			switch (m_tutorialTag) {
				case JAMS_TUTORIAL:
					var jammed:Boolean = (propChanged == PropDictionary.PROP_NARROW && !propValue);
					var jamText:String = "Jam cleared! +" + 100 /* TODO: get from level*/ + " points.";
					if (jammed) {
						tip = new TutorialManagerTextInfo("Jam! Wide Link to\nNarrow Widget", null, pointToClash("var_0 -> type_0__var_0"), NineSliceBatch.BOTTOM_LEFT, NineSliceBatch.CENTER);
						tips.push(tip);
						jamText = "JAMS happen when wide Links enter\n" +
						"narrow Widgets. This Jam penalizes\n" +
						"your score by " + 100 /* TODO: get from level*/ + " points.";
					}
					m_currentToolTipsText = tips;
					dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
					m_currentTutorialText = new TutorialManagerTextInfo(
						jamText,
						null,
						pointToClash("var_0 -> type_0__var_0"),
						NineSliceBatch.TOP_RIGHT, NineSliceBatch.TOP);
					var txtVec:Vector.<TutorialManagerTextInfo> = new Vector.<TutorialManagerTextInfo>();
					txtVec.push(m_currentTutorialText);
					dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TUTORIAL_TEXT, "", true, txtVec));
					break;
				case LINKS_TUTORIAL:
					var edgeId:String;
					if (idChanged == "var_1") {
						edgeId = "var_1 -> type_1__var_1";
					} else if (idChanged == "var_0") {
						edgeId = "var_0 -> type_1__var_0";
					} else {
						break;
					}
					widthTxt = !propValue ? "Wide Link" : "Narrow Link";
					tip = new TutorialManagerTextInfo(widthTxt, null, pointToEdge(edgeId), NineSliceBatch.BOTTOM_RIGHT, NineSliceBatch.RIGHT);
					tips.push(tip);
					m_currentToolTipsText = tips;
					dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
					break;
				case WIDEN_TUTORIAL:
					if (idChanged == "var_0") {
						if (propValue) {
							tip = new TutorialManagerTextInfo("Jam! Wide Link to\nNarrow Widget", null, pointToClash("type_1__var_0 -> var_0"), NineSliceBatch.BOTTOM_LEFT, NineSliceBatch.CENTER);
							tips.push(tip);
						}
						m_currentToolTipsText = tips;
						dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
					}
					break;
			}
		}
		
		public function onGameNodeMoved(updatedGameNodes:Vector.<GameNode>):void
		{
			var tips:Vector.<TutorialManagerTextInfo> = new Vector.<TutorialManagerTextInfo>();
			switch (m_tutorialTag) {
				case GROUP_SELECT_TUTORIAL:
					if (!m_levelFinished && (updatedGameNodes.length > 1)) {
						m_levelFinished = true;
						Starling.juggler.delayCall(function():void {
							dispatchEvent(new TutorialEvent(TutorialEvent.SHOW_CONTINUE));
						}, 0.5);
					}
					break;
				case LAYOUT_TUTORIAL:
					for (var i:int = 0; i < updatedGameNodes.length; i++) {
						if (updatedGameNodes[i].m_id == "var_3") {
							m_currentToolTipsText = tips;
							dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
							break;
						}
					}
					break;
			}
		}
		
		public function getSolveButtonsAllowed():Boolean
		{
			switch (m_tutorialTag) {
				default:
					return false;
			}
			return true;
		}
		
		public function getPanZoomAllowed():Boolean
		{
			switch (m_tutorialTag) {
				case WIDGET_TUTORIAL:
				case WIDGET_PRACTICE_TUTORIAL:
				case LOCKED_TUTORIAL:
				case LINKS_TUTORIAL:
				case JAMS_TUTORIAL:
				case WIDEN_TUTORIAL:
				case OPTIMIZE_TUTORIAL:
					return false;
			}
			return true;
		}
		
		public function getMiniMapShown():Boolean
		{
			switch (m_tutorialTag) {
				case WIDGET_TUTORIAL:
				case WIDGET_PRACTICE_TUTORIAL:
				case LOCKED_TUTORIAL:
				case LINKS_TUTORIAL:
				case JAMS_TUTORIAL:
				case WIDEN_TUTORIAL:
				case OPTIMIZE_TUTORIAL:
				case ZOOM_PAN_TUTORIAL:
				case LAYOUT_TUTORIAL:
				case GROUP_SELECT_TUTORIAL:
				case CREATE_JOINT_TUTORIAL:
				case SKILLS_A_TUTORIAL:
					return false;
			}
			return true;
		}
		
		public function getLayoutFixed():Boolean
		{
			switch (m_tutorialTag) {
				case WIDGET_TUTORIAL:
				case WIDGET_PRACTICE_TUTORIAL:
				case LOCKED_TUTORIAL:
				case LINKS_TUTORIAL:
				case JAMS_TUTORIAL:
				case WIDEN_TUTORIAL:
				case OPTIMIZE_TUTORIAL:
				case ZOOM_PAN_TUTORIAL:
					return true;
			}
			return false;
		}
		
		public function getStartScaleFactor():Number
		{
			switch (m_tutorialTag) {
				case JAMS_TUTORIAL:
					return 1.1;
				case OPTIMIZE_TUTORIAL:
					return 1.35;
				case ZOOM_PAN_TUTORIAL:
					return 3.0;
				case LAYOUT_TUTORIAL:
				case GROUP_SELECT_TUTORIAL:
					return 0.6;
				case SKILLS_A_TUTORIAL:
					return 1.4;
				case SKILLS_B_TUTORIAL:
					return 3.0;
			}
			return 1.0;
		}
		
		public function getStartPanOffset():Point
		{
			switch (m_tutorialTag) {
				case LOCKED_TUTORIAL:
					return new Point(0, -5);// move up by 5px (pan down)
				case LINKS_TUTORIAL:
					return new Point(15, -10);//move right 15px (pan left) and up (pan down) 10px
				case JAMS_TUTORIAL:
					return new Point(0, -5);// move up by 5px (pan down)
				case WIDEN_TUTORIAL:
					return new Point(0, -10);// move up by 10px
				case OPTIMIZE_TUTORIAL:
					return new Point(0, -10);// move up by 10px (pan down)
				case ZOOM_PAN_TUTORIAL:
					return new Point( -10, 10);// move left 10px, down 10px
				case LAYOUT_TUTORIAL:
					return new Point(0, 5);// move down by 5px (pan up)
				case GROUP_SELECT_TUTORIAL:
					return new Point(0, 25);// move down by 25px
				case SKILLS_A_TUTORIAL:
					return new Point(0, -15);// move up by 15px
				case SKILLS_B_TUTORIAL:
					return new Point(75, 75);// pan left 75 px, up by 75px
			}
			return new Point();
		}
		
		private function pointToNode(name:String):Function
		{
			return function(currentLevel:Level):DisplayObject { return currentLevel.getNode(name); };
		}
		
		private function pointToEdge(name:String):Function
		{
			return function(currentLevel:Level):DisplayObject { return currentLevel.getEdgeContainer(name); };
		}
		
		private function pointToEdgeSegment(edgeName:String, segmentIndex:int):Function
		{
			return function(currentLevel:Level):DisplayObject {
				var container:GameEdgeContainer = currentLevel.getEdgeContainer(edgeName);
				if (container != null) return container.getSegment(segmentIndex);
				return null;
			};
		}
		
		private function pointToPassage(name:String):Function
		{
			return function(currentLevel:Level):DisplayObject {
				var edge:GameEdgeContainer = currentLevel.getEdgeContainer(name);
				if (edge && edge.innerFromBoxSegment) {
					return edge.innerFromBoxSegment;
				} else {
					return null;
				}
			};
		}
		
		private function pointToClash(name:String):Function
		{
			return function(currentLevel:Level):DisplayObject {
				var edge:GameEdgeContainer = currentLevel.getEdgeContainer(name);
				if (edge && edge.errorContainer) {
					return edge.errorContainer;
				} else {
					return null;
				}
			};
		}
		
		public function getPersistentToolTipsInfo():Vector.<TutorialManagerTextInfo>
		{
			if (m_currentToolTipsText != null) return m_currentToolTipsText;
			var tips:Vector.<TutorialManagerTextInfo> = new Vector.<TutorialManagerTextInfo>();
			var tip:TutorialManagerTextInfo;
			switch (m_tutorialTag) {
				case LOCKED_TUTORIAL:
					tip = new TutorialManagerTextInfo("Locked\nNarrow\nWidget", null, pointToNode("var_0"), NineSliceBatch.BOTTOM, NineSliceBatch.CENTER);
					tips.push(tip);
					tip = new TutorialManagerTextInfo("Locked\nWide\nWidget", null, pointToNode("var_1"), NineSliceBatch.BOTTOM, NineSliceBatch.CENTER);
					tips.push(tip);
					break;
				case JAMS_TUTORIAL:
					tip = new TutorialManagerTextInfo("Jam! Wide Link to\nNarrow Widget", null, pointToClash("var_0 -> type_0__var_0"), NineSliceBatch.BOTTOM_LEFT, NineSliceBatch.CENTER);
					tips.push(tip);
					break;
				case LINKS_TUTORIAL:
					tip = new TutorialManagerTextInfo("Narrow Link", null, pointToEdge("var_0 -> type_1__var_0"), NineSliceBatch.BOTTOM_RIGHT, NineSliceBatch.RIGHT);
					tips.push(tip);
					tip = new TutorialManagerTextInfo("Wide Link", null, pointToEdge("var_1 -> type_1__var_1"), NineSliceBatch.BOTTOM_RIGHT, NineSliceBatch.RIGHT);
					tips.push(tip);
					break;
				case WIDEN_TUTORIAL:
					tip = new TutorialManagerTextInfo("Jam! Wide Link to\nNarrow Widget", null, pointToClash("type_1__var_0 -> var_0"), NineSliceBatch.BOTTOM_LEFT, NineSliceBatch.CENTER);
					tips.push(tip);
					break;
				case LAYOUT_TUTORIAL:
					tip = new TutorialManagerTextInfo(
						"Widgets can be dragged to\n" +
						"help organize the layout.\n" +
						"Separate the Widgets.",
						null,
						pointToNode("var_3"),
						NineSliceBatch.BOTTOM_LEFT, null);
					tips.push(tip);
					break;
			}
			return tips;
		}
		
		public function getTextInfo():TutorialManagerTextInfo
		{
			if (m_currentTutorialText != null) return m_currentTutorialText;
			switch (m_tutorialTag) {
				case WIDGET_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Click on WIDGETS to change their color.\n" +
						"Make them a solid color to get points!",
						null,
						pointToNode("IntroWidget2"),
						NineSliceBatch.TOP, null);
				case WIDGET_PRACTICE_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Practice clicking on Widgets and matching colors.\n",
						null,
						null,
						null, null);
				case LOCKED_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Gray Widgets are locked.\n" +
						"Their colors can't be changed.",
						null,
						pointToNode("LockedWidget2"),
						NineSliceBatch.TOP, null);
				case LINKS_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Widgets are connected\n" +
						"by LINKS. Light Widgets\n" +
						"create narrow Links, dark\n" +
						"Widgets create wide\n" +
						"Links.",
						null,
						pointToEdge("e1__OUT__"),
						NineSliceBatch.LEFT, null);
				case JAMS_TUTORIAL:
					return new TutorialManagerTextInfo(
						"JAMS happen when wide Links enter\n" +
						"narrow Widgets. This Jam penalizes\n" +
						"your score by " + 100 /* TODO: get from level*/ + " points.",
						null,
						pointToClash("var_0 -> type_0__var_0"),
						NineSliceBatch.TOP_RIGHT, NineSliceBatch.TOP);
				case WIDEN_TUTORIAL:
					return null;/* new TutorialManagerTextInfo(
						"Click the widgets to widen their links\n" +
						"and fix the jams.",
						null,
						null,
						null, null);*/
				case OPTIMIZE_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Sometimes the best score still has Jams.\n" +
						"Try different configurations to improve your score!",
						null,
						null,
						NineSliceBatch.BOTTOM_LEFT, null);
				case ZOOM_PAN_TUTORIAL:
					return new TutorialManagerTextInfo(
						"       Larger levels require navigation:      \n" +
						" Drag the background to move around the level.\n" +
						"      Use the +/- keys to zoom in and out.    \n" +
						"Navigate between jams using Tab and Shift+Tab.",
						null,
						null,
						null, null);
				case LAYOUT_TUTORIAL:
					return new TutorialManagerTextInfo(
						"The LAYOUT can be changed to help visualize the\n" +
						"problem. Layout moves will not affect your score.",
						null,
						null,
						null, null);
				case GROUP_SELECT_TUTORIAL:
					return new TutorialManagerTextInfo(
						"SELECT groups of Widgets by holding <SHIFT>\n" +
						"and click-dragging the mouse. SELECT and\n" +
						"move a group of Widgets to continue.",
						null,
						null,
						null, null);
				case CREATE_JOINT_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Create a joint on any Link by\n" +
						"double-clicking a spot on the Link.",
						null,
						null,
						null, null);
				case SKILLS_A_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Use the skills\nyou've learned to\nsolve a bigger\nchallenge!",
						null,
						null,
						NineSliceBatch.TOP_LEFT, null);
				case SKILLS_B_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Good work!\nTry using the map\nin the top right\nto navigate this\nlarger level.",
						null,
						null,
						NineSliceBatch.TOP_LEFT, null);
				// The following are not currently in use:
				case COLOR_TUTORIAL:
					return new TutorialManagerTextInfo(
						"Some Widgets want to be a certain color. Match\n" +
						"the Widgets to the color squares to collect\n" +
						"bonus points.",
						null,
						null,
						null, null);
			}
			return null;
		}
	}
}
