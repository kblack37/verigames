package com.cgs.elements;

import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class EdgeSet extends Element
{
	protected ArrayList<EdgeElement> edges;
	protected ArrayList<String> edgeIDs;
	public boolean hasBeenOutputted = false;
	
	public EdgeSet(String _id)
	{
		super(_id);
		edges = new ArrayList<EdgeElement>();
		edgeIDs = new ArrayList<String>();
	}
	
	public void addEdge(EdgeElement edge)
	{
		edges.add(edge);
	}
	
	public void addEdgeID(String edgeID)
	{
		edgeIDs.add(edgeID);
	}
	
	public void writeOutput(BufferedWriter out)
	{
		  try{
			  
			  out.write("<edgeset id=\""+id+"\">\r");
			  for(int i = 0; i<edges.size(); i++)
				{
					EdgeElement edge = edges.get(i);
					edge.writeOutput(out);
				}
			  
			  out.write("</edgeset>\r");
			  //Close the output stream
		  }catch (Exception e){//Catch exception if any
			  System.err.println("Error: " + e.getMessage());
		  }
	}
	
	public void write(PrintWriter printWriter)
	{
		printWriter.println("<edge-set id=\"" + id + "\">");
		for(int i=0; i<edgeIDs.size(); i++)
			printWriter.println("<edgeref id=\"" + edgeIDs.get(i) + "\"/>");

		printWriter.println("</edge-set>");
	}
}

