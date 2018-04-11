package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/FontAwesome.otf",fontFamily="Awesome",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontAwesome extends Font
{
    public function new()
    {
        super();
    }
}
