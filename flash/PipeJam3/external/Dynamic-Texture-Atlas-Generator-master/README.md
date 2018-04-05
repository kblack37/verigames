Dynamic Texture Atlas and Bitmap Font Generator (Starling framework Extension)
========

This tool will convert any MovieClip containing Other MovieClips, Sprites or Graphics into a starling Texture Atlas, all in runtime.
It can also register bitmap Fonts from system or embedded regular fonts.
By using it, you won't have to statically create your spritesheets or fonts. For instance, you can just take a regular MovieClip containing all the display objects you wish to put into your Altas, and convert everything from vectors to bitmap textures.
Or you can select which font (specifying characters) you'd like to register as a Bitmap Font, using a string or passing a Regular TextField as a parameter.
This extension could save you a lot of time specially if you'll be coding mobile apps with the [starling framework](http://www.starling-framework.org/).

# version 1.0 #
- Added the checkBounds parameter to scan the clip prior the rasterization in order to get the bounds of the entire MovieClip (prevent scaling in some cases). Thank you Aymeric Lamboley.
- Added the fontCustomID parameter to the Bitmap font creation. Thank you Regan.

### Features ###

* Dynamic creation of a Texture Atlas from a MovieClip (flash.display.MovieClip) container that could act as a sprite sheet, or from a Vector of Classes
* Filters made to the objects are captured
* Color transforms (tint, alpha) are optionally captured
* Scales the objects (and also the filters) to a specified value
* Automatically detects the objects bounds so you don't necessarily have to set the registration points to TOP LEFT
* Registers Bitmap Fonts based on system or embedded fonts from strings or from good old Flash TextFields

### TODO List ###

* Further code optimization
* A better implementation of the Bitmap Font creation process
* Documentation (?)

### Whish List ###
* Optional division of the process into small intervals (for smooth performance of the app)

### Usage ###
You can use the following static methods (examples at the gitHub Repo):
	
[Texture Atlas creation]
- DynamicAtlas.fromMovieClipContainer(swf:flash.display.MovieClip, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true):starling.textures.TextureAtlas
- DynamicAtlas.fromClassVector(assets:Vector.<Class>, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true):starling.textures.TextureAtlas

[Bitmap Font registration]
- DynamicAtlas.bitmapFontFromString(chars:String, fontFamily:String, fontSize:Number = 12, bold:Boolean = false, italic:Boolean = false, charMarginX:int=0):void
- DynamicAtlas.bitmapFontFromTextField(tf:flash.text.TextField, charMarginX:int=0):void

Enclose inside a try/catch for error handling:
	try {
		var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc);
	} catch (e:Error) {
		trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
	}

 History:
 -------
# version 0.9.5 #
- Added the fromClassVector static function. Thank you Thomas Haselwanter
 
# version 0.9 #
- Added Bitmap Font creation support
- Scaling also applies to filters.
- Added Margin and PreserveColor Properties

# version 0.8 #
- Added the scaleFactor constructor parameter. Now you can define a custom scale to the final result.
- Scaling also applies to filters.
- Added Margin and PreserveColor Properties

# version 0.7 #
First Public version


### Steps to make your own Dynamic Texture Atlas ###
#### Base Sprite sheet creation (Inside Flash IDE) ####
Create a new fla and make sure it is minimum flash 9 using as3.
Start creating MovieClips that you want to be written to a sprite sheet. Be sure to avoid using actionscript, and if you have sub clips use graphics as opposed to MovieClip so that they get picked up.
Drag all the MovieClips you want rendered to the main stage and name them.
Export the swf.

You can also drag all the MovieClips inside another Clip and assign a class to it if you prefer not to load an external swf.
Dynamically creating the MovieClip container and every one of its children is also possible.

#### TextureAtlas conversion ####
Load the sprite sheet swf or create an instance of it as a MovieClip
Use the DynamicAtlas.fromMovieClipContainer() static method to convert your flash.display.MovieClip to a starling.textures.TextureAtlas.
(don't forget to destroy your now useless MovieClip)

### Steps for making your own Dynamic Bitmap Font ###
You can use an embedded font and call the DynamicAtlas.bitmapFontFromString method, passing the chars to be rasterized as well as your font.
Also, you can create a TextField, assign filters, color transforms and setting the chars to be rasterized into its text and then call the DynamicAtlas.bitmapFontFromTextField function.
The selected font will be dynamically converted to a Starling Bitmap Font.

### Using the sample included in the package ###
The sample included is a simple FlashDevelop project which uses a library item as base MovieClip to create a TextureAtlas and some Bitmap Fonts at runtime.
If you plan to use it, you need to add the Classpaths of your copy of the starling framework and of this extension (dynamicTextureAtlasGenerator).
You should also link the sample swc to your project to be able to use the assets inside of it.
For the Dynamic Bitmap Fonts to work, you need to have the following fonts installed and embedded into a swc or directly into the project (Class names are defined inside the sample_for_atlas.fla file):
		 * - Verdana
		 * - Comic Sans
#### Requirements ####
Please refer to the [starling documentation](http://doc.starling-framework.org/core/) or to the [starling tutorial](http://www.bytearray.org/?p=3371) for requirements and setup.

This project began as a fork of the [Texture Atlas Generator](https://github.com/pixelrevision/texture_atlas_generator) by pixelrevision
Most of this comes thanks to the inspiration (and code) of [Thibault Imbert](http://www.bytearray.org) and [Nicolas Gans](http://www.flashxpress.net/)	