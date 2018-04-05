package userInterface;

import userInterface.components.*;
import flash.text.*;
import utilities.Fonts;
import visualWorld.*;
import networkGraph.*;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Bitmap;

class GameControlPanel extends RectangularObject
{
    /** Graphical object showing user's score */
    private var score_pane : RectangularObject;
    
    /** Text label for SCORE */
    private var score_title_textfield : TextField;
    
    /** Text showing current score on score_pane */
    private var score_textfield : TextField;
    
    /** Text font, etc associated with the title "SCORE" */
    private var score_title_textformat : TextFormat;
    
    /** Text font, etc associated with the score */
    private var score_textformat : TextFormat;
    
    /** Button allowing user to place a buzzsaw on the current board */
    public var buzzsaw_button : ImageButton;
    
    /** Button to bring the user back to the previous board */
    public var back_button : BitmapButton;
    
    /** Button to save to XML */
    private var exit_button : BitmapButton;
    
    /** Button to replay last level */
    private var replay_button : BitmapButton;
    
    /** Button to save to XML */
    private var save_button : BitmapButton;
    
    /** Button to save XML and return to end to end system */
    private var submit_button : BitmapButton;
    
    /** Score of the player */
    private var current_score : Int = 0;
    
    /** Most recent score of the player (could be used to animate between the two, but currently is not) */
    private var prev_score : Int = 0;
    
    
    @:meta(Embed(source="../../lib/assets/ExitButton.png"))

    public var ExitButtonImageClass : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/ExitButtonClick.png"))

    public var ExitButtonClickImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/ReplayButton.png"))

    public var ReplayButtonImageClass : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/ReplayButtonClick.png"))

    public var ReplayButtonClickImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/SaveButton.png"))

    public var SaveButtonImageClass : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/SaveButtonClick.png"))

    public var SaveButtonClickImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/SubmitButton.png"))

    private var SubmitButtonImageClass : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/SubmitButtonClick.png"))

    private var SubmitButtonClickImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/BackButton.png"))

    private var BackButtonImageClass : Class<Dynamic>;
    @:meta(Embed(source="../../lib/assets/BackButtonClick.png"))

    private var BackButtonClickImageClass : Class<Dynamic>;
    
    private var m_gameSystem : VerigameSystem;
    private var m_initialized : Bool = false;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, gameSystem : VerigameSystem)
    {
        super(_x, _y, _width, _height);
        m_gameSystem = gameSystem;
    }
    
    public function init() : Void
    {
        score_title_textfield = new TextField();
        score_textfield = new TextField();
        score_pane = new RectangularObject(0, 200, 330, 84);
        score_title_textformat = new TextFormat(Fonts.FONT_DEFAULT, 18, 0xFFFFFF, true, false, false, null, null, TextFormatAlign.CENTER);
        score_textformat = new TextFormat(Fonts.FONT_FRACTION, 45, 0x00CCFF, true, false, false, null, null, TextFormatAlign.CENTER);
        
        score_title_textfield.x = 0;
        score_title_textfield.y = 4;
        
        score_pane.graphics.clear();
        score_pane.graphics.beginFill(0x0, 0.0);
        score_pane.graphics.lineStyle(1.0, 0x0, 0.0);
        score_pane.graphics.drawRect(0, 0, 200, 80);
        score_pane.graphics.endFill();
        score_pane.name = "score_pane";
        score_title_textfield.embedFonts = true;
        score_title_textfield.text = "SCORE";
        score_title_textfield.setTextFormat(score_title_textformat);
        score_title_textfield.wordWrap = true;
        score_title_textfield.width = score_pane.width;
        score_title_textfield.autoSize = TextFieldAutoSize.CENTER;
        score_title_textfield.selectable = false;
        score_title_textfield.name = "score_title";
        score_pane.addChild(score_title_textfield);
        score_textfield.embedFonts = true;
        score_textfield.text = "0";
        score_textfield.setTextFormat(score_textformat);
        score_textfield.wordWrap = true;
        score_textfield.width = score_pane.width;
        score_textfield.x = 0;
        score_textfield.autoSize = TextFieldAutoSize.CENTER;
        score_textfield.y = 24;
        score_textfield.selectable = false;
        score_textfield.name = "score_textfield";
        score_pane.addChild(score_textfield);
        
        var merge_mc : MovieClip = new ArtSignConstructionMergeIcon();
        merge_mc.x = 0.5 * merge_mc.width;
        merge_mc.y = 0.5 * merge_mc.height;
        var buzz_button_parent : Sprite = new Sprite();
        buzz_button_parent.addChild(merge_mc);
        var merge_roll_mc : MovieClip = new ArtSignConstructionMerge();
        merge_roll_mc.x = 0.5 * merge_roll_mc.width;
        merge_roll_mc.y = 0.5 * merge_roll_mc.height;
        var buzz_roll_button_parent : Sprite = new Sprite();
        buzz_roll_button_parent.addChild(merge_roll_mc);
        buzzsaw_button = new ImageButton(65, 300, 200, 200, buzz_button_parent, buzz_roll_button_parent, m_gameSystem.buzzsawButtonClick);
        buzzsaw_button.name = "buzzsaw_button";
        
        var exit_button_image : Bitmap = Type.createInstance(ExitButtonImageClass, []);
        var exit_button_roll_image : Bitmap = Type.createInstance(ExitButtonClickImageClass, []);
        exit_button = new BitmapButton(10, 10, 80, 80, exit_button_image, exit_button_roll_image, m_gameSystem.onBackToMainMenuButtonClick);
        exit_button.name = "exit_button";
        
        var replay_button_image : Bitmap = Type.createInstance(ReplayButtonImageClass, []);
        var replay_button_roll_image : Bitmap = Type.createInstance(ReplayButtonClickImageClass, []);
        replay_button = new BitmapButton(90, 10, 80, 80, replay_button_image, replay_button_roll_image, m_gameSystem.onReplayButtonClick);
        replay_button.name = "replay_button";
        
        var save_button_image : Bitmap = Type.createInstance(SaveButtonImageClass, []);
        var save_button_roll_image : Bitmap = Type.createInstance(SaveButtonClickImageClass, []);
        save_button = new BitmapButton(10, 40, 80, 80, save_button_image, save_button_roll_image, m_gameSystem.onSaveButtonClick);
        save_button.name = "save_button";
        //		addChild(save_button);
        var submit_button_image : Bitmap = Type.createInstance(SubmitButtonImageClass, []);
        var submit_button_roll_image : Bitmap = Type.createInstance(SubmitButtonClickImageClass, []);
        submit_button = new BitmapButton(10, 70, 80, 80, submit_button_image, submit_button_roll_image, m_gameSystem.onSubmitButtonClick);
        submit_button.name = "submit_button";
        //		addChild(submit_button);
        var back_button_image : Bitmap = Type.createInstance(BackButtonImageClass, []);
        var back_button_roll_image : Bitmap = Type.createInstance(BackButtonClickImageClass, []);
        back_button = new BitmapButton(90, 55, 80, 80, back_button_image, back_button_roll_image, m_gameSystem.onBackButtonClick);
        back_button.name = "back_button";
        //		addChild(back_button);
        back_button.disabled = true;
        
        m_initialized = true;
    }
    
    public function isInitialized() : Bool
    {
        return m_initialized;
    }
    
    /**
		 * Re-calculates score and updates the score on the screen
		 */
    public function updateScore() : Void
    /* Current scoring:
			* 
			For pipes:
			No points for any red pipe.
			For green pipes:
			10 points for every wide input pipe
			5 points for every narrow input pipe
			10 points for every narrow output pipe
			5 points for every wide output pipe
			1 point for every internal pipe, no matter what its width
			
			For solving the game:
			30 points per board solved
			- Changed this to 30 from 10 = original
			
			100 points per level solved
			1000 points per world solved
			
			For each exception to the laws of physics:
			-50 points
			*/
    {
        
        
        var currentWorld : World = m_gameSystem.current_world;
        
        prev_score = current_score;
        var my_score : Int = 0;
        for (my_level/* AS3HX WARNING could not determine type for var: my_level exp: EField(EIdent(currentWorld),levels) type: null */ in currentWorld.levels)
        {
            if (!my_level.failed)
            {
                my_score += 100;
            }
            for (my_board/* AS3HX WARNING could not determine type for var: my_board exp: EField(EIdent(my_level),boards) type: null */ in my_level.boards)
            {
                if (my_board.trouble_points.length == 0)
                {
                    my_score += 30;
                }
                for (my_pipe/* AS3HX WARNING could not determine type for var: my_pipe exp: EField(EIdent(my_board),pipes) type: null */ in my_board.pipes)
                {
                    if (my_pipe.has_buzzsaw)
                    {
                        my_score -= 50;
                    }
                    if (!my_pipe.failed)
                    {
                        my_score += 1;
                        
                        var is_input : Bool = false;
                        if (my_pipe.associated_edge.from_node.kind == NodeTypes.INCOMING)
                        {
                            is_input = true;
                        }
                        
                        var is_output : Bool = false;
                        if (my_pipe.associated_edge.to_node.kind == NodeTypes.OUTGOING)
                        {
                            is_output = true;
                        }
                        
                        if (is_input && (my_pipe.is_wide))
                        {
                            my_score += 10;
                        }
                        else if (is_input && (!my_pipe.is_wide))
                        {
                            my_score += 5;
                        }
                        
                        if (is_output && (my_pipe.is_wide))
                        {
                            my_score += 5;
                        }
                        else if (is_output && (!my_pipe.is_wide))
                        {
                            my_score += 10;
                        }
                    }
                }
            }
        }
        
        current_score = my_score;
        
        score_textfield.text = Std.string(current_score);
        score_textfield.setTextFormat(score_textformat);
        if (score_textfield.parent == score_pane)
        {
            score_pane.removeChild(score_textfield);
        }
        score_pane.addChild(score_textfield);
        
        // TODO: animate away the old score - translate up and alpha out
        
        draw();
    }
    
    
    /**
		 * Draw current graphics: background, UI, buzzsaws, etc
		 */
    public function draw() : Void
    {
        graphics.clear();
        
        
        if (score_pane.parent == this)
        {
            removeChild(score_pane);
        }
        addChild(score_pane);
        
        if (exit_button.parent == this)
        {
            setChildIndex(exit_button, numChildren - 1);
        }
        else
        {
            addChild(exit_button);
        }
        if (replay_button.parent == this)
        {
            setChildIndex(replay_button, numChildren - 1);
        }
        else
        {
            addChild(replay_button);
        }
        if (save_button.parent == this)
        {
            setChildIndex(save_button, numChildren - 1);
        }
        else
        {
            addChild(save_button);
        }
        if (submit_button.parent == this)
        {
            setChildIndex(submit_button, numChildren - 1);
        }
        else
        {
            addChild(submit_button);
        }
        if (back_button.parent == this)
        {
            setChildIndex(back_button, numChildren - 1);
        }
        else
        {
            addChild(back_button);
        }
        
        if (buzzsaw_button.parent != this)
        {
            addChild(buzzsaw_button);
        }
        else
        {
            setChildIndex(buzzsaw_button, numChildren - 1);
        }
    }
}
