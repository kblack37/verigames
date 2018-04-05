package scenes.game.display
{
	import starling.display.Quad;
	
	public class Triangle extends Quad
	{
		
		public function Triangle(width:Number, height:Number, color:uint=0xffffff, premultipliedAlpha:Boolean=true)
		{
			super(width, height, color, premultipliedAlpha);
			
			//move position 1 to make an isoceles triangle
			mVertexData.setPosition(1,width, height/2);
			//Move vertex 2 to the center of the from side, 3 to the old 2 position
			mVertexData.setPosition(2, -3, height/2);
			mVertexData.setPosition(3, 0, height);
			mVertexData.setUniformColor(color);
			
			onVertexDataChanged();
		}
	}
}