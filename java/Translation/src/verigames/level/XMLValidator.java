package verigames.level;

import static verigames.utilities.Misc.ensure;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class XMLValidator
{
  /**
   * Validates the XML presented by stdin. Exits with 0 and no output if it is
   * valid, otherwise throws an exception
   */
  public static void main(String[] args)
  {
    World w = new WorldXMLParser().parse(System.in);
    // the parser calls validate, but we'll call it anyway so we know this
    // self-contained validator does its job even if the parser is modified
    validate(w);
  }

  public static void validate(World w)
  {
    List<Board> boards = getBoards(w);
    validateBoards(boards);

    // maps variableID to a set of Chutes with that variableID
    Map<Integer, Set<Chute>> chutesByVarID = getChutesByVarID(w);
    Set<Set<Integer>> linkedVarIDs = w.getLinkedVarIDs();

    validateVarIDs(linkedVarIDs, chutesByVarID);
    validateLinkedChuteWidth(linkedVarIDs, chutesByVarID);
  }

  private static List<Board> getBoards(World w)
  {
    List<Board> boards = new ArrayList<>();
    for (Level l : w.getLevels().values())
      boards.addAll(l.getBoards().values());
    return boards;
  }

  private static Map<Integer, Set<Chute>> getChutesByVarID(World w)
  {
    Map<Integer, Set<Chute>> chutesByVarID = new HashMap<>();

    for (Level l : w.getLevels().values())
    {
      for (Board b : l.getBoards().values())
      {
        for (Chute c : b.getEdges())
        {
          int varID = c.getVariableID();
          if (!chutesByVarID.containsKey(varID))
            chutesByVarID.put(varID, new HashSet<Chute>());
          chutesByVarID.get(varID).add(c);
        }
      }
    }

    return chutesByVarID;
  }

  private static void validateBoards(List<Board> boards)
  {
    for (Board b : boards)
      validateBoard(b);
  }

  private static void validateBoard(Board b)
  {
    Set<Chute> chutes = b.getEdges();
    Set<Intersection> intersections = b.getNodes();

    ensure(b.getIncomingNode() != null, "Board must have an incoming node");
    ensure(b.getOutgoingNode() != null, "Board must have an outgoing node");

    // TODO validate number of connections for intersections

    // make sure all chute connections are contained in this board
    for (Chute c : chutes)
    {
      ensure(intersections.contains(c.getStart()),
             "Chute's start node should be contained in the Board");
      ensure(intersections.contains(c.getEnd()),
             "Chute's end node should be contained in the Board");
    }

    // make sure all intersections connections are contained in this board
    for (Intersection n : intersections)
    {
      for (String port : n.getInputIDs())
      {
        Chute c = n.getInput(port);
        ensure(chutes.contains(c),
               "Intersection's connected chute should be contained in the Board");
      }

      for (String port : n.getOutputIDs())
      {
        Chute c = n.getOutput(port);
        ensure(chutes.contains(c),
               "Intersection's connected chute should be contained in the Board");
      }
    }

    ensure(b.isAcyclic(), "Board must not contain a cycle");

    // TODO SUBBOARD node must have the correct number of inputs and outputs
    // TODO SUBBOARD node must have the name attribute
  }

  /**
   * Make sure there are no negative varIDs listed in the linkedVarIDs, and make
   * sure that every varID listed corresponds to a chute
   */
  private static void validateVarIDs(Set<Set<Integer>> linkedVarIDs,
                                     Map<Integer, Set<Chute>> chutesByVarID)
  {
    // all varIDs in the linkedVarIDs set
    Set<Integer> allVarIDs = new HashSet<>();
    for (Set<Integer> s : linkedVarIDs)
      allVarIDs.addAll(s);

    for (int varID : allVarIDs)
    {
      ensure(varID >= 0, "All varIDs in a varID set should be positive");

      Set<Chute> chutes = chutesByVarID.get(varID);

      String message = "There should be a chute associated with every variableID in a varID set";
      ensure(chutes != null, message);
      ensure(!chutes.isEmpty(), message);
    }
  }

  /**
   * Make sure that linked chutes have the same width and editableness
   */
  private static void validateLinkedChuteWidth(Set<Set<Integer>> linkedVarIDs,
                                               Map<Integer, Set<Chute>>
                                               chuteByVarID)
  {
    Set<Set<Chute>> linkedChutes = new HashSet<>();
    Set<Integer> encounteredVarIDs = new HashSet<>();

    for (Set<Integer> linkedIDs : linkedVarIDs)
    {
      Set<Chute> chutes = new HashSet<>();
      for (int ID : linkedIDs)
      {
        chutes.addAll(chuteByVarID.get(ID));
        encounteredVarIDs.add(ID);
      }
    }

    for (int ID : chuteByVarID.keySet())
    {
      // if we haven't already added this varID's chutes to the set, and it is
      // actually a set of chutes that should be linked
      if (ID >= 0 && !encounteredVarIDs.contains(ID))
        linkedChutes.add(chuteByVarID.get(ID));
    }

    // do the actual check
    for (Set<Chute> chutes : linkedChutes)
    {
      Boolean narrow = null;
      Boolean editable = null;
      for (Chute c : chutes)
      {
        if (narrow == null)
          narrow = c.isNarrow();
        if (editable == null)
          editable = c.isEditable();

        ensure(c.isNarrow() == narrow,
               "Linked chutes should have the same width (variable id: " + c.getVariableID() + ")");
        ensure(c.isEditable() == editable,
               "Linked chutes should have the same editableness");
      }
    }
  }
}
