package verigames.layout;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * A record type that stores coordinates in hundredths of points. A point is
 * 1/72 inch, and is one of the units that Graphviz uses.<p>
 *
 * Hundredths of points are used for greater precision, without the potential
 * rounding errors introduced by floating point numbers
 *
 * The origin is at the the bottom-left, with y coordinates growing upward.
 */
class GraphvizPointCoordinate
{
  private final int x;
  private final int y;

  public GraphvizPointCoordinate(int x, int y)
  {
    this.x = x;
    this.y = y;
  }

  /**
   * Converts coordinates from hundredths of points, using the bottom left as
   * the origin, to game units using the top left as the origin.<p>
   *
   * Because the origin is at the bottom-left for a GraphvizPointCoordinate, and
   * at the top-left for a GameCoordinate, the height of the board is needed to
   * appropriately place the origin when the coordinates are converted
   */
  public GameCoordinate toGameCoordinate(int boardHeight)
  {
    int x = this.x;
    // change the location of the origin
    int y = boardHeight - this.y;

    double xResult = ((double) x / 7200d);
    double yResult = ((double) y / 7200d);

    return new GameCoordinate(xResult, yResult);
  }

  public int getX()
  {
    return this.x;
  }

  public int getY()
  {
    return this.y;
  }

  @Override
  public boolean equals(/*@Nullable*/ Object o)
  {
    if (o instanceof GraphvizPointCoordinate)
    {
      GraphvizPointCoordinate p = (GraphvizPointCoordinate) o;
      return this.getY() == p.getY() && this.getX() == p.getX();
    }
    else
    {
      return false;
    }
  }

  @Override
  public int hashCode()
  {
    return getX() * 31 + getY();
  }
}
