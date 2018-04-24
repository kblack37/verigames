package display;

import starling.display.Image;
import starling.display.MeshBatch;

//attempt to minimize quad batches
class GameObjectBatch
{
    
    private var meshBatchList : Array<MeshBatch>;
    
    public function new()
    {
        meshBatchList = new Array<MeshBatch>();
        var mB : MeshBatch = new MeshBatch();
        meshBatchList.push(mB);
    }
    
    public function addImage(image : Image) : Void
    {
        var mB : MeshBatch = getCurrentMeshBatch();
        mB.addMesh(image);
    }
    
    //this should track the size of the last quad batch created, and if full, create a new one
    private function getCurrentMeshBatch() : MeshBatch
    {
        var listSize : Int = meshBatchList.length;
        var mB : MeshBatch = meshBatchList[listSize - 1];
        //			trace("-", qB.objectIndex, qB.mVertexData.numVertices);
        if (mB.numVertices > 32767)
        {
        //stop way short, just in case I'm adding alot to it...
            
            {
                mB = new MeshBatch();
                meshBatchList.push(mB);
            }
        }
        return mB;
    }
}

