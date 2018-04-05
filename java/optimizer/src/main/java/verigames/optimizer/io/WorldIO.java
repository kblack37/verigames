package verigames.optimizer.io;

import verigames.level.Board;
import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.level.Level;
import verigames.level.StubBoard;
import verigames.level.World;
import verigames.level.WorldXMLParser;
import verigames.level.WorldXMLPrinter;
import verigames.optimizer.Util;
import verigames.optimizer.model.BoardRef;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;
import verigames.utilities.MultiMap;
import verigames.utilities.Pair;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class WorldIO {

    public static class LoadedWorld {
        private final NodeGraph graph;
        private final Map<Integer, Edge> edgeIDMapping;
        private final Map<String, StubBoard> stubs;
        public LoadedWorld(NodeGraph graph, Map<Integer, Edge> edgeIDMapping, Map<String, StubBoard> stubs) {
            this.graph = graph;
            this.edgeIDMapping = edgeIDMapping;
            this.stubs = stubs;
        }
        public NodeGraph getGraph() {
            return graph;
        }
        public Map<Integer, Edge> getEdgeIDMapping() {
            return edgeIDMapping;
        }
        public Map<String, StubBoard> getStubs() {
            return stubs;
        }
    }

    public LoadedWorld load(InputStream in, boolean validate) {
        return load(new WorldXMLParser(true, validate).parse(in));
    }

    public LoadedWorld load(World w) {
        NodeGraph g = new NodeGraph();
        Map<Integer, Edge> mapping = new HashMap<>();

        // set up edge sets
        Set<Set<Integer>> linkedVars = w.getLinkedVarIDs();
        for (Set<Integer> varIDs : linkedVars) {
            g.linkVarIDs(varIDs);
        }

        // avoids object duplication -- there aren't (in general) that many unique ports in a world
        Map<String, Port> ports = new HashMap<>();

        // go through each board and extract all the intersections & chutes
        Map<Intersection, Node> nodeMap = new HashMap<>();
        for (Map.Entry<String, Level> levelEntry : w.getLevels().entrySet()) {
            final String levelName = levelEntry.getKey();
            final Level level = levelEntry.getValue();
            for (Map.Entry<String, Board> boardEntry : level.getBoards().entrySet()) {
                final String boardName = boardEntry.getKey();
                final Board board = boardEntry.getValue();
                for (Intersection intersection : board.getNodes()) {
                    final Node node;
                    if (intersection.isSubboard()) {
                        String subboardName = intersection.asSubboard().getSubnetworkName();
                        Board subBoard = w.getBoard(subboardName);
                        StubBoard stubBoard = w.getStubBoard(subboardName);
                        assert (subBoard != null) ^ (stubBoard != null);
                        BoardRef ref = subBoard != null ?
                                new BoardRef(subboardName) :
                                new BoardRef(subboardName, stubBoard);
                        node = new Node(levelName, boardName, intersection.getIntersectionKind(), ref);
                    } else {
                        node = new Node(levelName, boardName, intersection.getIntersectionKind());
                    }
                    nodeMap.put(intersection, node);
                    g.addNode(node);
                }
                for (Chute chute : board.getEdges()) {

                    Port input = ports.get(chute.getStartPort());
                    if (input == null) {
                        input = new Port(chute.getStartPort());
                        ports.put(chute.getStartPort(), input);
                    }

                    Port output = ports.get(chute.getEndPort());
                    if (output == null) {
                        output = new Port(chute.getEndPort());
                        ports.put(chute.getEndPort(), output);
                    }

                    Edge e = g.addEdge(nodeMap.get(chute.getStart()), input,
                            nodeMap.get(chute.getEnd()), output,
                            EdgeData.fromChute(chute));
                    mapping.put(chute.getUID(), e);

                }
            }
        }

        Map<String, StubBoard> stubs = new HashMap<>();
        for (Level l : w.getLevels().values()) {
            stubs.putAll(l.getStubBoards());
        }

        return new LoadedWorld(g, mapping, stubs);
    }

    public Pair<World, Map<Edge, Integer>> toWorld(NodeGraph g) {

        Map<Edge, Integer> mapping = new HashMap<>();
        World world = new World();

        // Assemble some info
        Collection<Edge> edges = g.getEdges();
        MultiMap<String, Node> nodesByLevel = new MultiMap<>();
        MultiMap<String, Node> nodesByBoard = new MultiMap<>();
        MultiMap<String, String> boardsByLevel = new MultiMap<>();
        MultiMap<String, Edge> edgesByBoard = new MultiMap<>();
        Map<Node, Intersection> newIntersectionsByNode = new HashMap<>();
        for (Node n : g.getNodes()) {
            nodesByLevel.put(n.getLevelName(), n);
            nodesByBoard.put(n.getBoardName(), n);
            boardsByLevel.put(n.getLevelName(), n.getBoardName());

            Intersection newIntersection;
            if (n.getKind() == Intersection.Kind.SUBBOARD) {
                String subnetworkName = n.getBoardRef().getName();
                newIntersection = Intersection.subboardFactory(subnetworkName);
            } else {
                newIntersection = Intersection.factory(n.getKind());
            }
            newIntersectionsByNode.put(n, newIntersection);
        }
        for (Edge e : edges) {
            edgesByBoard.put(e.getSrc().getBoardName(), e);
        }

        // Build the data structure
        for (String levelName : nodesByLevel.keySet()) {
            Level newLevel = new Level();
            for (String boardName : boardsByLevel.get(levelName)) {
                Set<Node> boardNodes = nodesByBoard.get(boardName);
                Board newBoard = new Board(boardName);

                // Inane restriction on Boards: callers must add incoming node first
                Node incoming = null;
                for (Node node : boardNodes) {
                    if (node.getKind() == Intersection.Kind.INCOMING) {
                        incoming = node;
                        break;
                    }
                }
                if (incoming == null)
                    throw new RuntimeException("No incoming node exists for board '" + boardName + "'");
                newBoard.addNode(newIntersectionsByNode.get(incoming));

                // add the rest
                for (Node node : boardNodes) {
                    if (node != incoming) // do not add the incoming node twice
                        newBoard.addNode(newIntersectionsByNode.get(node));
                    if (node.getKind() == Intersection.Kind.SUBBOARD) {
                        BoardRef ref = node.getBoardRef();
                        String subboardName = ref.getName();
                        if (ref.isStub() && world.getStubBoard(subboardName) == null && !newLevel.contains(subboardName)) {
                            newLevel.addStubBoard(subboardName, ref.asStubBoard());
                        }
                    }
                }
                for (Edge edge : edgesByBoard.get(boardName)) {
                    Chute newChute = edge.getEdgeData().toChute();
                    Intersection start = newIntersectionsByNode.get(edge.getSrc());
                    String startPort = edge.getSrcPort().getName();
                    Intersection end = newIntersectionsByNode.get(edge.getDst());
                    String endPort = edge.getDstPort().getName();
                    newBoard.add(start, startPort, end, endPort, newChute);
                    mapping.put(edge, newChute.getUID());
                }
                newLevel.addBoard(boardName, newBoard);
            }
            world.addLevel(levelName, newLevel);
        }

        // Link up var IDs
        Set<Integer> realVarIDs = g.nonnegativeVarIDs();
        for (Set<Integer> linked : g.linkedVarIDs()) {
            Set<Integer> x = new HashSet<>(linked);
            x.retainAll(realVarIDs);
            if (x.isEmpty())
                continue;
            int canonical = Util.first(x);
            for (int id : x) {
                if (id != canonical)
                    world.linkByVarID(canonical, id);
            }
        }

        world.finishConstruction();
        return Pair.of(world, mapping);
    }

    public Map<Edge, Integer> export(OutputStream out, NodeGraph g) {
        Pair<World, Map<Edge, Integer>> p = toWorld(g);
        World world = p.getFirst();

        PrintStream printStream = new PrintStream(out);
        WorldXMLPrinter writer = new WorldXMLPrinter();
        writer.print(world, printStream, null);

        return p.getSecond();
    }

}
