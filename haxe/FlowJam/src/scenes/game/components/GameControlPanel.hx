package scenes.game.components;

import assets.AssetInterface;
import assets.AssetsFont;
import display.BasicButton;
import display.FullScreenButton;
import display.NineSliceButton;
import display.RecenterButton;
import display.SmallScreenButton;
import display.SoundButton;
import display.TextBubble;
import display.ZoomInButton;
import display.ZoomOutButton;
import events.MenuEvent;
import events.NavigationEvent;
import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import scenes.BaseComponent;
import scenes.game.display.GameComponent;
import scenes.game.display.Level;
import scenes.game.display.World;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import utils.XSprite;




class GameControlPanel extends BaseComponent
{
    private static var WIDTH : Float = Constants.GameWidth;
    public static var HEIGHT : Float = 82 - 20;
    
    public static var OVERLAP : Float = 72 - 10;
    public static var SCORE_PANEL_AREA : Rectangle = new Rectangle(108, 18, 284 - 10, 34);
    private static inline var SCORE_PANEL_MAX_SCALEY : Float = 1.5;
    
    /** Graphical object showing user's score */
    private var m_scorePanel : BaseComponent;
    
    /** Graphical object, child of scorePanel to hold scorebar */
    private var m_scoreBarContainer : Sprite;
    
    /** Indicate the current score */
    private var m_scoreBar : Quad;
    
    /** Text showing current score on score_pane */
    private var m_scoreTextfield : TextFieldWrapper;
    
    /** Text showing current score on score_pane */
    private var m_levelNameTextfield : TextFieldWrapper;
    
    /** Button to bring the up the menu */
    private var m_newLevelButton : NineSliceButton;
    
    /** Button to solve the selected nodes */
    private var m_solveButton : NineSliceButton;
    
    /** Button to start the level over */
    private var m_resetButton : NineSliceButton;
    
    /** Button to save the level */
    private var m_saveButton : NineSliceButton;
    
    /** Button to share the level */
    private var m_shareButton : NineSliceButton;
    
    /** Navigation buttons */
    private var m_zoomInButton : BasicButton;
    private var m_zoomOutButton : BasicButton;
    private var m_recenterButton : BasicButton;
    private var m_fullScreenButton : BasicButton;
    private var m_smallScreenButton : BasicButton;
    private var menuShowing : Bool = false;
    
    /** Goes over the scorebar but under the menu, transparent in scorebar area */
    private var m_scorebarForeground : Image;
    
    /** Display the target score the player is looking to beat for the level */
    private var m_targetScoreLine : TargetScoreDisplay;
    
    /** Display the best score the player has achieved this session for the level */
    private var m_bestPlayerScoreLine : TargetScoreDisplay;
    
    /** Display the last saved score by this player for this level */
    private var m_lastSavedScoreLine : TargetScoreDisplay;
    
    /** Display the current best score for this level */
    private var m_bestScoreLine : TargetScoreDisplay;
    
    public function new()
    {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }
    
    public function addedToStage(event : Event) : Void
    {
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        var foregroundTexture : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_ScoreBarForeground);
        m_scorebarForeground = new Image(foregroundTexture);
        m_scorebarForeground.touchable = false;
        m_scorebarForeground.width = WIDTH;
        m_scorebarForeground.height = HEIGHT;
        addChild(m_scorebarForeground);
        
        m_scorePanel = new BaseComponent();
        m_scorePanel.x = SCORE_PANEL_AREA.x;
        m_scorePanel.y = SCORE_PANEL_AREA.y;
        var quad : Quad = new Quad(SCORE_PANEL_AREA.width + 10, SCORE_PANEL_AREA.height, 0x231F20);
        m_scorePanel.addChild(quad);
        addChildAt(m_scorePanel, 0);
        
        m_scoreBarContainer = new Sprite();
        m_scorePanel.addChild(m_scoreBarContainer);
        var topLeftScorePanel : Point = m_scorePanel.localToGlobal(new Point(0, 0));
        m_scorePanel.clipRect = new Rectangle(topLeftScorePanel.x, topLeftScorePanel.y, m_scorePanel.width, m_scorePanel.height);
        
        m_scoreTextfield = TextFactory.getInstance().createTextField("0", "_sans", SCORE_PANEL_AREA.width / 10, 2.0 * SCORE_PANEL_AREA.height / 3.0, 2.0 * SCORE_PANEL_AREA.height / 3.0, GameComponent.SCORE_COLOR);
        m_scoreTextfield.touchable = false;
        m_scoreTextfield.x = (SCORE_PANEL_AREA.width - m_scoreTextfield.width) / 2;
        m_scoreTextfield.y = SCORE_PANEL_AREA.height / 6.0;
        TextFactory.getInstance().updateAlign(m_scoreTextfield, 2, 1);
        m_scorePanel.addChild(m_scoreTextfield);
        
        // Top shadow over score panel
        var shadowOverlay : Quad = new Quad(SCORE_PANEL_AREA.width, 10, 0x0);
        shadowOverlay.setVertexAlpha(2, 0);
        shadowOverlay.setVertexAlpha(3, 0);
        shadowOverlay.touchable = false;
        m_scorePanel.addChild(shadowOverlay);
        
        var LEVEL_TEXT_WIDTH : Float = 100.0;
        m_levelNameTextfield = TextFactory.getInstance().createTextField("", "_sans", LEVEL_TEXT_WIDTH, 10, 10, GameComponent.WIDE_COLOR);
        m_levelNameTextfield.touchable = false;
        m_levelNameTextfield.x = WIDTH - LEVEL_TEXT_WIDTH - 10;
        m_levelNameTextfield.y = -10;
        TextFactory.getInstance().updateAlign(m_levelNameTextfield, 1, 0);
        addChild(m_levelNameTextfield);
        
        m_newLevelButton = ButtonFactory.getInstance().createButton((PipeJam3.TUTORIAL_DEMO) ? "Level Select" : "New Level", 44, 14, 8, 8, "Start a new level");
        m_newLevelButton.addEventListener(Event.TRIGGERED, onMenuButtonTriggered);
        m_newLevelButton.x = (SCORE_PANEL_AREA.x - m_newLevelButton.width) / 2 + 5;
        m_newLevelButton.y = 25.5;
        addChild(m_newLevelButton);
        
        m_resetButton = ButtonFactory.getInstance().createButton("Reset", 44, 14, 8, 8, "Reset the board to\nits starting condition");
        m_resetButton.addEventListener(Event.TRIGGERED, onStartOverButtonTriggered);
        m_resetButton.x = m_newLevelButton.x;
        m_resetButton.y = m_newLevelButton.y + m_newLevelButton.height + 3;
        addChild(m_resetButton);
        
        m_zoomInButton = new ZoomInButton();
        m_zoomInButton.addEventListener(Event.TRIGGERED, onZoomInButtonTriggered);
        m_zoomInButton.scaleX = m_zoomInButton.scaleY = 0.5;
        XSprite.setPivotCenter(m_zoomInButton);
        m_zoomInButton.x = WIDTH - 92.5;
        m_zoomInButton.y = 21;
        addChild(m_zoomInButton);
        
        m_zoomOutButton = new ZoomOutButton();
        m_zoomOutButton.addEventListener(Event.TRIGGERED, onZoomOutButtonTriggered);
        m_zoomOutButton.scaleX = m_zoomOutButton.scaleY = 0.5;
        XSprite.setPivotCenter(m_zoomOutButton);
        m_zoomOutButton.x = m_zoomInButton.x + m_zoomInButton.width + 3;
        m_zoomOutButton.y = m_zoomInButton.y;
        addChild(m_zoomOutButton);
        
        m_recenterButton = new RecenterButton();
        m_recenterButton.addEventListener(Event.TRIGGERED, onRecenterButtonTriggered);
        m_recenterButton.scaleX = m_recenterButton.scaleY = 0.5;
        XSprite.setPivotCenter(m_recenterButton);
        m_recenterButton.x = m_zoomOutButton.x + m_zoomOutButton.width + 3;
        m_recenterButton.y = m_zoomOutButton.y;
        addChild(m_recenterButton);
        
        // Note: this button is for display only, we listen for native touch events below on the stage and
        // see whether this button was clicked because Flash requires native MouseEvents to trigger fullScreen
        //Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, checkForTriggerFullScreen);
        //m_fullScreenButton = new FullScreenButton();
        //m_fullScreenButton.scaleX = m_fullScreenButton.scaleY = 0.5;
        //XSprite.setPivotCenter(m_fullScreenButton);
        //m_fullScreenButton.x = m_recenterButton.x + m_recenterButton.width + 3;
        //m_fullScreenButton.y = m_zoomInButton.y;
        //addChild(m_fullScreenButton);
        //
        //m_smallScreenButton = new SmallScreenButton();
        //m_smallScreenButton.addEventListener(Event.TRIGGERED, onFullScreenButtonTriggered);
        //m_smallScreenButton.scaleX = m_smallScreenButton.scaleY = 0.5;
        //XSprite.setPivotCenter(m_smallScreenButton);
        //m_smallScreenButton.x = m_fullScreenButton.x;
        //m_smallScreenButton.y = m_fullScreenButton.y;
        //addChild(m_smallScreenButton);
        //m_smallScreenButton.visible = false;
        
        m_solveButton = ButtonFactory.getInstance().createButton("Solve Selection", (m_recenterButton.x + m_recenterButton.width) - m_zoomInButton.x, 
                        14, 8, 8, "Autosolve the current selection.\nShift-click or shift-marquee to select."
            );
        m_solveButton.addEventListener(Event.TRIGGERED, onSolveSelection);
        m_solveButton.x = m_zoomInButton.bounds.x;  //center around zoomOut center  
        m_solveButton.y = m_zoomInButton.bounds.bottom + 3;
        addChild(m_solveButton);
        
        busyAnimationMovieClip = new MovieClip(BaseComponent.waitAnimationImages, 4);
        
        busyAnimationMovieClip.x = m_solveButton.x + m_solveButton.width + 3;
        busyAnimationMovieClip.y = m_solveButton.y;
        busyAnimationMovieClip.scaleX = busyAnimationMovieClip.scaleY = m_solveButton.height / busyAnimationMovieClip.height;
    }
    
    public function startSolveAnimation() : Void
    {
        if (!Starling.current.juggler.contains(this.busyAnimationMovieClip))
        {
            if (busyAnimationMovieClip != null)
            {
                addChild(busyAnimationMovieClip);
            }
            Starling.current.juggler.add(this.busyAnimationMovieClip);
            trace("start animation");
        }
    }
    
    public function stopSolveAnimation() : Void
    {
        Starling.current.juggler.remove(this.busyAnimationMovieClip);
        if (busyAnimationMovieClip != null)
        {
            busyAnimationMovieClip.removeFromParent();
        }
        trace("stop animation");
    }
    
    private function checkForTriggerFullScreen(event : MouseEvent) : Void
    {
        if (m_fullScreenButton == null)
        {
            return;
        }
        if (m_fullScreenButton.parent == null)
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
            ExternalInterface.call("console.log", "Starling.contentScaleFactor:" + Starling.current.contentScaleFactor);
            ExternalInterface.call("console.log", "Starling.current.viewPort:" + Starling.current.viewPort);
            ExternalInterface.call("console.log", "event.stageX,Y:" + event.stageX + ", " + event.stageY);
        }
        buttonTopLeft.x *= Starling.current.contentScaleFactor;
        buttonBottomRight.x *= Starling.current.contentScaleFactor;
        buttonTopLeft.y *= Starling.current.contentScaleFactor;
        buttonBottomRight.y *= Starling.current.contentScaleFactor;
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
        {
        //need to mark that we are doing this, so we don't lose the selection
            
            World.changingFullScreenState = true;
            
            if (Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
            {
                Starling.current.nativeStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
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
    
    
    private function onMenuButtonTriggered() : Void
    {
        if (PipeJam3.TUTORIAL_DEMO)
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.SHOW_GAME_MENU));
        }
        else
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.GET_RANDOM_LEVEL));
        }
    }
    
    private function onStartOverButtonTriggered() : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.START_OVER));
    }
    
    private function onZoomInButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.ZOOM_IN));
    }
    
    private function onZoomOutButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.ZOOM_OUT));
    }
    
    private function onRecenterButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.RECENTER));
    }
    
    private function onShareButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.POST_SUBMIT_DIALOG));
    }
    
    private function onSaveButtonTriggered() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.POST_SAVE_DIALOG));
    }
    
    public function onMaxZoomReached() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = false;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = true;
        }
    }
    
    public function onMinZoomReached() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = true;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = false;
        }
    }
    
    public function onZoomReset() : Void
    {
        if (m_zoomInButton != null)
        {
            m_zoomInButton.enabled = true;
        }
        if (m_zoomOutButton != null)
        {
            m_zoomOutButton.enabled = true;
        }
    }
    
    private function onSolveSelection() : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.SOLVE_SELECTION));
    }
    
    public function removedFromStage(event : Event) : Void
    {
        Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, checkForTriggerFullScreen);
    }
    
    public function newLevelSelected(level : Level) : Void
    {
        updateScore(level, true);
        TextFactory.getInstance().updateText(m_levelNameTextfield, level.original_level_name);
        TextFactory.getInstance().updateAlign(m_levelNameTextfield, 1, 0);
        setNavigationButtonVisibility(level.getPanZoomAllowed());
        setSolveButtonsVisibility(level.getSolveButtonsAllowed());
    }
    
    private function setNavigationButtonVisibility(viz : Bool) : Void
    {
        m_zoomInButton.visible = viz;
        m_zoomOutButton.visible = viz;
        m_recenterButton.visible = viz;
    }
    
    private function setSolveButtonsVisibility(viz : Bool) : Void
    {
        m_solveButton.visible = viz;
    }
    
    /**
		 * Updates the score on the screen
		 */
    public function updateScore(level : Level, skipAnimatons : Bool) : Void
    {
        var currentScore : Int = level.currentScore;
        var bestScore : Int = level.bestScore;
        var targetScore : Int = level.getTargetScore();
        var maxScoreShown : Float = Math.max(currentScore, bestScore);
        maxScoreShown = Math.max(1, maxScoreShown);  // avoid divide by zero  
        if (targetScore < as3hx.Compat.INT_MAX)
        {
            maxScoreShown = Math.max(maxScoreShown, targetScore);
        }
        
        TextFactory.getInstance().updateText(m_scoreTextfield, Std.string(currentScore));
        TextFactory.getInstance().updateAlign(m_scoreTextfield, 2, 1);
        
        // Aim for max score shown to be 2/3 of the width of the scorebar area
        var newBarWidth : Float = (SCORE_PANEL_AREA.width * 2 / 3) * Math.max(0, currentScore) / maxScoreShown;
        var bestScoreX : Float = (SCORE_PANEL_AREA.width * 2 / 3) * Math.max(0, bestScore) / maxScoreShown;
        var newScoreX : Float = newBarWidth - m_scoreTextfield.width;
        if (m_scoreBar == null)
        {
            m_scoreBar = new Quad(Math.max(1, newBarWidth), 2.0 * SCORE_PANEL_AREA.height / 3.0, GameComponent.NARROW_COLOR);
            m_scoreBar.setVertexColor(2, GameComponent.WIDE_COLOR);
            m_scoreBar.setVertexColor(3, GameComponent.WIDE_COLOR);
            m_scoreBar.y = SCORE_PANEL_AREA.height / 6.0;
            m_scoreTextfield.x = newScoreX;
        }
        m_scoreBarContainer.addChild(m_scoreBar);
        
        if (targetScore < as3hx.Compat.INT_MAX)
        {
            if (m_targetScoreLine == null)
            {
                m_targetScoreLine = new TargetScoreDisplay(Std.string(targetScore), 0.65 * GameControlPanel.SCORE_PANEL_AREA.height, TextBubble.GOLD, TextBubble.GOLD, "Target Score");
            }
            else
            {
                m_targetScoreLine.update(Std.string(targetScore));
            }
            m_targetScoreLine.x = (SCORE_PANEL_AREA.width * 2.0 / 3.0) * targetScore / maxScoreShown;
            m_scoreBarContainer.addChild(m_targetScoreLine);
            m_scoreBarContainer.visible = true;
            m_scoreTextfield.visible = true;
        }
        else
        {
            if (m_targetScoreLine != null)
            {
                m_targetScoreLine.removeFromParent();
            }
            if (m_scoreBarContainer != null)
            {
                m_scoreBarContainer.visible = false;
            }
            m_scoreTextfield.visible = false;
        }
        
        if (m_bestPlayerScoreLine == null)
        {
            m_bestPlayerScoreLine = new TargetScoreDisplay(Std.string(bestScore), 0.35 * GameControlPanel.SCORE_PANEL_AREA.height, GameComponent.WIDE_COLOR, GameComponent.WIDE_COLOR, "Best Score\nClick to Load");
            m_bestPlayerScoreLine.addEventListener(TouchEvent.TOUCH, onTouchBestScore);
            m_bestPlayerScoreLine.useHandCursor = true;
            m_bestPlayerScoreLine.x = bestScoreX;
        }
        else
        {
            m_bestPlayerScoreLine.update(Std.string(bestScore));
        }
        m_bestPlayerScoreLine.alpha = 0.8;
        m_scoreBarContainer.addChild(m_bestPlayerScoreLine);
        
        if (newBarWidth < SCORE_PANEL_AREA.width / 10)
        {
        // If bar is not wide enough, put the text to the right of it instead of inside the bar
            
            TextFactory.getInstance().updateColor(m_scoreTextfield, 0xFFFFFF);
            newScoreX = -m_scoreTextfield.width + SCORE_PANEL_AREA.width / 10;
        }
        else
        {
            TextFactory.getInstance().updateColor(m_scoreTextfield, 0x0);
        }
        
        var FLASHING_ANIM_SEC : Float = 0;  // TODO: make this nonzero when animation is in place  
        var DELAY : Float = 0.5;
        var BAR_SLIDING_ANIM_SEC : Float = 1.0;
        if (skipAnimatons)
        {
            Starling.current.juggler.removeTweens(m_scoreBar);
            m_scoreBar.width = newBarWidth;
            Starling.current.juggler.removeTweens(m_scoreTextfield);
            m_scoreTextfield.x = newScoreX;
            Starling.current.juggler.removeTweens(m_bestPlayerScoreLine);
            m_bestPlayerScoreLine.x = bestScoreX;
        }
        else if (newBarWidth < m_scoreBar.width)
        {
        // If we're shrinking, shrink right away - then show flash showing the difference
            
            Starling.current.juggler.removeTweens(m_scoreBar);
            Starling.current.juggler.tween(m_scoreBar, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        width : newBarWidth
                    });
            Starling.current.juggler.removeTweens(m_scoreTextfield);
            Starling.current.juggler.tween(m_scoreTextfield, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        x : newScoreX
                    });
            Starling.current.juggler.removeTweens(m_bestPlayerScoreLine);
            Starling.current.juggler.tween(m_bestPlayerScoreLine, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        x : bestScoreX
                    });
        }
        else if (newBarWidth > m_scoreBar.width)
        {
        // If we're growing, flash the difference first then grow
            
            Starling.current.juggler.removeTweens(m_scoreBar);
            Starling.current.juggler.tween(m_scoreBar, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        delay : FLASHING_ANIM_SEC,
                        width : newBarWidth
                    });
            Starling.current.juggler.removeTweens(m_scoreTextfield);
            Starling.current.juggler.tween(m_scoreTextfield, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        delay : FLASHING_ANIM_SEC,
                        x : newScoreX
                    });
            Starling.current.juggler.removeTweens(m_bestPlayerScoreLine);
            Starling.current.juggler.tween(m_bestPlayerScoreLine, BAR_SLIDING_ANIM_SEC, {
                        transition : Transitions.EASE_OUT,
                        x : bestScoreX
                    });
        }
        else
        {
            return;
        }
        
        // If we've spilled off to the right, shrink it down after we've animated showing the difference
        
        var barBounds : Rectangle = m_scoreBar.getBounds(m_scorePanel);
        // Adjust bounds to be relative to top left=(0,0) and unscaled (scaleX,Y=1)
        var adjustedBounds : Rectangle = barBounds.clone();
        adjustedBounds.x -= m_scoreBarContainer.x;
        adjustedBounds.x /= m_scoreBarContainer.scaleX;
        adjustedBounds.y -= m_scoreBarContainer.y;
        adjustedBounds.y /= m_scoreBarContainer.scaleY;
        adjustedBounds.width /= m_scoreBarContainer.scaleX;
        adjustedBounds.height /= m_scoreBarContainer.scaleY;
        
        // Tween to make this fit the area we want it to, ONLY IF OFF SCREEN
        var newScaleX : Float = SCORE_PANEL_AREA.width / barBounds.width;
        //var newScaleY:Number = Math.min(SCORE_PANEL_MAX_SCALEY, SCORE_PANEL_AREA.height / adjustedBounds.height);
        var newX : Float = -barBounds.x * newScaleX;  // left-adjusted  
        //var newY:Number = SCORE_PANEL_AREA.height - adjustedBounds.bottom * newScaleY; // sits on the bottom
        // Only move the score blocks around/scale if some of the blocks are offscreen (out of score panel area)
        // OR if was shrunk below 100% and doesn't need to be
        if (barBounds.left < 0 || barBounds.right > SCORE_PANEL_AREA.width || ((m_scoreBarContainer.scaleX < 1.0) && (newScaleX > m_scoreBarContainer.scaleX)))
        {
            Starling.current.juggler.removeTweens(m_scoreBarContainer);
            Starling.current.juggler.tween(m_scoreTextfield, 1.5, {
                        transition : Transitions.EASE_OUT,
                        delay : (FLASHING_ANIM_SEC + BAR_SLIDING_ANIM_SEC + 2 * DELAY),
                        scaleX : newScaleX
                    });
        }
    }
    
    private function onTouchBestScore(evt : TouchEvent) : Void
    {
        if (m_bestPlayerScoreLine == null)
        {
            return;
        }
        if (evt.getTouches(m_bestPlayerScoreLine, TouchPhase.ENDED).length > 0)
        {
        // Clicked, load best score!
            
            dispatchEvent(new MenuEvent(MenuEvent.LOAD_BEST_SCORE));
        }
        else if (evt.getTouches(m_bestPlayerScoreLine, TouchPhase.HOVER).length > 0)
        {
        // Hover over
            
            m_bestPlayerScoreLine.alpha = 1;
        }
        // Hover out
        else
        {
            
            m_bestPlayerScoreLine.alpha = 0.8;
        }
    }
    
    private function onTouchHighScore(evt : TouchEvent) : Void
    {
        if (m_bestScoreLine == null)
        {
            return;
        }
        if (evt.getTouches(m_bestScoreLine, TouchPhase.ENDED).length > 0)
        {
        // Clicked, load best score!
            
            dispatchEvent(new MenuEvent(MenuEvent.LOAD_HIGH_SCORE));
        }
        else if (evt.getTouches(m_bestScoreLine, TouchPhase.HOVER).length > 0)
        {
        // Hover over
            
            m_bestScoreLine.alpha = 1;
        }
        // Hover out
        else
        {
            
            m_bestScoreLine.alpha = 0.8;
        }
    }
    
    public function setHighScores(highScoreArray : Array<Dynamic>) : Void
    {
        var level : Level = World.m_world.active_level;
        if (level != null && highScoreArray != null)
        {
            var currentScore : Int = level.currentScore;
            var bestScore : Int = level.bestScore;
            var targetScore : Int = level.getTargetScore();
            var maxScoreShown : Float = Math.max(currentScore, targetScore);
            var score : String = highScoreArray[0].current_score;
            
            if (m_bestScoreLine == null)
            {
                m_bestScoreLine = new TargetScoreDisplay(score, 0.05 * GameControlPanel.SCORE_PANEL_AREA.height, TextBubble.RED, TextBubble.RED, "High Score");
                m_bestScoreLine.addEventListener(TouchEvent.TOUCH, onTouchHighScore);
            }
            else
            {
                m_bestScoreLine.update(score);
            }
            m_bestScoreLine.x = (SCORE_PANEL_AREA.width * 2.0 / 3.0) * as3hx.Compat.parseInt(score) / maxScoreShown;
            m_scoreBarContainer.addChild(m_bestScoreLine);
        }
    }
    
    public function adjustSize(newWidth : Float, newHeight : Float) : Void
    //adjust back to standard?
    {
        
        var topLeftScorePanel : Point;
        if (Starling.current.nativeStage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
        {
            scaleX = 960 / newWidth;
            scaleY = 640 / newHeight;
            x = (480 - width) / 2;  //center  
            y = 320 - 72 * scaleY + 10;
            topLeftScorePanel = m_scorePanel.localToGlobal(new Point(0, 0));
            m_scorePanel.clipRect = new Rectangle(topLeftScorePanel.x, topLeftScorePanel.y, m_scorePanel.width, m_scorePanel.height);
            //m_fullScreenButton.visible = false;
            //m_smallScreenButton.visible = true;
        }
        else
        {
            scaleX = scaleY = 1;
            x = 0;
            y = 320 - height + 10;  //level name extends up out of the bounds  
            topLeftScorePanel = m_scorePanel.localToGlobal(new Point(0, 0));
            m_scorePanel.clipRect = new Rectangle(topLeftScorePanel.x, topLeftScorePanel.y, m_scorePanel.width, m_scorePanel.height);
            //m_fullScreenButton.visible = true;
            //m_smallScreenButton.visible = false;
        }
    }
    
    public function addSoundButton(m_sfxButton : SoundButton) : Void
    {
        m_sfxButton.x = 20;
        //center in between buttons
        m_sfxButton.y = (m_newLevelButton.bounds.bottom + m_resetButton.bounds.top) / 2 - m_sfxButton.height / 2;
        addChild(m_sfxButton);
    }
}