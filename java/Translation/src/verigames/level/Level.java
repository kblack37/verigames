package verigames.level;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * A mutable level for Pipe Jam. A {@code Level} consists of any number of
 * {@link Board}s, each associated with a unique name.  * <p>
 *
 * A {@code Level} also keeps track of which {@link Chute}s in the contained
 * {@code Board}s are linked (see below).  * <p>
 *
 * Specification Field: {@code linkedEdgeClasses} : {@code Set<Set<Chute>>} //
 * Contains equivalence classes of {@code Chute}s, as defined by the following
 * equivalence relation * <p>
 *
 * Let R be the maximal equivalence relation on the set of all {@code Chute}s
 * such that:<br/> aRb --> a and b necessarily have the same width. That is,
 * when a changes width, b must follow, and vice-versa.  * <p>
 *
 * Specification Field: {@code boards} : {@code Set<Board>} // represents the
 * set of all boards in this level * <p>
 *
 * Specification Field: {@code boardNames} : {@code Map<String, Board>} // maps
 * the name of a method to its {@code Board} * <p>
 *
 * Specification Field: {@code underConstruction} : {@code boolean} // {@code
 * true} iff {@code this} can still be modified. Once {@code underConstruction}
 * is set to {@code false}, {@code this} becomes immutable.
 *
 * @author Nathaniel Mote
 */

public class Level
{
  private final Map<String, Board> boardNames;
  private final Map<String, StubBoard> stubBoardNames;

  private boolean underConstruction = true;

  /**
   * Creates a new {@code Level} with an empty {@code linkedEdgeClasses},
   * {@code boards}, and {@code boardNames}
   */
  public Level()
  {
    boardNames = new LinkedHashMap<String, Board>();
    stubBoardNames = new LinkedHashMap<String, StubBoard>();
  }

  /**
   * Adds {@code b} to {@code boards}, and adds the mapping from {@code name}
   * to {@code b} to {@code boardNames}<br/>
   * <br/>
   * Modifies: {@code this}<br/>
   *
   * @param b
   * The {@link Board} to add to {@code boards}. Must not be contained in
   * {@code boards}
   * @param name
   * The name to associate with {@code b}. Must not be contained in
   * {@code boardNames.keySet()}
   */
  public void addBoard(String name, Board b)
  {
    if (this.contains(name))
      throw new IllegalArgumentException("name \"" + name + "\" already in use");
    // the following check is pretty expensive, but probably worth it.
    if (boardNames.containsValue(b))
      throw new IllegalArgumentException("Board " + b + " already contained");
    boardNames.put(name, b);
  }

  public void addStubBoard(String name, StubBoard b)
  {
    if (this.contains(name))
      throw new IllegalArgumentException("name \"" + name + "\" already in use");
    if (stubBoardNames.containsValue(b))
      throw new IllegalArgumentException("StubBoard " + b + " already contained");
    stubBoardNames.put(name, b);
  }

  /**
   * Return an unmodifiable {@code Map} view on {@code boardNames}. The
   * returned {@code Map} is backed by {@code this}, so changes in {@code
   * this} will be reflected in the returned {@code Map}.
   */
  public Map<String, Board> getBoards()
  {
    return Collections.unmodifiableMap(boardNames);
  }

  /**
   * Returns the {@code Board} to which {@code name} maps in {@code
   * boardNames}, or {@code null} if it maps to nothing
   */
  public/* @Nullable */Board getBoard(String name)
  {
    return boardNames.get(name);
  }

  public Map<String, StubBoard> getStubBoards()
  {
    return Collections.unmodifiableMap(stubBoardNames);
  }

  public /* @Nullable */ StubBoard getStubBoard(String name)
  {
    return stubBoardNames.get(name);
  }

  /**
   * Returns {@code true} if and only if this {@code Level} contains a {@link
   * Board} or a {@link StubBoard} by the given name.
   */
  public boolean contains(String name)
  {
    return boardNames.containsKey(name) || stubBoardNames.containsKey(name);
  }

  /**
   * Returns {@code underConstruction}
   */
  public boolean underConstruction()
  {
    return underConstruction;
  }

  /**
   * Sets {@code underConstruction} to {@code false}, finishes construction on
   * all contained {@link Board}s<br/>
   * <br/>
   * Requires:<br/>
   * - {@link #underConstruction() this.underConstruction()}<br/>
   * - all {@code Board}s in {@code boards} are in a state in which they can
   *   finish construction
   * - All chutes that have been linked must have the same width.
   */
  public void finishConstruction()
  {
    if (!underConstruction)
      throw new IllegalStateException("Mutation attempted on constructed Level");

    underConstruction = false;

    for (Board b : boardNames.values()) {
        b.finishConstruction();
    }
  }

  private Set<Chute> getAllChutes()
  {
    Set<Chute> chutes = new LinkedHashSet<Chute>();
    for (Board b : boardNames.values())
      chutes.addAll(b.getEdges());
    return chutes;
  }

  @Override
  public String toString()
  {
    return "Level: " + getBoards().keySet().toString();
  }
}
