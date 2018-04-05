package {
	
	import com.emibap.textureAtlas.DynamicAtlas;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.Font;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import starling.display.MovieClip;
	
	import starling.textures.TextureAtlas;
	import starling.display.Sprite;

	public class DynAtlasSample extends Sprite{
		
		public function DynAtlasSample(){
			super();
			init();
		}
		
		private function init():void {
			addClipsFromContainer();
			addTextFields();
			
		}
		
		/**
		 * This method creates a Dynamic Atlas from a MovieClip Container and adds some Display Objects to the starling stage
		 * 
		 * It assumes that a class named SheetMC is a MovieClip which has been defined in a swc. (See the sample_for_atlas.fla for reference)
		 */
		private function addClipsFromContainer():void 
		{
			try {
				var mc:SheetMC = new SheetMC();
				var t1:uint = getTimer();
				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc, .5, 0, true, true);
				var total:uint = getTimer() - t1;
				//trace("atlas:", atlas);
				trace(total, "msecs elapsed while converting...");
				
				var boy_mc:MovieClip = new MovieClip(atlas.getTextures("boy"), 60);
				boy_mc.x = boy_mc.y = 10;
				addChild(boy_mc);
				Starling.juggler.add(boy_mc);
				
				var btnSkin:Image = new Image(atlas.getTextures("buttonSkin")[0]);
				btnSkin.x = 30
				btnSkin.y = 80;
				addChild(btnSkin);
				
			} catch (e:Error) {
				trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
		}
		
		/**
		 * This method registers a number of Dynamically generated bitmap fonts and adds texfields to the starling stage
		 * 
		 * For this method to work, you need to have the following fonts installed and embedded into a swc (Class names are defined inside the sample_for_atlas.fla file):
		 * - Verdana
		 * - Comic Sans
		 */
		private function addTextFields():void 
		{
			try {
				var embeddedFont1:Font = new Verdana();
				var embeddedFont2:Font = new ComicSansMSBold();
				
				var chars2Add:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
				chars2Add += chars2Add.toLowerCase() + ",.-_!?1234567890: ";
	
				var cont:flash.display.MovieClip = new TextContainer();
				
				DynamicAtlas.bitmapFontFromString(chars2Add, embeddedFont1.fontName, 16, false, false, -2);
				DynamicAtlas.bitmapFontFromString(chars2Add, "_sans", 16, false, false, -2);
				DynamicAtlas.bitmapFontFromTextField(cont.tf, 0);
				
				var embedded_tf:TextField = new TextField(300, 100, "Here is some dynamically generated text using an embedded Bitmap Font", embeddedFont1.fontName, 16, 0xFF0000, true);
				embedded_tf.x = 150;
				embedded_tf.y = 10;
				embedded_tf.autoScale = true;
				embedded_tf.border = true;
				addChild(embedded_tf);
				//
				var system_tf:TextField = new TextField(300, 100, "Here is some dynamically generated text using a system Bitmap Font.", "_sans", 16, 0x00FF00, false);
				system_tf.x = embedded_tf.x;
				system_tf.y = embedded_tf.y + embedded_tf.height;
				system_tf.autoScale = true;
				system_tf.border = true;
				addChild(system_tf);
				
				var filtered_tf:TextField = new TextField(300, 100, "AND ONE HELLUVA FILTERED TEXT", embeddedFont2.fontName, 16, 0x00FF00);
				// the native bitmap font size, no scaling 
				filtered_tf.fontSize = BitmapFont.NATIVE_SIZE;
				// use white to use the texture as it is (no tinting) 
				filtered_tf.color = Color.WHITE;
				filtered_tf.x = embedded_tf.x;
				filtered_tf.y = system_tf.y + system_tf.height;
				filtered_tf.border = true;
				addChild(filtered_tf);
			} catch (e:Error) {
				trace("There was an error in the creation of one of the Bitmap Fonts. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
		}
	}
}