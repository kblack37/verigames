package assets;
import flash.display.BitmapData;
import flash.errors.ArgumentError;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Sound;
import haxe.Json;
import openfl.Assets;
import openfl.utils.AssetType;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
//import com.emibap.textureAtlas.DynamicAtlas;

class AssetInterface
{
    public static var contentScaleFactor(get, set) : Float;
    
    // Texture cache
    private static var sContentScaleFactor : Int = 1;
    private static var sTextureAtlases : Map<String,TextureAtlas> = new Map<String, TextureAtlas>();
    private static var sTextures : Map<String,Texture> = new Map<String, Texture>();
    private static var sSounds : Map<String,Sound> = new Map<String, Sound>();
	private static var sObjects : Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var sXmls : Map<String, Xml> = new Map<String, Xml>();
    private static var sBitmapFontsLoaded : Bool;
	
    public static function getTexture(filePath : String, name : String) : Texture
    {
		var texture : Texture = sTextures.get(name);
        if (texture == null)
        {
            var bmpData : BitmapData = Assets.getBitmapData(filePath + "/" + name);
			      texture = Texture.fromBitmapData(bmpData, true, false, sContentScaleFactor);
            sTextures.set(name, texture);
        }
        
        return texture;
    }
    
    /**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with the given colors replaces, i.e. replace 0xffff0000 with 0xff0000ff
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	colorToReplace Color to replace including leading alpha bits i.e. 0xffff0000 (red)
		 * @param	newColor Color to replace previous color with including leading alpha bits i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
    public static function getTextureReplaceColor(filePath : String, name : String, colorToReplace : Int, newColor : Int) : Texture
    {
        var newName : String = name + "_" + Std.string(colorToReplace) + "_" + Std.string(newColor);
		var texture : Texture = sTextures.get(newName);
        if (texture == null)
        {
            var bitmapData : BitmapData = Assets.getBitmapData(filePath + "/" + name);
			
            // Replace Color
            var maskToUse : Int = 0xffffffff;
            var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
            var p : Point = new Point(0, 0);
            bitmapData.threshold(bitmapData, rect, p, "==", colorToReplace, newColor, maskToUse, true);
			
            // Color Replaced
            texture = Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor);
			sTextures.set(newName, texture);
        }
        
        return texture;
    }
    
    /**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with any non-transparent section replaced with the given color
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	color Color to fill the shape with i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
    public static function getTextureColorAll(filePath : String, name : String, color : Int) : Texture
    {
        var newName : String = name + "_" + Std.string(color);
		var texture : Texture = sTextures.get(newName);
        if (texture == null)
        {
            var bitmapData : BitmapData = Assets.getBitmapData(filePath + "/" + name);
			
            // Replace any non-transparent color with input color
            var maskToUse : Int = 0xffffffff;
            var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
            var p : Point = new Point(0, 0);
            bitmapData.threshold(bitmapData, rect, p, ">=", 0x01000000, color, maskToUse, true);
			
            // Color Replaced
            texture = Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor);
			sTextures.set(newName, texture);
        }
        
        return texture;
    }
    
    public static function getSound(newName : String) : Sound
    {
        var sound : Sound = try cast(Reflect.field(sSounds, newName), Sound) catch(e:Dynamic) null;
        if (sound != null)
        {
            return sound;
        }
        else
        {
            throw new ArgumentError("Sound not found: " + newName);
        }
    }
    
    public static function getTextureAtlas(filePath : String, texName : String, xmlName : String) : TextureAtlas
    {
        return getTextureAtlasUsingDict(sTextureAtlases, filePath, texName, xmlName);
    }
    
    private static function getTextureAtlasUsingDict(dict : Map<String,TextureAtlas>, filePath : String, texName : String, xmlName : String) : TextureAtlas
    {
        if (!dict.exists(texName))
        {
            var texture : Texture = Texture.fromBitmapData(Assets.getBitmapData(filePath + "/" + texName));
            var xml = Xml.parse(Assets.getText(filePath + "/" + xmlName));
            dict.set(texName, new TextureAtlas(texture, xml));
        }
        return dict[texName];
    }
    
    public static function loadBitmapFont(filename : String, fontName : String, xmlFile : String) : Void
    {
        var texture : Texture = getTexture(filename, fontName);
        var xml = Xml.parse(Assets.getText(filename));
        TextField.registerBitmapFont(new BitmapFont(texture, xml));
        sBitmapFontsLoaded = true;
    }
    
    public static function getMovieClipAsTextureAtlas(filename : String, movieClipName : String) : TextureAtlas
    {
       // var clip : Dynamic = create(filename, movieClipName);
        //var atlas : TextureAtlas = DynamicAtlas.fromMovieClipContainer(try cast(clip, MovieClip) catch(e:Dynamic) null);
        //return atlas;TODO there is not DynamicAtlas in the build I dont know where this is coming from
		return null;
    }
	
	public static function getXml(filePath : String, name : String) : Xml
	{
		var xml : Xml = sXmls.get(name);
		if (xml == null)
		{
			xml = Xml.parse(Assets.getText(filePath + "/" + name));
			sXmls.set(name, xml);
		}
		
		return xml;
	}
	
	public static function getObject(filePath : String, name : String) : Dynamic
	{
		var object : Dynamic = sObjects.get(name);
		if (object == null) 
		{
			object = Json.parse(Assets.getText(filePath + "/" + name));
			sObjects.set(name, object);
		}
		
		return object;
	}
    
    public static function prepareSounds() : Void
    {
    }
    
    private static function get_contentScaleFactor() : Float
    {
        return sContentScaleFactor;
    }
	
    private static function set_contentScaleFactor(value : Float) : Float
    {
        sTextures = new Map<String, Texture>();
        sContentScaleFactor = (value < 1.5) ? 1 : 2;
        return value;
    }
}
