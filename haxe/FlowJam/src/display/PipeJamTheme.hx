/*
Copyright (c) 2012 Josh Tynjala

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package display;

import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.List;
import feathers.controls.PageIndicator;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.Screen;
import feathers.controls.ScrollBar;
import feathers.controls.ScrollText;
import feathers.controls.Scroller;
import feathers.controls.SimpleScrollBar;
import feathers.controls.Slider;
import feathers.controls.TextInput;
import feathers.controls.ToggleSwitch;
import feathers.controls.popups.DropDownPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.DisplayListWatcher;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import feathers.display.Scale3Image;
import feathers.display.Scale9Image;
import feathers.layout.VerticalLayout;
import feathers.skins.StandardIcons;
import feathers.system.DeviceCapabilities;
import feathers.textures.Scale3Textures;
import feathers.textures.Scale9Textures;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import feathers.themes.AeonDesktopTheme;

class PipeJamTheme extends AeonDesktopTheme
{
    @:meta(Embed(source="../../lib/assets/atlases/PipeJamSpriteSheet.png"))

    private static var ATLAS_IMAGE : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/atlases/PipeJamSpriteSheet.xml",mimeType="application/octet-stream"))

    private static var ATLAS_XML : Class<Dynamic>;
    
    
    
    private static inline var HEADER_TEXT_COLOR : Int = 0xffffff;
    
    private var menuBoxFreeSkinTextures : Scale9Textures;
    private var menuBoxAttachedSkinTextures : Scale9Textures;
    
    public function new(root : DisplayObjectContainer)
    {
        super(root);
    }
    
    override private function initialize() : Void
    {
        super.initialize();
        
        var atlasBitmapData : BitmapData = (Type.createInstance(ATLAS_IMAGE, [])).bitmapData;
        this.atlas = new TextureAtlas(Texture.fromBitmapData(atlasBitmapData, false), FastXML.parse(Type.createInstance(ATLAS_XML, [])));
        if (Starling.handleLostContext)
        {
            this.atlasBitmapData = atlasBitmapData;
        }
        else
        {
            atlasBitmapData.dispose();
        }
        
        this.defaultTextFormat = new TextFormat("_sans", 11, PRIMARY_TEXT_COLOR, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
        this.disabledTextFormat = new TextFormat("_sans", 11, DISABLED_TEXT_COLOR, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
        
        this.buttonUpSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuButton"), BUTTON_SCALE_9_GRID);
        this.buttonDownSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuButtonSelected"), BUTTON_SCALE_9_GRID);
        this.buttonHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuButtonOver"), BUTTON_SCALE_9_GRID);
        
        this.menuBoxFreeSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxFree"), BUTTON_SCALE_9_GRID);
        this.menuBoxAttachedSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxAttached"), BUTTON_SCALE_9_GRID);
        
        this.vScrollBarThumbUpSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButton"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.vScrollBarThumbHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButtonOver"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.vScrollBarThumbDownSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButtonSelected"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.vScrollBarTrackSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbar"), VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID);
        //			this.vScrollBarThumbIconTexture = this.atlas.getTexture("MenuBoxScrollbar");
        //			this.vScrollBarStepButtonUpSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-up-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
        //			this.vScrollBarStepButtonHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-hover-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
        //			this.vScrollBarStepButtonDownSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-down-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
        //			this.vScrollBarStepButtonDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-disabled-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
        //			this.vScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon");
        //			this.vScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon");
        
        this.hScrollBarThumbUpSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButton"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.hScrollBarThumbHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButtonOver"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.hScrollBarThumbDownSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbarButtonSelected"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
        this.hScrollBarTrackTextures = new Scale9Textures(this.atlas.getTexture("MenuBoxScrollbar"), HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID);
    }
    
    override private function listInitializer(list : List) : Void
    {
    }
    
    
    override private function headerInitializer(header : Header) : Void
    //no special background, currently
    {
        
        //header.backgroundSkin = new Scale9Image(headerBackgroundSkinTextures);
        
        //center doesn't seem to work?? So added left margin
        header.titleProperties.textFormat = new TextFormat("_sans", 18, HEADER_TEXT_COLOR, false, false, false, "", "", TextFormatAlign.CENTER, 20, 0, 0, 0);
        
        header.paddingTop = header.paddingBottom = 4;
        header.paddingRight = header.paddingLeft = 6;
    }
    
    override private function defaultHeaderOrFooterRendererInitializer(renderer : DefaultGroupedListHeaderOrFooterRenderer) : Void
    //	renderer.backgroundSkin = new Scale9Image(groupedListHeaderBackgroundSkinTextures);
    {
        
        //	renderer.backgroundSkin.height = 18;
        
        renderer.contentLabelProperties.textFormat = this.defaultTextFormat;
        
        renderer.paddingTop = renderer.paddingBottom = 2;
        renderer.paddingRight = renderer.paddingLeft = 6;
        renderer.minWidth = renderer.minHeight = 18;
    }
    
    override private function groupedListInitializer(list : GroupedList) : Void
    //list.backgroundSkin = new Scale9Image(simpleBorderBackgroundSkinTextures);
    {
        
        
        var layout : VerticalLayout = new VerticalLayout();
        layout.useVirtualLayout = true;
        layout.paddingTop = layout.paddingRight = layout.paddingBottom =
                                layout.paddingLeft = 0;
        layout.gap = 0;
        layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
        layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
        list.layout = layout;
        
        list.paddingTop = list.paddingRight = list.paddingBottom =
                                list.paddingLeft = 1;
    }
    private static var PipeJamTheme_static_initializer = {
        BUTTON_SCALE_9_GRID = new Rectangle(6, 6, 180, 180);
        true;
    }

}

