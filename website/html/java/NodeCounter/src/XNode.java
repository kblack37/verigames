
/**
 * 
 * @author Bryan Lu
 *
 *A struct for XGraph that stores 
 *1. Starting node id
 *2. Ending node id
 *3. Starting node port number
 *4. Ending node port number
 *
 *This is a modifiable struct
 *
 */
public class XNode {
	
	private String start;
	private String dest;
	private int sPort;
	private int dPort;
	
	/**
	 * Constructor set to default value
	 */
	public XNode(){
		start = "";
		dest = "";
		sPort = 0;
		dPort = 0;
	}
	
	/**
	 * Constructor set to parameter value
	 * @param s = starting node id
	 * @param d = ending node id
	 * @param sp = starting node port number
	 * @param dp = ending node port number
	 */
	public XNode(String s, String d, int sp, int dp){
		start = s;
		dest = d;
		sPort = sp;
		dPort = dp;
	}
	
	/**
	 * Check if the edge is valid
	 * @return true if valid, false otherwise
	 */
	public boolean inValid(){
		return sPort > dPort;
	}
	
	/**
	 * Set the starting id
	 * @param str, starting id
	 */
	public void setStart(String str){
		start = str;
	}
	
	/**
	 * Set the ending id
	 * @param str, ending id
	 */
	public void setDest(String str){
		dest = str;
	}
	
	/**
	 * set the starting node port number
	 * @param i, port number
	 */
	public void setSPort(int i){
		sPort = i;
	}
	
	/**
	 * set the ending node port number
	 * @param i, port number
	 */
	public void setDPort(int i){
		dPort = i;
	}
	
	/**
	 * @return start node id
	 */
	public String start(){
		return start;
	}
	/**
	 * @return end node id
	 */
	public String dest(){
		return dest;
	}
	/**
	 * @return starting port number
	 */
	public int sPort(){
		return sPort;
	}
	/**
	 * @return ending port number
	 */
	public int dPort(){
		return dPort;
	}
	
}
