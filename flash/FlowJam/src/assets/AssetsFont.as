package assets
{
	public class AssetsFont
	{
		[Embed(source="../../lib/assets/font/Vegur-R 0.602.otf", fontFamily="Vegur", embedAsCFF="false", mimeType="application/x-font")] private static const FontVegur:Class;
		[Embed(source="../../lib/assets/font/BEBAS___.TTF", fontFamily="Bebas", embedAsCFF="false", mimeType="application/x-font")] private static const FontBebas:Class;
		[Embed(source="../../lib/assets/font/Denk_One/DenkOne-Regular.ttf", fontFamily="DenkOne", embedAsCFF="false", mimeType="application/x-font")] private static const FontDenkOne:Class;
		[Embed(source="../../lib/assets/font/Metal_Mania/MetalMania-Regular.ttf", fontFamily="MetalMania", embedAsCFF="false", mimeType="application/x-font")] private static const FontMetalMania:Class;
		[Embed(source="../../lib/assets/font/Bangers/Bangers.ttf", fontFamily="Bangers", embedAsCFF="false", mimeType="application/x-font")] private static const FontBangers:Class;
		[Embed(source="../../lib/assets/font/Special_Elite/SpecialElite.ttf", fontFamily="SpecialElite", embedAsCFF="false", mimeType="application/x-font")] private static const FontSpecialElite:Class;
		[Embed(source = "../../lib/assets/font/UbuntuTitling-Bold.ttf", fontFamily="UbuntuTitlingBold", embedAsCFF="false", mimeType="application/x-font")] private static const FontUbuntuTitlingBold:Class;
		
		
		public static const FONT_DEFAULT:String   = "Vegur";
		public static const FONT_FRACTION:String  = "Bebas";
		public static const FONT_NUMERIC:String = "DenkOne";
		public static const FONT_METAL:String = "MetalMania";
		public static const FONT_BANGERS:String = "Bangers";
		public static const FONT_SPECIAL_ELITE:String = "SpecialElite";
		public static const FONT_UBUNTU:String = "UbuntuTitlingBold";
	}
}
