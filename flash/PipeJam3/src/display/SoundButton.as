package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class SoundButton extends ImageStateButton
	{
		public function SoundButton()
		{
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			var soundUp:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSound);
			var soundOver:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSoundOver);
			var soundDown:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSoundClick);
			
			var soundOnUp:Image = new Image(soundUp);
			//soundOnUp.width = soundOnUp.height = 25;
			var soundOffUp:Image = new Image(soundUp);
			soundOffUp.alpha = 0.5;
			var soundOnOver:Image = new Image(soundOver);
			var soundOffOver:Image = new Image(soundOver);
			soundOffOver.alpha = 0.5;
			var soundOnDown:Image = new Image(soundDown);
			var soundOffDown:Image = new Image(soundDown);
			soundOffDown.alpha = 0.5;
			
			super(
				Vector.<DisplayObject>([soundOnUp, soundOffUp]),
				Vector.<DisplayObject>([soundOnOver, soundOffOver]),
				Vector.<DisplayObject>([soundOnDown, soundOffDown])
			);
		}
		
		public function set sfxOn(on:Boolean):void
		{
			setState(on ? 0 : 1);
		}
	}
}
