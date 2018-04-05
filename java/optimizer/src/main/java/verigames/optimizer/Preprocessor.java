package verigames.optimizer;

import verigames.level.BallSizeTest;
import verigames.level.Intersection;
import verigames.level.StubBoard;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.EdgeData;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;
import verigames.optimizer.model.Port;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Cleans things up a bit before letting the optimizer have a go.
 */
public class Preprocessor {

    private final class Schema {
        public final List<Port> inputs;
        public final List<Port> outputs;
        public Schema() {
            inputs = new ArrayList<>();
            outputs = new ArrayList<>();
        }
        @Override
        public String toString() {
            return "Schema{" +
                    "inputs=" + inputs +
                    ", outputs=" + outputs +
                    '}';
        }
    }

    private final Port INPUT2 = new Port(Port.INPUT.getName() + "2");
    private final Port OUTPUT2 = new Port(Port.OUTPUT.getName() + "2");
    private final Port LARGE_BRANCH = new Port(BallSizeTest.LARGE_PORT);
    private final Port SMALL_BRANCH = new Port(BallSizeTest.SMALL_PORT);

    private Map<String, Schema> boardSchemas(NodeGraph g, Map<String, StubBoard> stubboardsByName) {
        Map<String, Schema> result = new HashMap<>();

        for (Node n : g.getNodes()) {
            Schema s = result.get(n.getBoardName());
            if (s == null) {
                s = new Schema();
                result.put(n.getBoardName(), s);
            }
            switch (n.getKind()) {
                case INCOMING:
                    for (Edge e : g.outgoingEdges(n)) {
                        s.inputs.add(e.getSrcPort());
                    }
                    break;
                case OUTGOING:
                    for (Edge e : g.incomingEdges(n)) {
                        s.outputs.add(e.getDstPort());
                    }
                    break;
            }
        }

        for (Map.Entry<String, StubBoard> entry : stubboardsByName.entrySet()) {
            Schema s = new Schema();
            result.put(entry.getKey(), s);
            StubBoard stub = entry.getValue();
            for (String portName : stub.getInputIDs()) {
                s.inputs.add(new Port(portName));
            }
            for (String portName : stub.getOutputIDs()) {
                s.outputs.add(new Port(portName));
            }
        }

        return result;
    }

    private List<Port> inputs(NodeGraph g, Map<String, Schema> boardSchemas, Node n) {
        Intersection.Kind k = n.getKind();
        switch (k) {
            case BALL_SIZE_TEST:
            case CONNECT:
            case SPLIT:
            case END:
                return Arrays.asList(Port.INPUT);
            case MERGE:
                return Arrays.asList(Port.INPUT, INPUT2);
            case START_SMALL_BALL:
            case START_LARGE_BALL:
            case START_PIPE_DEPENDENT_BALL:
            case START_NO_BALL:
            case INCOMING:
                return Collections.emptyList();
            case SUBBOARD:
                return boardSchemas.get(n.getBoardRef().getName()).inputs;
            case OUTGOING:
                return boardSchemas.get(n.getBoardName()).outputs;
        }
        throw new IllegalArgumentException("Unhandled node type " + k);
    }

    private List<Port> outputs(NodeGraph g, Map<String, Schema> boardSchemas, Node n) {
        Intersection.Kind k = n.getKind();
        switch (k) {
            case BALL_SIZE_TEST:
                return Arrays.asList(LARGE_BRANCH, SMALL_BRANCH);
            case START_SMALL_BALL:
            case START_LARGE_BALL:
            case START_PIPE_DEPENDENT_BALL:
            case START_NO_BALL:
            case CONNECT:
            case MERGE:
                return Arrays.asList(Port.OUTPUT);
            case SPLIT:
                return Arrays.asList(Port.OUTPUT, OUTPUT2);
            case END:
            case OUTGOING:
                return Collections.emptyList();
            case SUBBOARD:
                return boardSchemas.get(n.getBoardRef().getName()).outputs;
            case INCOMING:
                return boardSchemas.get(n.getBoardName()).inputs;
        }
        throw new IllegalArgumentException("Unhandled node type " + k);
    }

    private boolean inputPortNamesMatter(Node n) {
        switch (n.getKind()) {
            case OUTGOING:
            case SUBBOARD:
                return true;
        }
        return false;
    }

    private boolean outputPortNamesMatter(Node n) {
        switch (n.getKind()) {
            case INCOMING:
            case SUBBOARD:
            case BALL_SIZE_TEST:
                return true;
        }
        return false;
    }

    /**
     * Clean up the graph. Changes made (in order):
     * <ul>
     *     <li>Any edge that doesn't connect to 2 valid input or output ports gets broken</li>
     *     <li>
     *         Any node with a missing input gets a new
     *         {@link verigames.level.Intersection.Kind#START_NO_BALL START_NO_BALL}
     *         node added to fill the gap.
     *     </li>
     *     <li>
     *         Any node with a missing output gets a new
     *         {@link verigames.level.Intersection.Kind#END END}
     *         node added to fill the gap.
     *     </li>
     * </ul>
     * @param g the graph to alter
     * @param stubboardsByName the stubboards in the graph
     */
    public void preprocess(NodeGraph g, Map<String, StubBoard> stubboardsByName) {

        Map<String, Schema> schemas = boardSchemas(g, stubboardsByName);

        // break bogus edges
        for (Node node : g.getNodes()) {
            List<Port> inputs = inputs(g, schemas, node);
            List<Port> outputs = outputs(g, schemas, node);
            Collection<Edge> toRemove = new ArrayList<>();

            if (inputPortNamesMatter(node)) {
                for (Edge e : g.incomingEdges(node)) {
                    if (!inputs.contains(e.getDstPort())) {
                        toRemove.add(e);
                    }
                }
            } else {
                // remove edges arbitrarily
                List<Edge> es = new ArrayList<>(g.incomingEdges(node));
                for (int i = es.size(); i > inputs.size(); --i) {
                    toRemove.add(es.get(i - 1));
                }
            }

            if (outputPortNamesMatter(node)) {
                for (Edge e : g.outgoingEdges(node)) {
                    if (!outputs.contains(e.getSrcPort())) {
                        toRemove.add(e);
                    }
                }
            } else {
                // remove edges arbitrarily
                List<Edge> es = new ArrayList<>(g.outgoingEdges(node));
                for (int i = es.size(); i > outputs.size(); --i) {
                    toRemove.add(es.get(i - 1));
                }
            }

            g.removeEdges(toRemove);
        }

        // add missing edges
        for (Node node : new ArrayList<>(g.getNodes())) {
            List<Port> inputs = inputs(g, schemas, node);
            List<Port> outputs = outputs(g, schemas, node);

            if (inputPortNamesMatter(node)) {
                Set<Port> ports = new HashSet<>();
                for (Edge e : g.incomingEdges(node)) {
                    ports.add(e.getDstPort());
                }
                Set<Port> toFill = new HashSet<>(inputs);
                toFill.removeAll(ports);
                for (Port p : toFill) {
                    Node start = Util.newNodeOnSameBoard(node, Intersection.Kind.START_NO_BALL);
                    g.addEdge(start, Port.OUTPUT, node, p, EdgeData.WIDE);
                }
            } else {
                while (g.incomingEdges(node).size() < inputs.size()) {
                    Node start = Util.newNodeOnSameBoard(node, Intersection.Kind.START_NO_BALL);
                    g.addEdge(start, Port.OUTPUT, node, freshPort(), EdgeData.WIDE);
                }
            }

            if (outputPortNamesMatter(node)) {
                Set<Port> ports = new HashSet<>();
                for (Edge e : g.outgoingEdges(node)) {
                    ports.add(e.getSrcPort());
                }
                Set<Port> toFill = new HashSet<>(outputs);
                toFill.removeAll(ports);
                for (Port p : toFill) {
                    Node end = Util.newNodeOnSameBoard(node, Intersection.Kind.END);
                    g.addEdge(node, p, end, Port.INPUT, EdgeData.WIDE);
                }
            } else {
                while (g.outgoingEdges(node).size() < outputs.size()) {
                    Node end = Util.newNodeOnSameBoard(node, Intersection.Kind.END);
                    g.addEdge(node, freshPort(), end, Port.INPUT, EdgeData.WIDE);
                }
            }

        }

    }

    private Port freshPort() {
        return new Port(UUID.randomUUID().toString());
    }

}
