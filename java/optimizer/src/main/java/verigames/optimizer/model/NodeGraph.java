package verigames.optimizer.model;

import verigames.optimizer.common.Clustering;
import verigames.utilities.MultiMap;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * A mutable graph representing a Verigames world. This is an alternate
 * representation for the {@link verigames.level.World} class which the
 * optimizer finds more useful.
 */
public class NodeGraph {

    // READER BEWARE
    // The NodeGraph class does an immense amount of internal bookkeeping to
    // make most operations very very fast. That results in a lot of
    // complexity in this file.

    /**
     * This is the primary data structure for the graph. It maps
     * every source Node to a set of Port mappings. A Port
     * mapping maps each source Port to a collection of (Node, Port)
     * destination pairs.
     *
     * <p>Here, however, we need to store an extra piece of data:
     * the {@link EdgeData} for the edge. To keep things simple,
     * all the info is stored in the {@link Edge} class.
     *
     * <p>NOTE: A key is present if and only if the node is in the
     * graph. This is used to store the set of nodes.
     */
    private final Map<Node, Map<Port, Edge>> edges;

    /**
     * Very often we want to look up what flows INTO a node, not
     * just OUT of it. This reverse lookup table makes it much
     * easier to answer that question by mapping each Node to the
     * set of edges that flow into it.
     */
    private final MultiMap<Node, Edge> redges;

    /**
     * Linked variable IDs
     */
    private final Clustering<Integer> linkedVars;

    /**
     * Maps variable IDs (integers) to all the edges in this graph that
     * have the given ID. This is used in conjunction with
     * {@link #linkedVars} to determine what edges share widths.
     *
     * <p>NOTE: edges that have negative variable IDs are NOT stored in
     * this collection.
     */
    private final MultiMap<Integer, Edge> edgesByVarID;

    /**
     * Construct an empty graph.
     * @see #addNode(Node)
     * @see #addEdge(Node, Port, Node, Port, EdgeData)
     */
    public NodeGraph() {
        edges = new HashMap<>();
        redges = new MultiMap<>();
        linkedVars = new Clustering<>();
        edgesByVarID = new MultiMap<>();
    }

    /**
     * Add a node to the graph. It will not be connected to anything.
     * @param n the node to add
     * @see #addEdge(Node, Port, Node, Port, EdgeData)
     * @see #getNodes()
     */
    public void addNode(Node n) {
        if (!edges.containsKey(n)) {
            edges.put(n, new HashMap<Port, Edge>());
        }
    }

    /**
     * Remove a single node and all connected edges from the graph.
     * @param n the node to remove
     * @see #removeNodes(java.util.Collection)
     */
    public void removeNode(Node n) {
        removeNodes(Collections.singleton(n));
    }

    /**
     * Remove a collection of nodes from the graph. All edges connected
     * to these nodes are also removed.
     * @param toRemove the nodes to remove
     * @see #removeNode(Node)
     */
    public void removeNodes(Collection<Node> toRemove) {
        // Step 1: remove the edges out of this node
        Collection<Edge> edgesToRemove = new ArrayList<>();
        for (Node n : toRemove) {
            edgesToRemove.addAll(outgoingEdges(n));
            edgesToRemove.addAll(incomingEdges(n));
        }
        removeEdges(edgesToRemove);

        // Step 2: cleanup
        for (Node node : toRemove) {
            redges.remove(node);
            edges.remove(node);
        }
    }

    /**
     * Get all the nodes in this graph.
     * @return all the nodes
     * @see #addNode(Node)
     */
    public Collection<Node> getNodes() {
        return edges.keySet();
    }

    /**
     * Add an edge (if it wasn't already present). This will also add the
     * given nodes, if they are not already present.
     * @param src      the source node
     * @param srcPort  the port on the source node
     * @param dst      the target node
     * @param dstPort  the port on the target node
     * @param edgeData information about this edge
     * @return the edge that was added
     */
    public Edge addEdge(Node src, Port srcPort, Node dst, Port dstPort, EdgeData edgeData) {
        addNode(src);
        addNode(dst);
        Edge e = new Edge(src, srcPort, dst, dstPort, edgeData);
        edges.get(src).put(srcPort, e);
        redges.put(dst, e);
        if (edgeData.getVariableID() >= 0) {
            edgesByVarID.put(edgeData.getVariableID(), e);
        }
        return e;
    }

    /**
     * Remove an edge (if present).
     *
     * @param src      the source node
     * @param srcPort  the port on the source node
     * @param dst      the target node
     * @param dstPort  the port on the target node
     */
    public void removeEdge(Node src, Port srcPort, Node dst, Port dstPort) {
        Map<Port, Edge> dsts = edges.get(src);
        if (dsts == null)
            return;
        Edge e = dsts.get(srcPort);
        if (e != null && e.getDst().equals(dst) && e.getDstPort().equals(dstPort)) {
            dsts.remove(srcPort);
            edgesByVarID.remove(e.getVariableID(), e);
            redges.remove(dst, e);
        }
    }

    /**
     * Remove an edge (if present).
     * @param e the edge to remove
     */
    public void removeEdge(Edge e) {
        removeEdge(e.getSrc(), e.getSrcPort(), e.getDst(), e.getDstPort());
    }

    /**
     * Remove some edges (if present).
     * @param toRemove the edges to remove
     */
    public void removeEdges(Collection<Edge> toRemove) {
        for (Edge e : toRemove) {
            removeEdge(e);
        }
    }

    /**
     * Get all the edges in this graph.
     * @return all the edges in the graph
     */
    public Collection<Edge> getEdges() {
        // TODO: return a view, not a copy?
        Collection<Edge> edgesList = new ArrayList<>();
        for (Map.Entry<Node, Map<Port, Edge>> entry : edges.entrySet()) {
            for (Map.Entry<Port, Edge> entry2 : entry.getValue().entrySet()) {
                edgesList.add(entry2.getValue());
            }
        }
        return edgesList;
    }

    /**
     * Get all the edges linked to the given one. That is, all the edges that
     * must share the same width as the given one.
     * @param edge the edge
     * @return all the edges in the same edge set
     */
    public Set<Edge> edgeSet(Edge edge) {
        int varID = edge.getVariableID();
        if (varID < 0)
            return Collections.singleton(edge);
        Set<Integer> linked = linkedVars.getCluster(varID);
        Set<Edge> result = new HashSet<>();
        result.add(edge);
        for (int id : linked) {
            result.addAll(edgesByVarID.get(id));
        }
        return result;
    }

    /**
     * Determine whether two edges are linked (should always share the same
     * width). The edges do NOT need to be in this graph, only their var IDs
     * are considered.
     * @param e1 the first edge
     * @param e2 the second edge
     * @return true if e1 and e2 are linked
     */
    public boolean areLinked(Edge e1, Edge e2) {
        return e1.getVariableID() >= 0 &&
                e2.getVariableID() >= 0 &&
                edgeSet(e1).contains(e2);
    }

    /**
     * Determine whether two var IDs are linked.
     * @param varID1 the first var id
     * @param varID2 the second var id
     * @return true if varID1 and varID2 are linked
     */
    public boolean areLinked(int varID1, int varID2) {
        return varID1 >= 0 &&
                varID2 >= 0 &&
                linkedVars.getCluster(varID1).contains(varID2);
    }

    /**
     * Indicate that all the variables in the given collection should be
     * linked. See {@link verigames.level.World#linkByVarID(int, int)} for
     * more info.
     * @param varIDs a collection of var IDs to link
     */
    public void linkVarIDs(Collection<Integer> varIDs) {
        linkedVars.union(varIDs);
    }

    /**
     * Get all sets of linked var IDs containing more than 1 var ID
     * @return the sets of linked var IDs
     */
    public Collection<Set<Integer>> linkedVarIDs() {
        return linkedVars.getNontrivialClusters();
    }

    /**
     * Get all the nonnegative var IDs in this graph
     * @return the sets of nonnegative var IDs
     */
    public Set<Integer> nonnegativeVarIDs() {
        return edgesByVarID.keySet();
    }

    /**
     * Get the outgoing edges from a node
     * @param src the node
     * @return    the outgoing edges from the given node
     */
    public Collection<Edge> outgoingEdges(Node src) {
        final Map<Port, Edge> result = edges.get(src);
        return result == null ? Collections.<Edge>emptyList() : result.values();
    }

    /**
     * Get the incoming edges to a node
     * @param dst the node
     * @return    the incoming edges to the given node
     */
    public Collection<Edge> incomingEdges(Node dst) {
        return redges.get(dst);
    }

    /**
     * Get all the components of this graph. No edge in the graph
     * connects two different components, however, edges in different
     * components may be linked.
     * @return the disjoint components of the graph
     */
    public Collection<Subgraph> getComponents() {
        Clustering<Node> nodeClusters = new Clustering<>();
        for (Edge e : getEdges()) {
            nodeClusters.union(e.getSrc(), e.getDst());
        }

        Collection<Set<Node>> components = new ArrayList<>();
        components.addAll(nodeClusters.getNontrivialClusters());
        for (Node n : getNodes()) {
            Set<Node> cluster = nodeClusters.getCluster(n);
            if (cluster.size() == 1)
                components.add(cluster); // add trivial clusters
        }

        Collection<Subgraph> result = new ArrayList<>();
        for (Set<Node> nodes : components) {
            Subgraph g = new Subgraph();
            g.addNodes(nodes);
            for (Node n : nodes) {
                g.addEdges(incomingEdges(n));
                g.addEdges(outgoingEdges(n));
            }
            result.add(g);
        }

        return result;
    }

    /**
     * Remove all the geometry in a given subgraph.
     * @param subgraph the subgraph to remove
     */
    public void removeSubgraph(Subgraph subgraph) {
        removeEdges(subgraph.getEdges());
        removeNodes(subgraph.getNodes());
    }

}
