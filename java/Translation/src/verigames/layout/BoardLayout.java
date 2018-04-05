package verigames.layout;

import static verigames.layout.Misc.getIntersectionHeight;

import java.util.ArrayList;
import java.util.List;

import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection.Kind;
import verigames.level.Intersection;

/**
 * Adds layout information to a {@link verigames.level.Board Board} using
 * Graphviz.
 * <p>
 * This class does not represent an object -- it simply encapsulates the {@link
 * #layout(verigames.level.Board) layout(Board)} method. As such, it is not
 * instantiable.
 *
 * @see WorldLayout
 *
 * @author Nathaniel Mote
 */
// TODO document all variables with error-prone units using the units checker
public class BoardLayout
{
  /**
   * The minimum height that a board should be. If it is less than this height,
   * it will not display properly in the game.
   *
   * This is used to determine when a board should have its height scaled up.
   */
  private static final double MIN_HEIGHT = 7.68;

  /**
   * Should not be called. BoardLayout is simply a collection of static
   * methods.
   */
  private BoardLayout()
  {
    throw new RuntimeException("Uninstantiable");
  }

  /**
   * Adds layout information to {@code b} using Graphviz.
   * <p>
   * Modifies: {@code b}
   *
   * @param b
   * The {@link verigames.level.Board} to lay out. {@link
   * verigames.level.Board#underConstruction() b.underConstruction()} must be
   * false.
   *
   * @see WorldLayout#layout(verigames.level.World) WorldLayout.layout(World)
   */
  public static void layout(Board b)
  {
    if (b.underConstruction())
      throw new IllegalArgumentException("b is under construction");

    final GraphInformation info;

    // These variables are all just for clarity, so putting them in a block
    // avoids cluttering the namespace
    {
      AbstractDotPrinter printer = new DotPrinter();
      String command = "dot";
      AbstractDotParser parser = new DotParser();

      // the runner prints output according to the printer and then parses it
      // and returns the result as a GraphInformation structure
      GraphvizRunner runner = new GraphvizRunner(printer, command, parser);
      info = runner.run(b);
    }

    // the height of the board is needed when the origin is moved from the
    // bottom left to the top left.
    int boardHeight = info.getGraphAttributes().getHeight();

    // harvest the node layout information
    for (Intersection n : b.getNodes())
    {
      int UID = n.getUID();

      GraphInformation.NodeAttributes nodeAttrs;
      try
      {
        // throws IllegalArgumentException if the node is not present. This
        // should not happen, but if, somehow, Graphviz's output does not
        // include a node that is in the Board, the resulting, cryptic error
        // should not escape to the client.
        nodeAttrs = info.getNodeAttributes(Integer.toString(UID));
      }
      catch (IllegalArgumentException e)
      {
        throw new RuntimeException(
            "Internal error -- node in Board not present in Graphviz output", e);
      }
      
      // gives the location of the center of the node in hundredths of
      // points, using the top left corner of the board as the origin
      int xIn = nodeAttrs.getX();
      int yIn = boardHeight - nodeAttrs.getY();
      
      // gives the width and height of the node in hundredths of points
      int width = nodeAttrs.getWidth();
      int height = nodeAttrs.getHeight();
      
      // gives the upper left hand corner of the node in hundredths of points.
      int xCorner = Math.max(xIn - (width / 2), 0); //TODO JB: Shouldn't we never have a negative here?
      int yCorner = Math.max(yIn - (height / 2), 0);
      
      n.setX(((double) xCorner) / 7200d);
      n.setY(((double) yCorner) / 7200d);
    }

    // harvest the edge layout information
    for (Chute c : b.getEdges())
    {
      // get the chute UID. The printer uses this as a label to identify chutes.
      String chuteUID = DotPrinter.getChuteLabel(c);

      GraphInformation.EdgeAttributes edgeAttrs =
          info.getEdgeAttributes(chuteUID);

      List<GameCoordinate> layout = new ArrayList<GameCoordinate>();

      for (int i = 0; i < edgeAttrs.controlPointCount(); i++)
      {
        GameCoordinate coords =
            edgeAttrs.getCoordinates(i).toGameCoordinate(boardHeight);

        layout.add(coords);
      }

      /* if the start node is an INCOMING node, cheat a little bit and set the
       * starting y coordinate to 0. It's pretty close to 0 already, but it's
       * not quite because of some limitations with Graphviz. Because it's so
       * close, it shouldn't cause any problems with the spline, and it will
       * look better this way. */
      if (c.getStart().getIntersectionKind() == Intersection.Kind.INCOMING)
      {
        GameCoordinate firstCoord = layout.get(0);

        double x = firstCoord.getX();
        double y = 0;

        layout.set(0, new GameCoordinate(x,y));
      }

      c.setLayout(layout);
    }

    // scales up to the minimum height if the board is too short
    scaleUpToMinHeight(b);
  }

  /**
   * Scales {@code b} so that its height is at least {@link #MIN_HEIGHT}.
   * <p>
   * Modifies {@code b}
   */
  private static void scaleUpToMinHeight(Board b)
  {
    if (b.getOutgoingNode().getY() < MIN_HEIGHT)
    {
      double scaleFactor = MIN_HEIGHT / b.getOutgoingNode().getY();

      scaleBoardVertically(scaleFactor, b);
    }
  }

  /**
   * Scales {@code b} vertically by the given factor.
   * <p>
   * Modifies {@code b}
   */
  private static void scaleBoardVertically(double scaleFactor, Board b)
  {
    // first scale the node coordinates up by the scale factor, then scale and
    // translate the edges to match their intersections.
    for (Intersection n : b.getNodes())
      scaleNodeY(scaleFactor, n);
    for (Chute c : b.getEdges())
      scaleEdgeY(c);
  }

  /**
   * Scales the Y coordinate of the given node by the given factor.
   * <p>
   * Modifies {@code node}
   */
  private static void scaleNodeY(double scaleFactor, Intersection node)
  {
    node.setY(node.getY() * scaleFactor);
  }

  /**
   * Scales the Y coordinates of the given edge to reach the Y coordinates of
   * its endpoints.
   * <p>
   * Modifies {@code edge}
   */
  private static void scaleEdgeY(Chute edge)
  {
    Intersection start = edge.getStart();
    Intersection end = edge.getEnd();

    Kind startKind = start.getIntersectionKind();

    double startHeight = getIntersectionHeight(startKind);

    // the place where the edge should start is the y coordinate of the start
    // node plus its height, because the y coordinate refers to the top of the
    // node.
    double startY = start.getY() + startHeight;
    double endY = end.getY();

    scaleEdgeY(startY, endY, edge);
  }

  /**
   * Scales the Y coordinates of the given edge so that the top is at {@code
   * start} and the bottom is at {@code end}
   */
  private static void scaleEdgeY(double start, double end, Chute edge)
  {
    List<GameCoordinate> oldLayout = edge.getLayout();
    double oldStart = oldLayout.get(0).getY();
    double oldEnd = oldLayout.get(oldLayout.size() - 1).getY();

    // figure out the scale factor and the offset for the linear transformation
    double factor = (end - start) / (oldEnd - oldStart);
    double offset = start - factor * oldStart;

    List<GameCoordinate> newLayout = new ArrayList<GameCoordinate>();

    // loop through and transform each y coordinate
    for (GameCoordinate point : oldLayout)
    {
      double x = point.getX();
      double y = point.getY() * factor + offset;

      GameCoordinate newPoint = new GameCoordinate(x,y);
      newLayout.add(newPoint);
    }
    edge.setLayout(newLayout);
  }
}
