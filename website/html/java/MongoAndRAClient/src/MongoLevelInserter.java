import java.io.File;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.mongodb.*;


public class MongoLevelInserter {

	static String mongoAddress = "ec2-184-72-152-11.compute-1.amazonaws.com";

	DB db = null;
	DBCollection levelColl = null;
	DBCollection layoutColl = null;
	Document difficultyRatings;
	String priority;

	public MongoLevelInserter(DB _db, File difficultyFile, String extension, String _priority)
	{
		db = _db;
		priority = _priority;
		extension = "";
	//	if(extension != "")
	//		extension = "/" + extension;
		
	    levelColl = db.getCollection("Level" + extension);
	    layoutColl = db.getCollection("SubmittedLayouts" + extension);
	    if(difficultyFile != null)
	    {
	    	try{
	    	DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	    	DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	    	difficultyRatings = dBuilder.parse(difficultyFile);
	    	}
	    	catch(Exception e)
	    	{
	    		
	    	}
	    }
	    
	}
	
	public boolean isValid()
	{
		if(levelColl != null)
			return true;
		else
			return false;
	}
	
	public void addLevel(MongoFileInserter inserter, String levelName)
	{
 		DBObject obj = createLevelObject(inserter, levelName);
		WriteResult r1 = levelColl.insert(obj);
		System.out.println(r1.getLastError());
		
		DBObject layoutobj = createLayoutObject(inserter);
		r1 = layoutColl.insert(layoutobj);
		System.out.println(r1.getLastError());
	}
	
	public DBObject createLevelObject(MongoFileInserter inserter, String filename)
	{
		String xmlID = inserter.xmlID;
		String layoutID = inserter.layoutID;
		String constraintsID = inserter.constraintsID;
		String name = filename;

		System.out.println(xmlID+" " +layoutID+" " +constraintsID+" " +name);
		
		int numBoxes = 5;
		int numEdges = 5;
		int numConflicts = 0;
		int startingValue = 5;
		//find the levelID in the difficulty ratings, if it exists
		if(difficultyRatings != null)
		{
			NodeList nList = difficultyRatings.getElementsByTagName("file");
			for(int i = 0; i<nList.getLength(); i++)
			{
				Node node = nList.item(i);
				Element element = (Element) node;
				String nodeName = element.getAttribute("new_name");
				if(nodeName.equals(name))
				{
					numBoxes = Integer.parseInt(element.getAttribute("node_count"));
					numEdges = Integer.parseInt(element.getAttribute("edge_count"));
					numConflicts = Integer.parseInt(element.getAttribute("conflicts"));
					startingValue = Integer.parseInt(element.getAttribute("value"));
				}
			}
		}
		DBObject levelObj = new BasicDBObject();
		levelObj.put("xmlID", xmlID);
		levelObj.put("layoutID", layoutID);
		levelObj.put("constraintsID", constraintsID);
		levelObj.put("name", name);
		
		levelObj.put("version", "v6test");
		
		DBObject metadataObj = new BasicDBObject();
		levelObj.put("metadata", metadataObj);

		metadataObj.put("priority", 5);
		
		DBObject paramObj = new BasicDBObject();
		paramObj.put("type", 0.0);
		paramObj.put("difficulty", 5.0);
		metadataObj.put("parameters", paramObj);
		
		DBObject propertiesObj = new BasicDBObject();
		propertiesObj.put("boxes", numBoxes);
		propertiesObj.put("lines", numEdges);
		propertiesObj.put("visibleboxes", numBoxes);
		propertiesObj.put("visiblelines", numEdges);
		propertiesObj.put("startingValue", startingValue);
		propertiesObj.put("conflicts", numConflicts);
		metadataObj.put("properties", propertiesObj);
		
		System.out.println(levelObj);
		
		return levelObj;
	}

	public DBObject createLayoutObject(MongoFileInserter inserter)
	{
		String xmlID = inserter.xmlID;
		String layoutID = inserter.layoutID;
		
		DBObject layoutObj = new BasicDBObject();
		layoutObj.put("name", "Starter Layout");
        layoutObj.put("layoutID", layoutID);
		layoutObj.put("xmlID", xmlID+"L");
		
		System.out.println(layoutObj);
		
		return layoutObj;
	}

}
