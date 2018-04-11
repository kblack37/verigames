package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/Cabin-Regular.otf",fontFamily="Cabin",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontCabin extends Font
{
    public function new()
    {
        super();
    }
}
