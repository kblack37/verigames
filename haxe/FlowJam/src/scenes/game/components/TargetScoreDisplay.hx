package scenes.game.components;

import assets.AssetsFont;
import display.ToolTippableSprite;
import openfl.Assets;
import starling.display.Quad;
import events.ToolTipEvent;

class TargetScoreDisplay extends ToolTippableSprite
{
    private var m_targetScoreTextfield : TextFieldWrapper;
    private var m_textHitArea : Quad;
    private var m_toolTipText : String;
    
    public function new(score : String, textY : Float, lineColor : Int, fontColor : Int, toolTipText : String = "")
    {
        super();
        m_toolTipText = toolTipText;
        // Add a dotted line effect
        for (dq in 0...10)
        {
            var dottedQ : Quad = new Quad(1, 1, lineColor);
            dottedQ.x = -dottedQ.width / 2;
            dottedQ.y = ((dq + 1.0) / 11.0) * GameControlPanel.SCORE_PANEL_AREA.height;
            addChild(dottedQ);
        }
        m_targetScoreTextfield = try cast(TextFactory.getInstance().createTextField(score, Assets.getFont("fonts/UbuntuTitling-Bold.otf"), GameControlPanel.SCORE_PANEL_AREA.width / 2, GameControlPanel.SCORE_PANEL_AREA.height / 3.0, GameControlPanel.SCORE_PANEL_AREA.height / 3.0, fontColor), TextFieldWrapper) catch(e:Dynamic) null;
        m_targetScoreTextfield.x = 2.0;
        
        TextFactory.getInstance().updateAlign(m_targetScoreTextfield, 0, 1);
        m_targetScoreTextfield.y = textY;
        addChild(m_targetScoreTextfield);
        // Create hit areas for capturing mouse events
        m_textHitArea = new Quad(m_targetScoreTextfield.textBounds.width, m_targetScoreTextfield.textBounds.height, 0xFFFFFF);
        m_textHitArea.x = m_targetScoreTextfield.x + m_targetScoreTextfield.textBounds.x;
        m_textHitArea.y = m_targetScoreTextfield.y + m_targetScoreTextfield.textBounds.y;
        m_textHitArea.alpha = 0;
        addChild(m_textHitArea);
        var lineHitArea : Quad = new Quad(8, GameControlPanel.SCORE_PANEL_AREA.height, 0xFFFFFF);
        lineHitArea.x = -4;
        lineHitArea.alpha = 0;
        addChild(lineHitArea);
    }
    
    public function update(score : String) : Void
    {
        TextFactory.getInstance().updateText(m_targetScoreTextfield, score);
        TextFactory.getInstance().updateAlign(m_targetScoreTextfield, 0, 1);
        m_textHitArea.width = m_targetScoreTextfield.textBounds.width;
        m_textHitArea.height = m_targetScoreTextfield.textBounds.height;
        m_textHitArea.x = m_targetScoreTextfield.x + m_targetScoreTextfield.textBounds.x;
        m_textHitArea.y = m_targetScoreTextfield.y + m_targetScoreTextfield.textBounds.y;
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    {
        return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, m_toolTipText);
    }
}