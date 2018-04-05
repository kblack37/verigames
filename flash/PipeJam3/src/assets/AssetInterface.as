package assets
{
    import com.emibap.textureAtlas.DynamicAtlas;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
    
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import starling.text.BitmapFont;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
	
    public class AssetInterface
    {
        // If you're developing a game for the Flash Player / browser plugin, you can directly
        // embed all textures directly in this class. This demo, however, provides two sets of
        // textures for different resolutions. That's useful especially for mobile development,
        // where you have to support devices with different resolutions.
        //
        // For that reason, the actual embed statements are in separate files; one for each
        // set of textures. The correct set is chosen depending on the "contentScaleFactor".
        
        // Texture cache
        
        public static var sContentScaleFactor:int = 1;
		private static var sParadoxSpriteSheetAtlas:TextureAtlas;
		private static var sPipeJamSpriteSheetAtlas:TextureAtlas;
		private static var sDialogWindowAtlas:TextureAtlas;
		private static var sPipeJamLevelSelectAtlas:TextureAtlas;
		private static var sTextureAtlases:Dictionary = new Dictionary();
        private static var sTextures:Dictionary = new Dictionary();
        private static var sSounds:Dictionary = new Dictionary();
        private static var sTextureAtlas:TextureAtlas;
        private static var sBitmapFontsLoaded:Boolean;
		
		//need to declare a variable of each type, else they get stripped by the compiler and dynamic generation doesn't work
		private var gameAssetEmbeds_1x:GameAssetEmbeds_1x;
		private var gameAssetEmbeds_2x:GameAssetEmbeds_2x;
		
		// List of Subtexture names from PipeJamSpriteSheet atlas
		public static const PipeJamSubTexture_MenuButtonPrefix:String = "MenuButton";
		public static const PipeJamSubTexture_MenuButtonOverPrefix:String = "MenuButtonOver";
		public static const PipeJamSubTexture_MenuButtonSelectedPrefix:String = "MenuButtonSelected";
		public static const PipeJamSubTexture_TutorialArrow:String = "TutorialArrow";
		public static const PipeJamSubTexture_TutorialBoxPrefix:String = "TutorialBox";
		
		// Level select atlas textures:
		public static const LevelSelectSubTexture_MapMaximizeButton:String = "MaximizeButton";
		public static const LevelSelectSubTexture_MapMaximizeButtonClick:String = "MaximizeButtonClick";
		public static const LevelSelectSubTexture_MapMaximizeButtonMouseover:String = "MaximizeButtonMouseover";
		public static const LevelSelectSubTexture_MapMinimizeButton:String = "MinimizeButton";
		public static const LevelSelectSubTexture_MapMinimizeButtonClick:String = "MinimizeButtonClick";
		public static const LevelSelectSubTexture_MapMinimizeButtonMouseover:String = "MinimizeButtonMouseover";
		public static const LevelSelectSubTexture_ScrollbarArrowUp:String = "ScrollbarArrowUp";
		public static const LevelSelectSubTexture_Scrollbar:String = "Scrollbar";
		public static const LevelSelectSubTexture_ScrollbarButton:String = "ScrollbarButton";
		public static const LevelSelectSubTexture_ScrollbarButtonMouseover:String = "ScrollbarButtonMouseover";
		public static const LevelSelectSubTexture_ScrollbarButtonClick:String = "ScrollbarButtonClick";
		
		//paradox atlas textures, might be possible to get rid of all the above, at some point
		public static const ParadoxSubTexture_BrushSolverColor:String = "BrushSolverColor";
		public static const ParadoxSubTexture_BrushSelectionColor:String = "BrushSelectionColor";
		
		public static const ParadoxSubTexture_BrushCircle:String = "BrushCircle";
		public static const ParadoxSubTexture_BrushCircleClick:String = "BrushCircleClick";
		public static const ParadoxSubTexture_BrushDiamond:String = "BrushDiamond";
		public static const ParadoxSubTexture_BrushDiamondClick:String = "BrushDiamondClick";
		public static const ParadoxSubTexture_BrushSquare:String = "BrushSquare";
		public static const ParadoxSubTexture_BrushSquareClick:String = "BrushSquareClick";
		public static const ParadoxSubTexture_ButtonBrushCircle:String = "ButtonBrushCircle";
		public static const ParadoxSubTexture_ButtonBrushCircleClick:String = "ButtonBrushCircleClick";
		public static const ParadoxSubTexture_ButtonBrushCircleOver:String = "ButtonBrushCircleOver";
		public static const ParadoxSubTexture_ButtonBrushDiamond:String = "ButtonBrushDiamond";
		public static const ParadoxSubTexture_ButtonBrushDiamondClick:String = "ButtonBrushDiamondClick";
		public static const ParadoxSubTexture_ButtonBrushDiamondOver:String = "ButtonBrushDiamondOver";
		public static const ParadoxSubTexture_ButtonBrushHexagon:String = "ButtonBrushHexagon";
		public static const ParadoxSubTexture_ButtonBrushHexagonClick:String = "ButtonBrushHexagonClick";
		public static const ParadoxSubTexture_ButtonBrushHexagonOver:String = "ButtonBrushHexagonOver";
		public static const ParadoxSubTexture_ButtonBrushSquare:String = "ButtonBrushSquare";
		public static const ParadoxSubTexture_ButtonBrushSquareClick:String = "ButtonBrushSquareClick";
		public static const ParadoxSubTexture_ButtonBrushSquareOver:String = "ButtonBrushSquareOver";
		public static const ParadoxSubTexture_ButtonCenter:String = "ButtonCenter";
		public static const ParadoxSubTexture_ButtonCenterClick:String = "ButtonCenterClick";
		public static const ParadoxSubTexture_ButtonCenterOver:String = "ButtonCenterOver";
		public static const ParadoxSubTexture_ButtonMaximize:String = "ButtonMaximize";
		public static const ParadoxSubTexture_ButtonMaximizeClick:String = "ButtonMaximizeClick";
		public static const ParadoxSubTexture_ButtonMaximizeOver:String = "ButtonMaximizeOver";
		public static const ParadoxSubTexture_ButtonMenu:String = "ButtonMenu";
		public static const ParadoxSubTexture_ButtonMenuClick:String = "ButtonMenuClick";
		public static const ParadoxSubTexture_ButtonMenuOver:String = "ButtonMenuOver";
		public static const ParadoxSubTexture_ButtonMinimize:String = "ButtonMinimize";
		public static const ParadoxSubTexture_ButtonMinimizeClick:String = "ButtonMinimizeClick";
		public static const ParadoxSubTexture_ButtonMinimizeOver:String = "ButtonMinimizeOver";
		public static const ParadoxSubTexture_ButtonSettings:String = "ButtonSettings";
		public static const ParadoxSubTexture_ButtonSettingsClick:String = "ButtonSettingsClick";
		public static const ParadoxSubTexture_ButtonSettingsOver:String = "ButtonSettingsOver";
		public static const ParadoxSubTexture_ButtonSound:String = "ButtonSound";
		public static const ParadoxSubTexture_ButtonSoundClick:String = "ButtonSoundClick";
		public static const ParadoxSubTexture_ButtonSoundOver:String = "ButtonSoundOver";
		public static const ParadoxSubTexture_ButtonUndo:String = "ButtonUndo";
		public static const ParadoxSubTexture_ButtonUndoClick:String = "ButtonUndoClick";
		public static const ParadoxSubTexture_ButtonUndoOver:String = "ButtonUndoOver";
		public static const ParadoxSubTexture_ButtonZoomIn:String = "ButtonZoomIn";
		public static const ParadoxSubTexture_ButtonZoomInClick:String = "ButtonZoomInClick";
		public static const ParadoxSubTexture_ButtonZoomInOver:String = "ButtonZoomInOver";
		public static const ParadoxSubTexture_ButtonZoomOut:String = "ButtonZoomOut";
		public static const ParadoxSubTexture_ButtonZoomOutClick:String = "ButtonZoomOutClick";
		public static const ParadoxSubTexture_ButtonZoomOutOver:String = "ButtonZoomOutOver";
		public static const ParadoxSubTexture_Conflict:String = "Conflict";
		public static const ParadoxSubTexture_ConflictCorrected:String = "ConflictCorrected";
		public static const ParadoxSubTexture_ConflictWorking:String = "ConflictWorking";
		public static const ParadoxSubTexture_Constraint:String = "Constraint";
		public static const ParadoxSubTexture_ConstraintConflict:String = "ConstraintConflict";
		public static const ParadoxSubTexture_ConstraintCorrected:String = "ConstraintCorrected";
		public static const ParadoxSubTexture_ConstraintWorking:String = "ConstraintWorking";
		public static const ParadoxSubTexture_EdgeNarrowSatisfiedSelected:String = "EdgeNarrowSatisfiedSelected";
		public static const ParadoxSubTexture_EdgeNarrowSatisfiedUnselected:String = "EdgeNarrowSatisfiedUnselected";
		public static const ParadoxSubTexture_EdgeNarrowUnsatisfiedSelected:String = "EdgeNarrowUnsatisfiedSelected";
		public static const ParadoxSubTexture_EdgeNarrowUnsatisfiedUnselected:String = "EdgeNarrowUnsatisfiedUnselected";
		public static const ParadoxSubTexture_EdgeWideSatisfiedSelected:String = "EdgeWideSatisfiedSelected";
		public static const ParadoxSubTexture_EdgeWideSatisfiedUnselected:String = "EdgeWideSatisfiedUnselected";
		public static const ParadoxSubTexture_EdgeWideUnsatisfiedSelected:String = "EdgeWideUnsatisfiedSelected";
		public static const ParadoxSubTexture_EdgeWideUnsatisfiedUnselected:String = "EdgeWideUnsatisfiedUnselected";
		public static const ParadoxSubTexture_MenuBottomCenter:String = "MenuBottomCenter";
		public static const ParadoxSubTexture_MenuBottomLeft:String = "MenuBottomLeft";
		public static const ParadoxSubTexture_MenuBottomRight:String = "MenuBottomRight";
		public static const ParadoxSubTexture_MenuBoxScrollbar:String = "MenuBoxScrollbar";
		public static const ParadoxSubTexture_MenuBoxScrollbarButton:String = "MenuBoxScrollbarButton";
		public static const ParadoxSubTexture_MenuBoxScrollbarButtonClick:String = "MenuBoxScrollbarButtonClick";
		public static const ParadoxSubTexture_MenuBoxScrollbarButtonOver:String = "MenuBoxScrollbarButtonOver";
		public static const ParadoxSubTexture_MenuCenter:String = "MenuCenter";
		public static const ParadoxSubTexture_MenuCenterLeft:String = "MenuCenterLeft";
		public static const ParadoxSubTexture_MenuCenterRight:String = "MenuCenterRight";
		public static const ParadoxSubTexture_MenuTopCenter:String = "MenuTopCenter";
		public static const ParadoxSubTexture_MenuTopLeft:String = "MenuTopLeft";
		public static const ParadoxSubTexture_MenuTopRight:String = "MenuTopRight";
		public static const ParadoxSubTexture_ParadoxLogoBlackLarge:String = "ParadoxLogoBlackLarge";
		public static const ParadoxSubTexture_ParadoxLogoBlackSmall:String = "ParadoxLogoBlackSmall";
		public static const ParadoxSubTexture_ParadoxLogoWhiteLarge:String = "ParadoxLogoWhiteLarge";
		public static const ParadoxSubTexture_ParadoxLogoWhiteSmall:String = "ParadoxLogoWhiteSmall";
		public static const ParadoxSubTexture_ScoreCircleBack:String = "ScoreCircleBack";
		public static const ParadoxSubTexture_ScoreCircleFront:String = "ScoreCircleFront";
		public static const ParadoxSubTexture_ScoreCircleMiddle:String = "ScoreCircleMiddle";
		public static const ParadoxSubTexture_Sidebar:String = "Sidebar";
		public static const ParadoxSubTexture_TextInput:String = "TextInput";
		public static const ParadoxSubTexture_TextInputOver:String = "TextInputOver";
		public static const ParadoxSubTexture_TextInputSelected:String = "TextInputSelected";
		public static const ParadoxSubTexture_VariableNarrow:String = "VariableNarrow";
		public static const ParadoxSubTexture_VariableNarrowSelected:String = "VariableNarrowSelected";
		public static const ParadoxSubTexture_VariableNarrowWorking:String = "VariableNarrowWorking";
		public static const ParadoxSubTexture_VariableWide:String = "VariableWide";
		public static const ParadoxSubTexture_VariableWideSelected:String = "VariableWideSelected";
		public static const ParadoxSubTexture_VariableWideWorking:String = "VariableWideWorking";
		public static const ParadoxSubTexture_ProgressMarkerPrefix:String = "ProgressMarker";
		
        public static function getTexture(file:String, name:String):Texture
        {
            if (sTextures[name] == undefined)
            {
                var data:Object = create(file, name);
                
                if (data is Bitmap)
				{
                    sTextures[name] = Texture.fromBitmap(data as Bitmap, true, false, sContentScaleFactor);
					data = null;
				}
                else if (data is ByteArray)
				{
                    sTextures[name] = Texture.fromAtfData(data as ByteArray, sContentScaleFactor);
					data = null;
				}
				else
				{
					var classInfo:XML = flash.utils.describeType(data);				
					// List the class name.
					trace( "Class " + classInfo.@name.toString());
				}
            }
            
            return sTextures[name];
        }
        
		/**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with the given colors replaces, i.e. replace 0xffff0000 with 0xff0000ff
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	colorToReplace Color to replace including leading alpha bits i.e. 0xffff0000 (red)
		 * @param	newColor Color to replace previous color with including leading alpha bits i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
		public static function getTextureReplaceColor(file:String, name:String, colorToReplace:uint, newColor:uint):Texture
		{
			var newName:String = name + "_" + colorToReplace.toString(16) + "_" + newColor.toString(16);
			if (sTextures[newName] == undefined)
            {
                var data:Object = create(file, name);
                
                if (data is Bitmap)
				{
					var bitmapData:BitmapData = (data as Bitmap).bitmapData;
					// Replace Color
					var maskToUse:uint = 0xffffffff;
					var rect:Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
					var p:Point = new Point(0, 0);
					bitmapData.threshold(bitmapData, rect, p, "==", colorToReplace, newColor, maskToUse, true);
					// Color Replaced
					sTextures[newName] = Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor);
					bitmapData = null;
					data = null;
				}
				else
				{
					var classInfo:XML = flash.utils.describeType(data);				
					// List the class name.
					trace( "Class " + classInfo.@name.toString());
				}
            }
			
			return sTextures[newName];
		}
		
		/**
		 * Similar to getTexture but creates/stores (or retrieves, if already created) bitmap with any non-transparent section replaced with the given color
		 * @param	file Name of asset Class
		 * @param	name Name to store/retrieve Texture by, as key to Dictionary of Textures
		 * @param	color Color to fill the shape with i.e. 0xff0000ff (blue)
		 * @return Texture created or retrieved (if already created)
		 */
		public static function getTextureColorAll(file:String, name:String, color:uint):Texture
		{
			var newName:String = name + "_" + color.toString(16);
			if (sTextures[newName] == undefined)
            {
                var data:Object = create(file, name);
                
                if (data is Bitmap)
				{
					var bitmapData:BitmapData = (data as Bitmap).bitmapData;
					// Replace any non-transparent color with input color
					var maskToUse:uint = 0xffffffff;
					var rect:Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
					var p:Point = new Point(0, 0);
					bitmapData.threshold(bitmapData, rect, p, ">=", 0x01000000, color, maskToUse, true);
					// Color Replaced
					sTextures[newName] = Texture.fromBitmapData(bitmapData, true, false, sContentScaleFactor);
					bitmapData = null;
					data = null;
				}
				else
				{
					var classInfo:XML = flash.utils.describeType(data);				
					// List the class name.
					trace( "Class " + classInfo.@name.toString());
				}
            }
			
			return sTextures[newName];
		}
		
        public static function getSound(newName:String):Sound
        {
            var sound:Sound = sSounds[newName] as Sound;
            if (sound) return sound;
            else throw new ArgumentError("Sound not found: " + newName);
        }
        
		public static function getTextureAtlas(file:String, texClassName:String, xmlClassName:String):TextureAtlas
		{
			return getTextureAtlasUsingDict(sTextureAtlases, file, texClassName, xmlClassName);
		}
		
		private static function getTextureAtlasUsingDict(dict:Dictionary, file:String, texClassName:String, xmlClassName:String):TextureAtlas
		{
			if (dict[file + texClassName] == undefined) {
				var data:Object = create(file, texClassName);
				var texture:Texture = Texture.fromBitmap(data as Bitmap, false);
				var xml:XML = XML(create(file, xmlClassName));
				dict[file + texClassName] = new TextureAtlas(texture, xml);
			}
			return dict[file + texClassName];
		}
        
		public static function get PipeJamSpriteSheetAtlas():TextureAtlas
		{
			if (sPipeJamSpriteSheetAtlas == null)
				sPipeJamSpriteSheetAtlas = getTextureAtlas("Game", "PipeJamSpriteSheetPNG" + PipeJam3.ASSET_SUFFIX, "PipeJamSpriteSheetXML" + PipeJam3.ASSET_SUFFIX);
			return sPipeJamSpriteSheetAtlas;
		}
		
		public static function get ParadoxSpriteSheetAtlas():TextureAtlas
		{
			if (sParadoxSpriteSheetAtlas == null)
				sParadoxSpriteSheetAtlas = getTextureAtlas("Game", "ParadoxSpriteSheetPNG" + PipeJam3.ASSET_SUFFIX, "ParadoxSpriteSheetXML" + PipeJam3.ASSET_SUFFIX);
			return sParadoxSpriteSheetAtlas;
		}
		
		public static function get DialogWindowAtlas():TextureAtlas
		{
			if (sDialogWindowAtlas == null)
				sDialogWindowAtlas = getTextureAtlas("Game", "DialogWindowPNG", "DialogWindowXML");
			return sDialogWindowAtlas;
		}
		
		public static function get PipeJamLevelSelectAtlas():TextureAtlas
		{
			if (sPipeJamLevelSelectAtlas == null)
				sPipeJamLevelSelectAtlas = getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
			return sPipeJamLevelSelectAtlas;
		}	
		
        public static function loadBitmapFont(filename:String, fontName:String, xmlFile:String):void
        {
            var texture:Texture = getTexture(filename, fontName);
            var xml:XML = XML(create(filename, xmlFile));
            TextField.registerBitmapFont(new BitmapFont(texture, xml));
            sBitmapFontsLoaded = true;
        }
		
		public static function getMovieClipAsTextureAtlas(filename:String, movieClipName:String):TextureAtlas
		{
			var clip:Object = create(filename, movieClipName);
			var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(clip as MovieClip);
			return atlas;
		}
        
        public static function prepareSounds():void
        {
        }
        
        private static function create(file:String, name:String):Object
        {
            var textureClassNameString:String = sContentScaleFactor == 1 ? file+"AssetEmbeds_1x" : file+"AssetEmbeds_2x";
			var qualifiedName:String = "assets." + textureClassNameString;
			var textureClass:Class = getDefinitionByName(qualifiedName) as Class;
			var textureClassObject:Object = textureClass[name] as Object;
            return new textureClassObject;
        }
        
        public static function get contentScaleFactor():Number { return sContentScaleFactor; }
        public static function set contentScaleFactor(value:Number):void 
        {
            for each (var texture:Texture in sTextures)
                texture.dispose();
            sTextures = new Dictionary();
            sContentScaleFactor = value < 1.5 ? 1 : 2; // assets are available for factor 1 and 2 
        }
    }
}