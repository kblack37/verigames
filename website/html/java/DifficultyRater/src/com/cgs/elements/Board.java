package com.cgs.elements;

import java.util.ArrayList;
import java.util.HashMap;

public class Board extends Element {

	public ArrayList<NodeElement> nodes;
	public HashMap<String, NodeElement> subboards;
	
	public HashMap<String, Board> dependsOn;
	public HashMap<String, Board> dependedOn;
	
	public Level containerLevel;
	
	//for stub-boards
	public ArrayList<Port> incomingConnections;
	public ArrayList<Port> outgoingConnections;

	public Board(String _id) {
		super(_id);
		nodes = new ArrayList<NodeElement>();
		subboards = new HashMap<String, NodeElement>();
		dependsOn = new HashMap<String, Board>();
		dependedOn = new HashMap<String, Board>();
	}
	
	public Board(String _id, boolean isStubboard) {
		super(_id);
		incomingConnections = new ArrayList<Port>();
		outgoingConnections = new ArrayList<Port>();
		dependedOn = new HashMap<String, Board>();
	}
	
	public void addNode(NodeElement node)
	{
		nodes.add(node);
	}
	
	public void addSubboard(NodeElement board)
	{
		subboards.put(board.name, board);
	}
	
	//used by stub boards
	public void addConnection(Port connection, boolean isIncoming)
	{
		if(isIncoming)
			incomingConnections.add(connection);
		else
			outgoingConnections.add(connection);
	}

}
