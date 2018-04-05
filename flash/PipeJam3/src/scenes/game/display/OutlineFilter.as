package scenes.game.display
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;

	public class OutlineFilter
	{
		private static var m_outlineFilter:BitmapFilter;
		
		public static function getOutlineFilter():BitmapFilter
		{
			if (!m_outlineFilter) {
				var glowFilter:GlowFilter = new GlowFilter();
				glowFilter.blurX = glowFilter.blurY = 2;
				glowFilter.color = 0x000000;
				glowFilter.quality = BitmapFilterQuality.HIGH;
				glowFilter.strength = 100;
				
				m_outlineFilter = glowFilter;
			}
			return m_outlineFilter;
		}
	}
}
