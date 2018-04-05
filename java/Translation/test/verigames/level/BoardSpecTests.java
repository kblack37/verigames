package verigames.level;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertEquals;

import org.junit.Before;
import org.junit.Test;

import verigames.level.*;
import verigames.level.Intersection.*;

public class BoardSpecTests
{
  
  public Board board;
  
  public Intersection incoming;
  public Intersection outgoing;
  public Intersection split;
  public Intersection merge;
  public Intersection connect;
  
  public Chute chute1;
  public Chute chute2;
  public Chute chute3;
  public Chute chute4;
  public Chute chute5;
  
  @Before public void initBoards()
  {
    board = new Board();
    
    incoming = Intersection.factory(Kind.INCOMING);
    outgoing = Intersection.factory(Kind.OUTGOING);
    split = Intersection.factory(Kind.SPLIT);
    merge = Intersection.factory(Kind.MERGE);
    connect = Intersection.factory(Kind.CONNECT);
    
    chute1 = new Chute();
    chute2 = new Chute();
    chute3 = new Chute();
    chute4 = new Chute();
    chute5 = new Chute();
  }
  
  // tests the contains method
  @Test public void containsTest()
  {
    assertFalse("An empty board should contain no elements",
        board.contains(incoming));
    assertFalse("An empty board should contain no elements",
        board.contains(chute1));
    
    board.addNode(incoming);
    assertTrue("board should contain incoming node", board.contains(incoming));
    
    board.addNode(split);
    assertTrue("board should contain split node", board.contains(split));
    
    board.addEdge(incoming, "0", split, "0", chute1);
    assertTrue("board should contain chute1", board.contains(chute1));
    
  }
  
  // tests getIncomingNode
  @Test public void incomingTest()
  {
    assertNull(
        "getIncomingNode should return null before an incoming node is added",
        board.getIncomingNode());
    
    board.addNode(incoming);
    assertEquals("getIncomingNode should return incoming", incoming,
        board.getIncomingNode());
  }
  
  // tests getOutgoingNode
  @Test public void outgoingTest()
  {
    assertNull(
        "getOutgoingNode should return null before an outgoing node is added",
        board.getOutgoingNode());
    
    board.addNode(incoming);
    board.addNode(outgoing);
    assertEquals("getOutgoingNode should return outgoing", outgoing,
        board.getOutgoingNode());
  }
  
  // tests that addEdge performs the proper connections
  @Test public void addEdgeTest()
  {
    board.addNode(incoming);
    board.addNode(outgoing);
    board.addEdge(incoming, "3", outgoing, "5", chute1);
    
    // verify that the connections between the chute and nodes have all been
    // made properly
    assertEquals(incoming.getOutput("3"), chute1);
    assertEquals(outgoing.getInput("5"), chute1);
    assertEquals(chute1.getStart(), incoming);
    assertEquals(chute1.getStartPort(), "3");
    assertEquals(chute1.getEnd(), outgoing);
    assertEquals(chute1.getEndPort(), "5");
  }

  @Test (expected=CycleException.class)
  public void cyclicGraphTest()
  {
    board.addNode(incoming);
    board.addNode(outgoing);
    board.addNode(split);
    board.addNode(merge);
    board.addNode(connect);

    board.addEdge(incoming, "a", merge, "foo", chute1);
    board.addEdge(merge, "baz", connect, "asdf", chute2);
    board.addEdge(connect, "bnm", split, "hjweq", chute3);
    board.addEdge(split, "db", outgoing, "e", chute4);
    board.addEdge(split, "c", merge, "bfb", chute5);

    board.finishConstruction();
  }
}
