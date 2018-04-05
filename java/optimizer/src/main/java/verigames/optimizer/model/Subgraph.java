package verigames.optimizer.model;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

public class Subgraph {

    private final Set<Node> nodes;
    private final Set<Edge> edges;

    public Subgraph() {
        this.nodes = new HashSet<>();
        this.edges = new HashSet<>();
    }

    public Set<Node> getNodes() {
        return nodes;
    }

    public Set<Edge> getEdges() {
        return edges;
    }

    public void addNode(Node node) {
        nodes.add(node);
    }

    public void addNodes(Collection<Node> ns) {
        nodes.addAll(ns);
    }

    public void addEdge(Edge edge) {
        edges.add(edge);
    }

    public void addEdges(Collection<Edge> es) {
        edges.addAll(es);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Subgraph subgraph = (Subgraph) o;
        if (!edges.equals(subgraph.edges)) return false;
        if (!nodes.equals(subgraph.nodes)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = nodes.hashCode();
        result = 31 * result + edges.hashCode();
        return result;
    }

}
