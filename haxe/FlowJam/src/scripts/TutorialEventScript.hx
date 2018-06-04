package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.MiniMapEvent;
import starling.display.Sprite;

/**
 * Event scripts for GridViewPanel.
 * 
 * @author ...
 */
class TutorialEventScript extends ScriptNode 
{
	private var gameEngine : IGameEngine;
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
		
		gameEngine.addEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
        gameEngine.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
        gameEngine.addEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
		
		gameEngine.addEventListener(TutorialEventScript.SHOW_CONTINUE, displayContinueButton);
		gameEngine.addEventListener(TutorialEventScript.HIGHLIGHT_BOX, onHighlightTutorialEvent);
		gameEngine.addEventListener(TutorialEventScript.HIGHLIGHT_EDGE, onHighlightTutorialEvent);
		gameEngine.addEventListener(TutorialEventScript.HIGHLIGHT_PASSAGE, onHighlightTutorialEvent);
		gameEngine.addEventListener(TutorialEventScript.HIGHLIGHT_CLASH, onHighlightTutorialEvent);
		gameEngine.addEventListener(TutorialEventScript.HIGHLIGHT_SCOREBLOCK, onHighlightTutorialEvent);
		gameEngine.addEventListener(TutorialEventScript.NEW_TUTORIAL_TEXT, onTutorialTextChange);
		gameEngine.addEventListener(TutorialEventScript.NEW_TOOLTIP_TEXT, onPersistentToolTipTextChange);
	}
	
	private var m_fanfareContainer : Sprite = new Sprite();
    private var m_fanfare : Array<FanfareParticleSystem> = new Array<FanfareParticleSystem>();
    private var m_fanfareTextContainer : Sprite = new Sprite();
    private var m_stopFanfareDelayedCallId : Int;
	/**
	 * Display the next level continue button. 
	 * 
	 * @param	permanently Whether to force the display for the continue button (and ignore score).
	 */
    public function displayContinueButton(permanently : Bool = false) : Void
    {
        if (permanently)
        {
            m_continueButtonForced = true;
        }
        if (continueButton == null)
        {
            continueButton = ButtonFactory.getInstance().createDefaultButton("Next Level", 128, 32);
            continueButton.addEventListener(Event.TRIGGERED, onNextLevelButtonTriggered);
            continueButton.x = WIDTH - continueButton.width - 5;
            continueButton.y = HEIGHT - continueButton.height - 20 - GameControlPanel.OVERLAP;
        }
        
        if (!m_currentLevel.targetScoreReached)
        {
            m_currentLevel.targetScoreReached = true;
            if (PipeJamGameScene.inTutorial)
            {
                addChild(continueButton);
            }
            
            // Fanfare
            removeFanfare();
            addChild(m_fanfareContainer);
            m_fanfareContainer.x = m_fanfareTextContainer.x = WIDTH / 2 - continueButton.width / 2;
            m_fanfareContainer.y = m_fanfareTextContainer.y = continueButton.y - continueButton.height;
            
            var levelCompleteText : String = (PipeJamGameScene.inTutorial) ? "Level Complete!" : "Great work!\nBut keep playing to further improve your score.";
            var textWidth : Float = (PipeJamGameScene.inTutorial) ? continueButton.width : 208;
            
            var i : Int = 5;
            while (i <= textWidth - 5)
            {
                var fanfare : FanfareParticleSystem = new FanfareParticleSystem();
                fanfare.x = i;
                fanfare.y = continueButton.height / 2;
                fanfare.scaleX = fanfare.scaleY = 0.4;
                m_fanfare.push(fanfare);
                m_fanfareContainer.addChild(fanfare);
                i += 10;
            }
            
            startFanfare();
            var LEVEL_COMPLETE_TEXT_MOVE_SEC : Float = (PipeJamGameScene.inTutorial) ? 2.0 : 0.0;
            var LEVEL_COMPLETE_TEXT_FADE_SEC : Float = (PipeJamGameScene.inTutorial) ? 0.0 : 1.0;
            var LEVEL_COMPLETE_TEXT_PAUSE_SEC : Float = (PipeJamGameScene.inTutorial) ? 1.0 : 5.0;
            var textField : TextFieldWrapper = TextFactory.getInstance().createTextField(levelCompleteText, "_sans", textWidth, continueButton.height, 16, 0xFFEC00);
            if (!PipeJam3.DISABLE_FILTERS)
            {
                TextFactory.getInstance().updateFilter(textField, OutlineFilter.getOutlineFilter());
            }
            m_fanfareTextContainer.addChild(textField);
            m_fanfareTextContainer.alpha = 1;
            addChild(m_fanfareTextContainer);
            
            if (PipeJamGameScene.inTutorial)
            {
            // For tutorial, move text and button off to the side
                
                var origX : Float = m_fanfareTextContainer.x;
                var origY : Float = m_fanfareTextContainer.y;
                for (i in 0...m_fanfare.length)
                {
                    Starling.current.juggler.tween(m_fanfare[i], LEVEL_COMPLETE_TEXT_MOVE_SEC, {
                                delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                                particleX : (continueButton.x - origX),
                                particleY : (continueButton.y - continueButton.height - origY),
                                transition : Transitions.EASE_OUT
                            });
                }
                Starling.current.juggler.tween(m_fanfareTextContainer, LEVEL_COMPLETE_TEXT_MOVE_SEC, {
                            delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                            x : continueButton.x,
                            y : continueButton.y - continueButton.height,
                            transition : Transitions.EASE_OUT
                        });
            }
            // For real levels, gradually fade out text
            else
            {
                
                Starling.current.juggler.tween(m_fanfareTextContainer, LEVEL_COMPLETE_TEXT_FADE_SEC, {
                            delay : LEVEL_COMPLETE_TEXT_PAUSE_SEC,
                            alpha : 0,
                            transition : Transitions.EASE_IN
                        });
            }
            m_stopFanfareDelayedCallId = Starling.current.juggler.delayCall(stopFanfare, LEVEL_COMPLETE_TEXT_PAUSE_SEC + LEVEL_COMPLETE_TEXT_MOVE_SEC + LEVEL_COMPLETE_TEXT_FADE_SEC - 0.5);
        }
        
        if (PipeJamGameScene.inTutorial)
        {
            TutorialController.getTutorialController().addCompletedTutorial(m_currentLevel.m_tutorialTag, true);
        }
    }

	/**
	 * Callback function executed when a piece of the tutorial is highlighted. Highlights a tutorial element.
	 * 
	 * @param	evt The event with the information on the new tutorial to highlight.
	 */
    public function onHighlightTutorialEvent(evt : TutorialEvent) : Void
    {
        if (!evt.highlightOn)
        {
            removeSpotlight();
            return;
        }
        if (m_currentLevel == null)
        {
            return;
        }
        var edge : GameEdgeContainer;
        var _sw1_ = (evt.type);        

        switch (_sw1_)
        {
            case TutorialEvent.HIGHLIGHT_BOX:
                var node : GameNode = m_currentLevel.getNode(evt.componentId);
                if (node != null)
                {
                    spotlightComponent(node);
                }
            case TutorialEvent.HIGHLIGHT_EDGE:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null)
                {
                    spotlightComponent(edge, 3.0, 1.75, 1.2);
                }
            case TutorialEvent.HIGHLIGHT_PASSAGE:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null && edge.innerFromBoxSegment != null)
                {
                    spotlightComponent(edge.innerFromBoxSegment, 3.0, 3, 2);
                }
            case TutorialEvent.HIGHLIGHT_CLASH:
                edge = m_currentLevel.getEdgeContainer(evt.componentId);
                if (edge != null && edge.errorContainer != null)
                {
                    spotlightComponent(edge.errorContainer, 3.0, 1.3, 1.3);
                }
        }
    }
    
	
	/**
	 * Callback function executed when a tutorial message changes. Changes tutorial text.
	 * 
	 * @param	evt The event with the information on the new tutorial message.
	 */
    public function onTutorialTextChange(evt : TutorialEvent) : Void
    {
        if (m_tutorialText != null)
        {
            m_tutorialText.removeFromParent(true);
            m_tutorialText = null;
        }
        
        var levelTextInfo : TutorialManagerTextInfo = ((evt.newTextInfo.length == 1)) ? evt.newTextInfo[0] : null;
        if (levelTextInfo != null)
        {
            m_tutorialText = new TutorialText(m_currentLevel, levelTextInfo);
            addChild(m_tutorialText);
        }
    }
	
}