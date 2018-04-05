package verigames.optimizer;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import verigames.level.RandomWorldGenerator;
import verigames.level.World;
import verigames.optimizer.io.ReverseMappingIO;
import verigames.optimizer.io.WorldIO;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.ReverseMapping;
import verigames.utilities.Pair;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * Tests various invariants of the optimizer.
 * In particular:
 * <ul>
 *     <li>the resulting world should be strictly smaller</li>
 *     <li>the resulting world should be a valid world</li>
 * </ul>
 */
@Test
public class OptimizerTest {

    Collection<World> worlds;
    WorldIO io;

    public static class Stats {
        int numLevels = 0;
        int numBoards = 0;
        int numNodes = 0;
        int numEdges = 0;
    }

    public Stats info(NodeGraph g) {
        Stats s = new Stats();
        s.numNodes = g.getNodes().size();
        s.numEdges = g.getEdges().size();
        Set<String> boardNames = new HashSet<>();
        Set<String> levelNames = new HashSet<>();
        for (Node n : g.getNodes()) {
            levelNames.add(n.getLevelName());
            boardNames.add(n.getBoardName());
        }
        s.numLevels = levelNames.size();
        s.numBoards = boardNames.size();
        return s;
    }

    @BeforeClass
    public void setup() {
        io = new WorldIO();
        final int NUM_WORLDS = 10;
        final int RANDOM_SEED = 33; // arbitrary, but consistent from run to run

        worlds = new ArrayList<>(NUM_WORLDS);
        Random random = new Random(RANDOM_SEED);
        RandomWorldGenerator gen = new RandomWorldGenerator(random);
        for (int i = 0; i < NUM_WORLDS; ++i) {
            worlds.add(gen.randomWorld());
        }
    }

    @Test
    public void worldIsValid() {
        Optimizer optimizer = new Optimizer();
        for (World world1 : worlds) {
            WorldIO.LoadedWorld w = io.load(world1);
            NodeGraph g = w.getGraph();
            ReverseMapping m = new ReverseMapping();
            m.initAll(w.getEdgeIDMapping());
            optimizer.optimize(g, m);
            World world2 = io.toWorld(g).getFirst();
            world2.validateSubboardReferences();
        }
    }

    @Test
    public void mappingIsValid() throws IOException {
        Optimizer optimizer = new Optimizer();
        for (World world1 : worlds) {
            WorldIO.LoadedWorld w = io.load(world1);
            NodeGraph g = w.getGraph();
            ReverseMapping mapping = new ReverseMapping();
            mapping.initAll(w.getEdgeIDMapping());
            optimizer.optimize(g, mapping);

            Pair<World, Map<Edge, Integer>> p = io.toWorld(g);
            mapping.finalizeAll(p.getSecond());
            World world2 = p.getFirst();
            new ReverseMappingIO().export(System.out, mapping);

            // make sure no exceptions are thrown
            SolutionTransferMain.applySolution(world2, mapping, world1);

        }
    }

    @Test
    public void worldIsSmaller() {
        Optimizer optimizer = new Optimizer();

        for (World world1 : worlds) {

            NodeGraph g = io.load(world1).getGraph();
            Stats s1 = info(g);
            optimizer.optimize(g);
            Stats s2 = info(g);

            assert s2.numLevels <= s1.numLevels;
            assert s2.numBoards <= s1.numBoards;
            assert s2.numNodes <= s1.numNodes;
            assert s2.numEdges <= s1.numEdges;

        }
    }

}
