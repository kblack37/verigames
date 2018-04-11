package cgs.logotos;

import openfl.display.Sprite;
import haxe.Constraints.Function;
import cgs.assets.fonts.FontVegur;
import cgs.server.data.TosData;
import cgs.server.data.IUserTosStatus;
import cgs.user.ICgsUser;

class TosUi extends Sprite
{
    private var textWidth(get, never) : Float;
    private var textX(get, never) : Float;
    private var showLinkTosButton(get, never) : Bool;
    private var disagreedScreenText(get, never) : String;
    private var agree(get, never) : String;
    private var disagree(get, never) : String;

    public static var NO_TOS : String = null;
    
    public static var EXEMPT : String = TosData.EXEMPT_TERMS;
    public static var NO_USER_NAME_TOS_40648_V1 : String = TosData.NO_USER_NAME_TOS_40648_TERMS;
    public static var USER_NAME_TOS_40648_V1 : String = TosData.USER_NAME_TOS_40648_TERMS;
    public static var TEACHER_TOS_40648_V1 : String = TosData.TEACHER_TOS_40648_TERMS;
    public static var THIRTEEN_OLDER_TOS_41035_V1 : String = TosData.THIRTEEN_OLDER_TOS_41035_TERMS;
    public static var SEVEN_TO_TWELVE_TOS_41035_V1 : String = TosData.SEVEN_TO_TWELVE_TOS_41035_TERMS;
    public static var COPILOT_45954_V3 : String = TosData.COPILOT_45954_TERMS;
    
    private static var FONT_REGISTERED : Bool = RegisterDefaultFonts();
    
    public static inline var FONT_DEFAULT : String = "Vegur";
    
    private static inline var BUTTON_WIDTH : Float = 180;
    private static inline var BUTTON_HEIGHT : Float = 50;
    
    //Set the max width of textfor readability.
    private static inline var MAX_TEXT_WIDTH : Float = 640;
    
    private var _cgsUser : ICgsUser;
    private var _userTosStatus : IUserTosStatus;
    private var _requireTos : Bool;
    
    private var _callback : Function;
    private var _gameName : String;
    private var _width : Float;
    private var _height : Float;
    private var _tosTextShown : String;
    private var _tosPane : ScrollPane;
    
    private var _showHeader : Bool;
    private var _showFooter : Bool;
    
    private var _headerTextField : TextField;
    private var _tosTextField : TextField;
    private var _footerTextField : TextField;
    
    private var _tosPaneBackground : MovieClip;
    private var _headerBackground : Sprite;
    private var _footerBackground : Sprite;
    
    private var _tosBodyFormat : TextFormat = 
        new TextFormat(FONT_DEFAULT, 18, 0x0, null, null, null, null, null);
    
    private var _tosHeaderFormat : TextFormat = 
        new TextFormat(FONT_DEFAULT, 22, 0x0, null, null, 
        null, null, null, TextFormatAlign.CENTER);
    
    private var m_button_format : TextFormat = new TextFormat(FONT_DEFAULT, 28, 
        0x0, true, null, null, null, null, TextFormatAlign.LEFT);
    
    private var _agreeButton : Button;
    private var _disagreeButton : Button;
    
    private var m_disagree_screen_text : TextField;
    private var _disagreeTextBackground : Sprite;
    private var _backTosButton : Button;
    
    //private var m_under_13_instructions:TextField;
    //private var m_under_13_instructions_background:Sprite;
    private var _showLinkButton : Bool;
    private var _linkTosButton : Button;
    
    //Variables used to determine what text and components should be displayed.
    //private var m_show_13_under_button:Boolean;
    //private var m_tos_terms:String;
    //private var m_tos_terms_text:String;
    
    private var _hGap : Int = 20;
    private var _vGap : Int = 20;
    
    /**
		 * UI and logging for Terms of Service screen.
		 * There is a Terms of Service text scrollpane, "Agree" instruction,
		 * and Agree Button and a Disagree button.
		 *
		 * @param _cgsServerInstance The initialized server instance used for logging - setup by game prior to this constructor
		 * @param _callback Function to call when terms of service is complete (accepts no arguments)
		 * @param _width Desired width of Terms of Service UI
		 * @param _height Desired height of Terms of Service UI
		 *
		 */
    public function new(
            cgsUser : ICgsUser, userTosStatus : IUserTosStatus,
            callback : Function, gameName : String, requireTos : Bool = true,
            width : Float = 800, height : Float = 600, fontName : String = "Vegur")
    {
        super();
        
        _cgsUser = cgsUser;
        _userTosStatus = userTosStatus;
        _requireTos = requireTos;
        
        _callback = callback;
        _gameName = gameName;
        _width = width;
        _height = height;
        
        _tosBodyFormat.font = fontName;
        m_button_format.font = fontName;
        
        createChildren();
        
        validateLayout();
        updateTerms();
    }
    
    private function handleAddedToStage(evt : Event) : Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        stage.invalidate();
    }
    
    private function get_textWidth() : Float
    {
        var maxWidth : Float = _width - _hGap - _hGap;
        return Math.min(maxWidth, MAX_TEXT_WIDTH);
    }
    
    private function get_textX() : Float
    {
        return (_width - textWidth) / 2;
    }
    
    private function updateTerms() : Void
    {
        if (_userTosStatus != null)
        {
            _showHeader = _userTosStatus.hasHeader;
            _headerTextField.visible = _showHeader;
            _headerBackground.visible = _showHeader;
            if (_showHeader)
            {
                var headerText : String = _gameName + "\n";
                headerText += _userTosStatus.termsHeader;
                _headerTextField.text = headerText;
                _headerTextField.width = textWidth;
            }
            
            _showFooter = _userTosStatus.hasFooter;
            _footerTextField.visible = _showFooter;
            _footerBackground.visible = _showFooter;
            if (_showFooter)
            {
                _footerTextField.text = _userTosStatus.termsFooter;
            }
            
            _showLinkButton = _userTosStatus.hasTosLink;
            _linkTosButton.visible = _showLinkButton;
            if (_showLinkButton)
            {
                _linkTosButton.label = _userTosStatus.linkTosText;
                if (!contains(_linkTosButton))
                {
                    addChild(_linkTosButton);
                }
            }
            
            _tosTextField.text = _userTosStatus.termsBody;
            _tosTextField.height = _tosTextField.textHeight;
            _tosPane.refreshPane();
            
            if (stage == null)
            {
                addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
            }
            else
            {
                stage.invalidate();
            }
            
            validateLayout();
        }
        else
        {
            //No terms to be shown, call the complete callback.
            handleComplete();
        }
    }
    
    private function get_showLinkTosButton() : Bool
    {
        return (_userTosStatus != null) ? _userTosStatus.hasTosLink : false;
    }
    
    //Remeasure and layout the elements.
    private function validateLayout() : Void
    {
        //Setup the header and footer and then figure out
        //how tall the scroll pane should be.
        var headerHeight : Float = 0;
        var textXPos : Float = textX;
        
        if (_showHeader)
        {
            _headerBackground.x = textXPos;
            _headerBackground.y = _vGap;
            
            drawTextBackground(_headerBackground, 
                    _headerTextField.width, _headerTextField.height
            );
            
            _headerTextField.y = _headerBackground.y;
            _headerTextField.x = textXPos;
            
            headerHeight = _headerTextField.height + _vGap;
        }
        
        m_disagree_screen_text.x = 0.1 * _width;
        m_disagree_screen_text.y = 0.3 * _height;
        m_disagree_screen_text.width = 0.8 * _width;
        m_disagree_screen_text.height = 0.2 * _height;
        
        _disagreeTextBackground.x = m_disagree_screen_text.x;
        _disagreeTextBackground.y = m_disagree_screen_text.y;
        
        if (_showLinkButton)
        {
            _linkTosButton.x = textXPos;
            _linkTosButton.y = headerHeight + _vGap;
            _linkTosButton.setSize(textWidth, 32);
            
            headerHeight += _vGap + _linkTosButton.height;
        }
        
        drawTextBackground(_disagreeTextBackground, 
                m_disagree_screen_text.width, m_disagree_screen_text.height
        );
        
        var buttonWidth : Float = _agreeButton.width + _disagreeButton.width + _hGap;
        var buttonX : Float = textX + ((textWidth - buttonWidth) / 2);
        
        _agreeButton.x = buttonX;
        _agreeButton.y = _height - _vGap - _disagreeButton.height;
        
        _disagreeButton.x = _agreeButton.x + _agreeButton.width + _vGap;
        _disagreeButton.y = _agreeButton.y;
        
        _backTosButton.x = 0.5 * _width - 1 * BUTTON_WIDTH;
        _backTosButton.y = 0.6 * _height;
        
        var footerY : Float = _disagreeButton.y;
        if (_showFooter)
        {
            _footerTextField.width = textWidth;
            _footerTextField.x = textXPos;
            _footerTextField.y = _agreeButton.y - _vGap - _footerTextField.height;
            
            _footerBackground.x = _footerTextField.x;
            _footerBackground.y = _footerTextField.y;
            
            footerY = _footerBackground.y;
            
            drawTextBackground(_footerBackground, _footerTextField.width, _footerTextField.height);
        }
        
        var tosPaneHeight : Float = footerY - headerHeight - _vGap - _vGap;
        
        _tosPane.x = textXPos;
        _tosPane.y = headerHeight + _vGap;
        _tosPane.setSize(textWidth, tosPaneHeight);
        
        _tosTextField.width = _tosPane.width - _hGap;
        
        drawTextBackground(_tosPaneBackground, _tosPane.width, _tosPane.height);
    }
    
    private function handleTosTextResize(evt : Event) : Void
    {
        _tosTextField.height = _tosTextField.textHeight + 4;
        _tosPane.refreshPane();
        
        _headerTextField.height = _headerTextField.textHeight + 4;
        _footerTextField.height = _footerTextField.textHeight + 4;
        
        validateLayout();
    }
    
    private function drawTextBackground(sprite : Sprite, textWidth : Float, textHeight : Float) : Void
    {
        var g : Graphics = sprite.graphics;
        g.clear();
        
        var mat : Matrix = new Matrix();
        mat.createGradientBox(textWidth, textHeight, 90);
        
        sprite.graphics.beginGradientFill(
                GradientType.LINEAR, new Array<Dynamic>(0xF0F0F0, 0xAAAAAA), 
                new Array<Dynamic>(0.8, 0.8), new Array<Dynamic>(0, 255), mat
        );
        
        sprite.graphics.drawRoundRect(0, 0, textWidth, textHeight, 10, 10);
    }
    
    private function createChildren() : Void
    {
        _tosTextField = new TextField();
        _tosTextField.addEventListener(Event.RENDER, handleTosTextResize);
        _tosTextField.multiline = true;
        _tosTextField.embedFonts = true;
        _tosTextField.wordWrap = true;
        _tosTextField.defaultTextFormat = _tosBodyFormat;
        
        _tosPane = new ScrollPane();
        _tosPaneBackground = new MovieClip();
        _tosPane.setStyle("skin", _tosPaneBackground);
        _tosPane.setStyle("upSkin", _tosPaneBackground);
        _tosPane.source = _tosTextField;
        
        _footerTextField = new TextField();
        _footerTextField.multiline = true;
        _footerTextField.embedFonts = true;
        _footerTextField.wordWrap = true;
        _footerTextField.defaultTextFormat = _tosBodyFormat;
        
        _footerBackground = new Sprite();
        
        _headerTextField = new TextField();
        _headerTextField.multiline = true;
        _headerTextField.embedFonts = true;
        _headerTextField.wordWrap = true;
        _headerTextField.defaultTextFormat = _tosHeaderFormat;
        
        _headerBackground = new Sprite();
        
        var measuringTextfield : TextField = new TextField();
        measuringTextfield.defaultTextFormat = m_button_format;
        measuringTextfield.embedFonts = true;
        measuringTextfield.text = agree;
        
        var agreeWidth : Float = Math.max(measuringTextfield.textWidth, BUTTON_WIDTH);
        _agreeButton = new Button();
        _agreeButton.setSize(agreeWidth, BUTTON_HEIGHT);
        _agreeButton.label = agree;
        _agreeButton.setStyle("textFormat", m_button_format);
        _agreeButton.setStyle("embedFonts", true);
        _agreeButton.setStyle("icon", Art_AcceptIcon);
        _agreeButton.addEventListener(MouseEvent.CLICK, onClickAgree);
        
        measuringTextfield.text = disagree;
        var disagreeWidth : Float = Math.max(measuringTextfield.textWidth, BUTTON_WIDTH);
        _disagreeButton = new Button();
        _disagreeButton.setSize(disagreeWidth, BUTTON_HEIGHT);
        _disagreeButton.label = disagree;
        _disagreeButton.setStyle("textFormat", m_button_format);
        _disagreeButton.setStyle("embedFonts", true);
        _disagreeButton.setStyle("icon", Art_DeclineIcon);
        _disagreeButton.addEventListener(MouseEvent.CLICK, onClickDisagree);
        
        /* Shown if "Disagree" is pressed. Cannot procceed to the game (callback is not called). */
        m_disagree_screen_text = new TextField();
        m_disagree_screen_text.embedFonts = true;
        m_disagree_screen_text.wordWrap = true;
        m_disagree_screen_text.defaultTextFormat = _tosBodyFormat;
        m_disagree_screen_text.text = this.disagreedScreenText;
        
        _disagreeTextBackground = new Sprite();
        
        _backTosButton = new Button();
        _backTosButton.label = "Back to Terms of Service";
        
        _backTosButton.setSize(2 * BUTTON_WIDTH, BUTTON_HEIGHT);
        _backTosButton.setStyle("textFormat", m_button_format);
        _backTosButton.setStyle("embedFonts", true);
        _backTosButton.addEventListener(MouseEvent.CLICK, onBackToTOS);
        
        _linkTosButton = new Button();
        _linkTosButton.setStyle("textFormat", _tosBodyFormat);
        _linkTosButton.setStyle("embedFonts", true);
        _linkTosButton.addEventListener(MouseEvent.CLICK, handleLinkTosButtonClick);
    }
    
    /**
		 * Function called after the CGSTos object has been added to the stage to display the UI elements.
		 *
		 */
    public function load() : Void
    {
        if (showLinkTosButton)
        {
            addChild(_linkTosButton);
        }
        if (_showHeader)
        {
            addChild(_headerBackground);
            addChild(_headerTextField);
        }
        
        addChild(_tosPane);
        addChild(_footerBackground);
        addChild(_footerTextField);
        addChild(_agreeButton);
        addChild(_disagreeButton);
        
        validateLayout();
    }
    
    private function onClickAgree(e : MouseEvent) : Void
    {
        saveTosStatus(true);
        handleComplete();
    }
    
    private function onClickDisagree(e : MouseEvent) : Void
    {
        saveTosStatus(false);
        
        if (_requireTos)
        {
            removeAll();
            
            addChild(_disagreeTextBackground);
            addChild(m_disagree_screen_text);
            addChild(_backTosButton);
        }
        else
        {
            handleComplete();
        }
    }
    
    private function handleComplete() : Void
    {
        unload();
        if (_callback != null)
        {
            _callback();
        }
    }
    
    private function onBackToTOS(e : MouseEvent) : Void
    {
        removeAll();
        
        updateTerms();
        _tosPane.verticalScrollPosition = 0;
        _tosPane.refreshPane();
        
        load();
    }
    
    private function removeAll() : Void
    {
        while (numChildren > 0)
        {
            removeChildAt(0);
        }
    }
    
    private function handleLinkTosButtonClick(e : MouseEvent) : Void
    {
        _userTosStatus.useLinkedTerms();
        updateTerms();
        _tosPane.verticalScrollPosition = 0;
        _tosPane.refreshPane();
    }
    
    private function setTOSText(text : String) : Void
    {
        if (_tosTextField != null)
        {
            _tosTextShown = text;
            _tosTextField.text = _gameName + "\n\n" + text;
            _tosTextField.height = _tosTextField.textHeight;
        }
    }
    
    private function saveTosStatus(status : Bool) : Void
    {
        if (_cgsUser != null)
        {
            _userTosStatus.updateAcceptance(status);
            _cgsUser.updateTosStatus(_userTosStatus);
        }
    }
    
    private function unload() : Void
    {
        graphics.clear();
        _agreeButton.removeEventListener(MouseEvent.CLICK, onClickAgree);
        _disagreeButton.removeEventListener(MouseEvent.CLICK, onClickDisagree);
        _linkTosButton.removeEventListener(MouseEvent.CLICK, handleLinkTosButtonClick);
        
        removeAll();
        
        _tosPane = null;
        _tosTextField = null;
        _footerBackground = null;
        _footerTextField = null;
        _agreeButton = null;
        _disagreeButton = null;
        _linkTosButton = null;
    }
    
    private static function RegisterDefaultFonts() : Bool
    {
        if (!FONT_REGISTERED)
        {
            Font.registerFont(FontRoboto);
            Font.registerFont(FontVegur);
        }
        
        return true;
    }
    
    //
    // Internationalization handling. (HACK: Need to add new lines for every new language code
    //
    private function get_disagreedScreenText() : String
    {
        var text : String = "";
        var languageCode : String = _cgsUser.languageCode;
        if (languageCode == "no")
        {
        }
        else
        {
            if (languageCode == "fr")
            {
            }
            else
            {
                text = "You have chosen to " +
                        "disagree to the Terms of Service. If you wish to play this game, " +
                        "you may click below to return to the " +
                        "Terms of Service and change your response.";
            }
        }
        
        return text;
    }
    
    private function get_agree() : String
    {
        var languageCode : String = _cgsUser.languageCode;
        if (languageCode == "no")
        {
            return "Enig";
        }
        else
        {
            if (languageCode == "fr")
            {
                return "D'accord";
            }
        }
        
        return "Agree";
    }
    
    private function get_disagree() : String
    {
        var languageCode : String = _cgsUser.languageCode;
        if (languageCode == "no")
        {
            return "Uenig";
        }
        else
        {
            if (languageCode == "fr")
            {
                return "No";
            }
        }
        
        return "Disagree";
    }
}
