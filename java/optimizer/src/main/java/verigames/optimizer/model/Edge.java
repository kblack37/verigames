package verigames.optimizer.model;

/**
 * An edge in a {@link NodeGraph}.
 */
public class Edge {

    private final Node src;
    private final Port srcPort;
    private final Node dst;
    private final Port dstPort;
    private final EdgeData data;

    public Edge(Node src, Port srcPort, Node dst, Port dstPort, EdgeData data) {
        this.src = src;
        this.srcPort = srcPort;
        this.dst = dst;
        this.dstPort = dstPort;
        this.data = data;
    }

    public Node getSrc() {
        return src;
    }

    public Port getSrcPort() {
        return srcPort;
    }

    public Node getDst() {
        return dst;
    }

    public Port getDstPort() {
        return dstPort;
    }

    public EdgeData getEdgeData() {
        return data;
    }

    public int getVariableID() {
        return data.getVariableID();
    }

    public String getDescription() {
        return data.getDescription();
    }

    public boolean isNarrow() {
        return data.isNarrow();
    }

    public boolean isEditable() {
        return data.isEditable();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Edge edge = (Edge) o;
        if (!data.equals(edge.data)) return false;
        if (!dst.equals(edge.dst)) return false;
        if (!dstPort.equals(edge.dstPort)) return false;
        if (!src.equals(edge.src)) return false;
        if (!srcPort.equals(edge.srcPort)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = src.hashCode();
        result = 31 * result + srcPort.hashCode();
        result = 31 * result + dst.hashCode();
        result = 31 * result + dstPort.hashCode();
        result = 31 * result + data.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "Edge(" + getSrc()
                + " -> "+ getDst()
                + ", " + getEdgeData() + ")";
    }

}
