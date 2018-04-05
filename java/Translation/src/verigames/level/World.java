package verigames.level;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * A mapping from names to {@link Level}s. Each {@code Level} must have a unique
 * name
 *
 * @author Nathaniel Mote
 *
 */

public class World
{
  private final Map<String, Level> nameToLevel;

  /**
   * Stores linked varIDs. All {@link Chute}s with varIDs listed in the same
   * {@code Set} will be linked, meaning that in the game they must change width
   * together.
   */
  private final Set<Set<Integer>> linkedVarIDs;

  /**
   * Contains information about which pipes can be stamped with the colors of
   * which other pipes in the game. It is a map from variableID to a set of
   * variableIDs with which it can be stamped.<p>
   *
   * This is for map.get in the nullness type system. For any given pipe, this
   * indicates which other pipes it can be stamped with. This is equivalent to
   * saying that for any given variable, this indicates what variables could
   * potentially be keys for it. Obviously, only when the key is a variableID
   * belonging to a Map object will the corresponding set be non-empty.
   */
  private final Map<Integer, Set<Integer>> stampSets;

  private boolean underConstruction = true;

  /**
   * Creates a new, empty {@code World}
   */
  public World()
  {
    nameToLevel = new LinkedHashMap<String, Level>();
    linkedVarIDs = new LinkedHashSet<Set<Integer>>();
    stampSets = new LinkedHashMap<Integer, Set<Integer>>();
  }

  /**
   * Adds {@code level} to {@code this}, with {@code name} as its name.
   *
   * @param level
   * The {@link Level} to add.
   * @param name
   * The name to associate with {@code level}.
   */
  public void addLevel(String name, Level level)
  {
    nameToLevel.put(name, level);
  }

  /**
   * Return an unmodifiable {@code Map} view on the mapping {@code this}
   * represents. The returned {@code Map} is backed by {@code this}, so changes
   * in {@code this} will be reflected in the returned {@code Map}.
   */
  public Map<String, Level> getLevels()
  {
    return Collections.unmodifiableMap(nameToLevel);
  }

  /**
   * Links all {@link Chute}s with the given variable IDs.<p>
   */
  // TODO should this be varargs or take a set? Or is linking two at once good
  // enough?
  public void linkByVarID(int var1, int var2)
  {
    link(linkedVarIDs, new LinkedHashSet<Integer>(Arrays.asList(var1, var2)));
  }

  public boolean areVarIDsLinked(int var1, int var2)
  {
    if (var1 == var2)
      return true;

    for (Set<Integer> s : linkedVarIDs)
    {
      if (s.contains(var1) && s.contains(var2))
        return true;
    }
    return false;
  }

  public Set<Set<Integer>> getLinkedVarIDs()
  {
    return Collections.unmodifiableSet(linkedVarIDs);
  }

  /**
   * Get the set of var IDs that are linked to the given one
   * @param varID the var ID to check
   * @return the set of var IDs linked to the given one
   */
  public Set<Integer> getLinkedVarIDs(int varID)
  {
    if (varID >= 0)
    {
      for (Set<Integer> set : linkedVarIDs)
      {
        if (set.contains(varID))
          return Collections.unmodifiableSet(set);
      }
    }
    return Collections.singleton(varID);
  }

  /**
   * Get all the sets of linked chutes. Every chute in this world will be
   * in exactly one of the returned sets.
   * @return a collection of chute sets
   */
  public Collection<Set<Chute>> getLinkedChutes() {
    Collection<Set<Chute>> result = new ArrayList<>();
    Map<Integer, Set<Chute>> sets = new HashMap<>();
    for (Set<Integer> linked : linkedVarIDs) {
      Set<Chute> set = new HashSet<>();
      for (Integer varID : linked) {
        sets.put(varID, set);
      }
    }
    for (Chute c : getChutes()) {
      if (c.getVariableID() >= 0) {
        Set<Chute> set = sets.get(c.getVariableID());
        if (set == null) {
          set = new HashSet<>();
          sets.put(c.getVariableID(), set);
        }
        set.add(c);
      } else {
        result.add(Collections.singleton(c));
      }
    }
    result.addAll(sets.values());
    return result;
  }

  private static <T> void link(Set<Set<T>> linkedClasses, Set<T> toLink)
  {
    if (toLink.size() > 1)
    {
      /*
       * Contains the sets that should be removed from linkedClasses
       * because they will be deprecated by the newly created equivalence
       * class
       */
      Set<Set<T>> toRemove = new LinkedHashSet<Set<T>>();

      /*
       * The new equivalence class to be added to linkedClasses. It will
       * at least have all of the elements in toLink.
       */
      Set<T> newEquivClass = new LinkedHashSet<T>(toLink);

      for (Set<T> linked : linkedClasses)
      {
        for (T c : toLink)
        {
          if (linked.contains(c))
          {
            toRemove.add(linked);
            newEquivClass.addAll(linked);
          }
        }
      }

      linkedClasses.removeAll(toRemove);

      linkedClasses.add(newEquivClass);
    }
  }

  /**
   * Adds the pipe identified by {@code stamp} to the list of "colors" with
   * which the pipe identified by {@code pipe} can be stamped.<p>
   *
   * It is extremely important not to mix up the order of the parameters. To be
   * clear, the first pipe will be able to be stamped by the color belonging to
   * the second pipe. The first receives the {@code @KeyFor} annotation in the
   * nullness type system.
   */
  public void addPossibleStamping(int pipe, int stamp)
  {
    if (stampSets.containsKey(pipe))
    {
      stampSets.get(pipe).add(stamp);
    }
    else
    {
      Set<Integer> set = new LinkedHashSet<Integer>();
      set.add(stamp);
      stampSets.put(pipe, set);
    }
  }

  public Set<Chute> getChutes()
  {
    Set<Chute> chutes = new LinkedHashSet<>();

    for (Level l : nameToLevel.values())
    {
      for (Board b : l.getBoards().values())
      {
        chutes.addAll(b.getEdges());
      }
    }

    return chutes;
  }

  private Map<Integer, Set<Chute>> getChutesByVarID()
  {
    Map<Integer, Set<Chute>> chuteMap = new LinkedHashMap<>();

    for (Chute c : getChutes())
    {
      int varID = c.getVariableID();

      if (!chuteMap.containsKey(varID))
        chuteMap.put(varID, new LinkedHashSet<Chute>());

      Set<Chute> chutes = chuteMap.get(varID);

      chutes.add(c);
    }

    return chuteMap;
  }

  /**
   * Board names ought to be globally unique for a world. This
   * convenience method finds the given board across all the
   * levels.
   * @param boardName the board to look for
   * @return the found board, or null if it was missing
   */
  public Board getBoard(String boardName) {
    for (Level level : getLevels().values()) {
      Board board = level.getBoard(boardName);
      if (board != null)
        return board;
    }
    return null;
  }

  /**
   * Board names ought to be globally unique for a world. This
   * convenience method finds the given stub board across all the
   * levels.
   * @param boardName the stub board to look for
   * @return the found stub board, or null if it was missing
   */
  public StubBoard getStubBoard(String boardName) {
    for (Level level : getLevels().values()) {
      StubBoard board = level.getStubBoard(boardName);
        if (board != null)
          return board;
      }
    return null;
  }

  /**
   * Marks this {@code World} as completed, runs some integrity checks, and
   * freezes the {@code World}, as well as all of its child elements.
   *
   * @param parseMode Should be set to true if the world is being generated from a parsed
   * World.xml file. Finish construction will not modify or normalize chute widths,
   * as we want the exact widths from file that is being loaded.
   *
   * @param inferredSubtypes A list of all variables inferred to be a subtype. Used
   * to pre-solve the world by setting chute widths. Only applies when parseMode is false.
   * If inferredSubtypes is null, chutes will be normalized to the typesystem's default width.
   *
   */
  public void finishConstruction()
  {
    finishConstruction(false, Collections.<Integer>emptyList());
  }

  /**
   * Marks this {@code World} as completed, runs some integrity checks, and
   * freezes the {@code World}, as well as all of its child elements.
   * TODO: document parameters
   */
  public void finishConstruction(boolean parseMode, List<Integer> inferredSubtypes)
  {
    if (!underConstruction)
      throw new IllegalStateException("Mutation attempted on constructed World");

    underConstruction = false;

    if (!parseMode) {
      /* Make sure that all chutes that are linked to each other have the same
       * width.
       *
       * If one chute is uneditable, all will become uneditable.
       */
      Map<Integer, Set<Chute>> chutesByVarID = getChutesByVarID();
      Map<Integer, Set<Chute>> nonLinkedChutes = getChutesByVarID();
      for (Set<Integer> linkedIDs : this.linkedVarIDs)
      {
        Set<Chute> linkedChutes = new HashSet<>();
        for (int varID : linkedIDs)
        {
          linkedChutes.addAll(chutesByVarID.get(varID));
          nonLinkedChutes.remove(varID);
        }

        ChuteNormalizer norm = new ChuteNormalizer(linkedChutes, inferredSubtypes);
        norm.normalizeChutes();
      }

      for (Set<Chute> chutes : nonLinkedChutes.values())
      {
        ChuteNormalizer norm = new ChuteNormalizer(chutes, inferredSubtypes);
        norm.normalizeChutes();
      }
    }

    // finish construction on all contained levels
    for (Level l : nameToLevel.values())
    {
      if (l.underConstruction())
        l.finishConstruction();
    }
  }

  public boolean underConstruction()
  {
    return this.underConstruction;
  }

  /**
   * Throws IllegalStateException if the following conditions are not met:
   *
   * Every board needs to have a unique name.
   *
   * Every subboard needs to refer to an identically named board.
   *
   * Every subboard must have the same number of input/output
   * ports as the board to which it refers.
   *
   * Every subboard's port identifiers must match those of its referent.
   */
  public void validateSubboardReferences()
  {
    Map<String, Board> boards = new LinkedHashMap<String, Board>();
    Map<String, StubBoard> stubBoards = new LinkedHashMap<String, StubBoard>();

    // stick all the boards in the map
    for (Level level : this.getLevels().values())
    {
      for (Map.Entry<String, Board> entry : level.getBoards().entrySet())
      {
        String name = entry.getKey();
        Board board = entry.getValue();
        if (boards.containsKey(name))
          throw new IllegalStateException("duplicate board references for " + name);
        boards.put(name, board);
      }

      for( Map.Entry<String, StubBoard> entry : level.getStubBoards().entrySet() ) {
          String name = entry.getKey();
          StubBoard stubs = entry.getValue();
          if (stubBoards.containsKey(name)) {
              throw new IllegalStateException("duplicate stubboard references for " + name);
          }

          stubBoards.put(name, stubs);
      }
    }

    // perform validation
    for (Board board : boards.values())
    {
      Set<Intersection> nodeSet = board.getNodes();
      for (Intersection isect : nodeSet)
      {
        if (isect.isSubboard())
        {
          Subboard subboard = isect.asSubboard();
          String name = subboard.getSubnetworkName();
          final boolean isBoard     = boards.containsKey( name );
          final boolean isStubBoard = stubBoards.containsKey( name );

          if ( !isBoard && !isStubBoard )
            throw new IllegalStateException("no board or stub board exists with name " + name);

          if( isBoard ) {
              validateReferenceToBoard( board, subboard, boards );
          } else {
              validateReferenceToStubBoard( board, subboard, stubBoards );
          }

        }
      }
    }
  }

 /**
  * Expected = board or stub board
  * actual   = subboard
  * @param subboardName
  * @param boardName
  * @param expectedInputs
  * @param expectedOutputs
  * @param actualInputs
  * @param actualOutputs
  * @return
  */
  private void checkReferences( final String subboardName, final String boardName,
                                final List<String> expectedInputs,
                                final List<String> expectedOutputs,
                                final List<String> actualInputs,
                                final List<String> actualOutputs) {
     if( verigames.utilities.Misc.CHECK_REP_STRICT ) {
       if (expectedInputs.size() != actualInputs.size())
         throw new IllegalStateException("subboard " + subboardName + " has " +
                                         actualInputs.size() + " inputs but its referent has " +
                                         expectedInputs.size() + " inputs");
       if (expectedOutputs.size() != actualOutputs.size())
         throw new IllegalStateException("subboard " + subboardName + " has " +
                 actualOutputs.size() + " outputs but its referent has " +
                 expectedOutputs.size() + " outputs" + " caller: " + boardName );

       if (!expectedInputs.equals(actualInputs))
         throw new IllegalStateException(String.format("subboard %s does " +
                 "not have the same input port identifiers as board: subboard " +
                 "has: %s, board has: %s", subboardName, actualInputs.toString(),
                 expectedInputs.toString()));

       if (!expectedOutputs.equals(actualOutputs))
         throw new IllegalStateException(String.format("subboard %s does " +
                 "not have the same output port identifiers as board: subboard " +
                 "has: %s, board has: %s, caller: %s", subboardName, actualOutputs.toString(),
                 expectedOutputs.toString(), boardName));
     }
  }

  private void validateReferenceToBoard(final Board currentBoard, final Subboard subboard, final Map<String, Board> boards ) {
      String name = subboard.getSubnetworkName();

      Board referent = boards.get(name);

      checkReferences( name,  referent.getName(),
                       referent.getIncomingNode().getOutputIDs(), referent.getOutgoingNode().getInputIDs(),
                       subboard.getInputIDs(), subboard.getOutputIDs() );
  }

  private void validateReferenceToStubBoard(final Board currentBoard, final Subboard subboard, final Map<String, StubBoard> stubBoards ) {
      String name = subboard.getSubnetworkName();

      StubBoard referent = stubBoards.get(name);
      List<String> referentInputs  = referent.getInputIDs();
      List<String> referentOutputs = referent.getOutputIDs();

      //Id's are stored in a TreeMap in Intersections and therefore come out in alphabetical order
      Collections.sort( referentInputs  );
      Collections.sort( referentOutputs );

      checkReferences( name,  name,
                       referentInputs, referentOutputs,
                       subboard.getInputIDs(), subboard.getOutputIDs() );
  }

  @Override
  public String toString()
  {
    return "World: " + getLevels().keySet().toString();
  }

}
