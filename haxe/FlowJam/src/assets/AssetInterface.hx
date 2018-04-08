package assets;

import flash.errors.ArgumentError;
//import com.emibap.textureAtlas.DynamicAtlas;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.media.Sound;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class AssetInterface
{
    public static var contentScaleFactor(get, set) : Float;

    // If you're developing a game for the Flash Player / browser plugin, you can directly
    // embed all textures directly in this class. This demo, however, provides two sets of
    // textures for different resolutions. That's useful especially for mobile development,
    // where you have to support devices with different resolutions.
    //
    // For that reason, the actual embed statements are in separate files; one for each
    // set of textures. The correct set is chosen depending on the "contentScaleFactor".
    
    // Texture cache
    
    public static var sContentScaleFactor : Int = 1;
    private static var sTextureAtlases : Dictionary = new Dictionary();
    private static var sTextures : Dictionary = new Dictionary();
    private static var sSounds : Dictionary = new Dictionary();
    private static var sTextureAtlas : TextureAtlas;
    private static var sBitmapFontsLoaded : Bool;
    
    //need to declare a variable of each type, else they get stripped by the compiler and dynamic generation doesn't work
    private var gameAssetEmbeds_1x : GameAssetEmbeds1x;
    private var gameAssetEmbeds_2x : GameAssetEmbeds2x;
    
    // List of Subtexture names from PipeJamSpriteSheet atlas
    public static inline var PipeJamSubTexture_BallSizeTestMapNarrow : String = "BallSizeTestMapNarrow";
    public static inline var PipeJamSubTexture_BallSizeTestMapWide : String = "BallSizeTestMapWide";
    public static inline var PipeJamSubTexture_BallSizeTestSimple : String = "BallSizeTestSimple";
    public static inline var PipeJamSubTexture_GrayDarkBoxPrefix : String = "GrayDarkBox";
    public static inline var PipeJamSubTexture_GrayDarkBoxSelectPrefix : String = "GrayDarkBoxSelect";
    public static inline var PipeJamSubTexture_GrayDarkStart : String = "GrayDarkStart";
    public static inline var PipeJamSubTexture_GrayDarkEnd : String = "GrayDarkEnd";
    public static inline var PipeJamSubTexture_GrayDarkPlug : String = "GrayDarkPlug";
    public static inline var PipeJamSubTexture_GrayDarkJoint : String = "GrayDarkJoint";
    public static inline var PipeJamSubTexture_GrayDarkSegmentPrefix : String = "GrayDarkSegment";
    public static inline var PipeJamSubTexture_GrayLightBoxPrefix : String = "GrayLightBox";
    public static inline var PipeJamSubTexture_GrayLightBoxSelectPrefix : String = "GrayLightBoxSelect";
    public static inline var PipeJamSubTexture_GrayLightStart : String = "GrayLightStart";
    public static inline var PipeJamSubTexture_GrayLightEnd : String = "GrayLightEnd";
    public static inline var PipeJamSubTexture_GrayLightPlug : String = "GrayLightPlug";
    public static inline var PipeJamSubTexture_GrayLightJoint : String = "GrayLightJoint";
    public static inline var PipeJamSubTexture_GrayLightSegmentPrefix : String = "GrayLightSegment";
    public static inline var PipeJamSubTexture_BorderBlueDark : String = "BlueDarkEnd";  //"BorderBlueDark";  
    public static inline var PipeJamSubTexture_BorderBlueLight : String = "BlueLightEnd";  //"BorderBlueLight";  
    public static inline var PipeJamSubTexture_BorderGrayDark : String = "GrayDarkEnd";  // "BorderGrayDark";  
    public static inline var PipeJamSubTexture_BorderGrayLight : String = "GrayLightEnd";  //"BorderGrayLight";  
    
    public static inline var PipeJamSubTexture_BlueDarkBoxPrefix : String = "BlueDarkBox";
    public static inline var PipeJamSubTexture_BlueDarkBoxSelectPrefix : String = "BlueDarkBoxSelect";
    public static inline var PipeJamSubTexture_BlueDarkStart : String = "BlueDarkStart";
    public static inline var PipeJamSubTexture_BlueDarkEnd : String = "BlueDarkEnd";
    public static inline var PipeJamSubTexture_BlueDarkPlug : String = "BlueDarkPlug";
    public static inline var PipeJamSubTexture_BlueDarkJoint : String = "BlueDarkJoint";
    public static inline var PipeJamSubTexture_BlueDarkSegmentPrefix : String = "BlueDarkSegment";
    public static inline var PipeJamSubTexture_BlueLightBoxPrefix : String = "BlueLightBox";
    public static inline var PipeJamSubTexture_BlueLightBoxSelectPrefix : String = "BlueLightBoxSelect";
    public static inline var PipeJamSubTexture_BlueLightStart : String = "BlueLightStart";
    public static inline var PipeJamSubTexture_BlueLightEnd : String = "BlueLightEnd";
    public static inline var PipeJamSubTexture_BlueLightPlug : String = "BlueLightPlug";
    public static inline var PipeJamSubTexture_BlueLightJoint : String = "BlueLightJoint";
    public static inline var PipeJamSubTexture_BlueLightSegmentPrefix : String = "BlueLightSegment";
    public static inline var PipeJamSubTexture_OrangeAdaptor : String = "OrangeAdaptor";
    public static inline var PipeJamSubTexture_OrangeAdaptorPlug : String = "OrangeAdaptorPlug";
    public static inline var PipeJamSubTexture_OrangeScore : String = "OrangeScore";
    public static inline var PipeJamSubTexture_ScoreBarForeground : String = "ScoreBarForeground";
    public static inline var PipeJamSubTexture_ScoreBarBlue : String = "ScoreBarBlue";
    public static inline var PipeJamSubTexture_ScoreBarOrange : String = "ScoreBarOrange";
    public static inline var PipeJamSubTexture_MenuBoxFreePrefix : String = "MenuBoxFree";
    public static inline var PipeJamSubTexture_MenuBoxAttachedPrefix : String = "MenuBoxAttached";
    public static inline var PipeJamSubTexture_MenuBoxScrollbar : String = "MenuBoxScrollbar";
    public static inline var PipeJamSubTexture_MenuBoxScrollbarButton : String = "MenuBoxScrollbarButton";
    public static inline var PipeJamSubTexture_MenuBoxScrollbarButtonOver : String = "MenuBoxScrollbarButtonOver";
    public static inline var PipeJamSubTexture_MenuBoxScrollbarButtonSelected : String = "MenuBoxScrollbarButtonSelected";
    public static inline var PipeJamSubTexture_MenuButtonPrefix : String = "MenuButton";
    public static inline var PipeJamSubTexture_MenuButtonOverPrefix : String = "MenuButtonOver";
    public static inline var PipeJamSubTexture_MenuButtonSelectedPrefix : String = "MenuButtonSelected";
    public static inline var PipeJamSubTexture_MenuArrowHorizonal : String = "MenuArrowHorizonal";
    public static inline var PipeJamSubTexture_MenuArrowVertical : String = "ScrollbarArrowUp";
    public static inline var PipeJamSubTexture_TutorialArrow : String = "TutorialArrow";
    public static inline var PipeJamSubTexture_TutorialBoxPrefix : String = "TutorialBox";
    public static inline var PipeJamSubTexture_BackButton : String = "BackButton";
    public static inline var PipeJamSubTexture_BackButtonOver : String = "BackButtonOver";
    public static inline var PipeJamSubTexture_BackButtonSelected : String = "BackButtonSelected";
    public static inline var PipeJamSubTexture_SettingsButton : String = "SettingsButton";
    public static inline var PipeJamSubTexture_SettingsButtonOver : String = "SettingsButtonOver";
    public static inline var PipeJamSubTexture_SettingsButtonSelected : String = "SettingsButtonSelected";
    public static inline var PipeJamSubTexture_SoundButton : String = "SoundButton";
    public static inline var PipeJamSubTexture_SoundButtonOver : String = "SoundButtonOver";
    public static inline var PipeJamSubTexture_SoundButtonSelected : String = "SoundButtonSelected";
    public static inline var PipeJamSubTexture_ZoomOutButton : String = "ZoomOutButton";
    public static inline var PipeJamSubTexture_ZoomOutButtonOver : String = "ZoomOutButtonOver";
    public static inline var PipeJamSubTexture_ZoomOutButtonSelected : String = "ZoomOutButtonSelected";
    public static inline var PipeJamSubTexture_ZoomInButton : String = "ZoomInButton";
    public static inline var PipeJamSubTexture_ZoomInButtonOver : String = "ZoomInButtonOver";
    public static inline var PipeJamSubTexture_ZoomInButtonSelected : String = "ZoomInButtonSelected";
    public static inline var PipeJamSubTexture_RecenterButton : String = "RecenterButton";
    public static inline var PipeJamSubTexture_RecenterButtonOver : String = "RecenterButtonOver";
    public static inline var PipeJamSubTexture_RecenterButtonSelected : String = "RecenterButtonSelected";
    public static inline var PipeJamSubTexture_FullscreenButton : String = "FullscreenButton";
    public static inline var PipeJamSubTexture_FullscreenButtonOver : String = "FullscreenButtonOver";
    public static inline var PipeJamSubTexture_FullscreenButtonSelected : String = "FullscreenButtonSelected";
    public static inline var PipeJamSubTexture_SmallscreenButton : String = "SmallscreenButton";
    public static inline var PipeJamSubTexture_SmallscreenButtonOver : String = "SmallscreenButtonOver";
    public static inline var PipeJamSubTexture_SmallscreenButtonSelected : String = "SmallscreenButtonSelected";
    public static inline var PipeJamSubTexture_TextInput : String = "TextInput";
    public static inline var PipeJamSubTexture_TextInputOver : String = "TextInputOver";
    public static inline var PipeJamSubTexture_TextInputSelected : String = "TextInputSelected";
    public static inline var PipeJamSubTexture_Thumb : String = "ScrollbarButton";
    public static inline var PipeJamSubTexture_ThumbOver : String = "ScrollbarButtonMouseover";
    public static inline var PipeJamSubTexture_ThumbSelected : String = "ScrollbarButtonClick";
    public static inline var PipeJamSubTexture_ScrollBarTrack : String = "Scrollbar";
    // Level select atlas textures:
    public static inline var LevelSelectSubTexture_MapMaximizeButton : String = "MaximizeButton";
    public static inline var LevelSelectSubTexture_MapMaximizeButtonClick : String = "MaximizeButtonClick";
    public static inline var LevelSelectSubTexture_MapMaximizeButtonMouseover : String = "MaximizeButtonMouseover";
    public static inline var LevelSelectSubTexture_MapMinimizeButton : String = "MinimizeButton";
    public static inline var LevelSelectSubTexture_MapMinimizeButtonClick : String = "MinimizeButtonClick";
    public static inline var LevelSelectSubTexture_MapMinimizeButtonMouseover : String = "MinimizeButtonMouseover";
    
    public static function getTexture(file : String, name : String) : Texture
    {
        if (Reflect.field(sTextures, name) == null)
        {
            var data : Dynamic = create(file, name);
            
            if (Std.is(data, Bitmap))
            {
                Reflect.setField(sTextures, name, Texture.fromBitmap(try cast(data, Bitmap) catch(e:Dynamic) null, true, false, sContentScaleFactor));
                data = null;
            }
            else if (Std.is(data, ByteArray))
            {
                Reflect.setField(sTextures, name, Texture.fromAtfData(try cast(data, ByteArray) catch(e:Dynamic) null, sContentScaleFactor));
                data = null;
            }
            else
            {
                var classInfo : FastXML = flash.utils.describeType(data);
                // List the class name.
                trace("Class " + Std.string(classInfo.att.name));
            }
        }
        
        return Reflect.field(sTextures, name);
    }
    
    /**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with the given colors replaces, i.e. replace 0xffff0000 with 0xff0000ff
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	colorToReplace Color to replace including leading alpha bits i.e. 0xffff0000 (red)
		 * @param	newColor Color to replace previous color with including leading alpha bits i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
    public static function getTextureReplaceColor(file : String, name : String, colorToReplace : Int, newColor : Int) : Texture
    {
        var newName : String = name + "_" + Std.string(colorToReplace) + "_" + Std.string(newColor);
        if (Reflect.field(sTextures, newName) == null)
        {
            var data : Dynamic = create(file, name);
            
            if (Std.is(data, Bitmap))
            {
                var bitmapData : BitmapData = (try cast(data, Bitmap) catch(e:Dynamic) null).bitmapData;
                // Replace Color
                var maskToUse : Int = 0xffffffff;
                var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
                var p : Point = new Point(0, 0);
                bitmapData.threshold(bitmapData, rect, p, "==", colorToReplace, newColor, maskToUse, true);
                // Color Replaced
                Reflect.setField(sTextures, newName, Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor));
                bitmapData = null;
                data = null;
            }
            else
            {
                var classInfo : FastXML = flash.utils.describeType(data);
                // List the class name.
                trace("Class " + Std.string(classInfo.att.name));
            }
        }
        
        return Reflect.field(sTextures, newName);
    }
    
    /**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with any non-transparent section replaced with the given color
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	color Color to fill the shape with i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
    public static function getTextureColorAll(file : String, name : String, color : Int) : Texture
    {
        var newName : String = name + "_" + Std.string(color);
        if (Reflect.field(sTextures, newName) == null)
        {
            var data : Dynamic = create(file, name);
            
            if (Std.is(data, Bitmap))
            {
                var bitmapData : BitmapData = (try cast(data, Bitmap) catch(e:Dynamic) null).bitmapData;
                // Replace any non-transparent color with input color
                var maskToUse : Int = 0xffffffff;
                var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
                var p : Point = new Point(0, 0);
                bitmapData.threshold(bitmapData, rect, p, ">=", 0x01000000, color, maskToUse, true);
                // Color Replaced
                Reflect.setField(sTextures, newName, Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor));
                bitmapData = null;
                data = null;
            }
            else
            {
                var classInfo : FastXML = flash.utils.describeType(data);
                // List the class name.
                trace("Class " + Std.string(classInfo.att.name));
            }
        }
        
        return Reflect.field(sTextures, newName);
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
    
    public static function getTextureAtlas(file : String, texClassName : String, xmlClassName : String) : TextureAtlas
    {
        return getTextureAtlasUsingDict(sTextureAtlases, file, texClassName, xmlClassName);
    }
    
    private static function getTextureAtlasUsingDict(dict : Dictionary, file : String, texClassName : String, xmlClassName : String) : TextureAtlas
    {
        if (dict[file + texClassName] == null)
        {
            var data : Dynamic = create(file, texClassName);
            var texture : Texture = Texture.fromBitmap(try cast(data, Bitmap) catch(e:Dynamic) null, false);
            var xml : FastXML = FastXML.parse(create(file, xmlClassName));
            dict[file + texClassName] = new TextureAtlas(texture, xml);
        }
        return dict[file + texClassName];
    }
    
    public static function loadBitmapFont(filename : String, fontName : String, xmlFile : String) : Void
    {
        var texture : Texture = getTexture(filename, fontName);
        var xml : FastXML = FastXML.parse(create(filename, xmlFile));
        TextField.registerBitmapFont(new BitmapFont(texture, xml));
        sBitmapFontsLoaded = true;
    }
    
    public static function getMovieClipAsTextureAtlas(filename : String, movieClipName : String) : TextureAtlas
    {
        //var clip : Dynamic = create(filename, movieClipName);
        //var atlas : TextureAtlas = DynamicAtlas.fromMovieClipContainer(try cast(clip, MovieClip) catch(e:Dynamic) null);
        //return atlas;
		return null;
    }
    
    public static function prepareSounds() : Void
    {
    }
    
    private static function create(file : String, name : String) : Dynamic
    {
        var textureClassNameString : String = (sContentScaleFactor == 1) ? file + "AssetEmbeds_1x" : file + "AssetEmbeds_2x";
        var qualifiedName : String = "assets." + textureClassNameString;
        var textureClass : Class<Dynamic> = Type.getClass(Type.resolveClass(qualifiedName));
        var textureClassObject : Dynamic = try cast(Reflect.field(textureClass, name), Dynamic) catch(e:Dynamic) null;
        return new TextureClassObject();
    }
    
    private static function get_contentScaleFactor() : Float
    {
        return sContentScaleFactor;
    }
    private static function set_contentScaleFactor(value : Float) : Float
    {
        for (texture/* AS3HX WARNING could not determine type for var: texture exp: EIdent(sTextures) type: Dictionary */ in sTextures)
        {
            texture.dispose();
        }
        sTextures = new Dictionary();
        sContentScaleFactor = (value < 1.5) ? 1 : 2;
        return value;
    }

    public function new()
    {
    }
}