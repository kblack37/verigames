package scenes.game.display;

import assets.AssetsFont;
import display.NineSliceBatch;
import events.GameComponentEvent;
import openfl.Assets;
import openfl.Vector;
import scenes.game.display.GameComponent;
import starling.display.Quad;
import starling.text.TextField;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextFormat;

class ScoreBlock extends GameComponent
{
    /* Name of 9 slice asset to use */
    private var m_assetName : String;
    
    /* 9 slice asset created */
    private var m_sliceBatch : NineSliceBatch;
    
    /** Component associated with this score, GameNodes have points for wide inputs/narrow outputs
		 * while GameEdgeContainers have negative points for errors. Assigning no gameComponent will
		 * just display the score and the ScoreBlock will not be interactive */
    private var m_gameComponent : GameComponent;
    private var m_color : Float;
    private var m_score : String;
    private var m_width : Float;
    private var m_height : Float;
    private var m_fontSize : Float;
    
    /** Text showing current score on score_pane */
    private var m_text : TextField;
    
    public function new(_assetName : String, _score : String, _width : Float, _height : Float, _fontSize : Float, _gameComponent : GameComponent = null, _radius : Float = -1)
    {
        super("");
        m_assetName = _assetName;
        m_score = _score;
        m_width = _width;
        m_height = _height;
        m_fontSize = _fontSize;
        m_gameComponent = _gameComponent;
        if (_radius <= 0)
        {
            _radius = Math.min(m_width, m_height) / 5.0;
        }
        
        m_sliceBatch = new NineSliceBatch(m_width + 2 * _radius, m_height + 2 * _radius, _radius, _radius, "Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML", m_assetName);
        m_sliceBatch.adjustUsedSlices(true, true, false, true, true, false, false, false, false);
        addChild(m_sliceBatch);
        
        var estWidth : Float = 0.5 * (m_fontSize) * m_score.length;
        if (estWidth > m_width + _radius)
        {
        // Adjust font size if width too large
            
            m_fontSize *= (m_width + _radius) / estWidth;
        }
        if (m_score == "1")
        {
        // Cheat for now since TextFields are causing resource limits on larger levels
            
            var one_quad : Quad = new Quad(4, m_height + 2 * _radius - 16, 0x0);
            one_quad.x = _radius + 0.5 * m_width - 2;
            one_quad.y = 8;
            addChild(one_quad);
        }
        else
        {
            m_text = new TextField(Std.int(m_width + 2 * _radius), Std.int(m_height + 2 * _radius), m_score, new TextFormat(Assets.getFont("fonts/UbuntuTitling-Bold.otf").fontName, m_fontSize));
            addChild(m_text);
        }
        
        if (m_gameComponent != null)
        {
            addEventListener(TouchEvent.TOUCH, onTouch);
            this.useHandCursor = true;
        }
    }
    
    override public function dispose() : Void
    {
        if (m_text != null)
        {
            m_text.dispose();
        }
        m_text = null;
        disposeChildren();
        if (hasEventListener(TouchEvent.TOUCH))
        {
            removeEventListener(TouchEvent.TOUCH, onTouch);
        }
        super.dispose();
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Vector<Touch> = event.touches;
        if (event.getTouches(this, TouchPhase.ENDED).length > 0)
        {
            if (touches.length == 1)
            {
                if (Std.is(m_gameComponent, GameEdgeContainer))
                {
                // Center on marker joint - this is where we actually display the error
                    
                    var jointToCenter : GameEdgeJoint = (try cast(m_gameComponent, GameEdgeContainer) catch(e:Dynamic) null).m_markerJoint;
                    dispatchEvent(new GameComponentEvent(GameComponentEvent.CENTER_ON_COMPONENT, jointToCenter));
                }
                else
                {
                    dispatchEvent(new GameComponentEvent(GameComponentEvent.CENTER_ON_COMPONENT, m_gameComponent));
                }
            }
        }
    }
}
