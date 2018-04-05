import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import com.cgs.elements.EdgeElement;
import com.cgs.elements.EdgeSet;
import com.cgs.elements.Level;
import com.cgs.elements.NodeElement;
import com.cgs.elements.Port;

import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Vector;

NOTE:  (I know this code doesn't compile anymore, that's part of the purpose of this note....)
This project has been superceded by scripts that use the ASP evaluate functions to generate information about the levels.
ENDNOTE....

public class DifficultyRater extends ChainBase {

    File layoutFile;
    File constraintsFile;
    String outputFileName;
    static File outputFile;
    static PrintWriter printWriter;
    static File countFile;
    static PrintWriter countPrintWriter;
    static File outputDirectory;
	
	static String scriptName = "";
	
        /**
         * @param args
         */
        public static void main(String[] args) {

 
        	if(args.length != 3)
        	{
        		System.out.println("Usage: java -jar DifficultyRater.jar sourcedir outputdir typecheckerscriptname");
        		return;
        	}
            try{

               File root = new File(args[0]);
                outputDirectory = new File(args[1]);
                scriptName = args[2];
                outputFile = new File(outputDirectory + "/conflicts.txt");
                printWriter = new PrintWriter(outputFile);
                countFile = new File(outputDirectory + "/difficultyratings.xml");
                countPrintWriter = new PrintWriter(countFile);
                countPrintWriter.println("<files>");
                
                if(root.isDirectory())
                {
                        File[] listOfFiles = root.listFiles();
        
                        for (File file : listOfFiles) {
                        	try{
	                            if (file.isFile()) {
	                                    if(file.getName().endsWith("Layout.xml"))
	                                    {
	                                        handleFile(file);
	                                    }
	                            }
                            }catch(Exception e)
                            {
                            	System.out.println("error while processing " + file.getName()); 
                            }
                        }
                }
                else
                {
                	if(root.getName().endsWith("Layout.xml"))
                		handleFile(root);
                        
                }
                
                printWriter.flush();
                printWriter.close();
                countPrintWriter.println("</files>");
                countPrintWriter.flush();
                countPrintWriter.close();
                }
            catch(Exception e)
            {
               System.out.println(e); 
               printWriter.flush();
               printWriter.close();
               countPrintWriter.println("</files>");
               countPrintWriter.flush();
               countPrintWriter.close();
            }
            
            System.out.println("Run Completed"); 
        }
        
        static String layoutFileName = null;
        static boolean printedFileName = false;
        public static void handleFile(File file)
        {
        	printedFileName = false;
            layoutFileName = file.getPath();
             int strLen = layoutFileName.length();
             String constraintsFileName = file.getPath().substring(0, strLen-10) + "Constraints.xml";
             File constraintsFile = new File(constraintsFileName);
             DifficultyRater rater = new DifficultyRater(file, constraintsFile);
         	 
            rater.parseLayoutFile();
             rater.parseConstraintsFile();
             rater.buildChains();
             
            rater.checkChains();
            rater.outputLayout(file, outputDirectory);
            
            rater.reportOnFile(file);
        //    printWriter.print(mostNumConflicts + " " + totalEditableChains + " " + totalUneditableChains);
            
            
        }
        
        public void buildChains()
        {
        	 //trace connected nodes       
            for(int i = 0; i<nodeVector.size(); i++)
            {
                NodeElement node = nodeVector.get(i);
                if(!node.counted)
                {
                	node.counted = true;
                    ChainInfo chain = new ChainInfo();
                    chainInfoVector.add(chain);
                    chain.addNode(node);
                    chain.chainNumber = currentChainNumber;
                    traceNode(node, chain);
                    currentChainNumber++;
              }
            }
        }
        
        public DifficultyRater(File layoutFile, File constraintsFile)
        {
        	super();
            this.layoutFile = layoutFile;
            this.constraintsFile = constraintsFile;
        }
        
        public void parseLayoutFile() 
        { 
                try {
                        
                        SAXParserFactory factory = SAXParserFactory.newInstance();
                        //factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);

                        SAXParser saxParser = factory.newSAXParser();
                        
                        DefaultHandler handler = new DefaultHandler() {
                                                               
                                public void startElement(String uri, String localName,String qName, 
                                        Attributes attributes) throws SAXException {
                         
                                        if (qName.equalsIgnoreCase("level")) {
                                                String levelName = attributes.getValue("id");
                                                currentLevel = new Level(levelName);
                                                levelList.add(currentLevel);
                                        }
                                        else if (qName.equalsIgnoreCase("box") || qName.equalsIgnoreCase("joint")) {
                                                String nodeName = attributes.getValue("id");
                                                currentNode = new NodeElement(nodeName, currentLevel.id);
                                                nodes.put(nodeName, currentNode);
                                                nodeVector.add(currentNode);
                                                if(qName.equalsIgnoreCase("box"))
                                                        currentNode.isBox = true;
                                        }
                                        else if (qName.equalsIgnoreCase("line")) {
                                                String id = attributes.getValue("id");
                                                currentEdge = new EdgeElement(null, id, currentLevel.id);
                                                edges.put(id, currentEdge);
                                                edgeVector.add(currentEdge);
                                        }
                                        else if (qName.equalsIgnoreCase("fromjoint") || qName.equalsIgnoreCase("frombox")) {
                                                String nodeID = attributes.getValue("id");
                                                NodeElement elem = nodes.get(nodeID);
                                                if(elem != null)
                                                {
                                                        elem.addOutputPort(currentEdge.id);
                                                        currentEdge.fromNodeID = nodeID;
                                                }
                                                else
                                                        printWriter.println("missing node "+ nodeID);
                                        }
                                        else if (qName.equalsIgnoreCase("tojoint") || qName.equalsIgnoreCase("tobox")) {
                                            String nodeID = attributes.getValue("id");
                                            String portID = attributes.getValue("port");
                                            NodeElement elem = nodes.get(nodeID);
                                            if(elem != null)
                                            {
                                                    elem.addInputPort(currentEdge.id);
                                                    currentEdge.toNodeID = nodeID;
                                            }
                                            else
                                                    printWriter.println("missing node "+ nodeID);
                                    }
                                }
                         
                                public void endElement(String uri, String localName,
                                        String qName) throws SAXException {
                                         
                                }
                        };

                        saxParser.parse(layoutFile, handler);
                        
                }catch (Exception e){//Catch exception if any
                        System.err.println("Error: " + e.getMessage());
                }        
          }
        
        public void parseConstraintsFile() 
        { 
            try {
                    
                SAXParserFactory factory = SAXParserFactory.newInstance();
                //factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);

                SAXParser saxParser = factory.newSAXParser();
                    
                DefaultHandler handler = new DefaultHandler() {
                         
                    boolean inInputNode = false; //false suggests we are in an output node
                    boolean inFromNode = false;  //ditto...
                    
                    public void startElement(String uri, String localName,String qName, 
                        Attributes attributes) throws SAXException {
             
                        if (qName.equalsIgnoreCase("box"))
                        {
                            String nodeID = attributes.getValue("id");
                            NodeElement elem = nodes.get(nodeID);
                            if(elem != null)
                            {
                                    String width = attributes.getValue("width");
                                    String editable = attributes.getValue("editable");
                                    elem.isWide = width.equals("wide") ? true : false;
                                    elem.isEditable = editable.equals("true") ? true : false;
                            }
                            else
                                    printWriter.println("missing node "+ nodeID);
                        }
                           
                    }
             
                    public void endElement(String uri, String localName,
                            String qName) throws SAXException {
                             
                    }
                };

                saxParser.parse(constraintsFile, handler);
                    
            }catch (Exception e){//Catch exception if any
                    System.err.println("Error: " + e.getMessage());
            }        
        }
        
        public void reportOnFile(File file)
        {
//        	if(numChainsWithConflicts > 0)
//        	{
	        	 String layoutFileName = file.getName();
	             int strLen = layoutFileName.length();
//	        	String regularFileName = file.getPath().substring(0, strLen-10) + ".xml";
        	String fileName = layoutFileName.substring(0, strLen-10);
//	        	String constraintsFileName = file.getPath().substring(0, strLen-10) + "Constraints.xml";
//	        	printWriter.println("\"" + regularFileName + "\"'");
//	        	printWriter.println("\"" + constraintsFileName + "\"'");
//	        	printWriter.println("\"" + file.getPath() + "\"'");
//        	}
        	visibleNodes = nodes.size();
        	visibleEdges = edges.size();
            countPrintWriter.println("<file id=\"" + fileName + "\" name=\"" + currentLevel.id
            		+ "\" nodes=\"" + nodes.size() + "\" edges=\"" + edges.size()+"\" visible_nodes=\"" 
            		+ visibleNodes + "\" visible_edges=\"" + visibleEdges
            			+"\" conflicts=\""+totalConflicts+"\" bonus_nodes=\""+totalBonusNodes
            			+"\" scriptname=\"" + scriptName + "\"/>");
          //  printWriter.println("Chain Count " + nodeChains.size());
  //          printWriter.println("editableChainCount " + editableChainCount + " " + "editableNodes " + editableNodes);
   //         printWriter.println("uneditableChainCount " + uneditableChainCount + " " + "uneditableNodes " + uneditableNodes);
        //    printWriter.println("numChainsWithConflicts " + numChainsWithConflicts);
         //   printWriter.println("longestChainSizeWithConflict " + longestChainSizeWithConflict + " " + "numNodesWithConflictInChain " + numNodesWithConflictInChain);
       totalEditableChains += editableChainCount;
       totalUneditableChains += uneditableChainCount;
       System.out.println("reported");
        }
        
 
        
        public void outputLayout(File layoutFile, File outputDirectory)
        {
//        	try
//        	{
//	        	//open layout dom, make changes, save to new file
//				DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
//				dbFactory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
//	
//				DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
//				Document doc = dBuilder.parse(layoutFile);
//				
//				//hide all boxes, joints and lines that don't have conflicts in their chain
//				NodeList nodeList = doc.getElementsByTagName("box");
//				for(int i=0; i<nodeList.getLength(); i++)
//				{
//					Element node = (Element)nodeList.item(i);
//					String id = node.getAttribute("id");
//					NodeElement nodeElem = nodes.get(id);
//					if(nodeElem != null)
//					{
//						ChainInfo info = chainInfo.get(nodeElem.chainNumber);
//						if(info.numConflicts > 0)
//						{
//							node.setAttribute("visible", "true");
//							visibleNodes++;
//						}
//						else
//							node.setAttribute("visible", "false");
//					}
//				}
//				
//				NodeList jointList = doc.getElementsByTagName("joint");
//				for(int i=0; i<jointList.getLength(); i++)
//				{
//					Element node = (Element)jointList.item(i);
//					String id = node.getAttribute("id");
//					NodeElement nodeElem = nodes.get(id);
//					if(nodeElem != null)
//					{
//						ChainInfo info = chainInfo.get(nodeElem.chainNumber);
//						if(info.numConflicts > 0)
//						{
//							node.setAttribute("visible", "true");
//							visibleNodes++;
//						}
//						else
//							node.setAttribute("visible", "false");
//					}
//				}
//				
//				NodeList lineList = doc.getElementsByTagName("line");
//				for(int i=0; i<lineList.getLength(); i++)
//				{
//					Element node = (Element)lineList.item(i);
//					String id = node.getAttribute("id");
//					EdgeElement edgeElem = edges.get(id);
//					if(edgeElem != null)
//					{
//						ChainInfo info = chainInfo.get(edgeElem.chainNumber);
//						if(info.numConflicts > 0)
//						{
//							node.setAttribute("visible", "true");
//							visibleEdges++;
//						}
//						else
//							node.setAttribute("visible", "false");
//					}
//				}
//				
//				// Prepare the DOM document for writing
//		        Source source = new DOMSource(doc);
//
//		        // Prepare the output file
//		        File file = new File(outputDirectory, layoutFile.getName());
//		        System.out.println(file.getAbsolutePath());
//		        Result result = new StreamResult(file);
//
//		        // Write the DOM document to the file
//		        Transformer xformer = TransformerFactory.newInstance().newTransformer();
//		        xformer.transform(source, result);
//        	}
//        	catch(Exception e)
//        	{
//        		
//        	}
        }
}
