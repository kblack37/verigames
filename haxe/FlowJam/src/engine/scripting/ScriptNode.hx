package engine.scripting;

/**
 * Base class for all systems & scripts
 * 
 * @author kristen autumn blackburn
 */
class ScriptNode {
	
	/**
	 * The id of the node
	 */
	public var id(get, never) : String;
	
	private var m_id : String;
	
	private var m_children : Array<ScriptNode>;
	
	private var m_parent : ScriptNode;

	public function new(id : String = null) {
		m_id = id;
		
		m_children = new Array<ScriptNode>();
	}
	
	/**
	 * Adds the given script as a child of this one
	 * @param	child	The given script to be added as a child
	 * @param	index	The index to add the child at
	 */
	public function addChild(child : ScriptNode, index : Int = -1) {
		m_children.insert(index, child);
		child.m_parent = this;
	}
	
	/**
	 * Removes the given script from this one's children if it exists
	 * @param	childToRemove	The script to remove
	 */
	public function removeChild(childToRemove : ScriptNode) {
		m_children.remove(childToRemove);
		childToRemove.dispose();
	}
	
	/**
	 * To be overriden by subclasses. Does any necessary work that needs to be
	 * done every frame
	 * @return	A code representing the status of the script
	 */
	public function visit() : Int {
		return ScriptStatus.ERROR;
	}
	
	/**
	 * To be overriden by subclasses. By default, resets all children
	 * of this script
	 */
	public function reset() {
		for (child in m_children) {
			child.reset();
		}
	}
	
	/**
	 * Searches the entire tree this script is in to try to
	 * find the script with the given id
	 */
	public function findNodeById(id : String) : ScriptNode {
		var currentNode = this;
		while (currentNode.m_parent != null) {
			currentNode = currentNode.m_parent;
		}
		
		return currentNode._findNodeById(id);
	}
	
	private function _findNodeById(id : String) : ScriptNode {
		var targetNode : ScriptNode = null;
		if (m_id == id) {
			targetNode = this;
		} else {
			for (child in m_children) {
				targetNode = child._findNodeById(id);
				if (targetNode != null) break;
			}
		}
		
		return targetNode;
	}
	
	public function dispose() {
		for (child in m_children) {
			child.dispose();
		}
		
		m_parent = null;
	}
	
	function get_id() : String {
		return m_id;
	}
}