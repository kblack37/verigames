package verigames.level;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;


import org.junit.Test;

import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.World;
import verigames.level.WorldXMLPrinter;
import verigames.level.Intersection.Kind;

public class LevelXMLTests
{

  /**
   * Generates the XML for TestClass (below)
   *
   * class TestClass
   * {
   *    String s;
   *
   *    public TestClass()
   *    {
   *       s = null;
   *    }
   *
   *    public void method()
   *    {
   *       s = new String("asdf");
   *    }
   * }
   */
  @Test public void TestClassXML() throws FileNotFoundException
  {
    Level l = new Level();

    Board constructor = new Board();
    constructor.addNode(Intersection.factory(Kind.INCOMING));
    Intersection start = Intersection
        .factory(Kind.START_LARGE_BALL);
    constructor.addNode(start);
    Intersection outgoing = Intersection.factory(Kind.OUTGOING);
    constructor.addNode(outgoing);
    Chute c = new Chute(0, null);
    c.setNarrow(false);
    constructor.addEdge(start, "0", outgoing, "0", c);

    l.addBoard("constructor", constructor);

    Intersection incoming = Intersection.factory(Kind.INCOMING);
    Intersection end = Intersection.factory(Kind.END);
    Intersection restart = Intersection
        .factory(Kind.START_SMALL_BALL);
    Intersection out = Intersection.factory(Kind.OUTGOING);

    Board method = new Board();
    method.addNode(incoming);
    method.addNode(end);
    method.addNode(restart);
    method.addNode(out);

    Chute c2 = new Chute(1, null);
    Chute c3 = new Chute(2, null);
    c2.setNarrow(false);
    c3.setNarrow(false);

    method.addEdge(incoming, "0", end, "0", c2);
    method.addEdge(restart, "0", out, "0", c3);

    l.addBoard("method", method);

    World w = new World();
    w.addLevel("TestClass", l);

    w.linkByVarID(0, 1);
    w.linkByVarID(2, 1);

    w.finishConstruction();

    PrintStream p = new PrintStream(new FileOutputStream(new File(
        "TestClass.actual.xml")));
    new WorldXMLPrinter().print(w, p, null);
    p.close();
  }
}
