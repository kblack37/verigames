package scenes.game.display
{
	import constraints.INodeProps;
	import flash.utils.Dictionary;
	import utils.XMath;
	
	import assets.AssetInterface;
	
	import constraints.ConstraintValue;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class NodeSkin extends Sprite implements INodeProps
	{
		static protected var availableGameNodeSkins:Vector.<NodeSkin>;
		static protected var activeGameNodeSkins:Dictionary;
		
		static protected var mAtlas:TextureAtlas;	
		static protected var DarkBlueCircle:Texture;
		static protected var LightBlueCircle:Texture;
		static protected var LightBlueSelectedCircle:Texture;
		static protected var DarkBlueSelectedCircle:Texture;
		static protected var SatisfiedConstraintTexture:Texture;
		static protected var UnsatisfiedConstraintTexture:Texture;
		static protected var UnsatisfiedConstraintBackgroundTexture:Texture;
		
		public var isBackground:Boolean = false;
		public var isDirty:Boolean = true;
		protected var textureImage:Image;
		protected var constraintImage:Image;
		
		static public const WIDE_COLOR:int = 0x0B80FF;
		static public const NARROW_COLOR:int = 0xABFFF2;

		static public const WIDE_COLOR_COMPLEMENT:int = 0x0B90FF;
		static public const NARROW_COLOR_COMPLEMENT:int = 0x89DDD0;
		
		public var id:int;
		public static var numSkins:int = 2000;
		// TODO: Move to factory
		static public function InitializeSkins():void
		{
			//generate skins
			availableGameNodeSkins = new Vector.<NodeSkin>;
			activeGameNodeSkins = new Dictionary();
			
			for(var numSkin:int = 0; numSkin < numSkins; numSkin++)
			{
				availableGameNodeSkins.push(new NodeSkin(numSkin));
			}
		}
		
		private static var nextId:int = 0;
		static public function getNextSkin():NodeSkin
		{
			var nextSkin:NodeSkin;
			if(availableGameNodeSkins.length > 0)
				nextSkin = availableGameNodeSkins.pop();
			else
			{
				if (false) // attempt limiting the number of skins
				{
					var attempts:int = 0;
					while (!activeGameNodeSkins[nextId])
					{
						if (nextId > numSkins) nextId = 0;
						nextId++;
						attempts++;
						if (attempts > numSkins) break;
					}
					nextSkin = activeGameNodeSkins[nextId];
					nextId++;
					if (nextSkin)
					{
						nextSkin.removeFromParent(true);
						nextSkin.disableSkin();
						// TODO: Node's skin is non-null still
					}
				}
				else
				{
					nextSkin = new NodeSkin(numSkins);
					numSkins++;
				}
			}

			if (nextSkin) activeGameNodeSkins[nextSkin.id] = nextSkin;
			nextSkin.isDirty =  true;
			return nextSkin;
		}
		
		static public function getColor(node:Node, edge:Edge = null):int
		{
			//ask the node if it's a clause, and if it is, figure out if the end is wide or not
			if(edge)
			{
				if(edge.graphConstraint.lhs.id.indexOf('c') == 0)
					return WIDE_COLOR;
				else
					return NARROW_COLOR;
			}
			if(!node.isNarrow)
			{
				return WIDE_COLOR;
			}
			else
			{
				return NARROW_COLOR;
			}
		}
		
		static public function getComplementColor(node:Object):int
		{
			if(!node.isNarrow)
				return WIDE_COLOR_COMPLEMENT;
			else
				return NARROW_COLOR_COMPLEMENT;
		}
		
		public static function countKeys(myDictionary:Dictionary):int 
		{
			var n:int = 0;
			for (var key:* in myDictionary) {
				n++;
			}
			return n;
		}
		
		public function NodeSkin(numSkin:int)
		{
			id = numSkin;
			
			if(!mAtlas)
			{
				mAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
				DarkBlueCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableWide);
				LightBlueCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableNarrow);
				LightBlueSelectedCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableNarrowSelected);
				DarkBlueSelectedCircle = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_VariableWideSelected);
				UnsatisfiedConstraintTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_ConstraintConflict);
				SatisfiedConstraintTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_ConstraintCorrected);
				UnsatisfiedConstraintBackgroundTexture = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_Conflict);
			}
		}
		
		public function draw():void
		{
			if (!isDirty) return;
			isDirty = false;
			Starling.juggler.removeTweens(this);
			
			if (textureImage) textureImage.removeFromParent(true);
			if (constraintImage) constraintImage.removeFromParent(true);
			
			if(!isClause())
			{
				if (isNarrow() && isSelected())
				{
					textureImage = new Image(LightBlueSelectedCircle);
				}
				else if (!isNarrow() && isSelected())
				{
					textureImage = new Image(DarkBlueSelectedCircle);
				}
				else if(!isNarrow())
				{
					textureImage = new Image(DarkBlueCircle);
				}
				else // narrow, unselected
				{
					textureImage = new Image(LightBlueCircle);
				}
				
				//if(isSolved() && isSelected())
				//{
					//textureImage.setVertexColor(0, 0x00ff00);
					//textureImage.setVertexColor(1, 0x00ff00);
					//textureImage.setVertexColor(2, 0x00ff00);
					//textureImage.setVertexColor(3, 0x00ff00);
				//}
				//else
				//{
					//textureImage.setVertexColor(0, 0xffffff);
					//textureImage.setVertexColor(1, 0xffffff);
					//textureImage.setVertexColor(2, 0xffffff);
					//textureImage.setVertexColor(3, 0xffffff);
				//}	
				
				textureImage.width = textureImage.height = 14;
				textureImage.x = -textureImage.width/2;
				textureImage.y = -textureImage.width/2; 
				addChild(textureImage);
			}
			else
			{
				// Is clause
				if(hasError())
				{
					if (isBackground)
					{
						constraintImage = new Image(UnsatisfiedConstraintBackgroundTexture);
						constraintImage.width = constraintImage.height = 40;
					}
					else
					{
						constraintImage = new Image(UnsatisfiedConstraintTexture);
						constraintImage.width = constraintImage.height = 10;
					}
				}
				else
				{
					if (isBackground) return; // no background image for satisfied conflicts
					constraintImage = new Image(SatisfiedConstraintTexture);
					constraintImage.width = constraintImage.height = 10;
				}
				constraintImage.x = -constraintImage.width/2;
				constraintImage.y = -constraintImage.width/2; 
				addChild(constraintImage);
			}
		}
		
		public override function dispose():void
		{
			Starling.juggler.removeTweens(this);
			if (textureImage != null) textureImage.removeFromParent(true);
			if (constraintImage != null) constraintImage.removeFromParent(true);
			alpha = scaleX = scaleY = 1;
			removeChildren(0, -1, true);
			super.dispose();
		}
		
		public function disableSkin():void
		{
			availableGameNodeSkins.push(this);
			delete activeGameNodeSkins[id];
		}
		
		override public function removeChild(_child:DisplayObject, dispose:Boolean = false):DisplayObject
		{
			return super.removeChild(_child, dispose);
		}
		
		public function setNodeProps(_isClause:Boolean = false, 
								_isNarrow:Boolean = false, 
								_isSelected:Boolean = false, 
								_isSolved:Boolean = false, 
								_hasError:Boolean = false,
								_isBackground:Boolean = false):void
		{
			m_isClause = _isClause;
			m_isNarrow = _isNarrow;
			m_isSelected = _isSelected;
			m_isSolved = _isSolved;
			m_hasError = _hasError;
			isBackground = _isBackground;
			isDirty = true;
		}
		
		public function scale(newScale:Number):void
		{
			var currentWidth:Number;
			var newWidth:Number;
			if (textureImage != null)
			{
				textureImage.scaleX = textureImage.scaleY = newScale;
				newWidth = XMath.clamp(textureImage.width, 5, 50);
				textureImage.width = textureImage.height = newWidth;
				textureImage.x = -newWidth / 2;
				textureImage.y = -newWidth / 2;
			}
			if (constraintImage != null)
			{
				constraintImage.scaleX = constraintImage.scaleY = newScale;
				newWidth = XMath.clamp(constraintImage.width, isBackground ? 10 : 5, isBackground ? 500 : 50);
				constraintImage.width = constraintImage.height = newWidth;
				constraintImage.x = -newWidth / 2;
				constraintImage.y = -newWidth / 2;
			}
		}
		
		// --- INodeProps --->
		private var m_isClause:Boolean = false;
		private var m_isNarrow:Boolean = false;
		private var m_isSelected:Boolean = false;
		private var m_isSolved:Boolean = false;
		private var m_hasError:Boolean = false;
		public function isClause():Boolean { return m_isClause; }
		public function isNarrow():Boolean { return m_isNarrow; }
		public function isSelected():Boolean { return m_isSelected; }
		public function isSolved():Boolean { return m_isSolved; }
		public function hasError():Boolean { return m_hasError; }
		// <--- INodeProps ---
	}
}