package verigames.optimizer.model;

import verigames.optimizer.common.ManyToOne;

import java.util.ArrayList;
import java.util.Map;

/**
 * This class is used to track optimizations made to a world. It can be used
 * to convert a solution on an optimized world to a solution on the original
 * board.
 *
 * <p>Usage is somewhat complicated, unfortunately. The general idea is that
 * we are trying to map edge IDs from the original world to edge IDs in the
 * final world across two values: width and buzzsaws.
 *
 * <p>During world import, call {@link #initEdge(Integer, Edge)} for each
 * edge (or use the helper {@link #initAll(java.util.Map)}).
 *
 * <p>During optimization, call one of the following for every removed edge:
 * <ul>
 *     <li>{@link #mapEdge(NodeGraph, Edge, Edge)}</li>
 *     <li>{@link #forceWide(Edge)}</li>
 *     <li>{@link #forceNarrow(Edge)}</li>
 * </ul>
 * If none of the above are called, it means "this edge can take on any width
 * without causing conflicts." You will also want to call
 * {@link #mapBuzzsaw(Edge, Edge)} when appropriate to ensure that buzzsaws are
 * transferred correctly.
 *
 * <p>During world export, call {@link #finalizeEdge(Edge, Integer)} for each
 * edge (or use the helper {@link #finalizeAll(java.util.Map)}).
 *
 */
public class ReverseMapping {

    /**
     * Represents what a chute can map to. Either it maps to another chute
     * or it maps to a specific value.
     */
    public static interface Mapping {
        boolean value(Map<Integer, Boolean> edgeValues);
    }

    public static class EdgeMapping implements Mapping {
        private final int edgeID;
        public EdgeMapping(int edgeID) {
            this.edgeID = edgeID;
        }
        public int getEdgeID() {
            return edgeID;
        }
        @Override
        public boolean value(Map<Integer, Boolean> edgeValues) {
            Boolean narrow = edgeValues.get(edgeID);
            return narrow != null && narrow;
        }
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            EdgeMapping that = (EdgeMapping) o;
            return edgeID == that.edgeID;
        }
        @Override
        public int hashCode() {
            return edgeID;
        }
        @Override
        public String toString() {
            return "EdgeMapping(" + edgeID + ')';
        }
    }

    public static class ForcedMapping implements Mapping {
        private final boolean value;
        public ForcedMapping(boolean value) {
            this.value = value;
        }
        public boolean getValue() {
            return value;
        }
        @Override
        public boolean value(Map<Integer, Boolean> edgeValues) {
            return value;
        }
        @Override
        public int hashCode() {
            return value ? 1 : 0;
        }
        @Override
        public boolean equals(Object o) {
            return o != null &&
                    o.getClass().equals(getClass()) &&
                    value == ((ForcedMapping)o).value;
        }
        @Override
        public String toString() {
            return "ForcedMapping(" + value + ')';
        }
    }

    public static class DanglingMapping implements Mapping {
        private final Edge edge;
        private DanglingMapping(Edge edge) {
            this.edge = edge;
        }
        @Override
        public boolean value(Map<Integer, Boolean> edgeValues) {
            return false;
        }
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            DanglingMapping that = (DanglingMapping) o;
            return edge.equals(that.edge);
        }
        @Override
        public int hashCode() {
            return edge.hashCode();
        }
        @Override
        public String toString() {
            return "DanglingMapping(" + edge + ')';
        }
    }

    protected static final Mapping TRUE = new ForcedMapping(true);
    protected static final Mapping FALSE = new ForcedMapping(false);

    /**
     * Width mappings for each chute. {@link Mapping#value(java.util.Map)} means "is narrow".
     */
    private final ManyToOne<Integer, Mapping> widthMappings;

    /**
     * Buzzsaw mappings for each chute. {@link Mapping#value(java.util.Map)} means "has buzzsaw".
     */
    private final ManyToOne<Integer, Mapping> buzzsawMappings;

    public ReverseMapping() {
        widthMappings = new ManyToOne<>();
        buzzsawMappings = new ManyToOne<>();
    }

    public void putWidthMapping(Integer edgeID, Mapping m) {
        widthMappings.put(edgeID, m);
    }

    public void putBuzzsawMapping(Integer edgeID, Mapping m) {
        buzzsawMappings.put(edgeID, m);
    }

    public void initEdge(Integer edgeID, Edge e) {
        Mapping m = new DanglingMapping(e);
        if (e.isEditable())
            widthMappings.put(edgeID, m);
        buzzsawMappings.put(edgeID, m);
    }

    public void initAll(Map<Integer,Edge> edgeIDMapping) {
        for (Map.Entry<Integer, Edge> e : edgeIDMapping.entrySet()) {
            initEdge(e.getKey(), e.getValue());
        }
    }

    public void finalizeEdge(Edge e, Integer newID) {
        DanglingMapping old = new DanglingMapping(e);
        Mapping m = new EdgeMapping(newID);
        updateMapping(widthMappings, old, m);
        updateMapping(buzzsawMappings, old, m);
    }

    public void finalizeAll(Map<Edge, Integer> edgeIDMapping) {
        for (Map.Entry<Edge, Integer> e : edgeIDMapping.entrySet()) {
            finalizeEdge(e.getKey(), e.getValue());
        }
    }

    /**
     * Indicate that the given edge in the unoptimized world should assume the
     * value of the given edge in the optimized world once a solution is
     * obtained. Has no effect if the unoptimized argument is immutable.
     * @param g            the graph being optimized
     *                     (does not need to contain the given edges)
     * @param unoptimized  the edge in the unoptimized world
     * @param optimized    the edge in the optimized world
     */
    public void mapEdge(NodeGraph g, Edge unoptimized, Edge optimized) {
        // immutable edges can't map to anything
        if (!unoptimized.isEditable())
            return;
        // by default, edges in the same edge set will do the right thing
        if (g.areLinked(unoptimized, optimized))
            return;
        DanglingMapping old = new DanglingMapping(unoptimized);
        Mapping m = new DanglingMapping(optimized);
        updateMapping(widthMappings, old, m);
    }

    /**
     * Indicate that the given edge in the unoptimized world should have a
     * buzzsaw if and only if the given edge in the optimized world has one.
     * @param unoptimized  the edge in the unoptimized world
     * @param optimized    the edge in the optimized world
     */
    public void mapBuzzsaw(Edge unoptimized, Edge optimized) {
        updateMapping(buzzsawMappings, new DanglingMapping(unoptimized), new DanglingMapping(optimized));
    }

    /**
     * The given chute must be made wide in the solution.
     * Has no effect if the unoptimized argument is immutable.
     *
     * <p>NOTE: either the given chute must not be linked to any
     * other edges, or you must forceWide all the edges in its
     * edge set.
     * @param unoptimized a chute in the unoptimized world
     */
    public void forceWide(Edge unoptimized) {
        forceNarrow(unoptimized, false);
    }

    /**
     * The given chute must be made narrow in the solution.
     * Has no effect if the unoptimized argument is immutable.
     *
     * <p>NOTE: either the given chute must not be linked to any
     * other edges, or you must forceNarrow all the edges in its
     * edge set.
     * @param unoptimized a chute in the unoptimized world
     */
    public void forceNarrow(Edge unoptimized) {
        forceNarrow(unoptimized, true);
    }

    /**
     * Force the given chute to be narrow or wide in the solution.
     * Has no effect if the unoptimized argument is immutable.
     *
     * <p>NOTE: either the given chute must not be linked to any
     * other edges, or you must forceNarrow all the edges in its
     * edge set to the same value.
     * @param unoptimized a chute in the unoptimized world
     * @param narrow      true to force to narrow, false to force
     *                    to wide
     */
    public void forceNarrow(Edge unoptimized, boolean narrow) {
        // immutable edges can't map to anything
        if (!unoptimized.isEditable())
            return;
        updateMapping(widthMappings, new DanglingMapping(unoptimized), narrow ? TRUE : FALSE);
    }

    protected void updateMapping(ManyToOne<Integer, Mapping> mapping, DanglingMapping old, Mapping m) {
        for (Integer i : new ArrayList<>(mapping.inverse().get(old))) {
            mapping.put(i, m);
        }
    }

    public Map<Integer, Mapping> getWidthMappings() {
        return widthMappings.asMap();
    }

    public Map<Integer, Mapping> getBuzzsawMappings() {
        return buzzsawMappings.asMap();
    }

    public boolean isNarrow(int unoptimizedEdgeID, Map<Integer, Boolean> optimizedEdgeNarrow) {
        Mapping m = widthMappings.get(unoptimizedEdgeID);
        return m != null && m.value(optimizedEdgeNarrow);
    }

    public boolean hasBuzzsaw(int unoptimizedEdgeID, Map<Integer, Boolean> optimizedEdgeBuzzsaws) {
        Mapping m = buzzsawMappings.get(unoptimizedEdgeID);
        return m != null && m.value(optimizedEdgeBuzzsaws);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ReverseMapping that = (ReverseMapping) o;
        if (!buzzsawMappings.equals(that.buzzsawMappings)) return false;
        if (!widthMappings.equals(that.widthMappings)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = widthMappings.hashCode();
        result = 31 * result + buzzsawMappings.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "ReverseMapping{" +
                "widthMappings=" + widthMappings +
                ", buzzsawMappings=" + buzzsawMappings +
                '}';
    }

}
