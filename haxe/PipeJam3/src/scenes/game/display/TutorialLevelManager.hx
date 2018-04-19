package scenes.game.display;

import flash.errors.Error;
import haxe.Constraints.Function;
import assets.AssetInterface;
import constraints.ConstraintEdge;
import constraints.ConstraintGraph;
import constraints.ConstraintVar;
import events.TutorialEvent;
import starling.display.Image;
import starling.textures.Texture;
import utils.PropDictionary;
import starling.core.Starling;
import networking.TutorialController;
import flash.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

class TutorialLevelManager extends EventDispatcher
{
    // This is the order the tutorials appears in:
    // TODO
    
    private var m_tutorialTag : String;
    private var m_levelStarted : Bool = false;
    private var m_levelFinished : Bool = false;
    // If default text is ovewridden, store here (otherwise if null, use default text)
    private var m_currentTutorialText : TutorialManagerTextInfo;
    private var m_currentToolTipsText : Array<TutorialManagerTextInfo>;
    
    public static inline var SOLVER_BRUSH : Int = 0x000001;
    public static inline var WIDEN_BRUSH : Int = 0x000002;
    public static inline var NARROW_BRUSH : Int = 0x000004;
    
    public function new(_tutorialTag : String)
    {
        super();
        m_tutorialTag = _tutorialTag;
        switch (m_tutorialTag)
        {
            case "001", "002", "01", "004", "02", "03", "04", "1", "2", "3", "4", "5", "6", "7", "8", "10", "12", "13", "14":
            default:
                throw new Error("Unknown Tutorial encountered: " + m_tutorialTag);
        }
    }
    
    override public function dispatchEvent(event : Event) : Void
    // Don't allow events to dispatch if stopped playing level
    {
        
        if (m_levelStarted)
        {
            super.dispatchEvent(event);
        }
    }
    
    public function startLevel() : Void
    {
        m_currentTutorialText = null;
        m_currentToolTipsText = null;
        m_levelFinished = false;
        m_levelStarted = true;
    }
    
    public function endLevel() : Void
    {
        m_currentTutorialText = null;
        m_currentToolTipsText = null;
        m_levelFinished = true;
        m_levelStarted = false;
    }
    
    public function onWidgetChange(idChanged : String, propChanged : String, propValue : Bool, levelGraph : ConstraintGraph) : Void
    {
        var tips : Array<TutorialManagerTextInfo> = new Array<TutorialManagerTextInfo>();
        var tip : TutorialManagerTextInfo;
        var widthTxt : String;
        switch (m_tutorialTag)
        {
            case "01":
                var var_98011_1 : ConstraintVar = levelGraph.variableDict["var_98011"];
                var var_98019_1 : ConstraintVar = levelGraph.variableDict["var_98019"];
                if (var_98011_1 != null && var_98011_1.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (var_98019_1 != null && var_98019_1.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
            case "02":
                var var_98011_2 : ConstraintVar = levelGraph.variableDict["var_98011"];
                var var_98019_2 : ConstraintVar = levelGraph.variableDict["var_98019"];
                if (var_98011_2 != null && var_98011_2.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (var_98019_2 != null && var_98019_2.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (tips.length == 0)
                {
                    tip = new TutorialManagerTextInfo("To remove this conflict two others\nwould be created, so leaving this\nconflict is the optimal solution", null, pointToNode("c_111708"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                else
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_111708"), Constants.BOTTOM, Constants.BOTTOM);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
        }
    }
    
    public function afterScoreUpdate(levelGraph : ConstraintGraph) : Void
    {
        var tips : Array<TutorialManagerTextInfo> = new Array<TutorialManagerTextInfo>();
        var tip : TutorialManagerTextInfo;
        var num : Int;
        var longConflictFound : Bool;
        var key : String;
        switch (m_tutorialTag)
        {
            case "001":
                num = 0;
                for (key in Reflect.fields(levelGraph.unsatisfiedConstraintDict))
                {
                    num++;
                }
                if (num == 0)
                {
                // End of level, display summary
                    
                    tip = new TutorialManagerTextInfo(
                            "Great work! The target score for this level was reached by\n" +
                            "satisfying all the constraints. Move on to the next level to learn more!", 
                            null, 
                            null, 
                            Constants.BOTTOM, null);
                    m_currentTutorialText = tip;
                    tips.push(tip);
                    dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TUTORIAL_TEXT, "", true, tips));
                }
            case "002":
                tip = new TutorialManagerTextInfo((levelGraph.unsatisfiedConstraintDict["c_4"] != null) ? "constraint\nwith\nconflict" : "conflict\nremoved!", null, pointToNode("c_4"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo((levelGraph.unsatisfiedConstraintDict["c_9"] != null) ? "constraint\nwith\nconflict" : "conflict\nremoved!", null, pointToNode("c_9"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
            case "01":
                var var_98011_1 : ConstraintVar = levelGraph.variableDict["var_98011"];
                var var_98019_1 : ConstraintVar = levelGraph.variableDict["var_98019"];
                if (var_98011_1 != null && var_98011_1.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (var_98019_1 != null && var_98019_1.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
            case "02":
                var var_98011_2 : ConstraintVar = levelGraph.variableDict["var_98011"];
                var var_98019_2 : ConstraintVar = levelGraph.variableDict["var_98019"];
                if (var_98011_2 != null && var_98011_2.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (var_98019_2 != null && var_98019_2.getValue().intVal == 1)
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                if (tips.length == 0)
                {
                    tip = new TutorialManagerTextInfo("To remove this conflict two others\nwould be created, so leaving this\nconflict is the optimal solution", null, pointToNode("c_111708"), Constants.TOP, Constants.TOP);
                    tips.push(tip);
                }
                else
                {
                    tip = new TutorialManagerTextInfo("Conflict", null, pointToNode("c_111708"), Constants.BOTTOM, Constants.BOTTOM);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
            case "04":
                num = 0;
                longConflictFound = false;
                for (key in Reflect.fields(levelGraph.unsatisfiedConstraintDict))
                {
                    num++;
                    if (key == "c_80002" || key == "c_150843" || key == "c_13896")
                    {
                        longConflictFound = true;
                    }
                }
                if (num == 1 && longConflictFound)
                {
                    tip = new TutorialManagerTextInfo("Try painting from here   ", null, pointToNode("var_86825"), Constants.LEFT, Constants.LEFT);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here", null, pointToNode("var_86622"), Constants.TOP_RIGHT, Constants.TOP_RIGHT);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here", null, pointToNode("var_86623"), Constants.TOP_LEFT, Constants.TOP_LEFT);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
            case "6":
                num = 0;
                longConflictFound = false;
                for (key in Reflect.fields(levelGraph.unsatisfiedConstraintDict))
                {
                    num++;
                    if (key == "c_61618" || key == "c_102237" || key == "c_27250")
                    {
                        longConflictFound = true;
                    }
                }
                if (num == 1 && longConflictFound)
                {
                    tip = new TutorialManagerTextInfo("Try painting\nfrom here", null, pointToNode("c_61618"), Constants.BOTTOM, Constants.BOTTOM);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here", null, pointToNode("var_2596"), Constants.TOP_LEFT, Constants.TOP_LEFT);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here", null, pointToNode("var_2646"), Constants.TOP_LEFT, Constants.TOP_LEFT);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here", null, pointToNode("var_2657"), Constants.BOTTOM_RIGHT, Constants.BOTTOM_RIGHT);
                    tips.push(tip);
                    tip = new TutorialManagerTextInfo("To here and this\nwhole cluster", null, pointToNode("var_3561"), Constants.BOTTOM_RIGHT, Constants.BOTTOM_RIGHT);
                    tips.push(tip);
                }
                m_currentToolTipsText = tips;
                dispatchEvent(new TutorialEvent(TutorialEvent.NEW_TOOLTIP_TEXT, "", true, tips));
        }
    }
    
    public function getAutoSolveAllowed() : Bool
    {
        return true;
    }
    
    public function getPanZoomAllowed() : Bool
    {
        switch (m_tutorialTag)
        {
            case "001", "002", "01", "004", "02", "03", "04", "1":
                return false;
        }
        return true;
    }
    
    public function getMiniMapShown() : Bool
    {
        switch (m_tutorialTag)
        {
            case "001", "002", "01", "004", "02", "03", "04", "1", "2", "3", "4", "5", "6", "7", "8", "10":
                return false;
        }
        return true;
    }
    
    public function getLayoutFixed() : Bool
    {
        return true;
    }
    
    public function getStartScaleFactor() : Float
    {
        switch (m_tutorialTag)
        {
            case "001", "002", "01", "02":
                return 0.75;
            case "2":
                return 1.3;
            case "004":
                return 0.95;
            case "03", "04", "1", "3", "4", "5", "6", "7", "8", "10", "12", "13", "14":
                return 1.0;
        }
        return 1.0;
    }
    
    public function getStartPanOffset() : Point
    {
        switch (m_tutorialTag)
        {
            case "001", "01", "004", "02", "03", "04", "1":
                return new Point(0, 10);  // shift level down by 10px  
            case "002":
                return new Point(-50, 0);
            case "2", "3", "4", "5", "6", "7", "8":
                return new Point();
        }
        return new Point();
    }
    
    public function getMaxSelectableWidgets() : Int
    {
        if (PipeJam3.SELECTION_STYLE != PipeJam3.SELECTION_STYLE_CLASSIC)
        {
            switch (m_tutorialTag)
            {
                case "001", "002":
                    return 2;
                case "01", "004", "02":
                    return 5;
                case "03", "04":
                    return 20;
                case "1":
                    return 30;
                case "2":
                    return 50;
                case "3", "4", "5":
                    return 75;
                case "6", "7", "8":
                    return 100;
                case "10":
                    return 125;
            }
            return 250;
        }
        else
        {
            switch (m_tutorialTag)
            {
                case "001", "002", "01", "004", "02":
                    return 10;
                case "03", "04":
                    return 50;
                case "1":
                    return 100;
                case "2":
                    return 150;
                case "3", "4", "5":
                    return 225;
                case "6", "7", "8":
                    return 350;
                case "10":
                    return 400;
                case "12":
                    return 1000;
                case "13", "14":
                    return 2000;
            }
        }
        return -1;
    }
    
    public function getPerformSmallAutosolveGroupCheck() : Bool
    {
        switch (m_tutorialTag)
        {
            case "001", "002", "01", "004", "02":
                return false;
            case "03", "04", "1", "2", "3", "4", "5", "6", "7", "8", "10":
                return true;
        }
        return true;
    }
    
    public function getVisibleBrushes() : Int
    {
        switch (m_tutorialTag)
        {
            case "001":
                return WIDEN_BRUSH;
            case "002", "01":
                return WIDEN_BRUSH + NARROW_BRUSH;
            case "004", "02", "03", "04", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14":
                return SOLVER_BRUSH + WIDEN_BRUSH + NARROW_BRUSH;
            default:
                return SOLVER_BRUSH + WIDEN_BRUSH + NARROW_BRUSH;
        }
    }
    
    public function getStartingBrush() : Float
    {
        switch (m_tutorialTag)
        {
            case "002", "01", "004", "02":
                return WIDEN_BRUSH;
        }
        return Math.NaN;
    }
    
    public function emphasizeBrushes() : Int
    {
        switch (m_tutorialTag)
        {
            case "002", "01":
                return NARROW_BRUSH;
            case "004", "02":
                return SOLVER_BRUSH;
        }
        return 0x0;
    }
    
    private function pointToNode(name : String) : Function
    {
        return function(currentLevel : Level) : DisplayObject
        {
            return currentLevel.getNode(name).skin;
        };
    }
    
    private function pointToEdge(name : String) : Function
    {
        return function(currentLevel : Level) : DisplayObject
        {
            return currentLevel.getEdgeContainer(name);
        };
    }
    
    private function pointToEdgeSegment(edgeName : String, segmentIndex : Int) : Function
    {
        return function(currentLevel : Level) : DisplayObject
        {
            var container : DisplayObject = currentLevel.getEdgeContainer(edgeName);
            if (container != null)
            {
                return container.getSegment(segmentIndex);
            }
            return null;
        };
    }
    
    private function pointToPassage(name : String) : Function
    {
        return function(currentLevel : Level) : DisplayObject
        {
            var edge : DisplayObject = currentLevel.getEdgeContainer(name);
            if (edge != null && edge.innerFromBoxSegment)
            {
                return edge.innerFromBoxSegment;
            }
            else
            {
                return null;
            }
        };
    }
    
    private function pointToClash(name : String) : Function
    {
        return function(currentLevel : Level) : DisplayObject
        {
            var edge : DisplayObject = currentLevel.getEdgeContainer(name);
            return edge;
        };
    }
    
    public function getPersistentToolTipsInfo() : Array<TutorialManagerTextInfo>
    {
        if (m_currentToolTipsText != null)
        {
            return m_currentToolTipsText;
        }
        var tips : Array<TutorialManagerTextInfo> = new Array<TutorialManagerTextInfo>();
        var tip : TutorialManagerTextInfo;
        switch (m_tutorialTag)
        {
            case "001":
                tip = new TutorialManagerTextInfo("variable", null, pointToNode("var_1"), Constants.BOTTOM_RIGHT, Constants.CENTER);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("variable", null, pointToNode("var_2"), Constants.BOTTOM_LEFT, Constants.CENTER);
                tips.push(tip);
                
                tip = new TutorialManagerTextInfo("constraint", null, pointToNode("c_4"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("constraint", null, pointToNode("c_9"), Constants.TOP, Constants.TOP);
                tips.push(tip);
            case "002":
                tip = new TutorialManagerTextInfo("constraint\nwith\nconflict", null, pointToNode("c_4"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("constraint\nwith\nconflict", null, pointToNode("c_9"), Constants.TOP, Constants.TOP);
                tips.push(tip);
            case "01":
                tip = new TutorialManagerTextInfo("conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                tips.push(tip);
            case "02":
                tip = new TutorialManagerTextInfo("conflict", null, pointToNode("c_74452"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("conflict", null, pointToNode("c_74407"), Constants.TOP, Constants.TOP);
                tips.push(tip);
                tip = new TutorialManagerTextInfo("conflict", null, pointToNode("c_111708"), Constants.BOTTOM, Constants.BOTTOM);
                tips.push(tip);
        }
        return tips;
    }
    
    public function getSplashScreen() : Image
    {
        switch (m_tutorialTag)
        {
            case "002":
                var splashText : Texture = AssetInterface.getTexture("Game", "ConstraintsSplashClass" + PipeJam3.ASSET_SUFFIX);
                var splash : Image = new Image(splashText);
                return splash;
        }
        return null;
    }
    
    public function continueButtonDelay() : Float
    {
        switch (m_tutorialTag)
        {
            case "001":
                return 4.0;
        }
        return 0;
    }
    
    public function showFanfare() : Bool
    {
        switch (m_tutorialTag)
        {
            case "001":
                return false;
        }
        return true;
    }
    
    public function getTextInfo() : TutorialManagerTextInfo
    {
        if (m_currentTutorialText != null)
        {
            return m_currentTutorialText;
        }
        switch (m_tutorialTag)
        {
            case "001":
                return new TutorialManagerTextInfo(
                "Variables can change states. Click and drag to paint variables.\nRelease the mouse to apply the state being painted.", 
                null, 
                null, 
                null, null);
            case "002":
                return new TutorialManagerTextInfo(
                "New paintbrush\n" +
                "unlocked! Change\n" +
                "paintbrushes by\n" +
                "clicking on one\n" +
                "of the paintbrush\n" +
                "    previews -->", 
                null, 
                null, 
                Constants.RIGHT, null);
            case "01":
                return new TutorialManagerTextInfo(
                "Eliminate as many red conflicts as you can!", 
                null, 
                null, 
                null, null);
            case "004":
                return new TutorialManagerTextInfo(
                "New brush unlocked! The optimizer will automatically adjust the\nselected variables to reduce the overall number of conflicts.", 
                null, 
                null, 
                null, null);
            case "02":
                return new TutorialManagerTextInfo(
                "The optimizer will adjust the selected variables to reduce the\ntotal number of conflicts. Eliminate as many red conflicts as you can!", 
                null, 
                null, 
                null, null);
            case "03":
                return new TutorialManagerTextInfo(
                "There is a limit to how many things you select. The numbers on the\npaintbrush indicate how many you've selected and the selection limit.", 
                null, 
                null, 
                null, null);
            case "04":
                return new TutorialManagerTextInfo(
                "Different selection areas will create different solutions.\nSometimes many items need to change to eliminate a conflict.", 
                null, 
                null, 
                null, null);
            case "2":
                return new TutorialManagerTextInfo(
                "Use the arrow keys or right-click and drag to pan. Use +/- to zoom.", 
                null, 
                null, 
                null, null);
            case "1", "3", "4", "5", "6", "7", "8", "10", "13", "14":
                return new TutorialManagerTextInfo(
                "Keep eliminating the red conflicts!", 
                null, 
                null, 
                null, null);
            case "12":
                return new TutorialManagerTextInfo(
                "For larger levels use on the minimap in the top right to navigate.", 
                null, 
                null, 
                Constants.TOP_LEFT, null);
                
                return null;
        }
        return null;
    }
}

