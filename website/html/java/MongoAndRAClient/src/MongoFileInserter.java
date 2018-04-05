import java.io.*;

import com.mongodb.*;
import com.mongodb.gridfs.*;

import java.util.ArrayList;

import org.bson.types.ObjectId;

public class MongoFileInserter {

	static String mongoAddress = "ec2-184-72-152-11.compute-1.amazonaws.com";
	DB db = null;
	GridFS fs = null;
	
	public String xmlID;
	public String layoutID;
	public String constraintsID;
    
    public MongoFileInserter(DB _db, String gridFSName)
    {
    	db = _db;
    	fs = new GridFS( db, gridFSName);
    }
    
    //add xml and Layout.xml file
    public void addLevelFiles(File xmlFile) throws IOException
    {
		GridFSInputFile xmlin = fs.createFile( xmlFile );
		 String fileName = xmlFile.getName();
		 int index = fileName.lastIndexOf('.');
		 fileName = fileName.substring(0, index);
        xmlin.put("name", fileName);
        xmlin.save();
        xmlID = xmlin.getId().toString();
        
        String filePath = xmlFile.getPath();
        //remove xml, and add gxl extension
       int baseIndex = filePath.lastIndexOf('.');
        String filebase = filePath.substring(0, baseIndex);
        
        File layoutFile = new File(filebase+"Layout.zip");
        //Save layout into database
        GridFSInputFile layoutIn = fs.createFile( layoutFile );
        layoutIn.save();
        layoutID = layoutIn.getId().toString();
    }
    
    public String addConstraintsFile(File constraintsFile, String worldVersion) throws IOException
    {
        GridFSInputFile conin = fs.createFile( constraintsFile );
        conin.put("version", worldVersion);
        conin.save();
        constraintsID = conin.getId().toString();
        return constraintsID;
    }
}