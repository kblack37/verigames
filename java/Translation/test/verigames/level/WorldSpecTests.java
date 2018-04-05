package verigames.level;

import static org.junit.Assert.*;

import org.junit.*;

import verigames.level.*;
import verigames.level.Intersection.*;

import java.io.*;
import java.util.*;

public class WorldSpecTests
{
  public Chute[] chutes;

  public World w;

  @Before
  public void init()
  {
    chutes = new Chute[10];

    for (int i = 0; i < chutes.length; i++)
      chutes[i] = new Chute(i, null);

    Board b = new Board();

    Intersection in = Intersection.factory(Kind.INCOMING);
    Intersection out = Intersection.factory(Kind.OUTGOING);

    b.addNode(in);
    b.addNode(out);

    for (int i = 0; i < chutes.length; i++)
      b.addEdge(in, Integer.toString(i), out, Integer.toString(i), chutes[i]);

    Level l = new Level();
    l.addBoard("asdf", b);

    w = new World();
    w.addLevel("l", l);
  }

  /**
   * Test basic chute linking functionality
   */
  @Test
  public void testLinkedEdges1()
  {
    // link chutes 0 through 4
    for (int i = 0; i < 4; i++)
      w.linkByVarID(i, i + 1);

    // link chutes 5 through the end
    for (int i = 5; i < chutes.length - 1; i++)
      w.linkByVarID(i, i + 1);

    assertTrue(w.areVarIDsLinked(0, 4));
    assertTrue(w.areVarIDsLinked(5, chutes.length - 1));
    assertFalse(w.areVarIDsLinked(0, 6));
  }

  /**
   * Test that different sets of linked chutes are combined into one when
   * necessary
   */
  @Test
  public void testLinkedEdges2()
  {
    w.linkByVarID(0, 1);
    w.linkByVarID(1, 2);

    w.linkByVarID(3, 4);

    assertTrue(w.areVarIDsLinked(0, 2));
    assertTrue(w.areVarIDsLinked(3, 4));

    assertFalse(w.areVarIDsLinked(0, 3));

    w.linkByVarID(0, 3);

    assertTrue(w.areVarIDsLinked(0, 3));

    assertTrue(w.areVarIDsLinked(1, 4));
  }

  /**
   * Test that any given edge is always linked with itself (reflexivity in the
   * equivalence relation)
   */
  @Test
  public void testLinkedEdges3()
  {
    Set<Chute> set1 = new HashSet<Chute>();
    set1.add(chutes[0]);

    assertTrue(w.areVarIDsLinked(0, 0));

    w.linkByVarID(0, 1);

    assertTrue(w.areVarIDsLinked(0, 0));
  }

  @Test
  public void testLinkedVarIDs()
  {
    w.linkByVarID(1, 3);
    assertTrue(w.areVarIDsLinked(1, 3));
    assertFalse(w.areVarIDsLinked(1, 2));
  }
  @Test(expected = IllegalStateException.class)
  public void testDuplicateNames()
  {
    Board first = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2);
    Board second = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2);

    World w = makeWorldWithBoards("name", first, "name", second);

    triggerException(w);
  }

  @Test(expected = IllegalStateException.class)
  public void testNonexistentReferent()
  {
    Board first = boardFactory(Intersection.subboardFactory("non-existent-name"), 2, 2);
    Board second = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2);

    World w = makeWorldWithBoards("name1", first, "name2", second);

    triggerException(w);
  }

  @Test(expected = IllegalStateException.class)
  public void testInconsistentInputPortNumbers()
  {
    Board first = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2);
    Board second = boardFactory(Intersection.subboardFactory("name1"), 2, 2);

    World w = makeWorldWithBoards("name1", first, "name2", second);

    triggerException(w);
  }

  @Test(expected = IllegalStateException.class)
  public void testInconsistentOutputPortNumbers()
  {
    Board first = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2);
    Board second = boardFactory(Intersection.subboardFactory("name1"), 1, 1);

    World w = makeWorldWithBoards("name1", first, "name2", second);

    triggerException(w);
  }

  @Test(expected = IllegalStateException.class)
  public void testInconsistentInputPortIdentifiers()
  {
    Board first = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2, Arrays.asList("1"), Arrays.asList("1", "2"));
    Board second = boardFactory(Intersection.subboardFactory("name1"), 1, 2, Arrays.asList("one"), Arrays.asList("1", "2"));

    World w = makeWorldWithBoards("name1", first, "name2", second);

    triggerException(w);
  }

  @Test(expected = IllegalStateException.class)
  public void testInconsistentOutputPortIdentifiers()
  {
    Board first = boardFactory(Intersection.factory(Intersection.Kind.SPLIT), 1, 2, Arrays.asList("1"), Arrays.asList("1", "2"));
    Board second = boardFactory(Intersection.subboardFactory("name1"), 1, 2, Arrays.asList("1"), Arrays.asList("1", "two"));

    World w = makeWorldWithBoards("name1", first, "name2", second);

    triggerException(w);
  }

  private Board boardFactory(Intersection intersection, int numInPorts, int numOutPorts)
  {
    List<String> inPorts = new ArrayList<String>();
    List<String> outPorts = new ArrayList<String>();
    for (int i = 0; i < numInPorts; i++)
      inPorts.add(Integer.toString(i));
    for (int i = 0; i < numOutPorts; i++)
      outPorts.add(Integer.toString(i));

    return boardFactory(intersection, numInPorts, numOutPorts, inPorts, outPorts);
  }

  /** returns a board that contains only the given Intersection */
  private Board boardFactory(Intersection intersection, int numInPorts, int numOutPorts, List<String> inPorts, List<String> outPorts)
  {
    Board b = new Board();
    Intersection incoming = Intersection.factory(Intersection.Kind.INCOMING);
    Intersection outgoing = Intersection.factory(Intersection.Kind.OUTGOING);

    b.addNode(incoming);
    b.addNode(outgoing);
    b.addNode(intersection);

    for (int i = 0; i < numInPorts; i++)
    {
      String portStr = inPorts.get(i);
      b.addEdge(incoming, portStr, intersection, portStr, new Chute());
    }
    for (int i = 0; i < numOutPorts; i++)
    {
      String portStr = outPorts.get(i);
      b.addEdge(intersection, portStr, outgoing, portStr, new Chute());
    }

    b.finishConstruction();

    return b;
  }

  /** returns a World with the two given Boards in different levels. */
  private World makeWorldWithBoards(String firstName, Board first, String secondName, Board second)
  {
    Level firstLevel = new Level();
    Level secondLevel = new Level();

    firstLevel.addBoard(firstName, first);
    secondLevel.addBoard(secondName, second);

    firstLevel.finishConstruction();
    secondLevel.finishConstruction();

    World w = new World();
    w.addLevel("first", firstLevel);
    w.addLevel("second", secondLevel);

    return w;
  }

  private final PrintStream outputStub;
  {
    OutputStream outputStreamStub = new OutputStream()
    {
      @Override
      public void write(int b) { }
    };

    outputStub = new PrintStream(outputStreamStub);
  }

  // elicits an IllegalStateException if the given World fails the
  // board/subboard consistency checks
  public void triggerException(World w)
  {
    WorldXMLPrinter p = new WorldXMLPrinter();
    p.print(w, outputStub, null);
  }
}
