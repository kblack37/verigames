import assets.AssetsFont;
import flash.geom.Point;
import openfl.Assets;
import openfl.filters.BitmapFilter;
import openfl.text.Font;
import openfl.text.TextFieldAutoSize;
import starling.display.DisplayObject;
import starling.filters.FragmentFilter;
import starling.text.TextField;
import starling.text.TextFormat;
//import starling.utils.HAlign;
//import starling.utils.VAlign;

// TODO: the current way text is created is a weird mix of flash, openfl, & starling
// classes. we'll probably have to work through this
class TextFactory
{
    private static var m_instance : TextFactory;
    
    public static function getInstance() : TextFactory
    {
        if (m_instance == null)
        {
            m_instance = new TextFactory();
        }
        return m_instance;
    }
    
    public function new()
    {
    }
    
    public function updateText(textField : TextFieldWrapper, text : String) : Void
    {
        textField.text = text;
    }
    
    public function updateColor(textField : TextFieldWrapper, color : Int) : Void
    {
		var newFormat : TextFormat = new TextFormat();
		newFormat.copyFrom(textField.format);
		newFormat.color = color;
		textField.format = newFormat;
    }
    
    public static inline var HLEFT : Int = 0;
    public static inline var HCENTER : Int = 1;
    public static inline var HRIGHT : Int = 2;
    public static inline var VTOP : Int = 0;
    public static inline var VCENTER : Int = 1;
    public static inline var VBOTTOM : Int = 2;
    
    public function updateAlign(textField : TextFieldWrapper, hAlign : Int, vAlign : Int) : Void
    {
        //var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
		// TODO: starling halign/valign have to be refactored into whatever they were replaced with
        //switch (hAlign)
        //{
            //case HLEFT:
                //tf.hAlign = HAlign.LEFT;
            //case HCENTER:
                //tf.hAlign = HAlign.CENTER;
            //default:
                //tf.hAlign = HAlign.RIGHT;
        //}
        //switch (vAlign)
        //{
            //case VTOP:
                //tf.vAlign = VAlign.TOP;
            //case VCENTER:
                //tf.vAlign = VAlign.CENTER;
            //default:
                //tf.vAlign = VAlign.BOTTOM;
        //}
    }
    
    public function updateFilter(textField : TextField, filter : BitmapFilter) : Void
    {
        //var tf : TextFieldHack = (try cast(textField, TextFieldHack) catch(e:Dynamic) null);
        
        //if (filter != null)
        //{
			//textField.filter = filter;
        //}
        //else
        //{
            //textField.filter = null;
        //}
    }
    
    public function createDefaultTextField(text : String, width : Float, height : Float, fontSize : Float, color : Int) : TextFieldWrapper
    {
        return createTextField(text,"_sans", width, height, fontSize, color);
    }
    
    public function createDebugTextField(text : String, width : Float, height : Float, fontSize : Float, color : Int) : TextFieldWrapper
    {
        return createTextField(text,"_sans", width, height, fontSize, color);
    }
    
    public function createTextField(text : String, fontName: String, width : Float, height : Float, fontSize : Float, color : Int, wrap : Bool = false) : TextFieldWrapper
    {
        var ret : TextFieldWrapper = new TextFieldWrapper(Std.int(width), Std.int(height), text, new TextFormat(fontName, fontSize, color));
		ret.wordWrap = wrap;
        //ret.border = true;
        ret.touchable = false;
        return ret;
    }
    
    public function estimateTextFieldSize(text : String, fontName : String, fontSize : Float) : Point
    {
        var estField : TextFieldWrapper = new TextFieldWrapper(0, 0, text, new TextFormat(fontName, Std.int(fontSize)));
        estField.autoSize = TextFieldAutoSize.CENTER;
        return new Point(estField.width + 8, estField.height + 8);
    }
}