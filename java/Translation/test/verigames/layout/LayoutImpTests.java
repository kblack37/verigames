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
public class LayoutImpTests
{
  /**
   * The current height of a subboard, as rendered by the game
   */
  private static final double SUBBOARD_HEIGHT =
      Misc.getIntersectionHeight(Intersection.Kind.SUBBOARD);

  /**
   * Addresses a bug where y coordinates of short boards would be scaled
   * blindly, so the distance between chute endpoints connected to subboards
   * would increase to greater than the height of the subboard.
   */
  @Test
  public void scalingTest1()
  {
    Chute c1;
    Chute c2;
    // set up a board and put the chutes in it
    {
      Board b = new Board();
      
      Intersection incoming = Intersection.factory(INCOMING);
      Intersection outgoing = Intersection.factory(OUTGOING);
      Intersection middle = Intersection.subboardFactory("test");
      b.addNode(incoming);
      b.addNode(outgoing);
      b.addNode(middle);

      c1 = new Chute(-1, "c1");
      c2 = new Chute(-1, "c2");

      b.addEdge(incoming, "0", middle, "0", c1);
      b.addEdge(middle, "0", outgoing, "0", c2);

      b.finishConstruction();

      BoardLayout.layout(b);
    }

    List<GameCoordinate> layout1 = c1.getLayout();
    List<GameCoordinate> layout2 = c2.getLayout();

    // get the last y coordinate of the first chute and the first y coordinate
    // of the second chute
    double c1Y = layout1.get(layout1.size() - 1).getY();
    double c2Y = layout2.get(0).getY();

    // make sure that these differ by roughly the height of a subboard.
    assertEquals(
        "Chutes on the top and bottom of a subnetwork are not separated by " +
        SUBBOARD_HEIGHT + " units",
        SUBBOARD_HEIGHT, c2Y - c1Y, 0.05);
  }

  /**
   * Makes sure that the symptom described in scalingTest1 also does not appear
   * in larger boards.
   */
  @Test
  public void scalingTest2()
  {
    Chute c1;
    Chute c2;
    // set up a board and put the chutes in it
    {
      Board b = new Board();
      
      Intersection incoming = Intersection.factory(INCOMING);
      Intersection outgoing = Intersection.factory(OUTGOING);
      Intersection first = Intersection.subboardFactory("test");
      Intersection second = Intersection.factory(CONNECT);
      Intersection third = Intersection.factory(CONNECT);
      Intersection fourth = Intersection.factory(CONNECT);
      Intersection fifth = Intersection.factory(CONNECT);
      b.addNode(incoming);
      b.addNode(outgoing);
      b.addNode(first);
      b.addNode(second);
      b.addNode(third);
      b.addNode(fourth);
      b.addNode(fifth);

      c1 = new Chute(-1, "c1");
      c2 = new Chute(-1, "c2");

      b.addEdge(incoming, "0", first, "0", c1);
      b.addEdge(first, "0", second, "0", c2);
      b.addEdge(second, "0", third, "0", new Chute(-1, "c3"));
      b.addEdge(third, "0", fourth, "0", new Chute(-1, "c4"));
      b.addEdge(fourth, "0", fifth, "0", new Chute(-1, "c5"));
      b.addEdge(fifth, "0", outgoing, "0", new Chute(-1, "c6"));

      b.finishConstruction();

      BoardLayout.layout(b);
    }

    List<GameCoordinate> layout1 = c1.getLayout();
    List<GameCoordinate> layout2 = c2.getLayout();

    // get the last y coordinate of the first chute and the first y coordinate
    // of the second chute
    double c1Y = layout1.get(layout1.size() - 1).getY();
    double c2Y = layout2.get(0).getY();

    // make sure that these differ by roughly the height of a subboard.
    assertEquals(
        "Chutes on the top and bottom of a subnetwork are not separated by " +
        SUBBOARD_HEIGHT + " units",
        SUBBOARD_HEIGHT, c2Y - c1Y, 0.05);
  }
}
