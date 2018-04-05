package verigames.level;

import static org.junit.Assert.fail;

import org.junit.Before;
import org.junit.Test;

import verigames.level.Intersection;
import verigames.level.Intersection.Kind;

public class BoardImpTests
{
  // uses the test objects initialized in the spec tests. I know it's not the
  // best style, but it's just a test. Still, if anybody has an objection, I
  // can rewrite it.
  BoardSpecTests testObjs = new BoardSpecTests();
  
  @Before public void init()
  {
    testObjs.initBoards();
  }
  
  /**
   * Tests that there is a failure when the first node added is not an incoming
   * node
   */
  @Test(expected = IllegalArgumentException.class) public void testAddNode1()
  {
    testObjs.board.addNode(testObjs.split);
  }
  
  /**
   * Tests that there is a failure if multiple incoming nodes are added
   */
  @Test(expected = IllegalArgumentException.class) public void testAddNode2()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
    }
    catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addNode(Intersection.factory(Kind.INCOMING));
  }
  
  /**
   * Tests that there is a failure if multiple outgoing nodes are added
   */
  @Test(expected = IllegalArgumentException.class) public void testAddNode3()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
      testObjs.board.addNode(testObjs.outgoing);
    }
    catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addNode(Intersection.factory(Kind.OUTGOING));
  }
  
  /**
   * Tests that there is a failure if the same node is added twice
   */
  @Test(expected = IllegalArgumentException.class) public void testAddNode4()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
      testObjs.board.addNode(testObjs.merge);
    }
    catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addNode(testObjs.merge);
  }
  
  /**
   * Tests that the addNode method fails when neither node is in the Board
   */
  @Test(expected = IllegalArgumentException.class) public void testAddEdge1()
  {
    testObjs.board.addEdge(testObjs.incoming, "0", testObjs.outgoing, "0",
        testObjs.chute1);
  }
  
  /**
   * Tests that the addNode method fails when the start node is not in the
   * Board
   */
  @Test(expected = IllegalArgumentException.class) public void testAddEdge2()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
      testObjs.board.addNode(testObjs.outgoing);
    } catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addEdge(testObjs.split, "0", testObjs.outgoing, "0", testObjs.chute1);
  }
  
  /**
   * Tests that the addNode method fails when the end node is not in the
   * Board
   */
  @Test(expected = IllegalArgumentException.class) public void testAddEdge3()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
    }
    catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addEdge(testObjs.incoming, "0", testObjs.merge, "0", testObjs.chute1);
  }
  
  /**
   * Tests that the addNode method fails when the edge is already in the Board
   */
  @Test(expected = IllegalArgumentException.class) public void testAddEdge4()
  {
    try
    {
      testObjs.board.addNode(testObjs.incoming);
      testObjs.board.addNode(testObjs.merge);
      testObjs.board.addNode(testObjs.split);
      testObjs.board.addNode(testObjs.outgoing);
      testObjs.board.addEdge(testObjs.incoming, "0", testObjs.merge, "0", testObjs.chute1);
    }
    catch (Exception e)
    {
      fail("Unit test failed on configuration");
    }
    testObjs.board.addEdge(testObjs.split, "0", testObjs.outgoing, "0", testObjs.chute1);
  }
}
