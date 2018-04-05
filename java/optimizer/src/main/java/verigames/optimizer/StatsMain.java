package verigames.optimizer;

import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Level;
import verigames.level.World;
import verigames.level.WorldXMLParser;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Shows stats about worlds.
 */
public class StatsMain {

    public static void main(String[] args) {

        for (String arg : args) {
            if (arg.equals("-h") || arg.equals("--help") || arg.equals("-help")) {
                System.out.println("Usage: stats [world1.xml [world2.xml [...]]]");
                System.out.println("If no files are given or any file is \"-\", it reads from stdin.");
                return;
            }
        }

        if (args.length == 0 || (args.length == 1 && args[0].equals("-"))) {
            showStats(System.in);
            return;
        }

        for (String s : args) {
            System.out.println("Stats for " + s + ":");
            try (InputStream is = Util.getInputStream(s)) {
                showStats(is);
            } catch (FileNotFoundException e) {
                System.err.println("Could not find file");
            } catch (IOException e) {
                System.err.println("Failed to read file");
            }
        }

    }

    private static void showStats(InputStream in) {
        World w = new WorldXMLParser().parse(in);

        int nodes = 0;
        int edges = 0;
        int edgeSets = 0;
        int nontrivialVarIDSets = 0;
        int nontrivialEdgeSets = 0;
        int levels = 0;
        int boards = 0;

        Set<Integer> varIDs = new HashSet<>();
        Map<Integer, Integer> numEdgesByVarID = new HashMap<>();

        int nextVarID = -1;
        for (Level level : w.getLevels().values()) {
            ++levels;
            for (Board board : level.getBoards().values()) {
                ++boards;
                nodes += board.getNodes().size();
                edges += board.getEdges().size();
                for (Chute c : board.getEdges()) {
                    Integer varID = c.getVariableID();
                    if (c.isEditable() && varID < 0) {
                        varID = --nextVarID;
                    }
                    if (varID > 0) {
                        varIDs.add(varID);
                        Integer n = numEdgesByVarID.get(varID);
                        if (n == null)
                            n = 0;
                        numEdgesByVarID.put(varID, n + 1);
                    }
                }
            }
        }

        Map<Integer, Integer> edgeSetIDByVarID = new HashMap<>();
        int nextEdgeSetID = 0;

        for (Integer i : varIDs) {
            if (!edgeSetIDByVarID.containsKey(i))
                edgeSetIDByVarID.put(i, ++nextEdgeSetID);
        }

        for (Set<Integer> linkedVarIDs : w.getLinkedVarIDs()) {
            if (linkedVarIDs.size() > 1)
                ++nontrivialVarIDSets;
            Integer edgeSetID = ++nextEdgeSetID;
            for (Integer v : linkedVarIDs) {
                edgeSetIDByVarID.put(v, edgeSetID);
            }
        }

        edgeSets = new HashSet<>(edgeSetIDByVarID.values()).size();

        Map<Integer, Integer> edgesByEdgeSetID = new HashMap<>();
        for (Map.Entry<Integer, Integer> entry : edgeSetIDByVarID.entrySet()) {
            Integer varID = entry.getKey();
            Integer edgeSetID = entry.getValue();
            Integer count = edgesByEdgeSetID.get(edgeSetID);
            if (count == null)
                count = 0;
            edgesByEdgeSetID.put(edgeSetID, count + numEdgesByVarID.get(varID));
        }

        for (Integer count : edgesByEdgeSetID.values()) {
            if (count > 1)
                ++nontrivialEdgeSets;
        }

        System.out.println("Levels:                  " + levels);
        System.out.println("Boards:                  " + boards);
        System.out.println("Nodes:                   " + nodes);
        System.out.println("Edges:                   " + edges);
        System.out.println("Edge sets:               " + edgeSets);
        System.out.println("Edge sets (#vars > 1):   " + nontrivialVarIDSets);
        System.out.println("Edge sets (#edges > 1):  " + nontrivialEdgeSets);

    }

}
