package verigames.optimizer.io;

import org.testng.annotations.Test;
import verigames.level.Board;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.RandomWorldGenerator;
import verigames.level.World;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;

import java.util.Map;
import java.util.Random;

@Test
public class WorldIOTest {

    @Test
    public void testDump() {
        WorldIO io = new WorldIO();
        World w1 = new RandomWorldGenerator(new Random(10)).randomWorld();
        NodeGraph g1 = io.load(w1).getGraph();
        World w2 = io.toWorld(g1).getFirst();
        NodeGraph g2 = io.load(w2).getGraph();
        assert g1.getNodes().size() == g2.getNodes().size();
        assert g1.getEdges().size() == g2.getEdges().size();
        // TODO: lots more stuff we could check here
    }

    @Test
    public void testLoad() {
        WorldIO io = new WorldIO();
        World w = new RandomWorldGenerator(new Random(10)).randomWorld();
        NodeGraph g = io.load(w).getGraph();

        // Check node presence
        for (Map.Entry<String, Level> levelEntry : w.getLevels().entrySet()) {
            String levelName = levelEntry.getKey();
            Level level = levelEntry.getValue();
            for (Map.Entry<String, Board> entry : level.getBoards().entrySet()) {
                String boardName = entry.getKey();
                Board board = entry.getValue();
                for (Intersection i : board.getNodes()) {
                    System.out.println("+++ " + levelName + " . " + boardName);
                    System.out.println(i);
                    boolean found = false;
                    for (Node n : g.getNodes()) {
                        System.out.println("  --> " + n + " (" + n.getLevelName() + " . " + n.getBoardName() + ")");
                        if (n.getKind() == i.getIntersectionKind() &&
                                levelName.equals(n.getLevelName()) &&
                                boardName.equals(n.getBoardName())) {
                            found = true;
                            break;
                        }
                    }
                    assert found;
                }
            }
        }

        // Check edge set presence
        for (Edge e1 : g.getEdges()) {
            for (Edge e2 : g.getEdges()) {
                if (e1.getVariableID() >= 0 &&
                        e2.getVariableID() >= 0 &&
                        w.areVarIDsLinked(e1.getEdgeData().getVariableID(), e2.getEdgeData().getVariableID())) {
                    assert g.edgeSet(e1).equals(g.edgeSet(e2));
                }
            }
        }

        // TODO: lots more stuff we could check here
    }

}
