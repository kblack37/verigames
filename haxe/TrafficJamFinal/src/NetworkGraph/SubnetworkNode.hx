package networkGraph;

import visualWorld.Board;

/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
class SubnetworkNode extends Node
{
    
    /** Boards that was created based on this node (a clone of the original board that this SUBNETWORK node refers to) */
    public var associated_board : Board;
    
    public var subboard_name : String = "";
    
    public function new(_x : Float, _y : Float, _t : Float, _metadata : Dynamic = null)
    {
        if (_metadata != null)
        {
            if (_metadata.data != null)
            {
                if (_metadata.data.id != null)
                {
                    if (Std.string(_metadata.data.name).length > 0)
                    {
                        subboard_name = Std.string(_metadata.data.name);
                    }
                }
            }
        }
        
        super(_x, _y, _t, NodeTypes.SUBBOARD, _metadata);
    }
}

