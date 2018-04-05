package verigames.optimizer;

import verigames.level.Chute;
import verigames.level.Intersection;
import verigames.optimizer.model.Edge;
import verigames.optimizer.model.Node;
import verigames.optimizer.model.NodeGraph;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class Util {

    /////////// Config
    private static boolean verbose = false;

    /**
     * Pick out the first element from a collection. On unordered collections
     * like HashSets, the result might be any element.
     * @param collection  the collection to pick from
     * @param <T>         the type of element in the collection
     * @throws java.util.NoSuchElementException if the collection is empty
     * @return            the first element of the collection
     */
    public static <T> T first(Iterable<T> collection) {
        return collection.iterator().next();
    }

    /**
     * Enable or disable the output of {@link #logVerbose(Object)}
     * @param v true to enable verbose logging, false to disable
     */
    public static void setVerbose(boolean v) {
        verbose = v;
    }

    /**
     * Log a message, but only if verbose mode is enabled
     * @param o the object to log
     * @see #setVerbose(boolean)
     */
    public static void logVerbose(Object o) {
        if (verbose)
            System.err.println(o);
    }

    public static Chute immutableChute() {
        Chute result = new Chute();
        result.setEditable(false);
        return result;
    }

    public static Chute mutableChute() {
        Chute result = new Chute();
        result.setEditable(true);
        return result;
    }

    /**
     * Determine if an edge is "conflict free" meaning that it cannot
     * contribute a conflict to the board. Specifically, an edge is
     * conflict free if it either (1) is immutable and wide or (2) is
     * mutable and the only member of its edge set. An edge is NOT
     * conflict free if it controls a pipe dependent ball.
     *
     * <p>In particular, if you have a {@link verigames.optimizer.model.ReverseMapping}
     * and this function returns true for a chute, then it is always
     * safe to call {@link verigames.optimizer.model.ReverseMapping#forceNarrow(verigames.optimizer.model.Edge)}
     * or {@link verigames.optimizer.model.ReverseMapping#forceWide(verigames.optimizer.model.Edge)}
     * on the given chute.
     * @param g the graph containing the edge
     * @param e the edge to consider
     * @return true if the edge is conflict free, or false otherwise
     */
    public static boolean conflictFree(NodeGraph g, Edge e) {
        return (e.getSrc().getKind() != Intersection.Kind.START_PIPE_DEPENDENT_BALL) &&
                ((!e.isEditable() && !e.isNarrow()) ||
                 (e.isEditable() && g.edgeSet(e).size() <= 1));
    }

    /**
     * Determine if a chute is forced to be narrow
     * @param chute the chute to check
     * @return true if the chute is pinched or immutable narrow
     */
    public static boolean forcedNarrow(Edge chute) {
        return chute.isNarrow() && !chute.isEditable();
    }

    /**
     * Create a new node on the same board as "n". Note that this method does
     * NOT add the new node to any {@link NodeGraph} "n" belongs to.
     * @param n the node
     * @param kind any kind except {@link verigames.level.Intersection.Kind#SUBBOARD}.
     * @return a new node
     */
    public static Node newNodeOnSameBoard(Node n, Intersection.Kind kind) {
        String levelName = n.getLevelName();
        String boardName = n.getBoardName();
        return new Node(levelName, boardName, kind);
    }

    /**
     * Get an input stream for the given filename. If filename is "-", then stdin is used.
     * @param filename the filename to load
     * @return the stream
     * @throws FileNotFoundException if the input file could not be read from
     */
    public static InputStream getInputStream(String filename) throws FileNotFoundException {
        return filename.equals("-") ? System.in : new FileInputStream(filename);
    }

    /**
     * Get an output stream for the given filename. If filename is "-", then stdout is used.
     * @param filename the filename to load
     * @return the stream
     * @throws FileNotFoundException if the output file could not be written to
     */
    public static OutputStream getOutputStream(String filename) throws FileNotFoundException {
        return filename.equals("-") ? System.out : new FileOutputStream(filename);
    }
}
