package assets;

import flash.errors.ArgumentError;
import com.emibap.textureAtlas.DynamicAtlas;
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
    public static var PipeJamSpriteSheetAtlas(get, never) : TextureAtlas;
    public static var ParadoxSpriteSheetAtlas(get, never) : TextureAtlas;
    public static var DialogWindowAtlas(get, never) : TextureAtlas;
    public static var PipeJamLevelSelectAtlas(get, never) : TextureAtlas;
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
    private static var sParadoxSpriteSheetAtlas : TextureAtlas;
    private static var sPipeJamSpriteSheetAtlas : TextureAtlas;
    private static var sDialogWindowAtlas : TextureAtlas;
    private static var sPipeJamLevelSelectAtlas : TextureAtlas;
    private static var sTextureAtlases : Dictionary = new Dictionary();
    private static var sTextures : Dictionary = new Dictionary();
    private static var sSounds : Dictionary = new Dictionary();
    private static var sTextureAtlas : TextureAtlas;
    private static var sBitmapFontsLoaded : Bool;
    
    //need to declare a variable of each type, else they get stripped by the compiler and dynamic generation doesn't work
    private var gameAssetEmbeds_1x : GameAssetEmbeds1x;
    private var gameAssetEmbeds_2x : GameAssetEmbeds2x;
    
    // List of Subtexture names from PipeJamSpriteSheet atlas
    public static inline var PipeJamSubTexture_MenuButtonPrefix : String = "MenuButton";
    public static inline var PipeJamSubTexture_MenuButtonOverPrefix : String = "MenuButtonOver";
    public static inline var PipeJamSubTexture_MenuButtonSelectedPrefix : String = "MenuButtonSelected";
    public static inline var PipeJamSubTexture_TutorialArrow : String = "TutorialArrow";
    public static inline var PipeJamSubTexture_TutorialBoxPrefix : String = "TutorialBox";
    
    // Level select atlas textures:
    public static inline var LevelSelectSubTexture_MapMaximizeButton : String = "MaximizeButton";
    public static inline var LevelSelectSubTexture_MapMaximizeButtonClick : String = "MaximizeButtonClick";
    public static inline var LevelSelectSubTexture_MapMaximizeButtonMouseover : String = "MaximizeButtonMouseover";
    public static inline var LevelSelectSubTexture_MapMinimizeButton : String = "MinimizeButton";
    public static inline var LevelSelectSubTexture_MapMinimizeButtonClick : String = "MinimizeButtonClick";
    public static inline var LevelSelectSubTexture_MapMinimizeButtonMouseover : String = "MinimizeButtonMouseover";
    public static inline var LevelSelectSubTexture_ScrollbarArrowUp : String = "ScrollbarArrowUp";
    public static inline var LevelSelectSubTexture_Scrollbar : String = "Scrollbar";
    public static inline var LevelSelectSubTexture_ScrollbarButton : String = "ScrollbarButton";
    public static inline var LevelSelectSubTexture_ScrollbarButtonMouseover : String = "ScrollbarButtonMouseover";
    public static inline var LevelSelectSubTexture_ScrollbarButtonClick : String = "ScrollbarButtonClick";
    
    //paradox atlas textures, might be possible to get rid of all the above, at some point
    public static inline var ParadoxSubTexture_BrushSolverColor : String = "BrushSolverColor";
    public static inline var ParadoxSubTexture_BrushSelectionColor : String = "BrushSelectionColor";
    
    public static inline var ParadoxSubTexture_BrushCircle : String = "BrushCircle";
    public static inline var ParadoxSubTexture_BrushCircleClick : String = "BrushCircleClick";
    public static inline var ParadoxSubTexture_BrushDiamond : String = "BrushDiamond";
    public static inline var ParadoxSubTexture_BrushDiamondClick : String = "BrushDiamondClick";
    public static inline var ParadoxSubTexture_BrushSquare : String = "BrushSquare";
    public static inline var ParadoxSubTexture_BrushSquareClick : String = "BrushSquareClick";
    public static inline var ParadoxSubTexture_ButtonBrushCircle : String = "ButtonBrushCircle";
    public static inline var ParadoxSubTexture_ButtonBrushCircleClick : String = "ButtonBrushCircleClick";
    public static inline var ParadoxSubTexture_ButtonBrushCircleOver : String = "ButtonBrushCircleOver";
    public static inline var ParadoxSubTexture_ButtonBrushDiamond : String = "ButtonBrushDiamond";
    public static inline var ParadoxSubTexture_ButtonBrushDiamondClick : String = "ButtonBrushDiamondClick";
    public static inline var ParadoxSubTexture_ButtonBrushDiamondOver : String = "ButtonBrushDiamondOver";
    public static inline var ParadoxSubTexture_ButtonBrushHexagon : String = "ButtonBrushHexagon";
    public static inline var ParadoxSubTexture_ButtonBrushHexagonClick : String = "ButtonBrushHexagonClick";
    public static inline var ParadoxSubTexture_ButtonBrushHexagonOver : String = "ButtonBrushHexagonOver";
    public static inline var ParadoxSubTexture_ButtonBrushSquare : String = "ButtonBrushSquare";
    public static inline var ParadoxSubTexture_ButtonBrushSquareClick : String = "ButtonBrushSquareClick";
    public static inline var ParadoxSubTexture_ButtonBrushSquareOver : String = "ButtonBrushSquareOver";
    public static inline var ParadoxSubTexture_ButtonCenter : String = "ButtonCenter";
    public static inline var ParadoxSubTexture_ButtonCenterClick : String = "ButtonCenterClick";
    public static inline var ParadoxSubTexture_ButtonCenterOver : String = "ButtonCenterOver";
    public static inline var ParadoxSubTexture_ButtonMaximize : String = "ButtonMaximize";
    public static inline var ParadoxSubTexture_ButtonMaximizeClick : String = "ButtonMaximizeClick";
    public static inline var ParadoxSubTexture_ButtonMaximizeOver : String = "ButtonMaximizeOver";
    public static inline var ParadoxSubTexture_ButtonMenu : String = "ButtonMenu";
    public static inline var ParadoxSubTexture_ButtonMenuClick : String = "ButtonMenuClick";
    public static inline var ParadoxSubTexture_ButtonMenuOver : String = "ButtonMenuOver";
    public static inline var ParadoxSubTexture_ButtonMinimize : String = "ButtonMinimize";
    public static inline var ParadoxSubTexture_ButtonMinimizeClick : String = "ButtonMinimizeClick";
    public static inline var ParadoxSubTexture_ButtonMinimizeOver : String = "ButtonMinimizeOver";
    public static inline var ParadoxSubTexture_ButtonSettings : String = "ButtonSettings";
    public static inline var ParadoxSubTexture_ButtonSettingsClick : String = "ButtonSettingsClick";
    public static inline var ParadoxSubTexture_ButtonSettingsOver : String = "ButtonSettingsOver";
    public static inline var ParadoxSubTexture_ButtonSound : String = "ButtonSound";
    public static inline var ParadoxSubTexture_ButtonSoundClick : String = "ButtonSoundClick";
    public static inline var ParadoxSubTexture_ButtonSoundOver : String = "ButtonSoundOver";
    public static inline var ParadoxSubTexture_ButtonUndo : String = "ButtonUndo";
    public static inline var ParadoxSubTexture_ButtonUndoClick : String = "ButtonUndoClick";
    public static inline var ParadoxSubTexture_ButtonUndoOver : String = "ButtonUndoOver";
    public static inline var ParadoxSubTexture_ButtonZoomIn : String = "ButtonZoomIn";
    public static inline var ParadoxSubTexture_ButtonZoomInClick : String = "ButtonZoomInClick";
    public static inline var ParadoxSubTexture_ButtonZoomInOver : String = "ButtonZoomInOver";
    public static inline var ParadoxSubTexture_ButtonZoomOut : String = "ButtonZoomOut";
    public static inline var ParadoxSubTexture_ButtonZoomOutClick : String = "ButtonZoomOutClick";
    public static inline var ParadoxSubTexture_ButtonZoomOutOver : String = "ButtonZoomOutOver";
    public static inline var ParadoxSubTexture_Conflict : String = "Conflict";
    public static inline var ParadoxSubTexture_ConflictCorrected : String = "ConflictCorrected";
    public static inline var ParadoxSubTexture_ConflictWorking : String = "ConflictWorking";
    public static inline var ParadoxSubTexture_Constraint : String = "Constraint";
    public static inline var ParadoxSubTexture_ConstraintConflict : String = "ConstraintConflict";
    public static inline var ParadoxSubTexture_ConstraintCorrected : String = "ConstraintCorrected";
    public static inline var ParadoxSubTexture_ConstraintWorking : String = "ConstraintWorking";
    public static inline var ParadoxSubTexture_EdgeNarrowSatisfiedSelected : String = "EdgeNarrowSatisfiedSelected";
    public static inline var ParadoxSubTexture_EdgeNarrowSatisfiedUnselected : String = "EdgeNarrowSatisfiedUnselected";
    public static inline var ParadoxSubTexture_EdgeNarrowUnsatisfiedSelected : String = "EdgeNarrowUnsatisfiedSelected";
    public static inline var ParadoxSubTexture_EdgeNarrowUnsatisfiedUnselected : String = "EdgeNarrowUnsatisfiedUnselected";
    public static inline var ParadoxSubTexture_EdgeWideSatisfiedSelected : String = "EdgeWideSatisfiedSelected";
    public static inline var ParadoxSubTexture_EdgeWideSatisfiedUnselected : String = "EdgeWideSatisfiedUnselected";
    public static inline var ParadoxSubTexture_EdgeWideUnsatisfiedSelected : String = "EdgeWideUnsatisfiedSelected";
    public static inline var ParadoxSubTexture_EdgeWideUnsatisfiedUnselected : String = "EdgeWideUnsatisfiedUnselected";
    public static inline var ParadoxSubTexture_MenuBottomCenter : String = "MenuBottomCenter";
    public static inline var ParadoxSubTexture_MenuBottomLeft : String = "MenuBottomLeft";
    public static inline var ParadoxSubTexture_MenuBottomRight : String = "MenuBottomRight";
    public static inline var ParadoxSubTexture_MenuBoxScrollbar : String = "MenuBoxScrollbar";
    public static inline var ParadoxSubTexture_MenuBoxScrollbarButton : String = "MenuBoxScrollbarButton";
    public static inline var ParadoxSubTexture_MenuBoxScrollbarButtonClick : String = "MenuBoxScrollbarButtonClick";
    public static inline var ParadoxSubTexture_MenuBoxScrollbarButtonOver : String = "MenuBoxScrollbarButtonOver";
    public static inline var ParadoxSubTexture_MenuCenter : String = "MenuCenter";
    public static inline var ParadoxSubTexture_MenuCenterLeft : String = "MenuCenterLeft";
    public static inline var ParadoxSubTexture_MenuCenterRight : String = "MenuCenterRight";
    public static inline var ParadoxSubTexture_MenuTopCenter : String = "MenuTopCenter";
    public static inline var ParadoxSubTexture_MenuTopLeft : String = "MenuTopLeft";
    public static inline var ParadoxSubTexture_MenuTopRight : String = "MenuTopRight";
    public static inline var ParadoxSubTexture_ParadoxLogoBlackLarge : String = "ParadoxLogoBlackLarge";
    public static inline var ParadoxSubTexture_ParadoxLogoBlackSmall : String = "ParadoxLogoBlackSmall";
    public static inline var ParadoxSubTexture_ParadoxLogoWhiteLarge : String = "ParadoxLogoWhiteLarge";
    public static inline var ParadoxSubTexture_ParadoxLogoWhiteSmall : String = "ParadoxLogoWhiteSmall";
    public static inline var ParadoxSubTexture_ScoreCircleBack : String = "ScoreCircleBack";
    public static inline var ParadoxSubTexture_ScoreCircleFront : String = "ScoreCircleFront";
    public static inline var ParadoxSubTexture_ScoreCircleMiddle : String = "ScoreCircleMiddle";
    public static inline var ParadoxSubTexture_Sidebar : String = "Sidebar";
    public static inline var ParadoxSubTexture_TextInput : String = "TextInput";
    public static inline var ParadoxSubTexture_TextInputOver : String = "TextInputOver";
    public static inline var ParadoxSubTexture_TextInputSelected : String = "TextInputSelected";
    public static inline var ParadoxSubTexture_VariableNarrow : String = "VariableNarrow";
    public static inline var ParadoxSubTexture_VariableNarrowSelected : String = "VariableNarrowSelected";
    public static inline var ParadoxSubTexture_VariableNarrowWorking : String = "VariableNarrowWorking";
    public static inline var ParadoxSubTexture_VariableWide : String = "VariableWide";
    public static inline var ParadoxSubTexture_VariableWideSelected : String = "VariableWideSelected";
    public static inline var ParadoxSubTexture_VariableWideWorking : String = "VariableWideWorking";
    public static inline var ParadoxSubTexture_ProgressMarkerPrefix : String = "ProgressMarker";
    
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
    
    private static function get_PipeJamSpriteSheetAtlas() : TextureAtlas
    {
        if (sPipeJamSpriteSheetAtlas == null)
        {
            sPipeJamSpriteSheetAtlas = getTextureAtlas("Game", "PipeJamSpriteSheetPNG" + PipeJam3.ASSET_SUFFIX, "PipeJamSpriteSheetXML" + PipeJam3.ASSET_SUFFIX);
        }
        return sPipeJamSpriteSheetAtlas;
    }
    
    private static function get_ParadoxSpriteSheetAtlas() : TextureAtlas
    {
        if (sParadoxSpriteSheetAtlas == null)
        {
            sParadoxSpriteSheetAtlas = getTextureAtlas("Game", "ParadoxSpriteSheetPNG" + PipeJam3.ASSET_SUFFIX, "ParadoxSpriteSheetXML" + PipeJam3.ASSET_SUFFIX);
        }
        return sParadoxSpriteSheetAtlas;
    }
    
    private static function get_DialogWindowAtlas() : TextureAtlas
    {
        if (sDialogWindowAtlas == null)
        {
            sDialogWindowAtlas = getTextureAtlas("Game", "DialogWindowPNG", "DialogWindowXML");
        }
        return sDialogWindowAtlas;
    }
    
    private static function get_PipeJamLevelSelectAtlas() : TextureAtlas
    {
        if (sPipeJamLevelSelectAtlas == null)
        {
            sPipeJamLevelSelectAtlas = getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
        }
        return sPipeJamLevelSelectAtlas;
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
        var clip : Dynamic = create(filename, movieClipName);
        var atlas : TextureAtlas = DynamicAtlas.fromMovieClipContainer(try cast(clip, MovieClip) catch(e:Dynamic) null);
        return atlas;
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
