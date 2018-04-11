package cgs.ui;

import dragonbox.art.ArtAlertDialog;
import haxe.Constraints.Function;
import openfl.events.MouseEvent;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import cgs.assets.fonts.FontRoboto;

class AlertDialog extends ArtAlertDialog
{
    public var okCallback(never, set) : Function;
    public var cancelCallback(never, set) : Function;
    public var okButtonText(never, set) : String;
    public var cancelButtonText(never, set) : String;
    public var messageText(never, set) : String;

    public static inline var FONT_DEFAULT : String = "Roboto";
    
    private static var FONT_REGISTERED : Bool = RegisterDefaultFont();
    
    private var m_buttonFormat : TextFormat = new TextFormat(FONT_DEFAULT, 24, 0x0, true, null, null, null, null, TextFormatAlign.CENTER);
    
    private var _okCallback : Function;
    private var _cancelCallback : Function;
    
    public function new(message : String, okCallback : Function = null, cancelCallback : Function = null)
    {
        super();
        
        m_buttonFormat.font = FONT_DEFAULT;
        
        LoginButton.setStyle("textFormat", m_buttonFormat);
        LoginButton.setStyle("embedFonts", true);
        CancelButton.setStyle("textFormat", m_buttonFormat);
        CancelButton.setStyle("embedFonts", true);
        
        LoginButton.addEventListener(MouseEvent.CLICK, handleOkClick);
        CancelButton.addEventListener(MouseEvent.CLICK, handleCancelClick);
        
        messageText = message;
        _okCallback = okCallback;
        _cancelCallback = cancelCallback;
    }
    
    private function set_okCallback(callback : Function) : Function
    {
        _okCallback = callback;
        return callback;
    }
    
    private function set_cancelCallback(callback : Function) : Function
    {
        _cancelCallback = callback;
        return callback;
    }
    
    private function set_okButtonText(value : String) : String
    {
        LoginButton.label = value;
        return value;
    }
    
    private function set_cancelButtonText(value : String) : String
    {
        CancelButton.label = value;
        return value;
    }
    
    private function set_messageText(value : String) : String
    {
        TitleText.text = value;
        return value;
    }
    
    //
    // Mouse event handling.
    //
    
    private function handleOkClick(evt : MouseEvent) : Void
    {
        if (_okCallback != null)
        {
            _okCallback();
        }
    }
    
    private function handleCancelClick(evt : MouseEvent) : Void
    {
        if (_cancelCallback != null)
        {
            _cancelCallback();
        }
    }
    
    private static function RegisterDefaultFont() : Bool
    {
        if (!FONT_REGISTERED)
        {
            Font.registerFont(FontRoboto);
        }
        
        return true;
    }
}
