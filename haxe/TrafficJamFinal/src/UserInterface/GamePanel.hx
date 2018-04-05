package userInterface;

import events.CGSServerLocal;
import system.VerigameServerConstants;
import userInterface.components.BitmapButton;
import userInterface.components.ImageButton;
import userInterface.components.RectangularObject;
import utilities.Fonts;
import visualWorld.Board;
import visualWorld.VerigameSystem;
import visualWorld.World;
import cgs.server.logging.actions.ClientAction;
import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.*;
import flash.text.TextField;

class GamePanel extends RectangularObject
{
    private var m_gameSystem : VerigameSystem;
    private var m_initialized : Bool = false;
    public var m_currentBoard : Board = null;
    
    private var m_currentLevel : Int = 0;
    
    public var m_gameSurface : RectangularObject;
    private var m_gameSurfaceBorder : Int = 25;
    
    private var back_button : BitmapButton;
    public var next_button : BitmapButton;
    public var exit_button : BitmapButton;
    
    private var textFieldVector : Array<TextField> = null;
    
    /** The animated buzzsaw asset */
    @:meta(Embed(source="../../lib/assets/NextButtonUp.png"))

    private var NextLevelButtonClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/NextButtonOver.png"))

    private var NextLevelClickButtonClass : Class<Dynamic>;
    
    /** The animated buzzsaw asset */
    @:meta(Embed(source="../../lib/assets/BackButtonUp.png"))

    private var BackLevelButtonClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/BackButtonOver.png"))

    private var BackLevelClickButtonClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/ExitButton.png"))

    private var ExitButtonClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/ExitButtonClick.png"))

    private var ExitClickButtonClass : Class<Dynamic>;
    
    private var nextButtonBottomOffset : Int;
    private var backButtonBottomOffset : Int;
    private var buttomBottomBorder : Int = 60;
    
    private var buzzsaw_button : ImageButton;
    public var replayWorld : World;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, gameSystem : VerigameSystem)
    {
        super(_x, _y, _width, _height);
        m_gameSystem = gameSystem;
        
        m_gameSurface = new RectangularObject(m_gameSurfaceBorder, m_gameSurfaceBorder, width - (2 * m_gameSurfaceBorder), height - (2 * m_gameSurfaceBorder) - Board.ACTIVE_FONT_SIZE - m_gameSurfaceBorder);
        addChild(m_gameSurface);
        
        var back_button_image : Bitmap = Type.createInstance(BackLevelButtonClass, []);
        var back_button_roll_image : Bitmap = Type.createInstance(BackLevelClickButtonClass, []);
        backButtonBottomOffset = as3hx.Compat.parseInt(back_button_image.height + buttomBottomBorder);
        back_button = new BitmapButton(10, m_gameSurface.height - back_button_image.height - 60, back_button_image.width, back_button_image.height, 
                back_button_image, back_button_roll_image, onBackButtonClickEvent);
        back_button.name = "back_button";
        back_button.visible = false;
        m_gameSurface.addChild(back_button);
        
        var next_button_image : Bitmap = Type.createInstance(NextLevelButtonClass, []);
        var next_button_roll_image : Bitmap = Type.createInstance(NextLevelClickButtonClass, []);
        nextButtonBottomOffset = as3hx.Compat.parseInt(next_button_image.height + buttomBottomBorder);
        next_button = new BitmapButton(m_gameSurface.width - next_button_image.width - 10, m_gameSurface.height - nextButtonBottomOffset, 
                next_button_image.width, next_button_image.height, next_button_image, next_button_roll_image, onNextButtonClickEvent);
        next_button.name = "next_button";
        next_button.visible = true;
        m_gameSurface.addChild(next_button);
        
        var exit_button_image : Bitmap = Type.createInstance(ExitButtonClass, []);
        var exit_button_roll_image : Bitmap = Type.createInstance(ExitClickButtonClass, []);
        exit_button = new BitmapButton(10, 10, exit_button_image.width, exit_button_image.height, exit_button_image, exit_button_roll_image, m_gameSystem.onBackToMainMenuButtonClick);
        exit_button.name = "exit_button";
        m_gameSurface.addChild(exit_button);
        
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
        buzzsaw_button = new ImageButton(10, m_gameSurface.height / 2, 100, 100, buzz_button_parent, buzz_roll_button_parent, m_gameSystem.buzzsawButtonClick);
        buzzsaw_button.name = "buzzsaw_button";
        m_gameSurface.addChild(buzzsaw_button);
    }
    
    private function onBackButtonClickEvent(event : MouseEvent) : Void
    // TODO Auto-generated method stub
    {
        
        if (m_currentLevel > 0)
        {
            m_gameSystem.selecting_level = false;
            m_currentLevel--;
            m_gameSystem.selectLevel(m_gameSystem.worlds[0].findLevel(m_currentLevel));
            
            if (m_gameSystem.worlds[0].levels.length > m_currentLevel + 1)
            {
                next_button.visible = true;
            }
            if (m_currentLevel == 0)
            {
                back_button.visible = false;
            }
        }
        
        //make sure this is in the right place
        // if you get to the last screen and then go back, you need to move this
        exit_button.x = 10;
        exit_button.y = 10;
        
        
        m_gameSystem.selecting_level = false;
    }
    
    private function onNextButtonClickEvent(event : MouseEvent) : Void
    // TODO Auto-generated method stub
    {
        
        if (m_currentLevel + 1 < m_gameSystem.worlds[0].levels.length)
        {
            m_gameSystem.selecting_level = false;
            m_currentLevel++;
            m_gameSystem.selectLevel(m_gameSystem.worlds[0].findLevel(m_currentLevel));
            
            //hide until level completed
            if (m_gameSystem.active_board.level.failed == true)
            {
                next_button.visible = false;
            }
            
            if (m_gameSystem.worlds[0].levels.length == m_currentLevel + 1)
            {
                next_button.visible = false;
            }
            
            if (m_currentLevel > 0)
            {
                back_button.visible = true;
            }
        }
        
        m_gameSystem.selecting_level = false;
    }
    
    
    public function init() : Void
    {
        m_initialized = true;
    }
    
    public function isInitialized() : Bool
    {
        return m_initialized;
    }
    
    public function getContentRectangle() : RectangularObject
    {
        return m_gameSurface;
    }
    
    public function setGameSize(fullScreen : Bool = false) : Void
    {
        m_currentLevel = 0;
        
        if (fullScreen)
        {
            this.x = 0;
            this.y = 0;
            this.width = VerigameSystem.GAME_WIDTH;
            this.height = VerigameSystem.GAME_HEIGHT;
            m_gameSurface.width = width - (2 * m_gameSurfaceBorder);
            m_gameSurface.height = height - (2 * m_gameSurfaceBorder) - 2 * Board.ACTIVE_FONT_SIZE - m_gameSurfaceBorder;
            next_button.visible = false;
            exit_button.visible = true;
        }
        else
        {
            next_button.visible = false;
            back_button.visible = false;
            exit_button.visible = false;
        }
    }
    
    public function levelCompleted() : Void
    {
        if (m_gameSystem.worlds[0].levels.length > m_currentLevel + 1)
        {
            next_button.visible = true;
        }
        else
        {
            exit_button.x = next_button.x;
            exit_button.y = next_button.y;
        }
    }
    
    //logEvent = false if this is a replay event
    public function update(board : Board, logEvent : Bool = true) : Void
    {
        if (!m_initialized)
        {
            return;
        }
        
        if (VerigameSystem.LOGGING_ON && logEvent)
        {
            var switchBoardAction : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_SWITCH_BOARDS);
            switchBoardAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_BOARD_NAME, this.m_gameSystem.m_currentNetwork.obfuscator.getReverseBoardName(board.board_name));
            switchBoardAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME, this.m_gameSystem.m_currentNetwork.obfuscator.getReverseLevelName(board.level.level_name));
            CGSServerLocal.logQuestAction(switchBoardAction);
        }
        
        if (m_currentBoard != null)
        {
            if (m_currentBoard.parent)
            {
                m_currentBoard.parent.removeChild(m_currentBoard);
            }
        }
        m_currentBoard = board;
        
        if (m_currentBoard != null)
        {
            buzzsaw_button.visible = false;
            
            //get rid of old and create new
            if (textFieldVector != null)
            {
                while (textFieldVector.length > 0)
                {
                    var textFieldItem : TextField = textFieldVector.pop();
                    if (textFieldItem.parent)
                    {
                        textFieldItem.parent.removeChild(textFieldItem);
                    }
                }
            }
            textFieldVector = new Array<TextField>();
            
            var displayMetadata : FastXML = m_currentBoard.m_boardNodes.metadata["display"];
            
            if (displayMetadata != null)
            {
                displayTextMetadata(displayMetadata);
                
                
                for (buzzsawBlock in displayMetadata.get("buzzsaw"))
                {
                    var visibilityCheck : Bool = buzzsawBlock.nodes.attribute.get("visible");
                    buzzsaw_button.visible = visibilityCheck;
                }
            }
            m_currentBoard.x = 0;
            m_currentBoard.y = 0;
            m_currentBoard.scaleX = m_gameSurface.width / m_currentBoard.width;
            if (m_currentBoard.scaleX < .2)
            {
                m_currentBoard.scaleX = .2;
            }  //completely arbitrary, currently  
            //m_currentBoard.scaleY = m_currentBoard.scaleX;
            m_currentBoard.scaleY = m_gameSurface.height / m_currentBoard.height;
            m_gameSurface.addChild(m_currentBoard);
            m_currentBoard.activate();
            draw();
        }
    }
    
    public function displayTextMetadata(textParent : FastXML) : Void
    {
        for (textBlock in textParent.get("text-block"))
        {
            var textList : FastXMLList = textBlock.get("text");
            var textField : TextField = new TextField();
            textField.text = textList.get(0);  //should only be one  
            textField.x = textBlock.node.attribute.innerData("x");
            textField.y = textBlock.node.attribute.innerData("y");
            textField.autoSize = TextFieldAutoSize.LEFT;
            if (textBlock.get("font") != null)
            {
                var fontInfo : FastXML = textBlock.get("font").get(0);
                
                var fontSize : Int = 10;
                if (fontInfo.node.attribute.innerData("size").length() > 0)
                {
                    fontSize = fontInfo.node.attribute.innerData("size");
                }
                
                var fontFace : String = Fonts.FONT_DEFAULT;
                if (fontInfo.node.attribute.innerData("face").length() > 0)
                {
                    fontFace = fontInfo.node.attribute.innerData("face");
                }
                
                var color : Float = 0xFFFFFF;
                if (fontInfo.node.attribute.innerData("color").length() > 0)
                {
                    color = fontInfo.node.attribute.innerData("color");
                }
                
                var tf : TextFormat = new TextFormat(fontFace, fontSize, color);
                textField.setTextFormat(tf);
            }
            textFieldVector.push(textField);
        }
    }
    
    public function draw() : Void
    {
        m_currentBoard.draw();
        m_currentBoard.drawSubBoards();
        
        if (next_button.parent == m_gameSurface)
        {
            m_gameSurface.removeChild(next_button);
        }
        m_gameSurface.addChild(next_button);
        
        next_button.x = m_gameSurface.width - next_button.width - 10;
        next_button.y = m_gameSurface.height - nextButtonBottomOffset;
        
        if (back_button.parent == m_gameSurface)
        {
            m_gameSurface.removeChild(back_button);
        }
        m_gameSurface.addChild(back_button);
        
        back_button.y = m_gameSurface.height - backButtonBottomOffset;
        
        if (exit_button.parent == m_gameSurface)
        {
            m_gameSurface.removeChild(exit_button);
        }
        m_gameSurface.addChild(exit_button);
        
        if (buzzsaw_button.parent == m_gameSurface)
        {
            m_gameSurface.removeChild(buzzsaw_button);
        }
        m_gameSurface.addChild(buzzsaw_button);
        
        for (tf in textFieldVector)
        {
            if (tf.parent)
            {
                tf.parent.removeChild(tf);
            }
            m_gameSurface.addChild(tf);
        }
    }
}
