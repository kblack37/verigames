package com.cgs.elements;

import java.io.BufferedWriter;
import java.io.PrintWriter;

public class EdgeElement extends Element
{
	public String fromNodeID;
	public String fromPortName;
	public String toNodeID;
	public String toPortName;
	public String levelID;
	public String portName;
	public EdgeSet parent;
	
	public boolean isEditable;
	
	public boolean isInternal = true;
	public boolean isInOrOutConnection = false;
	public boolean isLevelConnection = false;
	
	public EdgeElement(EdgeSet parent, String _id, String _levelID)
	{
		super(_id);
		this.parent = parent;
		levelID = _levelID;
	}
	
	public void setInputNode(String _fromNodeID)
	{
		fromNodeID = _fromNodeID;
	}
	
	public void setInputNode(String _fromNodeID, String _portName)
	{
		fromNodeID = _fromNodeID;
		fromPortName = _portName;
	}
	
	public void setOutputNode(String _toNodeID)
	{
		toNodeID = _toNodeID;
	}
	
	public void setOutputNode(String _toNodeID, String _portName)
	{
		toNodeID = _toNodeID;
		toPortName = _portName;
	}
	
	public void writeOutput(BufferedWriter out)
	{
		  try{
			  
			  out.write("<edge id=\""+id+"\">\r");
			  
			  if(!isInternal)
				  out.write("isInternal="+isInternal+"\r");
			  if(isInOrOutConnection)
				  out.write("isInOrOutConnection="+isInOrOutConnection+"\r");
			  if(isLevelConnection)
				  out.write("isLevelConnection="+isLevelConnection+"\r");
			  
			  out.write("</edge>\r");
			  //Close the output stream
		  }catch (Exception e){//Catch exception if any
			  System.err.println("Error: " + e.getMessage());
		  }
	}
	
	public void write(PrintWriter printWriter)
	{
		printWriter.write("<edge ");
		writeAttributeString(printWriter);
		printWriter.println(">");
		printWriter.println("<from>");
		printWriter.println("<noderef id=\"" + fromNodeID + "\" port=\"" + fromPortName + "\"/>");
		printWriter.println("</from>");
		printWriter.println("<to>");
		printWriter.println("<noderef id=\"" + toNodeID + "\" port=\"" + toPortName + "\"/>");
		printWriter.println("</to>");
		printWriter.println("</edge>");
	}
}
