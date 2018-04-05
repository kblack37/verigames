package com.cgs.elements;


import java.io.BufferedWriter;
import java.util.ArrayList;
import java.util.HashMap;

public class Level extends Element
{
	protected ArrayList<EdgeSet> edgesets;	
	public ArrayList<Board> boards;
	
	public HashMap<String, Level> dependsOn;
	public HashMap<String, Level> dependedOn;
		
	public String name;
	static public int nextLevelNumber = 0;
	public Level(String _id)
	{
		super(_id);
		edgesets = new ArrayList<EdgeSet>();
		name = "L"+nextLevelNumber++;
		boards = new ArrayList<Board>();
		dependsOn = new HashMap<String, Level>();
		dependedOn = new HashMap<String, Level>();
	}
	
	public void addEdgeSet(EdgeSet edgeset)
	{
		edgesets.add(edgeset);
	}
	
	public void addBoard(Board board)
	{
		boards.add(board);
	}
	
	public void writeOutput(BufferedWriter out)
	{
		  try{
			  
			  out.write("<level id=\""+id+"\">\r");
			  for(int i = 0; i<edgesets.size(); i++)
				{
					EdgeSet edgeset = edgesets.get(i);
					edgeset.writeOutput(out);
				}
			  
			  out.write("</level>\r");
			  //Close the output stream
		  }catch (Exception e){//Catch exception if any
			  System.err.println("Error: " + e.getMessage());
		  }
	}

}