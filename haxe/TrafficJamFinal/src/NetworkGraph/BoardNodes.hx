package networkGraph;

import flash.errors.Error;
import flash.utils.Dictionary;

class BoardNodes
{
    
    public var board_name : String;
    
    /** This is a dictionary of Nodes; INDEXED BY NODE_ID */
    public var nodeDictionary : Dictionary = new Dictionary();
    
    /** The names of any boards that appear on this board */
    public var subboardNames : Array<String> = new Array<String>();
    
    /** Any nodes that represent the beginning of a pipe, either INCOMING OR START_* OR SUBBOARD with no incoming edges */
    public var beginningNodes : Array<Node> = new Array<Node>();
    
    /** Map from edge set id to all starting edges for that edge set ON THIS BOARD (no other boards) */
    public var startingEdgeDictionary : Dictionary = new Dictionary();
    
    /** True if a change in pipe width or buzzsaw was made since the last simulation */
    public var changed_since_last_sim : Bool = true;
    /** True if a simulation has been run on this board */
    public var simulated : Bool = false;
    /** True if the board is being checked for trouble points */
    public var simulating : Bool = false;
    
    public var metadata : Dictionary = new Dictionary();
    
    public function new(_board_name : String)
    {
        board_name = _board_name;
    }
    
    public function addNode(_node : Node) : Void
    {
        if (nodeDictionary[_node.node_id] == null)
        {
            nodeDictionary[_node.node_id] = _node;
            var _sw0_ = (_node.kind);            

            switch (_sw0_)
            {
                case NodeTypes.SUBBOARD:
                    if ((try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name.length > 0)
                    {
                        if (Lambda.indexOf(subboardNames, (try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name) == -1)
                        {
                            subboardNames.push((try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name);
                        }
                    }
                    // If there are no incoming pipes to the subboard, this is a beginning node - fall through to add to beginningNodes list
                    if (_node.incoming_ports.length == 0)
                    {
                        if (Lambda.indexOf(beginningNodes, _node) == -1)
                        {
                            beginningNodes.push(_node);
                        }
                    }
                case NodeTypes.OUTGOING:
                // It is also (apparently) possible for an outgoing node to have no inputs or outputs, this won't actually get processed but include it anyway
                if (_node.incoming_ports.length == 0)
                {
                    if (Lambda.indexOf(beginningNodes, _node) == -1)
                    {
                        beginningNodes.push(_node);
                    }
                }
                case NodeTypes.INCOMING, NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.START_SMALL_BALL:
                    if (Lambda.indexOf(beginningNodes, _node) == -1)
                    {
                        beginningNodes.push(_node);
                    }
            }
        }
        else
        {
            throw new Error("Duplicate world nodes found for node_id: " + _node.node_id);
        }
    }
    
    /**
		 * Adds the input edge and edge set index id pair to the startingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	id An edge set id to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
    public function addStartingEdgeToDictionary(e : Edge, id : String, checkIfExists : Bool = true) : Void
    {
        if (Reflect.field(startingEdgeDictionary, id) == null)
        {
            Reflect.setField(startingEdgeDictionary, id, new Array<Edge>());
        }
        if ((!checkIfExists) || (Reflect.field(startingEdgeDictionary, id).indexOf(e) == -1))
        {
            Reflect.field(startingEdgeDictionary, id).push(e);
        }
    }
}
