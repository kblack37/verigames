package cgs.logotos;

import haxe.crypto.Md5;
import src.cgs.ui.Button;
import cgs.ui.ScrollPane;
import cgs.logotos.assets.FileAssets;
import openfl.utils.Assets;
import haxe.Constraints.Function;
import cgs.assets.fonts.FontRoboto;
import cgs.assets.fonts.FontVegur;
import cgs.server.logging.ICgsServerApi;
import openfl.display.DisplayObject;
import openfl.display.GradientType;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class CGSTos extends Sprite
{
    public static var NO_TOS : String = null;
    public static inline var NO_USER_NAME_TOS_40648_V1 : String = "40648_nousername";
    public static inline var USER_NAME_TOS_40648_V1 : String = "40648_username";
    public static inline var TEACHER_TOS_40648_V1 : String = "40648_teacher";
    public static inline var THIRTEEN_OLDER_TOS_41035_V1 : String = "41035_13up";
    public static inline var SEVEN_TO_TWELVE_TOS_41035_V1 : String = "41035_7to12";
    public static inline var COPILOT_45954_V3 : String = "45954_copilot";

    //TODO: fix
    private static var FONT_REGISTERED : Bool = false;//RegisterDefaultFonts();
    
    public static inline var FONT_DEFAULT : String = "Vegur";
    
    private static inline var BUTTON_WIDTH : Float = 180;
    private static inline var BUTTON_HEIGHT : Float = 50;
    
    private var m_cgsServerInstance : ICgsServerApi;
    private var m_callback : Function;
    private var m_gameName : String;
    private var m_width : Float;
    private var m_height : Float;
    private var m_tos_text_shown : String;
    private var m_tos_pane : ScrollPane;
    private var m_tos_text : TextField;
    private var m_tos_by_clicking : TextField;
    private var m_tos_by_clicking_background : Sprite;
    private var m_tos_format : TextFormat = new TextFormat(FONT_DEFAULT, 18, 0x0, null, null, null, null, null, TextFormatAlign.CENTER);
    private var m_button_format : TextFormat = new TextFormat(FONT_DEFAULT, 28, 0x0, true, null, null, null, null, TextFormatAlign.LEFT);
    private var m_agree_button : Button;
    private var m_disagree_button : Button;
    private var m_disagree_screen_text : TextField;
    private var m_disagree_screen_text_background : Sprite;
    private var m_back_to_tos_button : Button;
    private var m_under_13_instructions : TextField;
    private var m_under_13_instructions_background : Sprite;
    private var m_under_13_button : Button;
    
    //Variables used to determine what text and components should be displayed.
    private var m_show_13_under_button : Bool;
    private var m_tos_terms : String;
    private var m_tos_terms_text : String;
    
    /**
		 * UI and logging for Terms of Service screen. There is a Terms of Service text scrollpane, "Agree" instruction, and Agree Button and a Disagree button.
		 * @param _cgsServerInstance The initialized server instance used for logging - setup by game prior to this constructor
		 * @param _callback Function to call when terms of service is complete (accepts no arguments)
		 * @param _width Desired width of Terms of Service UI
		 * @param _height Desired height of Terms of Service UI
		 *
		 */
    public function new(_cgsServerInstance : ICgsServerApi, _callback : Function, _gameName : String, _tos_terms : String, _width : Float = 800, _height : Float = 600, fontName : String = "Vegur")
    {
        super();
        
        m_cgsServerInstance = _cgsServerInstance;
        m_callback = _callback;
        m_gameName = _gameName;
        m_tos_terms = _tos_terms;
        m_width = _width;
        m_height = _height;
        graphics.clear();
        
        m_tos_format.font = fontName;
        m_button_format.font = fontName;
        
        m_tos_text = new TextField();
        m_tos_text.embedFonts = true;
        m_tos_text.wordWrap = true;
        m_tos_text.width = 0.8 * m_width - 15;
        m_tos_text.defaultTextFormat = m_tos_format;
        m_tos_terms_text = setupTosTerms(_tos_terms);
        setTOSText(m_tos_terms_text);
        m_tos_text.height = m_tos_text.textHeight;
        
        m_tos_pane = new ScrollPane();
        m_tos_pane.x = 0.1 * m_width;
        m_tos_pane.y = 0.2 * m_height;
        m_tos_pane.setSize(0.8 * m_width, 0.3 * m_height);
        var tos_pane_background : MovieClip = new MovieClip();
        tos_pane_background.graphics.clear();
        var mat : Matrix = new Matrix();
        mat.createGradientBox(m_tos_pane.width, m_tos_pane.height, 90);
        tos_pane_background.graphics.beginGradientFill(GradientType.LINEAR, [0xF0F0F0, 0xAAAAAA], [0.8, 0.8],[0, 255], mat);
        tos_pane_background.graphics.drawRoundRect(0, 0, m_tos_pane.width, m_tos_pane.height, 10, 10);
        m_tos_pane.setStyle("skin", tos_pane_background);
        m_tos_pane.setStyle("upSkin", tos_pane_background);
        m_tos_pane.source = m_tos_text;
        
        m_tos_by_clicking = new TextField();
        m_tos_by_clicking.embedFonts = true;
        m_tos_by_clicking.wordWrap = true;
        m_tos_by_clicking.x = 0.1 * m_width;
        m_tos_by_clicking.y = 0.55 * m_height;
        m_tos_by_clicking.width = 0.8 * m_width;
        m_tos_by_clicking.height = 0.2 * m_height;
        m_tos_by_clicking.defaultTextFormat = m_tos_format;
        m_tos_by_clicking.text = _tos_terms == COPILOT_45954_V3 ? TOS_BY_CLICKING_INSTRUCTIONS_COPILOT : TOS_BY_CLICKING_INSTRUCTIONS;
        
        m_tos_by_clicking_background = new Sprite();
        m_tos_by_clicking_background.x = m_tos_by_clicking.x;
        m_tos_by_clicking_background.y = m_tos_by_clicking.y;
        m_tos_by_clicking_background.graphics.clear();
        mat = new Matrix();
        mat.createGradientBox(m_tos_by_clicking.width, m_tos_by_clicking.height, 90);
        m_tos_by_clicking_background.graphics.beginGradientFill(GradientType.LINEAR,[0xF0F0F0, 0xAAAAAA],
        [0.8, 0.8], [0, 255], mat);
        m_tos_by_clicking_background.graphics.drawRoundRect(0, 0, m_tos_by_clicking.width, m_tos_by_clicking.height, 10, 10);
        
        m_agree_button = createDefaultButton("Agree", m_width / 3 - 0.5 * BUTTON_WIDTH, 0.8 * m_height);
        //TODO fix
       // m_agree_button.setStyle("textFormat", m_button_format);
       // m_agree_button.setStyle("embedFonts", true);
       // m_agree_button.setStyle("icon", Art_AcceptIcon);
        m_agree_button.addEventListener(MouseEvent.CLICK, onClickAgree);
        
        m_disagree_button = createDefaultButton("Disagree", 2 * m_width / 3 - 0.5 * BUTTON_WIDTH, 0.8 * m_height);
       // m_disagree_button.setStyle("textFormat", m_button_format);
        //m_disagree_button.setStyle("embedFonts", true);
       // m_disagree_button.setStyle("icon", Art_DeclineIcon);
        m_disagree_button.addEventListener(MouseEvent.CLICK, onClickDisagree);
        
        /* Shown if "Disagree" is pressed. Cannot procceed to the game (callback is not called). */
        m_disagree_screen_text = new TextField();
        m_disagree_screen_text.embedFonts = true;
        m_disagree_screen_text.wordWrap = true;
        m_disagree_screen_text.x = 0.1 * m_width;
        m_disagree_screen_text.y = 0.3 * m_height;
        m_disagree_screen_text.width = 0.8 * m_width;
        m_disagree_screen_text.height = 0.2 * m_height;
        m_disagree_screen_text.defaultTextFormat = m_tos_format;
        m_disagree_screen_text.text = DISAGREED_SCREEN_TEXT;
        
        m_disagree_screen_text_background = new Sprite();
        m_disagree_screen_text_background.x = m_disagree_screen_text.x;
        m_disagree_screen_text_background.y = m_disagree_screen_text.y;
        m_disagree_screen_text_background.graphics.clear();
        mat = new Matrix();
        mat.createGradientBox(m_disagree_screen_text.width, m_disagree_screen_text.height, 90);
        m_disagree_screen_text_background.graphics.beginGradientFill(GradientType.LINEAR, [0xF0F0F0, 0xAAAAAA], [0.8, 0.8], [0, 255], mat);
        m_disagree_screen_text_background.graphics.drawRoundRect(0, 0, m_disagree_screen_text.width, m_disagree_screen_text.height, 10, 10);
        
        m_back_to_tos_button = createDefaultButton("Back to Terms of Service", 0.5 * m_width - 1 * BUTTON_WIDTH, 0.6 * m_height);
        //TODO fix
        //m_back_to_tos_button.setSize(2 * BUTTON_WIDTH, BUTTON_HEIGHT);
       // m_back_to_tos_button.setStyle("textFormat", m_button_format);
       // m_back_to_tos_button.setStyle("embedFonts", true);
        m_back_to_tos_button.addEventListener(MouseEvent.CLICK, onBackToTOS);
        
        /* Only used if there is a separate, accompanying "under 13" TOS */
        m_under_13_instructions = new TextField();
        m_under_13_instructions.embedFonts = true;
        m_under_13_instructions.wordWrap = true;
        m_under_13_instructions.x = 0.1 * m_width;
        m_under_13_instructions.y = 0.1 * m_height;
        m_under_13_instructions.width = 0.8 * m_width;
        m_under_13_instructions.height = 30;
        m_under_13_instructions.defaultTextFormat = m_tos_format;
        m_under_13_instructions.text = UNDER_13_CLICK_HERE_TEXT;
        
        m_under_13_instructions_background = new Sprite();
        m_under_13_instructions_background.x = m_under_13_instructions.x;
        m_under_13_instructions_background.y = m_under_13_instructions.y;
        m_under_13_instructions_background.graphics.clear();
        mat = new Matrix();
        mat.createGradientBox(m_under_13_instructions.width, m_under_13_instructions.height, 90);
        m_under_13_instructions_background.graphics.beginGradientFill(GradientType.LINEAR, [0xF0F0F0, 0xAAAAAA],
        [0.8, 0.8], [0, 255], mat);
        m_under_13_instructions_background.graphics.drawRoundRect(0, 0, m_under_13_instructions.width, m_under_13_instructions.height, 10, 10);
        
        m_under_13_button = createDefaultButton("click here!", m_under_13_instructions.x + 0.5 * (m_under_13_instructions.width + m_under_13_instructions.textWidth) + 10, m_under_13_instructions.y);
        m_under_13_button.setSize(100, 26);
        //TODO fix
        // m_under_13_button.setStyle("textFormat", m_tos_format);
       // m_under_13_button.setStyle("embedFonts", true);
        m_under_13_button.addEventListener(MouseEvent.CLICK, onClickUnder13);
    }
    
    /**
		 * Function called after the CGSTos object has been added to the stage to display the UI elements.
		 *
		 */
    public function load() : Void
    {
        if (m_show_13_under_button)
        {
            addChild(m_under_13_instructions_background);
            addChild(m_under_13_instructions);
            addChild(m_under_13_button);
        }
        addChild(m_tos_pane);
        addChild(m_tos_by_clicking_background);
        addChild(m_tos_by_clicking);
        addChild(m_agree_button);
        addChild(m_disagree_button);
    }
    
    private function onClickAgree(e : MouseEvent) : Void
    {
        trace("agree");
        saveTosStatus(true);
        unload();
        m_callback();
    }
    
    private function onClickDisagree(e : MouseEvent) : Void
    {
        trace("disagree");
        saveTosStatus(false);
        while (numChildren > 0)
        {
            removeChildAt(0);
        }
        addChild(m_disagree_screen_text_background);
        addChild(m_disagree_screen_text);
        addChild(m_back_to_tos_button);
    }
    
    private function onBackToTOS(e : MouseEvent) : Void
    {
        while (numChildren > 0)
        {
            removeChildAt(0);
        }
        setTOSText(m_tos_terms_text);
        m_tos_pane.verticalScrollPosition = 0;
        m_tos_pane.refreshPane();
        load();
    }
    
    private function onClickUnder13(e : MouseEvent) : Void
    {
        if (m_under_13_instructions_background.parent == this)
        {
            removeChild(m_under_13_instructions_background);
        }
        if (m_under_13_instructions.parent == this)
        {
            removeChild(m_under_13_instructions);
        }
        if (m_under_13_button.parent == this)
        {
            removeChild(m_under_13_button);
        }
        m_tos_terms_text = setupTosTerms(SEVEN_TO_TWELVE_TOS_41035_V1);
        setTOSText(m_tos_terms_text);
        m_tos_pane.verticalScrollPosition = 0;
        m_tos_pane.refreshPane();
        m_tos_by_clicking.text = TOS_BY_CLICKING_INSTRUCTIONS_UNDER_13;
    }
    
    private function setTOSText(_text : String) : Void
    {
        if (m_tos_text != null)
        {
            m_tos_text_shown = _text;
            m_tos_text.text = m_gameName + "\n\n" + _text;
            m_tos_text.height = m_tos_text.textHeight;
        }
    }
    
    private function saveTosStatus(status : Bool) : Void
    {
        if (m_cgsServerInstance != null)
        {
            var languageCode : String = "en_US";
            var version : Int = 1;
            var tosHash : String = Md5.encode(m_tos_text_shown);
            m_cgsServerInstance.saveTosStatus(status, version, tosHash, languageCode);
        }
    }
    
    private function unload() : Void
    {
        graphics.clear();
        m_agree_button.removeEventListener(MouseEvent.CLICK, onClickAgree);
        m_disagree_button.removeEventListener(MouseEvent.CLICK, onClickDisagree);
        m_under_13_button.removeEventListener(MouseEvent.CLICK, onClickUnder13);
        while (numChildren > 0)
        {
            var child : DisplayObject = getChildAt(0);
            removeChild(child);
            child = null;
        }
        m_tos_pane = null;
        m_tos_text = null;
        m_tos_by_clicking_background = null;
        m_tos_by_clicking = null;
        m_agree_button = null;
        m_disagree_button = null;
        m_under_13_instructions = null;
        m_under_13_button = null;
    }
    
    private static function createDefaultButton(_text : String, _x : Float, _y : Float) : Button
    {
        var my_button : Button = new Button();
//        my_button.x = _x;
//        my_button.y = _y;
//        my_button.label.text = _text;
//        my_button.setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
        return my_button;
    }
    
    private function setupTosTerms(termsType : String) : String
    {
        var termsText : String = null;
        if (termsType == NO_USER_NAME_TOS_40648_V1)
        {
            termsText = Assets.getText(FileAssets.NoUserNameTos40648V1);
        }
        else
        {
            if (termsType == USER_NAME_TOS_40648_V1)
            {
                termsText = Assets.getText(FileAssets.UserNameTos40648V1);
            }
            else
            {
                if (termsType == THIRTEEN_OLDER_TOS_41035_V1)
                {
                    m_show_13_under_button = true;
                    termsText = Assets.getText(FileAssets.ThirteenOlderTos41035V1);
                }
                else
                {
                    if (termsType == SEVEN_TO_TWELVE_TOS_41035_V1)
                    {
                        m_show_13_under_button = true;
                        termsText = Assets.getText(FileAssets.SevenToTwelveTos40648V1);
                    }
                    else
                    {
                        if (termsType == TEACHER_TOS_40648_V1)
                        {
                            termsText = Assets.getText(FileAssets.TeacherTos40648V1);
                        }
                        else
                        {
                            if (termsType == COPILOT_45954_V3)
                            {
                                termsText = Assets.getText(FileAssets.CopilotTos45954V3);
                            }
                            else
                            {
                                termsText = "No valid Tos found.";
                            }
                        }
                    }
                }
            }
        }
        
        return termsText;
    }
    
    public static inline var UNDER_13_CLICK_HERE_TEXT : String = "Hey kids! If you’re under 13,";
    
    //public static var TOS_TEXT_TO_DISPLAY:String = FACEBOOK_LIKE_13_AND_OVER;
    //public static var TOS_UNDER_13_TEXT_TO_DISPLAY:String = FACEBOOK_LIKE_UNDER_13;
    
    private static inline var TOS_BY_CLICKING_INSTRUCTIONS : String = "By clicking Agree below, you agree that you have read the above terms and give your consent to conduct research on your game playing. If you are under 18, you agree that a parent or guardian has read the above terms and gives their consent for research.";
    private static inline var TOS_BY_CLICKING_INSTRUCTIONS_COPILOT : String = "[X] By leaving this box checked I give permission for my data to be used for research purposes.";
    private static inline var TOS_BY_CLICKING_INSTRUCTIONS_UNDER_13 : String = "By clicking Agree, you agree that a parent or guardian has read this and is letting you play.";
    
    private static inline var DISAGREED_SCREEN_TEXT : String = "You have chosen to disagree to the Terms of Service. If you wish to play this game, you may click below to return to the Terms of Service and change your response.";
    
    private static function RegisterDefaultFonts() : Bool
    {
        if (!FONT_REGISTERED)
        {
            Font.registerFont(FontRoboto);
            Font.registerFont(FontVegur);
        }
        
        return true;
    }
}

