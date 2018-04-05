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
package display
{
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
	
	public class PipeJamTheme extends AeonDesktopTheme
	{
		[Embed(source="../../lib/assets/atlases/PipeJamSpriteSheet.png")]
		protected static const ATLAS_IMAGE:Class;
		
		[Embed(source="../../lib/assets/atlases/PipeJamSpriteSheet.xml",mimeType="application/octet-stream")]
		protected static const ATLAS_XML:Class;
		
		BUTTON_SCALE_9_GRID = new Rectangle(6, 6, 180, 180);
		
		protected static const HEADER_TEXT_COLOR:uint = 0xffffff;
		
		protected var menuBoxFreeSkinTextures:Scale9Textures;
		protected var menuBoxAttachedSkinTextures:Scale9Textures;
		
		public function PipeJamTheme(root:DisplayObjectContainer)
		{
			super(root);
		}
		
		protected override function initialize():void
		{
			super.initialize();
			
			const atlasBitmapData:BitmapData = (new ATLAS_IMAGE()).bitmapData;
			this.atlas = new TextureAtlas(Texture.fromBitmapData(atlasBitmapData, false), XML(new ATLAS_XML()));
			if(Starling.handleLostContext)
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
//			this.hScrollBarThumbIconTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-icon");
//			this.hScrollBarStepButtonUpSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-up-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-hover-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonDownSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-down-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-disabled-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon");
//			this.hScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon");
//			this.buttonDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("button-disabled-skin"), BUTTON_SCALE_9_GRID);
//			this.buttonSelectedUpSkinTextures = new Scale9Textures(this.atlas.getTexture("button-selected-up-skin"), SELECTED_BUTTON_SCALE_9_GRID);
//			this.buttonSelectedHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("MenuButtonOver"), BUTTON_SCALE_9_GRID);
//			this.buttonSelectedDownSkinTextures = new Scale9Textures(this.atlas.getTexture("button-selected-down-skin"), SELECTED_BUTTON_SCALE_9_GRID);
//			this.buttonSelectedDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("button-selected-disabled-skin"), SELECTED_BUTTON_SCALE_9_GRID);
//			
//			this.hSliderThumbUpSkinTexture = this.atlas.getTexture("hslider-thumb-up-skin");
//			this.hSliderThumbHoverSkinTexture = this.atlas.getTexture("hslider-thumb-hover-skin");
//			this.hSliderThumbDownSkinTexture = this.atlas.getTexture("hslider-thumb-down-skin");
//			this.hSliderThumbDisabledSkinTexture = this.atlas.getTexture("hslider-thumb-disabled-skin");
//			this.hSliderTrackSkinTextures = new Scale3Textures(this.atlas.getTexture("hslider-track-skin"), HSLIDER_FIRST_REGION, HSLIDER_SECOND_REGION, Scale3Textures.DIRECTION_HORIZONTAL);
//			
//			this.vSliderThumbUpSkinTexture = this.atlas.getTexture("vslider-thumb-up-skin");
//			this.vSliderThumbHoverSkinTexture = this.atlas.getTexture("vslider-thumb-hover-skin");
//			this.vSliderThumbDownSkinTexture = this.atlas.getTexture("vslider-thumb-down-skin");
//			this.vSliderThumbDisabledSkinTexture = this.atlas.getTexture("vslider-thumb-disabled-skin");
//			this.vSliderTrackSkinTextures = new Scale3Textures(this.atlas.getTexture("vslider-track-skin"), HSLIDER_FIRST_REGION, HSLIDER_SECOND_REGION, Scale3Textures.DIRECTION_VERTICAL);
//			
//			this.itemRendererUpSkinTexture = this.atlas.getTexture("item-renderer-up-skin");
//			this.itemRendererHoverSkinTexture = this.atlas.getTexture("item-renderer-hover-skin");
//			this.itemRendererSelectedUpSkinTexture = this.atlas.getTexture("item-renderer-selected-up-skin");
//			
//			this.headerBackgroundSkinTextures = new Scale9Textures(this.atlas.getTexture("header-background-skin"), HEADER_SCALE_9_GRID);
//			this.groupedListHeaderBackgroundSkinTextures = new Scale9Textures(this.atlas.getTexture("grouped-list-header-background-skin"), HEADER_SCALE_9_GRID);
//			
//			this.checkUpIconTexture = this.atlas.getTexture("check-up-icon");
//			this.checkHoverIconTexture = this.atlas.getTexture("check-hover-icon");
//			this.checkDownIconTexture = this.atlas.getTexture("check-down-icon");
//			this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon");
//			this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon");
//			this.checkSelectedHoverIconTexture = this.atlas.getTexture("check-selected-hover-icon");
//			this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon");
//			this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon");
//			
//			this.radioUpIconTexture = this.atlas.getTexture("radio-up-icon");
//			this.radioHoverIconTexture = this.atlas.getTexture("radio-hover-icon");
//			this.radioDownIconTexture = this.atlas.getTexture("radio-down-icon");
//			this.radioDisabledIconTexture = this.atlas.getTexture("radio-disabled-icon");
//			this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon");
//			this.radioSelectedHoverIconTexture = this.atlas.getTexture("radio-selected-hover-icon");
//			this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon");
//			this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon");
//			
//			this.pageIndicatorNormalSkinTexture = this.atlas.getTexture("page-indicator-normal-skin");
//			this.pageIndicatorSelectedSkinTexture = this.atlas.getTexture("page-indicator-selected-skin");
//			
//			this.pickerListUpIconTexture = this.atlas.getTexture("picker-list-up-icon");
//			this.pickerListHoverIconTexture = this.atlas.getTexture("picker-list-hover-icon");
//			this.pickerListDownIconTexture = this.atlas.getTexture("picker-list-down-icon");
//			this.pickerListDisabledIconTexture = this.atlas.getTexture("picker-list-disabled-icon");
//			
//			this.textInputBackgroundSkinTextures = new Scale9Textures(this.atlas.getTexture("text-input-background-skin"), TEXT_INPUT_SCALE_9_GRID);
//			this.textInputBackgroundDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("text-input-background-disabled-skin"), TEXT_INPUT_SCALE_9_GRID);
//			
//			this.vScrollBarThumbUpSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-thumb-up-skin"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.vScrollBarThumbHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-thumb-hover-skin"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.vScrollBarThumbDownSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-thumb-down-skin"), VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.vScrollBarTrackSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-track-skin"), VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID);
//			this.vScrollBarThumbIconTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-icon");
//			this.vScrollBarStepButtonUpSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-up-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.vScrollBarStepButtonHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-hover-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.vScrollBarStepButtonDownSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-down-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.vScrollBarStepButtonDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("vertical-scroll-bar-step-button-disabled-skin"), VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.vScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon");
//			this.vScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon");
//			
//			this.hScrollBarThumbUpSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-thumb-up-skin"), HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.hScrollBarThumbHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-thumb-hover-skin"), HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.hScrollBarThumbDownSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-thumb-down-skin"), HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID);
//			this.hScrollBarTrackTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-track-skin"), HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID);
//			this.hScrollBarThumbIconTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-icon");
//			this.hScrollBarStepButtonUpSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-up-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonHoverSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-hover-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonDownSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-down-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarStepButtonDisabledSkinTextures = new Scale9Textures(this.atlas.getTexture("horizontal-scroll-bar-step-button-disabled-skin"), HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID);
//			this.hScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon");
//			this.hScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon");
//			
//			this.simpleBorderBackgroundSkinTextures = new Scale9Textures(this.atlas.getTexture("simple-border-background-skin"), SIMPLE_BORDER_SCALE_9_GRID);
//			this.panelBorderBackgroundSkinTextures = new Scale9Textures(this.atlas.getTexture("panel-background-skin"), PANEL_BORDER_SCALE_9_GRID);
//			
//			this.progressBarFillSkinTexture = this.atlas.getTexture("progress-bar-fill-skin");
//			
//			StandardIcons.listDrillDownAccessoryTexture = this.atlas.getTexture("list-accessory-drill-down-icon");
			

			
//			this.setInitializerForClassAndSubclasses(Screen, screenInitializer);
//			this.setInitializerForClass(Label, labelInitializer);
//			this.setInitializerForClass(ScrollText, scrollTextInitializer);
//			this.setInitializerForClass(BitmapFontTextRenderer, itemRendererAccessoryLabelInitializer, BaseDefaultItemRenderer.DEFAULT_CHILD_NAME_ACCESSORY_LABEL);
//			this.setInitializerForClass(Button, buttonInitializer);
//			this.setInitializerForClass(Button, toggleSwitchOnTrackInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_ON_TRACK);
//			this.setInitializerForClass(Button, toggleSwitchThumbInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_THUMB);
//			this.setInitializerForClass(Button, pickerListButtonInitializer, PickerList.DEFAULT_CHILD_NAME_BUTTON);
//			this.setInitializerForClass(Button, nothingInitializer, SimpleScrollBar.DEFAULT_CHILD_NAME_THUMB);
//			this.setInitializerForClass(Button, nothingInitializer, ScrollBar.DEFAULT_CHILD_NAME_THUMB);
//			this.setInitializerForClass(Button, nothingInitializer, ScrollBar.DEFAULT_CHILD_NAME_DECREMENT_BUTTON);
//			this.setInitializerForClass(Button, nothingInitializer, ScrollBar.DEFAULT_CHILD_NAME_INCREMENT_BUTTON);
//			this.setInitializerForClass(Button, nothingInitializer, ScrollBar.DEFAULT_CHILD_NAME_MINIMUM_TRACK);
//			this.setInitializerForClass(Button, nothingInitializer, ScrollBar.DEFAULT_CHILD_NAME_MAXIMUM_TRACK);
//			this.setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_THUMB);
//			this.setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MINIMUM_TRACK);
//			this.setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MAXIMUM_TRACK);
//			this.setInitializerForClass(ButtonGroup, buttonGroupInitializer);
//			this.setInitializerForClass(Check, checkInitializer);
//			this.setInitializerForClass(Radio, radioInitializer);
//			this.setInitializerForClass(ToggleSwitch, toggleSwitchInitializer);
//			this.setInitializerForClass(Slider, sliderInitializer);
//			this.setInitializerForClass(SimpleScrollBar, simpleScrollBarInitializer);
//			this.setInitializerForClass(ScrollBar, scrollBarInitializer);
//			this.setInitializerForClass(TextInput, textInputInitializer);
//			this.setInitializerForClass(PageIndicator, pageIndicatorInitializer);
//			this.setInitializerForClass(ProgressBar, progressBarInitializer);
//			this.setInitializerForClass(Scroller, scrollerInitializer);
//			this.setInitializerForClass(List, listInitializer);
//			this.setInitializerForClass(List, nothingInitializer, PickerList.DEFAULT_CHILD_NAME_LIST);
//			this.setInitializerForClass(GroupedList, groupedListInitializer);
//			this.setInitializerForClass(PickerList, pickerListInitializer);
//			this.setInitializerForClass(DefaultListItemRenderer, defaultItemRendererInitializer);
//			this.setInitializerForClass(DefaultGroupedListItemRenderer, defaultItemRendererInitializer);
//			this.setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, defaultHeaderOrFooterRendererInitializer);
//			this.setInitializerForClass(Header, headerInitializer);
//			this.setInitializerForClass(Callout, calloutInitializer);
		}
		
		protected override function listInitializer(list:List):void
		{

		}
		
		
		protected override function headerInitializer(header:Header):void
		{
			//no special background, currently
			//header.backgroundSkin = new Scale9Image(headerBackgroundSkinTextures);
			
			//center doesn't seem to work?? So added left margin
			header.titleProperties.textFormat = new TextFormat("_sans", 18, HEADER_TEXT_COLOR, false, false, false, "", "", TextFormatAlign.CENTER, 20, 0, 0, 0);
			
			header.paddingTop = header.paddingBottom = 4;
			header.paddingRight = header.paddingLeft = 6;
		}
		
		protected override function defaultHeaderOrFooterRendererInitializer(renderer:DefaultGroupedListHeaderOrFooterRenderer):void
		{
		//	renderer.backgroundSkin = new Scale9Image(groupedListHeaderBackgroundSkinTextures);
		//	renderer.backgroundSkin.height = 18;
			
			renderer.contentLabelProperties.textFormat = this.defaultTextFormat;
			
			renderer.paddingTop = renderer.paddingBottom = 2;
			renderer.paddingRight = renderer.paddingLeft = 6;
			renderer.minWidth = renderer.minHeight = 18;
		}
		
		protected override function groupedListInitializer(list:GroupedList):void
		{
			//list.backgroundSkin = new Scale9Image(simpleBorderBackgroundSkinTextures);
			
			const layout:VerticalLayout = new VerticalLayout();
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
		
//		protected override function scrollBarInitializer(scrollBar:ScrollBar):void
//		{
//			scrollBar.trackLayoutMode = ScrollBar.TRACK_LAYOUT_MODE_SINGLE;
//			
//			const decrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
//			decrementButtonDisabledIcon.alpha = 0;
//			scrollBar.decrementButtonProperties.disabledIcon = decrementButtonDisabledIcon;
//			
//			const incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
//			incrementButtonDisabledIcon.alpha = 0;
//			scrollBar.incrementButtonProperties.disabledIcon = incrementButtonDisabledIcon;
//			
//			if(scrollBar.direction == Slider.DIRECTION_VERTICAL)
//			{
//				scrollBar.decrementButtonProperties.defaultSkin = new Scale9Image(vScrollBarStepButtonUpSkinTextures);
//				scrollBar.decrementButtonProperties.hoverSkin = new Scale9Image(vScrollBarStepButtonHoverSkinTextures);
//				scrollBar.decrementButtonProperties.downSkin = new Scale9Image(vScrollBarStepButtonDownSkinTextures);
//				scrollBar.decrementButtonProperties.disabledSkin = new Scale9Image(vScrollBarStepButtonDisabledSkinTextures);
//				scrollBar.decrementButtonProperties.defaultIcon = new Image(vScrollBarDecrementButtonIconTexture);
//				
//				scrollBar.incrementButtonProperties.defaultSkin = new Scale9Image(vScrollBarStepButtonUpSkinTextures);
//				scrollBar.incrementButtonProperties.hoverSkin = new Scale9Image(vScrollBarStepButtonHoverSkinTextures);
//				scrollBar.incrementButtonProperties.downSkin = new Scale9Image(vScrollBarStepButtonDownSkinTextures);
//				scrollBar.incrementButtonProperties.disabledSkin = new Scale9Image(vScrollBarStepButtonDisabledSkinTextures);
//				scrollBar.incrementButtonProperties.defaultIcon = new Image(vScrollBarIncrementButtonIconTexture);
//				
//				var thumbSkin:Scale9Image = new Scale9Image(vScrollBarThumbUpSkinTextures);
//				thumbSkin.height = thumbSkin.width;
//				scrollBar.thumbProperties.defaultSkin = thumbSkin;
//				thumbSkin = new Scale9Image(vScrollBarThumbHoverSkinTextures);
//				thumbSkin.height = thumbSkin.width;
//				scrollBar.thumbProperties.hoverSkin = thumbSkin;
//				thumbSkin = new Scale9Image(vScrollBarThumbDownSkinTextures);
//				thumbSkin.height = thumbSkin.width;
//				scrollBar.thumbProperties.downSkin = thumbSkin;
//				scrollBar.thumbProperties.defaultIcon = new Image(vScrollBarThumbIconTexture);
//				scrollBar.thumbProperties.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
//				scrollBar.thumbProperties.paddingLeft = 4;
//				
//				scrollBar.minimumTrackProperties.defaultSkin = new Scale9Image(vScrollBarTrackSkinTextures);
//			}
//			else //horizontal
//			{
//				scrollBar.decrementButtonProperties.defaultSkin = new Scale9Image(hScrollBarStepButtonUpSkinTextures);
//				scrollBar.decrementButtonProperties.hoverSkin = new Scale9Image(hScrollBarStepButtonHoverSkinTextures);
//				scrollBar.decrementButtonProperties.downSkin = new Scale9Image(hScrollBarStepButtonDownSkinTextures);
//				scrollBar.decrementButtonProperties.disabledSkin = new Scale9Image(hScrollBarStepButtonDisabledSkinTextures);
//				scrollBar.decrementButtonProperties.defaultIcon = new Image(hScrollBarDecrementButtonIconTexture);
//				
//				scrollBar.incrementButtonProperties.defaultSkin = new Scale9Image(hScrollBarStepButtonUpSkinTextures);
//				scrollBar.incrementButtonProperties.hoverSkin = new Scale9Image(hScrollBarStepButtonHoverSkinTextures);
//				scrollBar.incrementButtonProperties.downSkin = new Scale9Image(hScrollBarStepButtonDownSkinTextures);
//				scrollBar.incrementButtonProperties.disabledSkin = new Scale9Image(hScrollBarStepButtonDisabledSkinTextures);
//				scrollBar.incrementButtonProperties.defaultIcon = new Image(hScrollBarIncrementButtonIconTexture);
//				
//				thumbSkin = new Scale9Image(hScrollBarThumbUpSkinTextures);
//				thumbSkin.width = thumbSkin.height;
//				scrollBar.thumbProperties.defaultSkin = thumbSkin;
//				thumbSkin = new Scale9Image(hScrollBarThumbHoverSkinTextures);
//				thumbSkin.width = thumbSkin.height;
//				scrollBar.thumbProperties.hoverSkin = thumbSkin;
//				thumbSkin = new Scale9Image(hScrollBarThumbDownSkinTextures);
//				thumbSkin.width = thumbSkin.height;
//				scrollBar.thumbProperties.downSkin = thumbSkin;
//				scrollBar.thumbProperties.defaultIcon = new Image(hScrollBarThumbIconTexture);
//				scrollBar.thumbProperties.verticalAlign = Button.VERTICAL_ALIGN_TOP;
//				scrollBar.thumbProperties.paddingTop = 4;
//				
//				scrollBar.minimumTrackProperties.defaultSkin = new Scale9Image(hScrollBarTrackTextures);
//			}
//		}
	}
}
