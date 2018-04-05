package verigames.level;

import verigames.utilities.Pair;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * Generates random {@link World}s. Useful for testing.
 */
public class RandomWorldGenerator {

    public static void main(String[] args) {
        RandomWorldGenerator generator = new RandomWorldGenerator(new Random());
        World world = generator.randomWorld();
        world.finishConstruction();
        try (PrintStream ps = new PrintStream(System.out)) {
            new WorldXMLPrinter().print(world, ps, null);
        }
    }

    private final Random random;
    private int id;

    public RandomWorldGenerator(Random random) {
        this.random = random;
        this.id = 0;
    }

    private int nextId() {
        return id++;
    }

    private String nextString() {
        return "str" + nextId();
    }

    public World randomWorld() {
        return randomWorld(10, 10, 10);
    }

    public World randomWorld(int maxLevels, int maxBoardsPerLevel, int maxBoardDepth) {
        int numLevels = random.nextInt(maxLevels) + 1;
        World result = new World();
        for (int i = 0; i < numLevels; ++i) {
            result.addLevel("level" + nextId(), randomLevel(maxBoardsPerLevel, maxBoardDepth));
        }
        result.finishConstruction();
        result.validateSubboardReferences();
        return result;
    }

    public Collection<String> generateStrings(int minCount, int maxCount) {
        int count = random.nextInt(maxCount - minCount + 1) + minCount;
        Collection<String> result = new ArrayList<>();
        for (int i = 0; i < count; ++i) {
            result.add(nextString());
        }
        return result;
    }

    public <T> T chooseRandom(T[] collection) {
        return collection[random.nextInt(collection.length)];
    }

    public <T> T chooseRandom(List<T> collection) {
        return collection.get(random.nextInt(collection.size()));
    }

    public <T> T chooseRandom(Collection<T> collection) {
        return chooseRandom(new ArrayList<>(collection));
    }

    /**
     * Remove a random sample of the given size from the given collection.
     * If the sample size is larger than the size of the collection, the
     * collection is emptied and all its elements are returned.
     * @param set    the collection to modify
     * @param count  the number of elements to remove
     * @param <T>    the type of the elements
     * @return       the removed elements
     */
    private <T> Collection<T> removeRandomSample(Set<T> set, int count) {
        Collection<T> result = new ArrayList<>();
        for (int i = 0; i < count && set.size() > 0; ++i) {
            List<T> l = new ArrayList<>(set);
            T val = chooseRandom(l);
            set.remove(val);
            result.add(val);
        }
        return result;
    }

    public Level randomLevel(int maxBoardsPerLevel, int maxBoardDepth) {
        int numBoards = random.nextInt(maxBoardsPerLevel) + 1;
        Collection<String> boardNames = new ArrayList<>();
        Map<String, Collection<String>> boardIncomingPorts = new HashMap<>();
        Map<String, Collection<String>> boardOutgoingPorts = new HashMap<>();
        for (int i = 0; i < numBoards; ++i) {
            String name = "board" + nextId();
            boardNames.add(name);
            boardIncomingPorts.put(name, generateStrings(1, 3));
            boardOutgoingPorts.put(name, generateStrings(1, 2));
        }
        Level result = new Level();
        for (String boardName : boardNames) {
            result.addBoard(boardName, randomBoard(boardName, maxBoardDepth, boardNames, boardIncomingPorts, boardOutgoingPorts));
        }
        return result;
    }

    public Chute randomChute() {
        boolean editable = random.nextBoolean();
        int varID = editable ? random.nextInt(30) : -1;
        Chute result = new Chute(varID, "no-description");
        result.setEditable(editable);
        boolean narrow = !editable && random.nextBoolean();
        result.setPinched(narrow && random.nextBoolean());
        result.setNarrow(narrow);
        result.setBuzzsaw(!narrow && random.nextBoolean());
        // TODO: result.setLayout(...)?
        return result;
    }

    public Board randomBoard(
            String name,
            int maxBoardDepth,
            Collection<String> possibleSubboardNames,
            Map<String, Collection<String>> boardIncomingPorts,
            Map<String, Collection<String>> boardOutgoingPorts) {
        int depth = random.nextInt(maxBoardDepth) + 1;

        Board board = new Board();
        Intersection start = board.addNode(Intersection.Kind.INCOMING);

        // This set is used to track "danling" unconnected ports that we can
        // hook up to stuff. We also always have the option of connecting
        // something to the incoming node.
        Set<Pair<Intersection, String>> dangling = new HashSet<>();
        for (String port : boardIncomingPorts.get(name)) {
            dangling.add(Pair.of(start, port));
        }

        // legal intersection kinds we can generate
        // incoming & outgoing nodes are handled specially, since there can only be one per board
        Collection<Intersection.Kind> kinds = new HashSet<>(Arrays.asList(Intersection.Kind.values()));
        kinds.remove(Intersection.Kind.INCOMING);
        kinds.remove(Intersection.Kind.OUTGOING);
        kinds.remove(Intersection.Kind.BALL_SIZE_TEST); // TODO: can't handle yet
        kinds.remove(Intersection.Kind.SUBBOARD); // TODO: can't handle yet

        // valid ball starts -- zero inputs, one output
        List<Intersection.Kind> starts = new ArrayList<>();
        for (Intersection.Kind k : kinds) {
            if (k.getNumberOfInputPorts() == 0 && k.getNumberOfOutputPorts() == 1)
                starts.add(k);
        }

        // valid ball ends -- one input, zero outputs
        List<Intersection.Kind> ends = new ArrayList<>();
        for (Intersection.Kind k : kinds) {
            if (k.getNumberOfInputPorts() == 1 && k.getNumberOfOutputPorts() == 0)
                ends.add(k);
        }

        for (int i = 0; i < depth; ++i) {
            for (int j = 0; j < random.nextInt(3); ++j) {
                Intersection.Kind kind = chooseRandom(kinds);
                // this basic case handles situations where the number of required input/output ports is known
                int numInputs = kind.getNumberOfInputPorts();
                int numOutputs = kind.getNumberOfOutputPorts();
                assert numInputs >= 0;
                assert numOutputs >= 0;
                Intersection intersection = board.addNode(kind);
                Collection<Pair<Intersection, String>> incomingEdges = removeRandomSample(dangling, numInputs);
                for (int k = incomingEdges.size(); k < numInputs; ++k) {
                    Intersection drop = board.addNode(chooseRandom(starts));
                    incomingEdges.add(Pair.of(drop, nextString()));
                }
                for (Pair<Intersection, String> pair : incomingEdges) {
                    Intersection src = pair.getFirst();
                    String outputPort = pair.getSecond();
                    board.addEdge(src, outputPort, intersection, nextString(), randomChute());
                }

                // add outgoing edges to dangling
                for (int k = 0; k < numOutputs; ++k) {
                    dangling.add(Pair.of(intersection, nextString()));
                }
            }
        }

        // connect output node
        Intersection outgoing = board.addNode(Intersection.Kind.OUTGOING);
        Collection<String> outgoingPorts = boardOutgoingPorts.get(name);
        Collection<Pair<Intersection, String>> left = removeRandomSample(dangling, outgoingPorts.size());
        while (left.size() < outgoingPorts.size()) {
            Intersection drop = board.addNode(chooseRandom(starts));
            left.add(Pair.of(drop, nextString()));
        }
        Iterator<String> portIterator = outgoingPorts.iterator();
        for (Pair<Intersection, String> pair : left) {
            Intersection src = pair.getFirst();
            String outputPort = pair.getSecond();
            board.addEdge(src, outputPort, outgoing, portIterator.next(), randomChute());
        }

        // close up any dangling ports
        for (Pair<Intersection, String> pair : dangling) {
            Intersection src = pair.getFirst();
            String outputPort = pair.getSecond();
            Intersection end = board.addNode(chooseRandom(ends));
            board.addEdge(src, outputPort, end, nextString(), randomChute());
        }

        return board;
    }

}
