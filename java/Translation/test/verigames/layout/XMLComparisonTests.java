package verigames.layout;

import verigames.layout.WorldLayout;
import verigames.level.*;
import verigames.utilities.FileCompare;

import java.io.*;

import org.junit.Test;

import static org.junit.Assert.*;
import static verigames.level.Intersection.Kind.*;

/**
 * Tests that the XML produced after a World is laid out is consistent with past
 * results.
 *
 * Based on output from graphviz version 2.26.3 (20100126.1600) on the
 * department research lab machines. A failure on a different version or machine
 * is not necessarily an indicator of a defect in the code.
 */
public class XMLComparisonTests
{
  /**
   * Tests that GET node layout is done properly
   */
  @Test
  public void GETLayoutTest() throws FileNotFoundException
  {
    comparisonTest("GETLayoutTest.expected.xml", "GETLayoutTest.actual.xml", GETLayoutTestWorld());
  }

  private static void comparisonTest(String file1, String file2, World w) throws FileNotFoundException
  {
    final File expectedOutput = new File(file1);
    final File actualOutput   = new File(file2);

    WorldLayout.layout(w);

    PrintStream out = new PrintStream(actualOutput);
    try
    {
      new WorldXMLPrinter(true).print(w, out, null);
    }
    finally
    {
      out.close();
    }

    FileCompare.Result result = FileCompare.compareFiles(new File(file1),
        actualOutput);

    assertTrue(result.toString(), result.getResult());
  }

  /**
   * Generate a simple test world used to make sure that the layout for the GET
   * node is working properly.
   *
   * TODO Note that in its current state, this does not actually produce valid
   * XML. We need to tell the game that the third chute can be stamped with the
   * color of the first chute, but we don't yet have a way to do that with this
   * library.
   */
  private static World GETLayoutTestWorld()
  {
    final Board b = new Board();
    {
      Intersection incoming = Intersection.factory(INCOMING);
      Intersection outgoing = Intersection.factory(OUTGOING);
      Intersection get = Intersection.factory(GET);

      b.addNode(incoming);
      b.addNode(outgoing);
      b.addNode(get);

      b.addEdge(incoming, "0", get, "0", new Chute());
      b.addEdge(incoming, "1", get, "1", new Chute());
      b.addEdge(incoming, "2", get, "2", new Chute());
      b.addEdge(incoming, "3", get, "3", new Chute());

      b.addEdge(get, "0", outgoing, "0", new Chute());
    }

    Level l = new Level();
    l.addBoard("GetTestBoard", b);
    l.finishConstruction();

    World w = new World();
    w.addLevel("GetTestLevel", l);

    return w;
  }
}
