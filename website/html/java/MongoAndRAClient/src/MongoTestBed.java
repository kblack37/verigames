import com.mongodb.*;
import com.mongodb.gridfs.*;

import java.io.BufferedReader;
import java.io.Console;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static java.nio.file.StandardCopyOption.*;

import java.util.Dictionary;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.bson.types.ObjectId;

public class MongoTestBed {

//    public static byte[] LoadFile(String filePath) throws Exception {
//        File file = new File(filePath);
//        int size = (int)file.length();
//        byte[] buffer = new byte[size];
//        FileInputStream in = new FileInputStream(file);
//        in.read(buffer);
//        in.close();
//        return buffer;
//    }

    private static final boolean removeLevels = false;

	public static void main(String[] args) throws Exception {

		String url = "api.paradox.verigames.org";
		String property = "property";
		String value = "interning";
		if(args.length > 0)
			url = args[0];
		
		if(args.length > 2)
		{
			property = args[1];
			value = args[2];
		}
		

		
        //staging game level server
       //    Mongo mongo = new Mongo( "api.flowjam.verigames.com" );
     Mongo mongo = new Mongo( url, 27017 );
       String dbName = "game3api";
        DB db = mongo.getDB( dbName );
        //Create GridFS object
        GridFS fs = new GridFS( db );

    //    listCollectionNames(db);
       HashMap<String, String> map = new HashMap<String, String>();
   //    map.put("version", "maxsat");//551ec321b0044206887210a8,551ec31fb0044206887210a0
       map.put(property, value);
      
   //     listEntries(db, "GameSolvedLevels", map);

    	//  listEntries(db, "ActiveLevels");

    //     listEntries(db, "ActiveLevels");
    //   listEntriesToFile(db, "GameSolvedLevels", "GameSolvedLevels.txt");
     //  listEntriesToFile(db, "ActiveLevels", "activeLevelsV13_1.txt");
   //    listFiles(fs);
    //   
       writeFilesLocally(db, "GameSolvedLevels", fs, map);
     //    listLog(db);
 //         saveAndCleanLog(db, "old");
 //      countPlayerSubmissions(db);
	    mongo.close();
	}
	
	static void listEntries(DB db, String collectionName)
	{
		listEntries(db, collectionName, null, false);
	}
	
	static void listEntries(DB db, String collectionName, HashMap<String, String> searchKeys)
	{
		listEntries(db, collectionName, searchKeys, false);
	}
	
	static void listEntries(DB db, String collectionName, HashMap<String, String> searchKeys, boolean remove)
	{
		PrintWriter writer = null;
    	DBCursor cursor = null;
    	try 
    	{
         	  
		BasicDBObject field = new BasicDBObject();
		if(searchKeys != null)
			for (Map.Entry<String, String> entry : searchKeys.entrySet()) {
			    String key = entry.getKey();
			    String value = entry.getValue();
			    field.put(key, value);
			}
		
		DBCollection collection = db.getCollection(collectionName);

			 cursor = collection.find(field);
			 while(cursor.hasNext()) {
           	DBObject obj = cursor.next();

               System.out.println(obj);

               if(remove)
            	   collection.remove(obj);
           }
    	}catch (Exception e)
    	{
    		
        } finally {
        	if(cursor != null)
        		cursor.close();
        }
	}
	
	static void listEntriesToFile(DB db, String collectionName, String filename)
	{
		listEntriesToFile(db, collectionName, filename, null);
	}
	
	static void listEntriesToFile(DB db, String collectionName, String filename, HashMap<String, String> searchKeys)
	{
		PrintWriter writer = null;
    	DBCursor cursor = null;
    	try 
    	{
    		writer = new PrintWriter(filename, "UTF-8");

			BasicDBObject field = new BasicDBObject();
			if(searchKeys != null)
				for (Map.Entry<String, String> entry : searchKeys.entrySet()) {
				    String key = entry.getKey();
				    String value = entry.getValue();
				    field.put(key, value);
				}
			
			DBCollection collection = db.getCollection(collectionName);

			 cursor = collection.find(field);
			 while(cursor.hasNext()) {
				DBObject obj = cursor.next();
               System.out.println(obj);
               writer.println(obj);
			 }

    	}catch (Exception e)
    	{
    		
        } finally {
        	if(cursor != null)
        		cursor.close();
        }
    	
    	 writer.close();
	}
	
	static void countPlayerSubmissions(DB db)
	{
    	DBCursor cursor = null;
    	try 
    	{
    		DBCollection collection = db.getCollection("PlayerActivity");

    		cursor = collection.find();
    		while(cursor.hasNext()) {
    			DBObject obj = cursor.next();

    			String playerID = (String)obj.get("playerID");
    			BasicDBList e = (BasicDBList)obj.get("completed_boards");
    			int submittedBoardCount = Integer.parseInt((String)obj.get("submitted_boards"));
    			int commulativeScore = Integer.parseInt((String)obj.get("cummulative_score"));
    			if(e != null && e.size() > 20)
    				System.out.println(playerID +  ' ' + e.size() + ' ' + submittedBoardCount + ' ' + commulativeScore);
    		}
    	}catch (Exception e)
    	{
    		System.out.println(e);
        } finally {
        	if(cursor != null)
        		cursor.close();
        }
	}
	
	static void groupSubmittedLevelsByPlayerID(DB db)
	{
    	DBCursor cursor = null;
    	try 
    	{
    		HashMap<String, Object[]> playerIDMap = new HashMap<String, Object[]>();
    		//playerIDMap.put("name", "p_000249_00011614");
    		String collectionName = "GameSolvedLevels";	   
        	  
			BasicDBObject field = new BasicDBObject();
			
			DBCollection collection = db.getCollection(collectionName);
			 cursor = collection.find(field);
			 while(cursor.hasNext()) {
	           	DBObject obj = cursor.next();
	           	String playerID = (String)obj.get("playerID");
			   if(playerID != null)
			   {
				   if(playerIDMap.containsKey(playerID) == false)
		           	{
		               Object[] arr = new Object[3];
		               arr[0] = 1;
		               arr[1] = Integer.parseInt((String)obj.get("current_score")) - Integer.parseInt((String)obj.get("prev_score"));
		               arr[2] = (String)obj.get("username");
		               playerIDMap.put(playerID, arr);
		           	}
				   else
				   {
					   Object[] arr = playerIDMap.get(playerID);
					   arr[0] = ((Integer)arr[0]).intValue() + 1;
					   arr[1] = ((Integer)arr[1]).intValue() + Integer.parseInt((String)obj.get("current_score")) - Integer.parseInt((String)obj.get("prev_score"));
				   }
			   }
           }
			String playerActivityCollectionName = "PlayerActivity";
			DBCollection playerActivityCollection = db.getCollection(playerActivityCollectionName);
			
			 for (Map.Entry<String, Object[]> entry : playerIDMap.entrySet()) {
				    String key = entry.getKey();
				    Object[] value = entry.getValue();
				    
				    System.out.println(key + " " + value[2] + " " + value[0] + " " + value[1]);
				    
				    DBObject playerObj = new BasicDBObject();
				    playerObj.put("playerID", key);
				    playerObj.put("submitted_boards", value[0].toString());
				    playerObj.put("cummulative_score", value[1].toString());
				    playerActivityCollection.save(playerObj);
				}
    	}catch (Exception e)
    	{
    		
        } finally {
        	if(cursor != null)
        		cursor.close();
        }
    	
    	// writer.close();
			
		
	}
        
 //       db.createCollection("SavedLevels", null);
  //      DBCollection foo = db.getCollection("SubmittedLevels");
   //     db.createCollection("SubmittedLayouts", null);
        //Save image into database
        
//        if(args.length == 1)
//        {
//	        File file = new File(args[0]);
//	        if(file.isDirectory())
//	        {
//	        	File[] files = file.listFiles(new FilenameFilter() {
//	        	    public boolean accept(File directory, String fileName) {
//	        	        return fileName.endsWith(".zip") 
//	        	        && !fileName.endsWith("Graph.zip") 
//	        	        && !fileName.endsWith("Constraints.zip");
//	        	    }});
//	        	
//	        	for(int i=0; i<files.length; i++)
//	        	{
//	        		File xmlFile = files[i];
//	        		GridFSInputFile xmlin = fs.createFile( xmlFile );
//	        		 String fileName = xmlFile.getName();
//	        		 int index = fileName.lastIndexOf('.');
//	        		 fileName = fileName.substring(0, index);
//	     	        xmlin.put("name", fileName);
//	     	        xmlin.save();
//	     	        
//	     	        String filePath = xmlFile.getPath();
//	     	        //remove xml, and add gxl extension
//	     	       int baseIndex = filePath.lastIndexOf('.');
//	     	        String filebase = filePath.substring(0, baseIndex);
//	     	        File graphFile = new File(filebase+"Graph.zip");
//	     	        //Save image into database
//	     	        GridFSInputFile gxlin = fs.createFile( graphFile );
//	     	        gxlin.setMetaData(new BasicDBObject("name", fileName+" Starter Layout"));
//	     	        gxlin.setMetaData(new BasicDBObject("xmlID", xmlin.getId()));
//	     	        gxlin.save();
//	     	        
//	     	        File constraintsFile = new File(filebase+"Constraints.zip");
//	     	        //Save image into database
//	     	        GridFSInputFile conin = fs.createFile( constraintsFile );
//	     	        conin.setMetaData(new BasicDBObject("name", fileName+" Starter Constraints"));
//	     	        conin.setMetaData(new BasicDBObject("xmlID", xmlin.getId()));
//	     	        conin.save();
//	        	}
//	        }
//        }
//        else
//        {
//	        File xmlFile = new File(args[0]+"\\"+args[1]+".xml");
//	        GridFSInputFile xmlin = fs.createFile( xmlFile );
//	        xmlin.put("name", args[1]);
//	        xmlin.save();
//	        
//	        File gxlFile = new File(args[0]+"\\"+args[1]+".gxl");
//	          //Save image into database
//	        GridFSInputFile gxlin = fs.createFile( gxlFile );
//	        gxlin.setMetaData(new BasicDBObject("xmlID", xmlin.getId()));
//	        gxlin.save();
//        }
       
        //Find saved image
       
      //save the a file
//        File install = new File(args[0]+"\\"+args[1]+".xml");		
//        GridFSInputFile inFile =  fs.createFile(install);
//        inFile.save();
      	
        //read the file
//        ObjectId id = new ObjectId("51881753a8e0d2ea01b9afd7");
//     //   BasicDBObject obj = new BasicDBObject("metadata.xmlID", id);
//        GridFSDBFile outFile = fs.findOne(id);
//        System.out.println(outFile.get("name"));
//        outFile.put("name", "test");
//    
//        System.out.println("");//xmlin.getID() " + xmlin.getId());
//        
//      		
//        //write output to temp file
 //       File temp = new File("C:\\Users\\craigc\\Documents\\Pipejam\\flash\\PipeJam3\\SampleWorlds\\DemoWorld\\test\\delme.tmp");
//        outFile.writeTo(temp);
        
//        BasicDBObject field = new BasicDBObject();
//        field.put("xmlID", "515b0fa84942d3ddc997bdc6");
////        
//        
//        GridFSDBFile objList1 = fs.findOne("Application1.xml");
//     //   for(int i = 0; i<objList1.size(); i++)
//        {
//        	System.out.println(objList1.toString());
//        }
        
//        DBCursor cursor1 = fs.getFileList();
//        try { 
//            while(cursor1.hasNext()) {
//            	DBObject obj = cursor1.next();
//                System.out.println(obj);
//                if(removeLevels)
//                	fs.remove(obj);
//            }
//         } finally {
//            cursor1.close();
//         }
    
//	
//	    //Save loaded image from database into new image file
//	    FileOutputStream outputImage = new FileOutputStream(args[0] + "\\bearCopy1.gxl");
//	    out.writeTo( outputImage );
//	    outputImage.close();
//	    
//	    System.out.println(xmlin.getId() + " " + gxlin.getId());
	
	static void findObjects(DB db, String objectID, String collectionName)
	{
//	        Set<String> colls = db.getCollectionNames();
//
//	        int count = 0;
//	        for (String s : colls) {
//
//	            System.out.println("Collection " + s);
//	            if(s.equals("log"))
//	            {
//	            	PrintWriter writer = new PrintWriter(s+"930.txt", "UTF-8");
//		            DBCollection coll = db.getCollection(s);
//		            ObjectId field = new ObjectId(objectID);
//		           // field.put("$oid", "51ed5bb9a8e0be024c017fa2");
//		            BasicDBObject field1 = new BasicDBObject();
//		            field1.put("playerID", "51e5b3460240288229000026");
//		            DBObject obj = coll.findOne(field);
//		            System.out.println(obj);
//		                     DBCursor cursor = coll.find();
//		    	        try {
//		    	           while(cursor.hasNext()) {
//		    	        	   count++;
//		    	        	   DBObject obj = cursor.next();
//		    	        	   System.out.println(obj); 
//		    	        	   writer.println(obj);
//		    	        	   
//		    	        	   coll.remove(obj);
//		    	           }
//		    	        } finally {
//		    	           cursor.close();
//		    	        }
//		    	   writer.close();
//	            }
//	        }
    }
   
   static void listCollectionNames(DB db)
    {
        Set<String> colls = db.getCollectionNames();
        for (String s : colls) 
        {
        	System.out.println(s);
        }
    }

   static void findOneObject(DB db, String collectionName, String objectID)
    {
        DBCollection coll = db.getCollection(collectionName);
	    ObjectId field = new ObjectId(objectID);
	    DBObject obj = coll.findOne(field);
	    System.out.println(obj);
    }
   
   static void listCollection(DB db, String collectionName)
    {
        DBCollection coll = db.getCollection(collectionName);
        DBCursor cursor = coll.find();
	        try {
	           while(cursor.hasNext()) {
	        	   DBObject obj = cursor.next();
	        	   System.out.println(obj);    
	           }
	        } finally {
	           cursor.close();
	        }
    }
    static void listNonLogCollections(DB db)
    {
        Set<String> colls = db.getCollectionNames();

        for (String s : colls) 
        {
            if(!s.equals("log"))
            {
	            DBCollection coll = db.getCollection(s);
	            DBCursor cursor = coll.find();
	    	        try {
	    	           while(cursor.hasNext()) {
	    	        	   DBObject obj = cursor.next();
	    	        	   System.out.println(obj);    
	    	           }
	    	        } finally {
	    	           cursor.close();
	    	        }
            }
        }
    }
    
    static void listLog(DB db)
    {
     	DBCollection coll = db.getCollection("log");
    	DBCursor cursor = coll.find();
	        try {
	           while(cursor.hasNext()) {
	        	   DBObject obj = cursor.next();
	        	   System.out.println(obj); 
	           }
	        } finally {
	           cursor.close();
	        }

    }
    
    static void saveAndCleanLog(DB db, String date)
    {
    	File file = new File("log"+date+".txt");
    	if(file.exists()) //don't allow writing over current log files
    	{
    		System.out.println("File already exists");
    		return;
    	}
    	PrintWriter writer = null;
    	DBCursor cursor = null;
    	try 
    	{
    		writer = new PrintWriter("log"+date+".txt", "UTF-8");
            DBCollection coll = db.getCollection("log");
            cursor = coll.find();
            while(cursor.hasNext()) {
        	   DBObject obj = cursor.next();
        	   
        	   writer.println(obj);
        	   coll.remove(obj);
            }
    	}
    	catch(Exception e)
    	{
    		System.out.println(e);
    	} 
    	finally {
    	    cursor.close();
    	    writer.close();
        }
    }
    
    static void listMetadata(DB db, String collectionName)
    {
    	System.out.println("Unless you've modified this, it's not doing what you want");
        DBCollection coll = db.getCollection(collectionName);
        DBCursor cursor = coll.find();
        while(cursor.hasNext()) {
    	   DBObject obj = cursor.next();
    	   DBObject metadata = (DBObject) obj.get("metadata");
		   if(metadata != null)
		   {
			   BasicDBList param = (BasicDBList) metadata.get("parameter");
			   if(param != null)
			   {
				   DBObject firstElem = (DBObject) param.get("0");
				   if(firstElem != null)
				   {
					   System.out.println(firstElem.get("name"));
				   }
			   }
		   }
        }
    }
    
    static void writeFilesLocally(DB db, String collectionName, GridFS fs, HashMap<String, String> searchKeys) throws Exception
    {
    	DBCursor cursor = null;
    	
        BasicDBObject field = new BasicDBObject();
    	if(searchKeys != null)
			for (Map.Entry<String, String> entry : searchKeys.entrySet()) {
			    String key = entry.getKey();
			    String value = entry.getValue();
			    field.put(key, value);
			}
    	
        try {
        	DBCollection collection = db.getCollection(collectionName);
        	HashMap<String, Integer> scoreMap = new HashMap<String, Integer>();
        	HashMap<String, String> assignmentMap = new HashMap<String, String>();
        	
        	cursor = collection.find(field);
			 while(cursor.hasNext()) {

				DBObject obj = cursor.next();
				
				String name = (String)obj.get("name");
				Integer score = new Integer((String)obj.get("current_score"));
				String assignmentsID = (String)obj.get("assignmentsID");
				
				if(scoreMap.get(name) == null)
				{
					scoreMap.put(name, score);
					assignmentMap.put(name, assignmentsID);
				}
				else
				{
					Integer currentScore = scoreMap.get(name);
					if(score > currentScore)
					{
						scoreMap.put(name, score);
						assignmentMap.put(name, assignmentsID);
					}
				}
			 }
				

			for(Map.Entry<String, String> assignmentsIDEntry : assignmentMap.entrySet())
			{
				String value = assignmentsIDEntry.getValue();
				String levelName = assignmentsIDEntry.getKey();
				String zipname = "output/" + levelName + "Assignments.zip";
				String dirname = "output/" + levelName + "Assignments";
				String filename = "output/" + levelName + "Assignments.json";
				BasicDBObject filefield = new BasicDBObject();
				filefield.put("_id", new ObjectId(value));
				List<GridFSDBFile> filecursor = fs.find(filefield);
				for(int i=0; i<filecursor.size();i++) {
					GridFSDBFile fileobj = filecursor.get(i);	   
	
					FileOutputStream outputImage = new FileOutputStream(zipname);
					fileobj.writeTo( outputImage );
					outputImage.close();
				}
				File file = new File(zipname);
				while (!file.exists()) {
				    try { 
				        Thread.sleep(100);
				    } catch (InterruptedException ie) { /* safe to ignore */ }
				}
				unZipIt(zipname, dirname);
				
				//now copy actual file out of directory
				Path source = Paths.get(dirname+"/assignments");
				Path dest = Paths.get(filename);
				Files.move(source, dest, REPLACE_EXISTING);
				
				try {
					Path zip = Paths.get(zipname);
					Path dir = Paths.get(dirname);
				    Files.delete(zip);
				    Files.delete(dir);
				} catch (Exception x) {
				    System.err.println(x);
				}
			}
        } finally {
           	if(cursor != null)
           		cursor.close();
           	}
    }
    
    static public void unZipIt(String zipFile, String outputFolder){

        byte[] buffer = new byte[1024];
       	
        try{
       		
       	//create output directory is not exists
       	File folder = new File(outputFolder);
       	if(!folder.exists()){
       		folder.mkdir();
       	}
       		
       	//get the zip file content
       	ZipInputStream zis = 
       		new ZipInputStream(new FileInputStream(zipFile));
       	//get the zipped file list entry
       	ZipEntry ze = zis.getNextEntry();
       		
       	while(ze!=null){
       			
       	   String fileName = ze.getName();
              File newFile = new File(outputFolder + File.separator + fileName);
                   
              System.out.println("file unzip : "+ newFile.getAbsoluteFile());
                   
               //create all non exists folders
               //else you will hit FileNotFoundException for compressed folder
               new File(newFile.getParent()).mkdirs();
                 
               FileOutputStream fos = new FileOutputStream(newFile);             

               int len;
               while ((len = zis.read(buffer)) > 0) {
          		fos.write(buffer, 0, len);
               }
           		
               fos.close();   
               ze = zis.getNextEntry();
       	}
       	
           zis.closeEntry();
       	zis.close();
       		
       	System.out.println("Done");
       		
       }catch(IOException ex){
          ex.printStackTrace(); 
       }
      } 
    
    static void writeFileLocally(GridFS fs, String objectID, String filename ) throws Exception
    {
        BasicDBObject field = new BasicDBObject();
        field.put("_id", new ObjectId(objectID));
		List<GridFSDBFile> cursor = fs.find(field);
        try {
           for(int i=0; i<cursor.size();i++) {
        	   GridFSDBFile obj = cursor.get(i);	   

        	   FileOutputStream outputImage = new FileOutputStream(filename);
        	   obj.writeTo( outputImage );
        	   outputImage.close();
           }
        } finally {
        }
    }

    static void listFiles(GridFS fs)
    {
        DBCursor cursor = fs.getFileList();
        List<DBObject> objList = cursor.toArray();
        for(int i = 0; i<objList.size(); i++)
        {
        	System.out.println(objList.get(i).toString());
        }
    }
    
    static void dropCollection(DB db, String collName)
    {
    	boolean answer = promptForOK("Are you sure you want to remove the collection " + collName + "?");
        
    	if(answer)
    	{
    		System.out.println("Removing collection " + collName);
	    	if (db.collectionExists(collName)) {
	    	    DBCollection myCollection = db.getCollection(collName);
	    	    myCollection.drop();
	    	}
    	}
    	else
    		System.out.print("Not removing collection");
    }
    
    static boolean promptForOK(String prompt)
    {
    	BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.print(prompt + " (y/n)");
        String s = "";
		try {
			s = br.readLine();
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
       if(s.indexOf('y') == -1)
       {
    	   return false;
       }
       
       return true;
    }

}