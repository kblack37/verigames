import java.io.*;
import java.util.*;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * 
 * @author Bryan Lu
 *
 *A class that count the xml file of PipeJam and counts the port and create a XGraph
 */
public class GraphParse extends DefaultHandler {
	//SAX default
	SAXParserFactory factory;
	SAXParser saxParser;
	DefaultHandler handler;
	//Graph
	private XGraph g;
	//Counting integers
	private int countNode;
	private int countEdge;
	private int countInvalid;
	//Global variables
	private String eId;
	private int from;
	//This is checking booleans
	Map<String, Boolean> booSet = new HashMap<String, Boolean>();
	
	//Main method
	public static void main(String[] args) throws ParserConfigurationException, SAXException{
		//Parsing with the handler
		GraphParse gp = null;

		try {
			gp = new GraphParse(args[0]);

			//Printing result
			File inputFile = new File(args[0]);
			String filename = inputFile.getName();
			int index = filename.indexOf('.');
			filename = filename.substring(0, index);
			PrintWriter writer = new PrintWriter(filename+".txt", "UTF-8");
			writer.println("Node : " + gp.getCountNode());
			writer.println("Edge : " + gp.getCountEdge());
			writer.println("Invalid : " + gp.getCountInvalid());
			writer.close();
			} catch (Exception e) {
			System.out.println("no file " + args[0]);
		}
	}
	
	/**
	 * Constructor that initialize the field and SaxParser
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 */
	public GraphParse(String file) throws ParserConfigurationException, SAXException, IOException{
		factory = SAXParserFactory.newInstance();
		factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
		saxParser = factory.newSAXParser();
		g = new XGraph();
		countNode = 0;
		countEdge = 0;
		//Initialize checking boolean map
		booSet.put("edge", false);
		booSet.put("from", false);
		booSet.put("to", false);
		booSet.put("node", false);
//		booSet.put("input", false);
//		booSet.put("ouput", false);
	
		/**
		 * a Handling method that do something when starting tag equal to node,edge, from, to, nodeRef;
		 * When tag = 
		 * Edge = add an edge to the graph
		 * node = count node
		 * from = set boolean
		 * to = set boolean
		 * nodeRef = set the starting or ending node according to from and to.
		 * 
		 * @modify = EId for graph checking
		 * 			= from port number for counting invalid
		 */
		handler = new DefaultHandler() 
		{
			
	
			public void startElement(String uri, String localName,String qName, Attributes attributes) 
					throws SAXException {
				System.out.println("Start Element :" + qName);
				//Checking booleans
				for(String key : booSet.keySet()){
					if(qName.equals(key)){
						booSet.put(key, true);
						if(key.equals("node")){
							countNode++;
						}else if(key.equals("edge")){
							countEdge ++;
							eId = attributes.getValue("id");
							g.addEdge(eId);
							
						}
					}
				}
				//NodeRef adding node counting invalids
				if(qName.equals("nodeRef")){
					if(booSet.get("edge") == true){
						if(booSet.get("from") == true){
							from = Integer.parseInt(attributes.getValue("port"));
							g.addFrom(eId, attributes.getValue("id"), from);
						}else if(booSet.get("to") == true){
							int to = Integer.parseInt(attributes.getValue("port"));
							g.addTo(eId, attributes.getValue("id"), to);
							if(from > to){
								countInvalid ++;
							}
							from = -1;
						}
					}
				}
			}
			public void endElement(String uri, String localName,String qName, Attributes attributes){
				System.out.println("End Element :" + qName);
				for(String key : booSet.keySet()){
					if(qName.equals(key)){
						booSet.put(key, false);
						if(key.equals("edge")){
							eId = "";
						}
					}
				}
			}
			/**
			 * The Handling method
			 */
			public void characters(){
				//Do nothing
			}
		};

		saxParser.parse(file, handler);
	}
	
	/**
	 * @param filename, output file
	 * @throws SAXException
	 * @throws IOException
	 */
	public void giveFile(String filename) throws SAXException, IOException{
		saxParser.parse(filename, handler);
	}
	
	/**
	 * @return number of Edges
	 */
	public int getCountEdge(){
		return countEdge;
	}
	
	/**
	 * @return number of Nodes
	 */
	public int getCountNode(){
		return countNode;
	}
	
	/**
	 * @return the number of Invalid
	 */
	public int getCountInvalid(){
		//return g.inValidPath();
		return countInvalid;
	}
}
