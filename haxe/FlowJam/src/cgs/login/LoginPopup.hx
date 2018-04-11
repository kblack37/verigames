package cgs.login;

import haxe.Constraints.Function;
import cgs.CgsApi;
import cgs.assets.fonts.FontRoboto;
import cgs.server.responses.CgsUserResponse;
import cgs.ui.AlertDialog;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsUser;
import openfl.display.DisplayObject;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldType;

/**
	 * Creates a login UI prompting a user for their username and password and returns when user is either logged in successfully or cancels.
	 *
	 * Sample usage:
	 *
	 * var props:CGSServerProps = new CGSServerProps(...);
	 * CGSServer.setup(props);
	 * var login:LoginPopup = new LoginPopup(CGSServer.instance, onLogin, onCancel);
	 * login.x = 0.5 * myGameWidth;
	 * login.y = 0.5 * myGameHeight;
	 * _game.addChild(login);
	 *
	 * function onLogin():void {
	 *    trace("Login successful, associated uid=" + CGSServer.instance.uid);
	 * }
	 *
	 * function onCancel():void {
	 *    trace("Login Canceled");
	 * }
	 */
class LoginPopup extends Sprite
{
    private var useCachedAuthentication(get, never) : Bool;
    public var teacherCode(never, set) : String;
    public var studentGradeLevel(never, set) : Int;
    public var showCreateStudentDialogOnFail(never, set) : Bool;
    public var usernameAsPassword(never, set) : Bool;
    public var cancelButtonText(get, set) : String;
    public var loginButtonText(get, set) : String;
    public var username(get, set) : String;
    public var password(get, set) : String;

    public static inline var FONT_DEFAULT : String = "Roboto";
    
    private var m_buttonFormat : TextFormat = new TextFormat(FONT_DEFAULT, 24, 0x0, true, null, null, null, null, TextFormatAlign.CENTER);
    private var m_inputFormat : TextFormat = new TextFormat(FONT_DEFAULT, 22, 0x0, true, null, null, null, null, TextFormatAlign.CENTER);
    private var m_titleFormat : TextFormat = new TextFormat(FONT_DEFAULT, 40, 0x384DA0, true, null, null, null, null, TextFormatAlign.CENTER);
    private var m_labelFormat : TextFormat = new TextFormat(FONT_DEFAULT, 30, 0x0, true, null, null, null, null, TextFormatAlign.CENTER);
    private var m_errorFormat : TextFormat = new TextFormat(FONT_DEFAULT, 12, 0xFF0000, true, null, null, null, null, TextFormatAlign.LEFT);
    
    private static var FONT_REGISTERED : Bool = RegisterDefaultFonts();
    
    private var m_cgsApi : CgsApi;
    private var m_loginCallback : Function;
    private var m_cancelCallback : Function;
    private var m_loginFailCallback : Function;
    
    private var m_usernameAsPassword : Bool;
    
    //The user instance that is being authenticated.
    private var m_authUser : ICgsUser;
    private var m_userProps : ICgsUserProperties;
    
    // Teacher code used for authentication and registration.
    private var m_teacherCode : String;
    
    // Grade used for student demographic info
    private var m_studentGrade : Int;
    
    // Gender used for student demographic info
    private var m_gender : Int = 0;
    
    // Default text strings
    private inline static var m_defaultUsernameText : String = "Username";
    private inline static var m_defaultPasswordText : String = "Password";
    private inline static var m_defaultTitleText : String = "Account Login";
    private inline static var m_defaultLoginText : String = "Login";
    private inline static var m_defaultCancelText : String = "Cancel";
    private inline static var m_defaultNameTakenText : String = "Please pick a new username, the name you chose is already in use.";
    private inline static var m_defaultYesText : String = "Yes";
    private inline static var m_defaultNoText : String = "No";
    private inline static var m_defaultCreateAccountText : String = "Are you sure you want to create a new account?";
    private inline static var m_defaultIncorrectUsernamePasswordText : String = "Incorrect username/password. Try again or cancel.";
    private inline static var m_defaultServerErrorText : String = "Server Error";
    private inline static var m_defaultTryAgainLaterText : String = "Try again later or cancel.";
    
    // Text strings to use (i.e. these hold variables to inject into the various text fields)
    private var m_nameTakenText : String;
    private var m_yesText : String;
    private var m_noText : String;
    private var m_createAccountText : String;
    private var m_incorrectUsernamePasswordText : String;
    private var m_serverErrorText : String;
    private var m_tryAgainLaterText : String;
    
    // Accesors to the individual components
    private var m_titleText : TextField;
    private var m_loginButton : SimpleButton;
    private var m_cancelButton : SimpleButton;
    private var m_logo : DisplayObject;
    private var m_usernameInput : TextField;
    private var m_usernameText : TextField;
    private var m_passwordInput : TextField;
    private var m_passwordText : TextField;
    private var m_errorText : TextField;
    private var m_background : DisplayObject;
    
    /**
		 * Should the player be allowed to cancel the prompt
		 */
    private var m_allowCancel : Bool;
    
    /**
		 * Should the password field be present in the login
		 */
    private var m_passwordEnabled : Bool;
    
    /**
     * Should the login popup show an additional prompt asking a student if they
     * want to create an account if the first login attempt fails
     */
    private var m_showCreateStudentDialogOnFail : Bool;
    
    /** Function to be called to create a logo on the popup */
    private var m_createLogoFactory : Function = defaultLogoFactory;
    /** Function to be called to create the title text */
    private var m_createTitleFactory : Function = defaultTitleFactory;
    /** Function to be called to create the label for inputs */
    private var m_createInputLabelFactory : Function = defaultInputLabelFactory;
    /** Function to be called to create the input field */
    private var m_createInputFactory : Function = defaultInputFactory;
    /** Function to be called to create the login button */
    private var m_createLoginButtonFactory : Function = defaultButtonFactory;
    /** Function to be called to create the cancel button */
    private var m_createCancelButtonFactory : Function = defaultButtonFactory;
    /** Function to be called to create the error text field */
    private var m_createErrorFactory : Function = defaultErrorFactory;
    /** Function to be called to create a background container */
    private var m_createBackgroundFactory : Function = defaultBackgroundFactory;
    
    /** Function to be called when it is time to layout the components */
    private var m_layoutFunction : Function = defaultLayout;
    
    /**
		 * Creates a login UI prompting a user for their username and password and returns when user is either logged in successfully or cancels.
		 * @param _cgsServerInstance CGSServer instance used for authenticating user. Make sure to call myCGSServerinstance.setup(props) beforehand, and DO NOT call myCGSServerinstance.init(..) before or afterwards
		 * @param _loginCallback Callback function for when the user logs in successfully, function should have the following signature (cgsUser:ICgsUser):void
		 * @param _cancelCallback Callback function for when the user clicks cancel, takes no arguments
		 * @param _fontName Custom embedded font's name (must be embedded beforehand)
		 *
		 */
    public function new(
            _cgsApi : CgsApi, _cgsProps : ICgsUserProperties, _loginCallback : Function,
            _cancelCallback : Function, _allowCancel : Bool = true,
            _fontName : String = FONT_DEFAULT,
            _useDefaultSkin : Bool = true)
    {
        super();
        
        m_cgsApi = _cgsApi;
        m_userProps = _cgsProps;
        
        m_loginCallback = _loginCallback;
        m_cancelCallback = _cancelCallback;
        m_loginFailCallback = null;
        
        m_buttonFormat.font = _fontName;
        m_inputFormat.font = _fontName;
        m_titleFormat.font = _fontName;
        m_labelFormat.font = _fontName;
        m_errorFormat.font = _fontName;
        
        m_allowCancel = _allowCancel;
        m_showCreateStudentDialogOnFail = true;
        if (_useDefaultSkin)
        {
            this.drawAndLayout();
        }
    }
    
    /**
		 * This callback should be registered if an application needs to know if a login failed
		 * for some reason. It may need this info to alter the display.
		 */
    public function setLoginFailCallback(_loginFailCallback : Function) : Void
    {
        m_loginFailCallback = _loginFailCallback;
    }
    
    /**
		 * To deal with localization, various text strings in the login dialog may need to
		 * be modified from their original english definitions. External applications are
		 * responsible for determining the each translation.
		 * 
		 * If any parameters are null, then default English values are used.
		 * 
		 * @param username
		 * 		Label for username input
		 * @param password
		 * 		Label for password input
		 * @param title
		 * 		The header on top on the main login dialog
		 * @param login
		 * 		Label for the login button
		 * @param cancel
		 * 		Label for the cancel login button
		 * @param nameTaken
		 * 		Warning message when a username is already taken
		 * @param yes
		 * 		Label for confirm button when creating account
		 * @param no
		 * 		Label for declone button when creating account
		 * @param createAccount
		 * 		Notice asking if the player wants to create an account
		 * @param incorrectUserNamePassword
		 * 		Warning message when an attempted login fails
		 * @param serverError
		 * 		Error message when server request fails
		 * @param tryAgainLater
		 * 		Notice asking for user to login later due to error
		 */
    public function setTextOptions(username : String = null,
            password : String = null,
            title : String = null,
            login : String = null,
            cancel : String = null,
            nameTaken : String = null,
            yes : String = null,
            no : String = null,
            createAccount : String = null,
            incorrectUserNamePassword : String = null,
            serverError : String = null,
            tryAgainLater : String = null) : Void
    {
        m_usernameText.text = ((username != null)) ? username : m_defaultUsernameText;
        m_passwordText.text = ((password != null)) ? password : m_defaultPasswordText;
        m_titleText.text = ((title != null)) ? title : m_defaultTitleText;
        m_loginButton.label = ((login != null)) ? login : m_defaultLoginText;
        m_cancelButton.label = ((cancel != null)) ? cancel : m_defaultCancelText;
        
        m_nameTakenText = ((nameTaken != null)) ? nameTaken : m_defaultNameTakenText;
        m_yesText = ((yes != null)) ? yes : m_defaultYesText;
        m_noText = ((no != null)) ? no : m_defaultNoText;
        m_createAccountText = ((createAccount != null)) ? createAccount : m_defaultCreateAccountText;
        m_incorrectUsernamePasswordText = ((incorrectUserNamePassword != null)) ? incorrectUserNamePassword : m_defaultIncorrectUsernamePasswordText;
        m_serverErrorText = ((serverError != null)) ? serverError : m_defaultServerErrorText;
        m_tryAgainLaterText = ((tryAgainLater != null)) ? tryAgainLater : m_defaultTryAgainLaterText;
    }
    
    private function get_useCachedAuthentication() : Bool
    {
        return (m_userProps != null) ? m_userProps.authenticateCachedStudent : false;
    }
    
    /**
		 * Adjusts the textfields for account login, username, pwd, and the error text.
		 */
    public function adjustTextFieldSizes() : Void
    {
        adjustTextFieldSize(m_titleText);
        adjustErrorTextField();
    }
    
    /**
		 * Adjusts error text.
		 */
    private function adjustErrorTextField() : Void
    {
        adjustTextFieldSize(m_errorText, 10);
    }
    
    /*
		Need a suite of factory functions to apply custom skinning to the component
		Components to skin are the background image, the confirm button, the cancel button
		If these functions are not overridden then the default skin is used
		*/
    
    /**
		 * The factory method to create a confirm button (this includes the text)
		 */
    public function setLoginButtonFactory(factoryFunction : Function) : Void
    {
        m_createLoginButtonFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create a cancel button (this includes the text)
		 */
    public function setCancelButtonFactory(factoryFunction : Function) : Void
    {
        m_createCancelButtonFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create a logo
		 */
    public function setLogoFactory(factoryFunction : Function) : Void
    {
        m_createLogoFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create a title text
		 */
    public function setTitleFactory(factoryFunction : Function) : Void
    {
        m_createTitleFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create the labels to place next to the input text fields
		 */
    public function setInputLabelFactory(factoryFunction : Function) : Void
    {
        m_createInputLabelFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create the inputs to type in information
		 */
    public function setInputFactory(factoryFunction : Function) : Void
    {
        m_createInputFactory = factoryFunction;
    }
    
    /**
		 * The factory method to create the background container for the login
		 */
    public function setBackgroundFactory(factoryFunction : Function) : Void
    {
        m_createBackgroundFactory = factoryFunction;
    }
    
    /**
		 *
		 * @param layoutFunction
		 * 		When this function is called, you can assume that all the necessary components have
		 * 		been created. It accepts parameters for every one of the components that
		 * 		can be laid out
		 */
    public function setLayoutFunction(layoutFunction : Function) : Void
    {
        m_layoutFunction = layoutFunction;
    }
    
    /**
		 * Using all the skin factory function currently set, this function will attempt to
		 * redraw all of the ui components and then lays them out using the given layout function
		 * 
		 */
    public function drawAndLayout() : Void
    {
        m_logo = m_createLogoFactory();
        m_titleText = m_createTitleFactory();
        m_usernameText = m_createInputLabelFactory();
        m_usernameInput = m_createInputFactory();
        m_passwordText = m_createInputLabelFactory();
        m_passwordInput = m_createInputFactory();
        m_loginButton = m_createLoginButtonFactory();
        m_cancelButton = m_createCancelButtonFactory();
        m_errorText = m_createErrorFactory();
        m_background = m_createBackgroundFactory();
        
        // If the default skin is used, then we immediately draw the popup.
        // Otherwise, the application is responsible for first setting up how
        // each component should look like and then
        setTextOptions();
        
        // After all components have been created AND the text content filled in, we can perform the layout
        m_layoutFunction(m_logo, m_titleText, m_usernameText, m_usernameInput, m_passwordText, m_passwordInput, m_loginButton, m_cancelButton, m_errorText, m_background, m_allowCancel, m_passwordEnabled);
        
        m_loginButton.removeEventListener(MouseEvent.CLICK, onClickLogin);
        m_loginButton.addEventListener(MouseEvent.CLICK, onClickLogin);
        if (m_allowCancel)
        {
            m_cancelButton.removeEventListener(MouseEvent.CLICK, onClickCancel);
            m_cancelButton.addEventListener(MouseEvent.CLICK, onClickCancel);
        }
        else
        {
            m_cancelButton.visible = false;
        }
    }
    
    private function defaultLogoFactory() : DisplayObject
    {
        var logo : DisplayObject = new ArtCGSSmallLogo();
        logo.width = 92;
        logo.height = 110;
        return logo;
    }
    
    private function defaultTitleFactory() : TextField
    {
        var titleText : TextField = new TextField();
        titleText.embedFonts = false;
        titleText.defaultTextFormat = m_titleFormat;
        titleText.embedFonts = true;
        titleText.width = 289;
        titleText.height = 106;
        titleText.selectable = false;
		titleText.type = TextFieldType.DYNAMIC;
        return titleText;
    }
    
    private function defaultInputLabelFactory() : TextField
    {
        var inputLabel : TextField = new TextField();
        inputLabel.selectable = false;
        inputLabel.defaultTextFormat = m_labelFormat;
        inputLabel.embedFonts = true;
        inputLabel.width = 188;
        inputLabel.height = 70;
		inputLabel.type = TextFieldType.DYNAMIC;
        return inputLabel;
    }
    
    private function defaultInputFactory() : TextField
    {
        var input : TextField = new TextField();
        input.setStyle("textFormat", m_inputFormat);
        input.setStyle("embedFonts", true);
        input.width = 180;
        input.height = 27;
		input.displayAsPassword = true;
		input.type = TextFieldType.INPUT;
        return input;
    }
    
    private function defaultButtonFactory() : DisplayObject
    {
        var button : Button = new Button();
        button.setStyle("textFormat", m_buttonFormat);
        button.setStyle("embedFonts", true);
        button.width = 150;
        button.height = 33;
        return button;
    }
    
    private function defaultErrorFactory() : TextField
    {
        var errorText : TextField = new TextField();
        errorText.selectable = false;
        errorText.defaultTextFormat = m_errorFormat;
        errorText.text = "";
        errorText.embedFonts = true;
        errorText.width = 365;
        errorText.height = 35;
		errorText.type = TextFieldType.DYNAMIC;
        return errorText;
    }
    
    private function defaultBackgroundFactory() : DisplayObject
    {
        var background : DisplayObject = new ArtDialogBackground();
        background.width = 400;
        background.height = 300;
        return background;
    }
    
    private function defaultLayout(logo : DisplayObject,
            titleText : TextField,
            usernameText : TextField,
            usernameInput : TextField,
            passwordText : TextField,
            passwordInput : TextField,
            loginButton : SimpleButton,
            cancelButton : SimpleButton,
            errorText : TextField,
            background : DisplayObject,
            allowCancel : Bool,
            passwordEnabled : Bool) : Void
    {
        while (this.numChildren > 0)
        {
            this.removeChildAt(0);
        }
        
        this.addChild(background);
        
        logo.x = 20 + logo.width * 0.5;
        logo.y = 0 + logo.height * 0.5;
        this.addChild(logo);
        
        titleText.x = 20 + logo.width;
        titleText.y = 10;
        this.addChild(titleText);
        
        usernameText.x = 0;
        usernameText.y = logo.height + 10;
        this.addChild(usernameText);
        
        usernameInput.x = background.width - usernameInput.width - 20;
        usernameInput.y = usernameText.y;
        this.addChild(usernameInput);
        
        passwordText.x = 0;
        passwordText.y = usernameText.y + usernameInput.height + 20;
        this.addChild(passwordText);
        
        passwordInput.x = usernameInput.x;
        passwordInput.y = passwordText.y;
        this.addChild(passwordInput);
        
        var combinedWidth : Float = loginButton.width + cancelButton.width + 20;
        loginButton.x = (background.width - combinedWidth) * 0.5;
        loginButton.y = background.height - loginButton.height - errorText.height;
        this.addChild(loginButton);
        
        if (allowCancel)
        {
            cancelButton.x = background.width - loginButton.x - cancelButton.width;
            cancelButton.y = loginButton.y;
            this.addChild(cancelButton);
        }
        
        errorText.x = 0;
        errorText.y = 0;
        this.addChild(errorText);
    }
    
    /**
		 * Set the login dialog to use a teacher code for login and registration.
		 */
    private function set_teacherCode(code : String) : String
    {
        m_teacherCode = code;
        return code;
    }
    
    private function set_studentGradeLevel(grade : Int) : Int
    {
        m_studentGrade = grade;
        return grade;
    }
    
    /**
     * Set whether a small dialog should show up if we are authenticating a student and the
     * first attempt fails because the username does not exist.
     * 
     * @param value
     *      true if the dialog should show up, false if it should not
     */
    private function set_showCreateStudentDialogOnFail(value : Bool) : Bool
    {
        m_showCreateStudentDialogOnFail = value;
        return value;
    }
    
    /**
		 * Set the username to be used as the password as well.
		 */
    private function set_usernameAsPassword(value : Bool) : Bool
    {
        m_usernameAsPassword = value;
        if (value)
        {
            this.disablePasswordPrompt();
        }
        else
        {
            this.enablePasswordPrompt();
        }
        return value;
    }
    
    private function get_cancelButtonText() : String
    {
        return m_cancelButton.textField.text;
    }
    
    private function set_cancelButtonText(value : String) : String
    {
        m_cancelButton.label = value;
        m_cancelButton.textField.text = value;
        return value;
    }
    
    private function get_loginButtonText() : String
    {
        return m_loginButton.textField.text;
    }
    
    private function set_loginButtonText(value : String) : String
    {
        m_loginButton.label = value;
        m_loginButton.textField.text = value;
        return value;
    }
    
    public function disablePasswordPrompt() : Void
    {
        m_passwordEnabled = false;
        if (m_passwordText != null && m_passwordInput != null)
        {
            // Perform layout again to take into account the change in password visibility
            m_passwordText.visible = false;
            m_passwordInput.visible = false;
            m_layoutFunction(m_logo, m_titleText, m_usernameText, m_usernameInput, m_passwordText, m_passwordInput, m_loginButton, m_cancelButton, m_errorText, m_background, m_allowCancel, m_passwordEnabled);
        }
    }
    
    public function enablePasswordPrompt() : Void
    {
        m_passwordEnabled = true;
        if (m_passwordText != null && m_passwordInput != null)
        {
            // Perform layout again to take into account the change in password visibility
            m_passwordText.visible = true;
            m_passwordInput.visible = true;
            m_layoutFunction(m_logo, m_titleText, m_usernameText, m_usernameInput, m_passwordText, m_passwordInput, m_loginButton, m_cancelButton, m_errorText, m_background, m_allowCancel, m_passwordEnabled);
        }
    }
    
    private function onClickLogin(e : MouseEvent) : Void
    {
        updateLoginState(false);
        
        var pass : String = (m_usernameAsPassword) ? 
        m_usernameInput.text : m_passwordInput.text;
        
        if (m_teacherCode != null)
        {
            if (pass != null)
            {
                pass = (pass.length == 0) ? null : pass;
            }
            
            m_authUser = m_cgsApi.authenticateStudent(
                            m_userProps, username, m_teacherCode, 
                            pass, m_studentGrade, handleStudentLoginCallback
                );
        }
        else
        {
            if (m_authUser == null)
            {
                m_authUser = m_cgsApi.authenticateUser(
                                m_userProps, username, pass, handleLoginCallback
                );
            }
            else
            {
                m_cgsApi.retryUserAuthentication(
                        m_authUser, username, pass, handleLoginCallback
            );
            }
        }
    }
    
    private function get_username() : String
    {
        return m_usernameInput.text;
    }
    
    private function set_username(value : String) : String
    {
        m_usernameInput.text = value;
        return value;
    }
    
    private function get_password() : String
    {
        return m_passwordInput.text;
    }
    
    private function set_password(value : String) : String
    {
        m_passwordInput.text = value;
        return value;
    }
    
    /**
		 * Attempt to login without a mouse click using username and password currently
		 * entered in the input boxes. It's usage is when we want to automatically log
		 * a player into a game if we already know their teacher code + assigned id.
		 */
    public function attemptLogin() : Void
    {
        onClickLogin(null);
    }
    
    private function handleStudentLoginCallback(status : CgsUserResponse) : Void
    {
        if (m_showCreateStudentDialogOnFail &&
            (status.userAuthenticationError || status.failed) &&
            !status.studentSignupLocked && !useCachedAuthentication)
        {
            // Ask the student if they are sure that they want to create a new account.
            var alertDialog : AlertDialog = 
            new AlertDialog(m_createAccountText);
            alertDialog.okButtonText = m_yesText;
            alertDialog.cancelButtonText = m_noText;
            
            alertDialog.okCallback = function() : Void
                    {
                        //Handle registering the user. This could still fail if
                        //someone else already registered with the same username.
                        //TODO - Add retries if the user is already created.
                        m_authUser = m_cgsApi.registerStudent(
                                        m_userProps, username, m_teacherCode, 
                                        m_studentGrade, handleStudentRegistration, m_gender
                    );
                        removeChild(alertDialog);
                    };
            
            alertDialog.cancelCallback = function() : Void
                    {
                        removeChild(alertDialog);
                        updateLoginState(true);
                    };
            
            // The alert dialog has its graphics with the registration point right in the center
            // need to shift over by that amount
            alertDialog.x = alertDialog.width * 0.5;
            alertDialog.y = alertDialog.height * 0.5;
            addChild(alertDialog);
            
            if (m_loginFailCallback != null)
            {
                m_loginFailCallback(status);
            }
        }
        else
        {
            handleLoginCallback(status);
        }
    }
    
    private function handleStudentRegistration(status : CgsUserResponse) : Void
    {
        if (status.userRegistrationError)
        {
            //TODO - Only allow registration at this point?
            m_errorText.text = m_nameTakenText;
        }
        else
        {
            handleLoginCallback(status);
        }
    }
    
    private function updateLoginState(enabled : Bool) : Void
    {
        m_loginButton.enabled = enabled;
        m_cancelButton.enabled = enabled;
        m_usernameInput.editable = enabled;
        m_passwordInput.editable = enabled;
    }
    
    //TODO - Need to update to handle user response.
    private function handleLoginCallback(status : CgsUserResponse) : Void
    {
        if (status.success)
        {
            //User login succeeded and the user is authenticated for the session.
            m_errorText.text = "";
            if (m_loginCallback != null)
            {
                m_loginCallback(status);
            }
            destroy();
        }
        else
        {
            if (status.userAuthenticationError)
            {
                //User failed to authenticate, this indicates incorrect credentials.
                m_errorText.text = errorText(status);
                updateLoginState(true);
            }
            else
            {
                if (status.failed)
                {
                    //Server was unable to authenticate the user due to a server failure of some sort.
                    m_errorText.text = errorText(status);
                    updateLoginState(true);
                }
                else
                {
                    if (status.requestFailed)
                    {
                        //Unable to reach server for whatever reason. There are IOErrorEvent, SecurityErrorEvent and Error objects that can be accessed.
                        m_errorText.text = errorText(status);
                        updateLoginState(true);
                    }
                    else
                    {
                        //Unable to reach server for unknown reason.
                        m_errorText.text = errorText(status);
                        updateLoginState(true);
                    }
                }
            }
        }
        adjustErrorTextField();
        
        if (!status.success && m_loginFailCallback != null)
        {
            m_loginFailCallback(status);
        }
    }
    
    /**
		 * Returns the appropriate error text based on the UserResponse status
		 * @param	status
		 * @return
		 */
    private function errorText(status : CgsUserResponse) : String
    {
        if (status.userAuthenticationError)
        {
            //User failed to authenticate, this indicates incorrect credentials.
            return m_incorrectUsernamePasswordText;
        }
        else
        {
            if (status.failed)
            {
                //Server was unable to authenticate the user due to a server failure of some sort.
                return m_serverErrorText;
            }
            else
            {
                if (status.requestFailed)
                {
                    //Unable to reach server for whatever reason. There are IOErrorEvent, SecurityErrorEvent and Error objects that can be accessed.
                    return m_serverErrorText;
                }
                else
                {
                    //Unable to reach server for unknown reason.
                    return m_serverErrorText;
                }
            }
        }
    }
    
    private function onClickCancel(e : MouseEvent) : Void
    {
        m_loginButton.enabled = false;
        m_cancelButton.enabled = false;
        if (m_cancelCallback != null)
        {
            m_cancelCallback();
        }
        destroy();
    }
    
    public function destroy() : Void
    {
        if (this.parent != null)
        {
            this.parent.removeChild(this);
        }
        m_loginCallback = null;
        m_cancelCallback = null;
    }
    
    private static function RegisterDefaultFonts() : Bool
    {
        if (!FONT_REGISTERED)
        {
            Font.registerFont(FontRoboto);
        }
        
        return true;
    }
    
    /**
		 * Adjusts text to fit within textfield size
		 * @param textField
		 * @param widthDiff - Buffer to each side of the text(default 20)
		 * @param testHeight - true if height plays a part, false if not. (defaults to true)
		 */
    private function adjustTextFieldSize(txt : TextField, widthDiff : Int = 20, testHeight : Bool = true) : Void
    {
        var f : TextFormat = txt.getTextFormat();
        f.size = ((txt.width > txt.height)) ? txt.width : txt.height;
        txt.setTextFormat(f);
        
        if (testHeight)
        {
            while (txt.textWidth > txt.width - widthDiff || txt.textHeight > txt.height - 6)
            {
                f.size = as3hx.Compat.parseInt(f.size) - 1;
                txt.setTextFormat(f);
            }
        }
        else
        {
            while (txt.textWidth > txt.width - widthDiff)
            {
                f.size = as3hx.Compat.parseInt(f.size) - 1;
                txt.setTextFormat(f);
            }
        }
    }
}

