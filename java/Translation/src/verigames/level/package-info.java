/**
 * Provides data structures for programmatically creating levels for Pipe Jam.
 *
 * <h4>Expected Use:</h4>
 * The expected use follows. The following model for translation is suited for a
 * line-by-line translation fo the code into the game. However, if a different
 * translation strategy is used, this model may not be ideal, and others may be
 * considered. For example, it may make sense to remove the one-to-one relation
 * between {@code Board}s and Java methods.
 * <p>
 * A {@link verigames.level.World World} represents a single game for Pipe Jam.
 * No two Worlds can be dependent on each other; any two worlds can be solved in
 * isolation. A {@code World} represents, typically, one Java project. 
 * <p>
 * Each {@code World} contains an arbitrary number of {@link
 * verigames.level.Level Level}s. {@code Level}s can be dependent on one
 * another. Each level represents a class in a Java project.
 * <p>
 * Each {@code Level} contains an arbitrary number of {@link
 * verigames.level.Board}s.  {@code Board}s can be dependent both on other
 * {@code Board}s in the same {@code Level} and on {@code Board}s in other
 * {@code Level}s in the same {@code World}. A {@code Board} represents a
 * method. A {@code Board} is essentially a DAG with {@link
 * verigames.level.Chute Chute}s as edges and {@link
 * verigames.level.Intersection Intersection}s.
 * <p>
 * A {@code Chute}, loosely, represents a type. The term "loosely" is used
 * because a single {@code Chute} can represent the type for more than one
 * variable, and the type of a single variable is also typically represented as
 * more than just one {@code Chute}.
 * <p>
 * An {@code Intersection} is the terminating point for a {@code Chute}.
 * Typically, it is no more than that, though in the cases of {@link
 * verigames.level.Subboard Subboard} and {@link verigames.level.BallSizeTest
 * BallSizeTest}, more meaning is carried.
 * <p>
 * Every {@code Board} has two special {@code Intersection}s: The incoming one
 * and the outgoing one.
 * <p>
 * The incoming node should be connected to chutes representing the types of all
 * of the fields and all of the parameters.
 * <br/>
 * Likewise, the outgoing node should be the ending node for the chutes
 * representing the types of the fields and the return type.
 * <p>
 * Only chutes for the type of variables with scope extending outside of the
 * method should be attached to incoming and outgoing nodes. Chutes representing
 * the types of local variables should be started with a START_XXX_BALL node and
 * ended with an END node.
 * <p>
 * In order to fully express the constraints in the game, some chutes must
 * represent the same type. This means that if one of these chutes changes
 * width, all the others representing the same variable must too. To express
 * this information, a client should call the {@link
 * verigames.level.Level#makeLinked Level.makeLinked} method with these {@code
 * Chute}s.
 */

package verigames.level;
