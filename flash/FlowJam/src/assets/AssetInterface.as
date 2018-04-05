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
		private static var sTextureAtlases:Dictionary = new Dictionary();
        private static var sTextures:Dictionary = new Dictionary();
        private static var sSounds:Dictionary = new Dictionary();
        private static var sTextureAtlas:TextureAtlas;
        private static var sBitmapFontsLoaded:Boolean;
		
		//need to declare a variable of each type, else they get stripped by the compiler and dynamic generation doesn't work
		private var gameAssetEmbeds_1x:GameAssetEmbeds_1x;
		private var gameAssetEmbeds_2x:GameAssetEmbeds_2x;
		
		// List of Subtexture names from PipeJamSpriteSheet atlas
		public static const PipeJamSubTexture_BallSizeTestMapNarrow:String = "BallSizeTestMapNarrow";
		public static const PipeJamSubTexture_BallSizeTestMapWide:String = "BallSizeTestMapWide";
		public static const PipeJamSubTexture_BallSizeTestSimple:String = "BallSizeTestSimple";
		public static const PipeJamSubTexture_GrayDarkBoxPrefix:String = "GrayDarkBox";
		public static const PipeJamSubTexture_GrayDarkBoxSelectPrefix:String = "GrayDarkBoxSelect";
		public static const PipeJamSubTexture_GrayDarkStart:String = "GrayDarkStart";
		public static const PipeJamSubTexture_GrayDarkEnd:String = "GrayDarkEnd";
		public static const PipeJamSubTexture_GrayDarkPlug:String = "GrayDarkPlug";
		public static const PipeJamSubTexture_GrayDarkJoint:String = "GrayDarkJoint";
		public static const PipeJamSubTexture_GrayDarkSegmentPrefix:String = "GrayDarkSegment";
		public static const PipeJamSubTexture_GrayLightBoxPrefix:String = "GrayLightBox";
		public static const PipeJamSubTexture_GrayLightBoxSelectPrefix:String = "GrayLightBoxSelect";
		public static const PipeJamSubTexture_GrayLightStart:String = "GrayLightStart";
		public static const PipeJamSubTexture_GrayLightEnd:String = "GrayLightEnd";
		public static const PipeJamSubTexture_GrayLightPlug:String = "GrayLightPlug";
		public static const PipeJamSubTexture_GrayLightJoint:String = "GrayLightJoint";
		public static const PipeJamSubTexture_GrayLightSegmentPrefix:String = "GrayLightSegment";
		public static const PipeJamSubTexture_BorderBlueDark:String = "BlueDarkEnd";//"BorderBlueDark";
		public static const PipeJamSubTexture_BorderBlueLight:String = "BlueLightEnd";//"BorderBlueLight";
		public static const PipeJamSubTexture_BorderGrayDark:String = "GrayDarkEnd";// "BorderGrayDark";
		public static const PipeJamSubTexture_BorderGrayLight:String = "GrayLightEnd";//"BorderGrayLight";
		
		public static const PipeJamSubTexture_BlueDarkBoxPrefix:String = "BlueDarkBox";
		public static const PipeJamSubTexture_BlueDarkBoxSelectPrefix:String = "BlueDarkBoxSelect";
		public static const PipeJamSubTexture_BlueDarkStart:String = "BlueDarkStart";
		public static const PipeJamSubTexture_BlueDarkEnd:String = "BlueDarkEnd";
		public static const PipeJamSubTexture_BlueDarkPlug:String = "BlueDarkPlug";
		public static const PipeJamSubTexture_BlueDarkJoint:String = "BlueDarkJoint";
		public static const PipeJamSubTexture_BlueDarkSegmentPrefix:String = "BlueDarkSegment";
		public static const PipeJamSubTexture_BlueLightBoxPrefix:String = "BlueLightBox";
		public static const PipeJamSubTexture_BlueLightBoxSelectPrefix:String = "BlueLightBoxSelect";
		public static const PipeJamSubTexture_BlueLightStart:String = "BlueLightStart";
		public static const PipeJamSubTexture_BlueLightEnd:String = "BlueLightEnd";
		public static const PipeJamSubTexture_BlueLightPlug:String = "BlueLightPlug";
		public static const PipeJamSubTexture_BlueLightJoint:String = "BlueLightJoint";
		public static const PipeJamSubTexture_BlueLightSegmentPrefix:String = "BlueLightSegment";
		public static const PipeJamSubTexture_OrangeAdaptor:String = "OrangeAdaptor";
		public static const PipeJamSubTexture_OrangeAdaptorPlug:String = "OrangeAdaptorPlug";
		public static const PipeJamSubTexture_OrangeScore:String = "OrangeScore";
		public static const PipeJamSubTexture_ScoreBarForeground:String = "ScoreBarForeground";
		public static const PipeJamSubTexture_ScoreBarBlue:String = "ScoreBarBlue";
		public static const PipeJamSubTexture_ScoreBarOrange:String = "ScoreBarOrange";
		public static const PipeJamSubTexture_MenuBoxFreePrefix:String = "MenuBoxFree";
		public static const PipeJamSubTexture_MenuBoxAttachedPrefix:String = "MenuBoxAttached";
		public static const PipeJamSubTexture_MenuBoxScrollbar:String = "MenuBoxScrollbar";
		public static const PipeJamSubTexture_MenuBoxScrollbarButton:String = "MenuBoxScrollbarButton";
		public static const PipeJamSubTexture_MenuBoxScrollbarButtonOver:String = "MenuBoxScrollbarButtonOver";
		public static const PipeJamSubTexture_MenuBoxScrollbarButtonSelected:String = "MenuBoxScrollbarButtonSelected";
		public static const PipeJamSubTexture_MenuButtonPrefix:String = "MenuButton";
		public static const PipeJamSubTexture_MenuButtonOverPrefix:String = "MenuButtonOver";
		public static const PipeJamSubTexture_MenuButtonSelectedPrefix:String = "MenuButtonSelected";
		public static const PipeJamSubTexture_MenuArrowHorizonal:String = "MenuArrowHorizonal";
		public static const PipeJamSubTexture_MenuArrowVertical:String = "ScrollbarArrowUp";
		public static const PipeJamSubTexture_TutorialArrow:String = "TutorialArrow";
		public static const PipeJamSubTexture_TutorialBoxPrefix:String = "TutorialBox";
		public static const PipeJamSubTexture_BackButton:String = "BackButton";
		public static const PipeJamSubTexture_BackButtonOver:String = "BackButtonOver";
		public static const PipeJamSubTexture_BackButtonSelected:String = "BackButtonSelected";
		public static const PipeJamSubTexture_SettingsButton:String = "SettingsButton";
		public static const PipeJamSubTexture_SettingsButtonOver:String = "SettingsButtonOver";
		public static const PipeJamSubTexture_SettingsButtonSelected:String = "SettingsButtonSelected";
		public static const PipeJamSubTexture_SoundButton:String = "SoundButton";
		public static const PipeJamSubTexture_SoundButtonOver:String = "SoundButtonOver";
		public static const PipeJamSubTexture_SoundButtonSelected:String = "SoundButtonSelected";
		public static const PipeJamSubTexture_ZoomOutButton:String = "ZoomOutButton";
		public static const PipeJamSubTexture_ZoomOutButtonOver:String = "ZoomOutButtonOver";
		public static const PipeJamSubTexture_ZoomOutButtonSelected:String = "ZoomOutButtonSelected";
		public static const PipeJamSubTexture_ZoomInButton:String = "ZoomInButton";
		public static const PipeJamSubTexture_ZoomInButtonOver:String = "ZoomInButtonOver";
		public static const PipeJamSubTexture_ZoomInButtonSelected:String = "ZoomInButtonSelected";
		public static const PipeJamSubTexture_RecenterButton:String = "RecenterButton";
		public static const PipeJamSubTexture_RecenterButtonOver:String = "RecenterButtonOver";
		public static const PipeJamSubTexture_RecenterButtonSelected:String = "RecenterButtonSelected";
		public static const PipeJamSubTexture_FullscreenButton:String = "FullscreenButton";
		public static const PipeJamSubTexture_FullscreenButtonOver:String = "FullscreenButtonOver";
		public static const PipeJamSubTexture_FullscreenButtonSelected:String = "FullscreenButtonSelected";
		public static const PipeJamSubTexture_SmallscreenButton:String = "SmallscreenButton";
		public static const PipeJamSubTexture_SmallscreenButtonOver:String = "SmallscreenButtonOver";
		public static const PipeJamSubTexture_SmallscreenButtonSelected:String = "SmallscreenButtonSelected";
		public static const PipeJamSubTexture_TextInput:String = "TextInput";
		public static const PipeJamSubTexture_TextInputOver:String = "TextInputOver";
		public static const PipeJamSubTexture_TextInputSelected:String = "TextInputSelected";
		public static const PipeJamSubTexture_Thumb:String = "ScrollbarButton";
		public static const PipeJamSubTexture_ThumbOver:String = "ScrollbarButtonMouseover";
		public static const PipeJamSubTexture_ThumbSelected:String = "ScrollbarButtonClick";
		public static const PipeJamSubTexture_ScrollBarTrack:String = "Scrollbar";
		// Level select atlas textures:
		public static const LevelSelectSubTexture_MapMaximizeButton:String = "MaximizeButton";
		public static const LevelSelectSubTexture_MapMaximizeButtonClick:String = "MaximizeButtonClick";
		public static const LevelSelectSubTexture_MapMaximizeButtonMouseover:String = "MaximizeButtonMouseover";
		public static const LevelSelectSubTexture_MapMinimizeButton:String = "MinimizeButton";
		public static const LevelSelectSubTexture_MapMinimizeButtonClick:String = "MinimizeButtonClick";
		public static const LevelSelectSubTexture_MapMinimizeButtonMouseover:String = "MinimizeButtonMouseover";
		
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