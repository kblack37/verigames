package scenes.game.display
{
	import assets.AssetInterface;
	import constraints.ConstraintVar;
	import starling.textures.Texture;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.textures.TextureAtlas;
	
	import utils.PropDictionary;
	
	public class EdgeSkin extends Sprite
	{
		static protected var mAtlas:TextureAtlas;
		static protected var EdgeNarrowSatisfiedSelected:Texture;
		static protected var EdgeNarrowSatisfiedUnselected:Texture;
		static protected var EdgeNarrowUnsatisfiedSelected:Texture;
		static protected var EdgeNarrowUnsatisfiedUnselected:Texture;
		static protected var EdgeWideSatisfiedSelected:Texture;
		static protected var EdgeWideSatisfiedUnselected:Texture;
		static protected var EdgeWideUnsatisfiedSelected:Texture;
		static protected var EdgeWideUnsatisfiedUnselected:Texture;
		
		public var parentEdge:Edge;
		
		protected var skinHeight:Number;
		protected var skinWidth:Number;
		
		protected var textureImage:Image;
		
		public function EdgeSkin(_width:Number, _height:Number, _parentEdge:Edge)
		{
			skinHeight = _height;
			skinWidth = _width;
			
			parentEdge = _parentEdge;
			
			if (mAtlas == null)
			{
				mAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
				EdgeNarrowSatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowSatisfiedSelected);
				EdgeNarrowSatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowSatisfiedUnselected);
				EdgeNarrowUnsatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowUnsatisfiedSelected);
				EdgeNarrowUnsatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeNarrowUnsatisfiedUnselected);
				EdgeWideSatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideSatisfiedSelected);
				EdgeWideSatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideSatisfiedUnselected);
				EdgeWideUnsatisfiedSelected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideUnsatisfiedSelected);
				EdgeWideUnsatisfiedUnselected = mAtlas.getTexture(AssetInterface.ParadoxSubTexture_EdgeWideUnsatisfiedUnselected);
			}
		}
		
		private function getText(edgeIsNarrow:Boolean, edgeIsSatisfied:Boolean, edgeIsSelected:Boolean):Texture
		{
			if (edgeIsNarrow)
			{
				if (edgeIsSatisfied)
				{
					return edgeIsSelected ? EdgeNarrowSatisfiedSelected : EdgeNarrowSatisfiedUnselected;
				}
				else
				{
					return edgeIsSelected ? EdgeNarrowUnsatisfiedSelected : EdgeNarrowUnsatisfiedUnselected;
				}
			}
			else
			{
				if (edgeIsSatisfied)
				{
					return edgeIsSelected ? EdgeWideSatisfiedSelected : EdgeWideSatisfiedUnselected;
				}
				else
				{
					return edgeIsSelected ? EdgeWideUnsatisfiedSelected : EdgeWideUnsatisfiedUnselected;
				}
			}
		}
		
		public function draw():void
		{
			if (textureImage) textureImage.removeFromParent(true);
			
			var edgeIsNarrow:Boolean = (parentEdge.graphConstraint.lhs is ConstraintVar);
			var edgeIsSatisfied:Boolean = false;
			var edgeIsSelected:Boolean = (parentEdge.toNode is VariableNode) ? parentEdge.toNode.isSelected : parentEdge.fromNode.isSelected;
			if (parentEdge.graphConstraint.lhs is ConstraintVar)
			{
				edgeIsSatisfied = (parentEdge.graphConstraint.lhs as ConstraintVar).getProps().hasProp(PropDictionary.PROP_NARROW);
			}
			else if (parentEdge.graphConstraint.rhs is ConstraintVar)
			{
				edgeIsSatisfied = !(parentEdge.graphConstraint.rhs as ConstraintVar).getProps().hasProp(PropDictionary.PROP_NARROW);
			}
			var text:Texture = getText(edgeIsNarrow, edgeIsSatisfied, edgeIsSelected);
			textureImage = new Image(text);
			textureImage.width = skinWidth;
			textureImage.height = skinHeight;
			addChild(textureImage);
		}
		
	}
}