package UserInterface.Components 
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import Utilities.Fonts;
	
	public class GenericProgressBar extends Sprite 
	{
		private static const WIDTH:Number = 200.0;
		private static const HEIGHT:Number = 20.0;
		private var title:TextField;
		private var progress_text:TextField;
		private var format:TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 16, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		
		public function GenericProgressBar(_task:String = "") 
		{
			super();
			
			title = new TextField();
			title.text = _task;
			title.selectable = false;
			title.setTextFormat(format);
			title.y = - HEIGHT - title.textHeight - 8;
			title.x = - 0.5 * WIDTH;
			title.width = WIDTH;
			title.embedFonts = true;
			addChild(title);
			
			progress_text = new TextField();
			progress_text.selectable = false;
			progress_text.setTextFormat(format);
			progress_text.y = 4;
			progress_text.x = - 0.5 * WIDTH;
			progress_text.width = WIDTH;
			progress_text.embedFonts = true;
			addChild(progress_text);
			var gf:GlowFilter = new GlowFilter(0x0, 1, 2, 2, 10, BitmapFilterQuality.MEDIUM);
			filters = [gf];
			update(0);
		}
		
		/**
		 * Function called to update progress bar based on percent (0.0-1.0)
		 * @param	pct Number 0.0-1.0
		 */
		public function update(pct:Number):void {
			pct = Math.max(Math.min(pct, 1.0), 0.0);
			progress_text.text = " " + Math.round(pct * 100).toString() + "%";
			progress_text.setTextFormat(format);
			graphics.clear();
			graphics.beginFill(0x0);
			graphics.lineStyle(6.0, 0x0);
			graphics.drawRect( -0.5 * WIDTH, -HEIGHT, WIDTH, HEIGHT);
			graphics.endFill();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect( -0.5 * WIDTH, -HEIGHT, pct * WIDTH, HEIGHT);
			graphics.endFill();
		}
		
	}

}