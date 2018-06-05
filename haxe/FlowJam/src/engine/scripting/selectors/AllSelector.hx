package engine.scripting.selectors;

import engine.scripting.ScriptNode;

/**
 * Simple selector that performs no logic and just runs its children in order
 * 
 * @author kristen autumn blackburn
 */
class AllSelector extends ScriptNode {

	public function new(id : String = null) {
		super(id);
	}
	
	override public function visit() : Int {
		for (child in m_children) {
			child.visit();
		}
		
		return ScriptStatus.RUNNING;
	}
}