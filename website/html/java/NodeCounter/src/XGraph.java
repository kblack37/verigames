import java.util.*;

/**
 * @author Bryan Lu
 *
 *
 * A Graph <Edge , XNode>
 * 
 * Graph saving edge to the XNode(which is the starting and ending node data struct)
 * 
 * Only adding edge and node are valid
 * Deleting is invlaid
 *
 */
public class XGraph {
	//String : ID of Node, String : ID of EDGE
	//Input Edge and Output Edge
	private Map<String, XNode> map;
	
	/**
	 * Constructor
	 */
	public XGraph(){
		map = new HashMap<String,XNode>();
	}
	
	/**
	 * Add an edge to the graph
	 * @param edge, edge id
	 */
	public void addEdge(String edge){
		map.put(edge, new XNode());
	}
	
	/**
	 * Add the starting node of an edge to the graph
	 * @param edge, edge id
	 * @param str, starting node id
	 * @param i, the port number
	 */
	public void addFrom(String edge, String str, int i){
		map.get(edge).setStart(str);
		map.get(edge).setSPort(i);
	}
	
	/**
	 * Add the ending node of an edge to the graph
	 * @param edge, edge id
	 * @param str, ending node id
	 * @param i, the port number
	 */
	public void addTo(String edge, String str, int i){
		map.get(edge).setDest(str);
		map.get(edge).setDPort(i);
	}
	
	/**
	 * Count the invalid edge (from 1 to 0)
	 * @return the number of invalid edge
	 */
	public int inValidPath(){
		int sum = 0;
		for(String key : map.keySet()){
			if(map.get(key).inValid()){
				sum ++;
			}
		}
		return sum;
	}
	
}