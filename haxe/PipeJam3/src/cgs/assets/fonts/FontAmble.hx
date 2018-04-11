package cgs.assets.fonts;

import flash.text.Font;

//Force compilier to use specific class for embed otherwise mx.core.FontAsset is used.
@:meta(Embed(source="../../../../assets/font/Amble-Regular.ttf",fontFamily="Amble",embedAsCFF="false",mimeType="application/x-font"))

@:final class FontAmble extends Font
{
    public function new()
    {
        super();
    }
}
