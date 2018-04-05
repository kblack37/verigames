package verigames.layout;

/**
 * A record type that stores coordinates in the units that the game uses.<p>
 *
 * The origin is at the top-left of the board, with y-coordinates growning
 * downwards.
 */
public class GameCoordinate
{
  private final double x;
  private final double y;

  public GameCoordinate(double x, double y)
  {
    this.x = x;
    this.y = y;
  }

  public double getX()
  {
    return this.x;
  }

  public double getY()
  {
    return this.y;
  }
}
