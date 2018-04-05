package verigames.layout;

import java.util.*;
import org.junit.Test;
import verigames.level.*;
import verigames.utilities.Pair;

import static org.junit.Assert.*;
import static verigames.level.Intersection.Kind.*;

/**
 * Tests to make sure that layout is sane. Specifically addresses certain bugs.
 */
public class LayoutSpecTests
{
  /**
   * Addresses a bug where layout would fail if arbitrary Strings (rather than
   * String representations of ints) were used as ports for subboards or other
   * nodes that are not represented to dot as discrete points, such as incoming,
   * outgoing, and get nodes.
   */
  @Test
  public void stringPortsTest()
  {
    Board b = new Board();

    Intersection incoming = Intersection.factory(INCOMING);
    Intersection outgoing = Intersection.factory(OUTGOING);
    b.addNode(incoming);
    b.addNode(outgoing);

    Intersection subboard = Intersection.subboardFactory("test");
    b.addNode(subboard);

    b.addEdge(incoming, "asdf", subboard, "bth", new Chute(-1, ""));
    b.addEdge(subboard, "34h", outgoing, "hkbf", new Chute(-1, ""));

    b.finishConstruction();

    BoardLayout.layout(b);
  }
  
  /**
   * Addresses a bug that occured when intersections were connected by more than
   * one chute. The chutes that ran between the same two intersections would be
   * given the same layout information.
   */
  @Test
  public void overlappingChutesTest()
  {
    Chute c1;
    Chute c2;
    // set up a board and put the chutes in it.
    {
      Board b = new Board();

      Intersection incoming = Intersection.factory(INCOMING);
      Intersection outgoing = Intersection.factory(OUTGOING);
      b.addNode(incoming);
      b.addNode(outgoing);

      c1 = new Chute(-1, "c1");
      c2 = new Chute(-1, "c2");

      b.addEdge(incoming, "0", outgoing, "0", c1);
      b.addEdge(incoming, "1", outgoing, "1", c2);

      b.finishConstruction();

      BoardLayout.layout(b);
    }

    List<GameCoordinate> layout1 = c1.getLayout();
    List<GameCoordinate> layout2 = c2.getLayout();

    double c1X = layout1.get(0).getX();
    double c2X = layout2.get(0).getX();

    // make sure that the first x value in each list of spline coordinates is
    // not the same. This is a good enough to tell if the layout is basically
    // the same or not.
    assertNotEquals(
        "Layout leaves chutes with identical layout information (they completely overlap)",
        c1X, c2X, 0.1);
  }

  /**
   * Helper for tests. Asserts that the two double values differ by at least epsilon
   */
  private static void assertNotEquals(String message, double a, double b, double epsilon)
  {
    assertTrue(message, Math.abs(a - b) > epsilon);
  }
}
