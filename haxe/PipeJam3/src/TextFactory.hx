import assets.AssetsFont;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import starling.display.DisplayObject;
import starling.utils.HAlign;
import starling.utils.VAlign;

class TextFactory
{
    private static var m_instance : TextFactory;
    
    public static function getInstance() : TextFactory
    {
        if (m_instance == null)
        {
            m_instance = new TextFactory(new SingletonLock());
        }
        return m_instance;
    }
    
    public function new(lock : SingletonLock)
    {
    }
    
    public function updateText(textField : TextFieldWrapper, text : String) : Void
    {
        var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
        tf.text = text;
    }
    
    public function updateColor(textField : TextFieldWrapper, color : Int) : Void
    {
        var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
        tf.color = color;
    }
    
    public static inline var HLEFT : Int = 0;
    public static inline var HCENTER : Int = 1;
    public static inline var HRIGHT : Int = 2;
    public static inline var VTOP : Int = 0;
    public static inline var VCENTER : Int = 1;
    public static inline var VBOTTOM : Int = 2;
    
    public function updateAlign(textField : TextFieldWrapper, hAlign : Int, vAlign : Int) : Void
    {
        var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
        switch (hAlign)
        {
            case HLEFT:
                tf.hAlign = HAlign.LEFT;
            case HCENTER:
                tf.hAlign = HAlign.CENTER;
            default:
                tf.hAlign = HAlign.RIGHT;
        }
        switch (vAlign)
        {
            case VTOP:
                tf.vAlign = VAlign.TOP;
            case VCENTER:
                tf.vAlign = VAlign.CENTER;
            default:
                tf.vAlign = VAlign.BOTTOM;
        }
    }
    
    public function updateFilter(textField : TextFieldWrapper, filter : BitmapFilter) : Void
    {
        var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
        if (filter != null)
        {
            tf.nativeFilters = [filter];
        }
        else
        {
            tf.nativeFilters = null;
        }
    }
    
    public function createDefaultTextField(text : String, width : Float, height : Float, fontSize : Float, color : Int) : TextFieldWrapper
    {
        return createTextField(text, AssetsFont.FONT_DEFAULT, width, height, fontSize, color);
    }
    
    public function createDebugTextField(text : String, width : Float, height : Float, fontSize : Float, color : Int) : TextFieldWrapper
    {
        return createTextField(text, "Verdana", width, height, fontSize, color);
    }
    
    public function createTextField(text : String, fontName : String, width : Float, height : Float, fontSize : Float, color : Int, wrap : Bool = false) : TextFieldWrapper
    {
        var ret : TextFieldHack = new TextFieldHack(width, height, text, fontName, fontSize, color, false, wrap);
        //ret.border = true;
        ret.touchable = false;
        return ret;
    }
    
    public function estimateTextFieldSize(text : String, fontName : String, fontSize : Float) : Point
    {
        var estField : TextField = new TextField();
        estField.defaultTextFormat = new TextFormat(fontName, fontSize);
        estField.embedFonts = true;
        estField.autoSize = TextFieldAutoSize.CENTER;
        estField.text = text;
        return new Point(estField.width + 8, estField.height + 8);
    }
}


class SingletonLock
{

    @:allow()
    private function new()
    {
    }
}  // to prevent outside construction of singleton  
