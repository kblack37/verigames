package display 
{
	import assets.AssetInterface;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.TextureAtlas;
	
	//attempt to minimize quad batches
	public class GameObjectBatch 
	{
		
		protected var quadBatchList:Vector.<QuadBatch>;
		
		public function GameObjectBatch()
		{
			quadBatchList = new Vector.<QuadBatch>;
			var qB:QuadBatch = new QuadBatch();
			quadBatchList.push(qB);
		}
		
		public function addImage(image:Image):void
		{			
			var qB:QuadBatch = getCurrentQuadBatch();
			qB.addImage(image);
		}
		
		//this should track the size of the last quad batch created, and if full, create a new one
		protected function getCurrentQuadBatch():QuadBatch
		{
			var listSize:int = quadBatchList.length;
			var qB:QuadBatch = quadBatchList[listSize-1];
//			trace("-", qB.objectIndex, qB.mVertexData.numVertices);
			if(qB.mVertexData.numVertices > 32767) //stop way short, just in case I'm adding alot to it...
			{
				qB = new QuadBatch;
				quadBatchList.push(qB);
			}
			return qB;
		}
	}
	
}