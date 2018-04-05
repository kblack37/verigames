package verigames.layout;

import verigames.level.Board;
import verigames.level.Level;
import verigames.level.World;

import java.util.Map;

/**
 * Adds layout information to a {@link verigames.level.World World} using Graphviz.
 * <p>
 * This class does not represent an object -- it simply encapsulates the {@link
 * #layout(verigames.level.World) layout(World)} method. As such, it is not instantiable.
 *
 * @see BoardLayout
 *
 * @author Nathaniel Mote
 */
public class WorldLayout
{
  /**
   * Should not be called. WorldLayout is simply a collection of static
   * methods.
   */
  private WorldLayout()
  {
    throw new RuntimeException("Uninstantiable");
  }

  /**
   * Adds layout information to all of the {@link verigames.level.Board Board}s contained
   * in {@code w} using {@link BoardLayout#layout(verigames.level.Board)
   * BoardLayout.layout(Board)}
   * <p>
   * Modifies: {@code w}
   *
   * @param w
   * The {@link verigames.level.World} to lay out. All {@link
   * verigames.level.Level Level}s must not be under construction.
   *
   * @see BoardLayout#layout(verigames.level.Board) BoardLayout.layout(Board)
   */
  public static void layout(World w)
  {
    checkNotUnderConstruction(w);
    int totalBoards = 0;
    for(Level l : w.getLevels().values() ) {
        totalBoards += l.getBoards().values().size();
    }

    int currentBoard = 0;
    for (Level l : w.getLevels().values())
    {
      for (Board b : l.getBoards().values())
      {
        System.out.println("Printing board: " + currentBoard + " of " + totalBoards);
        BoardLayout.layout(b);
        ++currentBoard;
      }
    }
  }

  /**
   * Throws an IllegalArgumentException if {@code w} contains any levels that
   * are under construction. Otherwise, does nothing.
   */
  private static void checkNotUnderConstruction(World w)
  {
    for (Map.Entry<String, Level> entry : w.getLevels().entrySet())
    {
      String name = entry.getKey();
      Level l = entry.getValue();
      if (l.underConstruction())
        throw new IllegalArgumentException("Level " + name + " is under construction");
    }
  }
}
