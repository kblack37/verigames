package scenes.game.components;

import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import scenes.game.PipeJamGameScene;
import starling.display.DisplayObject;
import utils.XMath;
import assets.AssetInterface;
import assets.AssetsFont;
import display.SimpleButton;
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

class SideControlPanel extends BaseComponent
{
    private var WIDTH : Float;
    private var HEIGHT : Float;
    
    public static inline var OVERLAP : Float = 2;
    
    /** Button to bring the up the menu */
    private var m_menuButton : NineSliceButton;
    private var m_turkFinishButton : NineSliceButton;
    
    private var scoreCircleMiddleImage : Image;
    private var scoreCircleFrontImage : Image;
    private var scoreImageCenter : Point;
    
    /** Navigation buttons */
    private var m_zoomInButton : SimpleButton;
    private var m_zoomOutButton : SimpleButton;
    private var m_fullScreenButton : SimpleButton;
    
    private var m_solver1Brush : NineSliceToggleButton;
    private var m_solver2Brush : NineSliceToggleButton;
    private var m_widenBrush : NineSliceToggleButton;
    private var m_narrowBrush : NineSliceToggleButton;
    private var m_brushButtonGroup : RadioButtonGroup;
    
    /** Text showing current score */
    private var m_scoreTextfield : TextFieldWrapper;
    
    /** Text showing best score */
    private var m_bestTextfield : TextFieldWrapper;
    
    /** Text showing the target percentage score */
    private var m_targetPercentTextfield : TextFieldWrapper;
    
    /** display control variables */
    private var m_panZoomAllowed : Bool;
    
    private var addSolverArray : Array<Dynamic> = [1, 0, 1, 1];
    public static inline var OPTIMIZER1_BRUSH_CONTROL : Int = 0;
    public static inline var OPTIMIZER2_BRUSH_CONTROL : Int = 1;
    public static inline var WIDE_BRUSH_CONTROL : Int = 2;
    public static inline var NARROW_BRUSH_CONTROL : Int = 3;
    
    public function new(_width : Float, _height : Float)
    {
        super();
        WIDTH = _width;
        HEIGHT = _height;
        
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        
        var scoreCircleBackTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleBack);
        var scoreCircleMiddleTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleMiddle);
        var scoreCircleFrontTexture : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ScoreCircleFront);
        
        var scoreCircleBackImage : Image = new Image(scoreCircleBackTexture);
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
        
        scoreImageCenter = new Point(scoreCircleFrontImage.x + scoreCircleFrontImage.width / 2, 
                scoreCircleFrontImage.y + scoreCircleFrontImage.height / 2);
        
        var background : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_Sidebar);
        var backgroundImage : Image = new Image(background);
        backgroundImage.scaleX = backgroundImage.scaleY = 0.5;
        addChild(backgroundImage);
        
        m_menuButton = ButtonFactory.getInstance().createButton((PipeJam3.TUTORIAL_DEMO) ? "Level Select" : "Menu", 44, 14, 8, 8, "Return to the main menu");
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
        
        var logo : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ParadoxLogoWhiteSmall);
        var logoImage : Image = new Image(logo);
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
        
        m_solver1Brush = try cast(createPaintBrushButton(GridViewPanel.SOLVER1_BRUSH, changeCurrentBrush, "Optimize"), NineSliceToggleButton) catch(e:Dynamic) null;
        //	m_solver2Brush = createPaintBrushButton(GridViewPanel.SOLVER2_BRUSH, changeCurrentBrush, "Optimize") as NineSliceToggleButton;
        m_widenBrush = try cast(createPaintBrushButton(GridViewPanel.WIDEN_BRUSH, changeCurrentBrush, "Make Wide"), NineSliceToggleButton) catch(e:Dynamic) null;
        m_narrowBrush = try cast(createPaintBrushButton(GridViewPanel.NARROW_BRUSH, changeCurrentBrush, "Make Narrow"), NineSliceToggleButton) catch(e:Dynamic) null;
        
        m_widenBrush.y = 00;
        m_narrowBrush.y = 30;
        m_solver1Brush.y = 60;
        
        m_solver1Brush.visible = false;
        if (addSolverArray[OPTIMIZER1_BRUSH_CONTROL] == 1)
        {
            m_brushButtonGroup.addChild(m_solver1Brush);
            GridViewPanel.FIRST_SOLVER_BRUSH = GridViewPanel.SOLVER1_BRUSH;
            m_brushButtonGroup.makeActive(m_solver1Brush);
        }
        else
        {
            GridViewPanel.FIRST_SOLVER_BRUSH = GridViewPanel.SOLVER2_BRUSH;
        }
        
        m_widenBrush.visible = false;
        if (addSolverArray[WIDE_BRUSH_CONTROL] == 1)
        {
            m_brushButtonGroup.addChild(m_widenBrush);
        }
        
        m_narrowBrush.visible = false;
        if (addSolverArray[NARROW_BRUSH_CONTROL] == 1)
        {
            m_brushButtonGroup.addChild(m_narrowBrush);
        }
        
        this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
    }
    
    private function showTurkFinishButton() : Void
    {
        addChild(m_turkFinishButton);
    }
    
    public function addedToStage(event : starling.events.Event) : Void
    {
        if (PipeJam3.ASSET_SUFFIX == "Turk")
        {
            if (!PipeJamGameScene.inTutorial)
            {
                Starling.juggler.delayCall(showTurkFinishButton, 5 * 60);
            }
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
    
    public function addSoundButton(m_sfxButton : SoundButton) : Void
    {
        m_sfxButton.scaleX = m_sfxButton.scaleY = m_zoomInButton.scaleX;
        m_sfxButton.x = m_zoomInButton.x - 3.5;
        m_sfxButton.y = m_zoomOutButton.y + m_zoomOutButton.height + 3.5;
        var test : Point = localToGlobal(new Point(m_sfxButton.x, m_sfxButton.y));
        addChild(m_sfxButton);
    }
    
    //min scale == max zoom
    public function onMaxZoomReached() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = true && m_panZoomAllowed;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = false && m_panZoomAllowed;
        }
    }
    
    public function onMinZoomReached() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = false && m_panZoomAllowed;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = true && m_panZoomAllowed;
        }
    }
    
    public function onZoomReset() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = true && m_panZoomAllowed;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = true && m_panZoomAllowed;
        }
    }
    
    public function newLevelSelected(level : Level) : Void
    //			m_currentLevel = level;
    {
        
        //			updateScore(level, true);
        //			TextFactory.getInstance().updateText(m_levelNameTextfield, level.level_name);
        //			TextFactory.getInstance().updateAlign(m_levelNameTextfield, 1, 1);
        //			setNavigationButtonVisibility(level.getPanZoomAllowed());
        //			setSolveButtonsVisibility(level.getAutoSolveAllowed());
        //			updateNumNodesSelectedDisplay();
        
        m_brushButtonGroup.resetGroup();
        
        m_panZoomAllowed = level.getPanZoomAllowed();
        // NOTE: this assumes you start at a zoom that is not the min or max zoom!
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = m_panZoomAllowed;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = m_panZoomAllowed;
        }
    }
    
    public function removedFromStage(event : starling.events.Event) : Void
    {
        removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
        Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, checkForTriggerFullScreen);
    }
    
    override public function hitTest(localPoint : Point, forTouch : Bool = false) : DisplayObject
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
    
    override private function onTouch(event : TouchEvent) : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.MOUSE_OVER_CONTROL_PANEL));
    }
    
    private function onMenuButtonTriggered() : Void
    {
        if (PipeJam3.TUTORIAL_DEMO)
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
        }
        else
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
        }
    }
    
    private function onTurkFinishButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.TURK_FINISH));
    }
    
    private function onZoomInButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.ZOOM_IN));
    }
    
    private function onZoomOutButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.ZOOM_OUT));
    }
    
    private function checkForTriggerFullScreen(event : MouseEvent) : Void
    {
        if (m_fullScreenButton == null)
        {
            return;
        }
        if (!m_fullScreenButton.parent)
        {
            return;
        }
        var buttonTopLeft : Point = m_fullScreenButton.parent.localToGlobal(new Point(m_fullScreenButton.x - 0.5 * m_fullScreenButton.width, m_fullScreenButton.y - 0.5 * m_fullScreenButton.height));
        var buttonBottomRight : Point = m_fullScreenButton.parent.localToGlobal(new Point(m_fullScreenButton.x + 0.5 * m_fullScreenButton.width, m_fullScreenButton.y + 0.5 * m_fullScreenButton.height));
        // Need to use viewport to convert to native stage
        if (ExternalInterface.available)
        {
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
        if (ExternalInterface.available)
        {
            ExternalInterface.call("console.log", "adjbuttonTopLeft:" + buttonTopLeft);
            ExternalInterface.call("console.log", "adjbuttonBottomRight:" + buttonBottomRight);
        }
        if (event.stageX >= buttonTopLeft.x && event.stageX <= buttonBottomRight.x && event.stageY >= buttonTopLeft.y && event.stageY <= buttonBottomRight.y)
        
        //need to mark that we are doing this, so we don't lose the selection{
            
            World.changingFullScreenState = true;
            
            if (Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN)
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
    private function onFullScreenButtonTriggered(event : Event) : Void
    {
    }
    
    /**
		 * Updates the score on the screen
		 */
    public function updateScore(level : Level, skipAnimatons : Bool) : Float
    {
        var maxConflicts : Int = level.maxScore;
        var currentConflicts : Int = MiniMap.numConflicts;
        var score : Float = ((maxConflicts - currentConflicts) / maxConflicts) * 100;
        var integerPart : Int = Math.floor(score);
        var decimalPart : Int = as3hx.Compat.parseInt((score - integerPart) * 100);
        
        var currentScore : String = as3hx.Compat.toFixed(score, 2) + "%";
        trace("conflict count", maxConflicts, currentConflicts, currentScore);
        
        TextFactory.getInstance().updateText(m_scoreTextfield, currentScore);
        TextFactory.getInstance().updateAlign(m_scoreTextfield, 2, 1);
        
        var integerRotation : Float = -(100 - integerPart) * 1.8;  //180/100  
        var decimalRotation : Float = -(100 - decimalPart) * 1.8;
        rotateToDegree(scoreCircleMiddleImage, scoreImageCenter, integerRotation);
        rotateToDegree(scoreCircleFrontImage, scoreImageCenter, decimalRotation);
        
        return score;
    }
    
    /**
		 * Updates the target percentage on the screen
		 */
    public function targetPercent(level : Level) : Float
    {
        var maxConflicts : Int = level.maxScore;
        var targetScore : Int = level.getTargetScore();
        var targetPercentage : Float = (targetScore / maxConflicts) * 100;
        var score : Float = ((maxConflicts - MiniMap.numConflicts) / maxConflicts) * 100;
        
        var currentTarget : String = as3hx.Compat.toFixed(targetPercentage, 2) + "%";
        
        TextFactory.getInstance().updateText(m_targetPercentTextfield, "Target:\n" + currentTarget);
        TextFactory.getInstance().updateAlign(m_targetPercentTextfield, 2, 1);
        if (score >= targetPercentage)
        {
            TextFactory.getInstance().updateColor(m_targetPercentTextfield, 0x00FF00);
        }
        else
        {
            TextFactory.getInstance().updateColor(m_targetPercentTextfield, 0xB1ACAA);
        }
        
        return targetPercentage;
    }
    
    private function changeCurrentBrush(evt : starling.events.Event) : Void
    {
        m_brushButtonGroup.makeActive(try cast(evt.target, NineSliceToggleButton) catch(e:Dynamic) null);
        dispatchEvent(new SelectionEvent(SelectionEvent.BRUSH_CHANGED, evt.target, null));
    }
    
    public function changeSelectedBrush(brush : String) : Void
    {
        switch (brush)
        {
            case GridViewPanel.SOLVER1_BRUSH:
                m_brushButtonGroup.makeActive(m_solver1Brush);
            case GridViewPanel.SOLVER2_BRUSH:
                m_brushButtonGroup.makeActive(m_solver2Brush);
            case GridViewPanel.WIDEN_BRUSH:
                m_brushButtonGroup.makeActive(m_widenBrush);
            case GridViewPanel.NARROW_BRUSH:
                m_brushButtonGroup.makeActive(m_narrowBrush);
        }
    }
    
    public function showVisibleBrushes(visibleBrushes : Int) : Void
    {
        var count : Int = 0;
        m_solver1Brush.visible = ((visibleBrushes & TutorialLevelManager.SOLVER_BRUSH) != 0) ? true : false;
        if (m_solver1Brush.visible)
        {
            count++;
        }
        //	m_solver2Brush.visible = visibleBrushes & TutorialLevelManager.SOLVER_BRUSH ? true : false;
        //	if(m_solver2Brush.visible) count++;
        m_narrowBrush.visible = ((visibleBrushes & TutorialLevelManager.WIDEN_BRUSH) != 0) ? true : false;
        if (m_narrowBrush.visible)
        {
            count++;
        }
        m_widenBrush.visible = ((visibleBrushes & TutorialLevelManager.NARROW_BRUSH) != 0) ? true : false;
        if (m_widenBrush.visible)
        {
            count++;
        }
        
        //if only one shows, hide them all
        if (count == 1)
        {
            m_solver1Brush.visible = m_narrowBrush.visible = m_widenBrush.visible = false;
        }
    }
    
    public function emphasizeBrushes(emphasizeBrushes : Int) : Void
    {
        m_narrowBrush.deemphasize();
        m_widenBrush.deemphasize();
        m_solver1Brush.deemphasize();
        if ((emphasizeBrushes & TutorialLevelManager.NARROW_BRUSH) != 0)
        {
            m_narrowBrush.emphasize();
        }
        if ((emphasizeBrushes & TutorialLevelManager.WIDEN_BRUSH) != 0)
        {
            m_widenBrush.emphasize();
        }
        if ((emphasizeBrushes & TutorialLevelManager.SOLVER_BRUSH) != 0)
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
    
    public function setHighScores(highScoreArray : Array<Dynamic>) : Void
    {
        var level : Level = World.m_world.active_level;
        if (level != null && highScoreArray != null)
        {
            var htmlString : String = "";
            var count : Int = 1;
            var scoreObjArray : Array<Dynamic> = new Array<Dynamic>();
            var highScoreObjArray : Array<Dynamic> = new Array<Dynamic>();
            for (scoreInstance in highScoreArray)
            {
                var scoreObj : Dynamic = {};
                Reflect.setField(scoreObj, "name", PlayerValidation.getUserName(Reflect.field(scoreInstance, Std.string(1)), count));
                Reflect.setField(scoreObj, "score", Reflect.field(scoreInstance, Std.string(0)));
                Reflect.setField(scoreObj, "assignmentsID", Reflect.field(scoreInstance, Std.string(2)));
                Reflect.setField(scoreObj, "score_improvement", Reflect.field(scoreInstance, Std.string(3)));
                var maxConflicts : Int = level.maxScore;
                var intScore : Int = as3hx.Compat.parseInt(maxConflicts - as3hx.Compat.parseInt(Reflect.field(scoreInstance, Std.string(0))));
                var value : Float = ((maxConflicts - intScore) / maxConflicts) * 100;
                if (maxConflicts != 0 && value < 101)
                {
                    Reflect.setField(scoreObj, "percent", as3hx.Compat.toFixed(value, 2) + "%");
                }
                else
                {
                    Reflect.setField(scoreObj, "percent", "Calculating...");
                }
                if (Reflect.field(scoreInstance, Std.string(1)) == PlayerValidation.playerID)
                {
                    scoreObj.activePlayer = 1;
                }
                else
                {
                    scoreObj.activePlayer = 0;
                }
                
                scoreObjArray.push(scoreObj);
                highScoreObjArray.push(scoreObj);
                count++;
            }
            if (scoreObjArray.length > 0)
            {
                scoreObjArray.sort(orderHighScoresByScore);
                var scoreStr : String = haxe.Json.stringify(scoreObjArray);
                HTTPCookies.addHighScores(scoreStr);
                
                highScoreObjArray.sort(orderHighScoresByDifference);
                var scoreStr1 : String = haxe.Json.stringify(highScoreObjArray);
                HTTPCookies.addScoreImprovementTotals(scoreStr1);
            }
            else
            {
                var nonScoreObj : Dynamic = {};
                Reflect.setField(nonScoreObj, "name", "Not played yet");
                Reflect.setField(nonScoreObj, "score", "");
                Reflect.setField(nonScoreObj, "assignmentsID", "");
                Reflect.setField(nonScoreObj, "score_improvement", "");
                nonScoreObj.activePlayer = 0;
                
                scoreObjArray.push(nonScoreObj);
                var scoreStr2 : String = haxe.Json.stringify(scoreObjArray);
                HTTPCookies.addHighScores(scoreStr2);
                Reflect.setField(scoreObjArray[0], "name", "");
                var scoreStr3 : String = haxe.Json.stringify(scoreObjArray);
                HTTPCookies.addScoreImprovementTotals(scoreStr3);
            }
            
            var currentScore : Int = level.currentScore;
            var bestScore : Int = level.bestScore;
            var targetScore : Int = level.getTargetScore();
            var maxScoreShown : Float = Math.max(currentScore, targetScore);
            var score : String = "0";
            if (highScoreArray.length > 0)
            {
                score = highScoreArray[0].current_score;
            }
        }
    }
    
    public static function orderHighScoresByScore(a : Dynamic, b : Dynamic) : Int
    {
        var score1 : Int = as3hx.Compat.parseInt(Reflect.field(a, "score"));
        var score2 : Int = as3hx.Compat.parseInt(Reflect.field(b, "score"));
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
    
    public static function orderHighScoresByDifference(a : Dynamic, b : Dynamic) : Int
    {
        var score1 : Int = as3hx.Compat.parseInt(Reflect.field(a, "score_improvement"));
        var score2 : Int = as3hx.Compat.parseInt(Reflect.field(b, "score_improvement"));
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
