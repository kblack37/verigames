package verigames.level;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static verigames.utilities.Misc.ensure;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An intersection between {@link Chute}s. Mutable until construction is
 * finished.
 * <p>
 * Uses eternal equality so that it can be used in {@code Collection}s while
 * maintaining mutability.
 * <p>
 * Most {@code Intersection}s simply serve to connect different {@code Chute}s,
 * indicating a relationship between the types that the {@code Chute}s
 * represent. However, some special {@code Intersection}s exist:
 * <ul>
 * <li>
 * INCOMING: An INCOMING node is at the top of every {@link Board}. It serves as
 * the starting point for the topmost {@code Chute}s in the {@code Board} that
 * represent the types for fields and method parameters.
 * </li>
 * <li>
 * OUTGOING: An OUTGOING node is at the bottom of every {@code Board}. It serves
 * as the ending point for the bottommost {@code Chute}s in the {@code Board}
 * that represent the types for fields and return values.
 * </li>
 * <li>
 * SUBBOARD: A SUBBOARD node represents a method call. It is essentially a
 * {@code Board} embedded within another {@code Board}.
 * </li>
 * <li>
 * BALL_SIZE_TEST: A BALL_SIZE_TEST ndoe represents an if statement conditional
 * on the nullness type of a variable. On one side of the branch, the variable
 * is considered Nullable, and on the other, it is considered NonNull.
 * </li>
 * START_XXX_BALL and END: These are used to start and end chutes for the types
 * of local variables. Local variables don't persist outside of the methods in
 * which they are contained, so their chutes do not connect to the INCOMING and
 * OUTGOING nodes. START_NO_BALL is used when a type exists, but nothing about
 * it is known.
 * </li>
 * </ul>
 * <p>
 * Specification Field: {@code kind} : {@link Intersection.Kind}
 * // represents which kind of {@code Intersection} {@code this} is.
 * <p>
 * Specification Field: Layout Coordinate : (x: real, y:real) // The coordinates
 * at which {@code this} will be located when its containing {@link Board} is
 * laid out to be played. These layout coordinates are in game units. The origin
 * is at the top-left, y coordinates grow downard, and the coordinates represent
 * the top-left point of the intersections.
 * <p>
 * Specification Field: {@code UID} : integer // the unique identifier for this
 * {@code Intersection}.
 *
 * @author Nathaniel Mote
 */

public class Intersection extends verigames.graph.Node<Chute>
{
  /**
   * Specifies different kinds of {@code Intersection}s. Different kinds of
   * {@code Intersection}s are used for different purposes in a
   * {@link verigames.level.Board Board}.
   */
  public static enum Kind
  {
    /** The node used for Map.get */
    GET(4,1),
    /** The start point of chutes that enter the board on the top */
    INCOMING(0, -1),
    /** The end point of chutes that exit the board on the bottom */
    OUTGOING(-1, 0),
    /** An intersection in which a chute is split into two chutes */
    SPLIT(1, 2),
    /** An intersection where two chutes merge into one */
    MERGE(2, 1),
    /** Simply connects one chute to another */
    CONNECT(1, 1),
    /** Represents a split due to testing for null */
    BALL_SIZE_TEST(1, 2),
    /** Represents a white (not null) ball being dropped into the top a chute.
     */
    START_SMALL_BALL(0, 1),
    /** Represents a black (null) ball being dropped into the top of a chute. */
    START_LARGE_BALL(0, 1),
    /**A node that represents a start ball that changes size depending on the
     * width of the chute below it */
    START_PIPE_DEPENDENT_BALL(0,1),
    /** Represents a chute with no ball dropping into it */
    START_NO_BALL(0, 1),
    /** Terminate a chute */
    END(1, 0),
    /** Represents a method call */
    SUBBOARD(-1, -1);

    /**
     * The number of input ports that an {@link Intersection} of this {@code
     * Kind} must have. {@code -1} if there is no restriction.
     */
    private final int numInputPorts;
    /**
     * The number of output ports that an {@link Intersection} of this {@code
     * Kind} must have. {@code -1} if there is no restriction.
     */
    private final int numOutputPorts;

    /**
     * Constructs a new {@code Kind} enum object.
     *
     * @param numInputPorts
     * The number of input ports that an {@link Intersection} of this {@code
     * Kind} must have. {@code -1} if there is no restriction.
     *
     * @param numOutputPorts
     * The number of output ports that an {@link Intersection} of this {@code
     * Kind} must have. {@code -1} if there is no restriction.
     */
    private Kind(int numInputPorts, int numOutputPorts)
    {
      this.numInputPorts = numInputPorts;
      this.numOutputPorts = numOutputPorts;
    }

    /**
     * Returns the number of input ports that an {@link Intersection} of this
     * {@code Kind} must have, or {@code -1} if there is no restriction.
     */
    public int getNumberOfInputPorts()
    {
      return this.numInputPorts;
    }

    /**
     * Returns the number of output ports that an {@link Intersection} of this
     * {@code Kind} must have, or {@code -1} if there is no restriction.
     */
    public int getNumberOfOutputPorts()
    {
      return this.numOutputPorts;
    }
  };

  private static final boolean CHECK_REP_ENABLED = verigames.utilities.Misc.CHECK_REP_ENABLED;

  private final Kind intersectionKind;

  private double x = -1d;
  private double y = -1d;

  private final int UID;

  private static int nextUID = 0;

  /*
   * Representation Invariant:
   *
   * When underConstruction, both the highest port number plus one and the number of used
   * input/output ports can be no greater than the value returned by
   * getNumberOfInputPorts() and getNumberOfOutputPorts().
   *
   * When constructed, both the highest port number plus one and the number of
   * used input/output ports must be exactly equal to the value returned by
   * getNumberOf____Ports(),
   */

  /**
   * checks that the rep invariant holds
   */
  @Override protected void checkRep()
  {
    super.checkRep();

    if (!CHECK_REP_ENABLED)
      return;

    // The total number of ports that this Kind of Intersection can have
    int numRequiredInPorts = intersectionKind.getNumberOfInputPorts();
    int numRequiredOutPorts = intersectionKind.getNumberOfOutputPorts();

    List<String> inputPorts = getInputIDs();
    List<String> outputPorts = getOutputIDs();

    int usedInPorts = inputPorts.size();
    int usedOutPorts = outputPorts.size();

    if (underConstruction())
    {
      /*
       * Ensures that the number of used input/output ports is no greater than
       * the value returned by getNumberOfInputPorts() and
       * getNumberOfOutputPorts().
       */

      if (numRequiredInPorts != -1)
        ensure(usedInPorts <= numRequiredInPorts,
            "Too many input ports used for a(n) " + intersectionKind +
            " Intersection");

      if (numRequiredOutPorts != -1)
        ensure(usedOutPorts <= numRequiredOutPorts,
            "Too many output ports used for a(n) " + intersectionKind +
            " Intersection");
    }
    else
    {
      // Because construction is finished, all ports must be filled.

      if (numRequiredInPorts != -1)
        ensure(usedInPorts == numRequiredInPorts, "Intersection: " + this +
            " usedInPorts: " + usedInPorts + " numRequiredInPorts: " +
            numRequiredInPorts);

      if (numRequiredOutPorts != -1)
        ensure(usedOutPorts == numRequiredOutPorts, "Intersection: " + this +
            " usedOutPorts: " + usedOutPorts + " numRequiredOutPorts: " +
            numRequiredOutPorts);
    }
  }

  /**
   * Returns an {@code Intersection} of the {@link Intersection.Kind Kind}
   * {@code kind}<br/>
   * <br/>
   * Requires: {@code kind !=} {@link Kind#SUBBOARD SUBNETWORK} (use
   * {@link #subboardFactory(java.lang.String) subnetworkFactory})
   *
   * @param kind
   */
  public static Intersection factory(Kind kind)
  {
    if (kind == Kind.SUBBOARD)
      throw new IllegalArgumentException(
          "intersectionFactory passed Kind.SUBBOARD. Use subboardFactory instead.");
    else if (kind == Kind.BALL_SIZE_TEST)
      return new BallSizeTest();
    else
      return new Intersection(kind);
  }

  /**
   * Dangerous package-level factory method that lets you specify the ID.
   */
  static Intersection factory(int id, Kind kind)
  {
    if (kind == Kind.SUBBOARD)
      throw new IllegalArgumentException(
          "intersectionFactory passed Kind.SUBBOARD. Use subboardFactory instead.");
    else if (kind == Kind.BALL_SIZE_TEST)
      return new BallSizeTest(id);
    else
      return new Intersection(id, kind);
  }

  /**
   * Returns a {@link Subboard} representing a method with {@code methodName}
   *
   * @param methodName
   */
  public static Subboard subboardFactory(String methodName)
  {
    return new Subboard(methodName);
  }

  /**
   * Dangerous package-level factory method that lets you specify the ID.
   */
  static Subboard subboardFactory(int id, String methodName)
  {
    return new Subboard(id, methodName);
  }

  /**
   * Creates a new {@code Intersection} of the given {@code Kind} with empty
   * input and output ports<br/>
   * <br/>
   * Requires:<br/>
   * - {@code checkIntersectionKind(kind)}<br/>
   * <br/>
   * Subclasses calling this constructor override
   * {@link #checkIntersectionKind(Kind)} to change the restrictions on what
   * {@link Intersection.Kind Kind}s can be used.
   *
   * @param kind
   * The kind of {@code Intersection} to create
   *
   */
  protected Intersection(Kind kind)
  {
    this(nextUID++, kind);
  }

  /**
   * Dangerous package-level constructor that lets you specify the ID manually.
   * @param id   the id of this intersection
   * @param kind the kind of this intersection
   */
  Intersection(int id, Kind kind)
  {
    if (!checkIntersectionKind(kind)) // if kind is not a valid Kind for this
      // implementation of Intersection
      throw new IllegalArgumentException("Invalid Intersection Kind " + kind
          + " for this implementation");
    this.UID = id;
    this.intersectionKind = kind;
    checkRep();
  }

  /**
   * Returns true iff {@code kind} is valid for this implementation of
   * {@code Intersection}.<br/>
   * <br/>
   * This implementation supports all {@link Intersection.Kind Kind}s except
   * {@link Kind#SUBBOARD SUBNETWORK} and {@link Kind#BALL_SIZE_TEST
   * BALL_SIZE_TEST}
   *
   * @param kind
   */
  protected boolean checkIntersectionKind(/*>>> @Raw Intersection this,*/ Kind kind)
  {
    // this implementation supports every Intersection kind except for
    // SUBBOARD and BALL_SIZE_TEST
    return kind != Kind.SUBBOARD && kind != Kind.BALL_SIZE_TEST;
  }

  /**
   * Returns {@code intersectionKind}
   */
  public Kind getIntersectionKind()
  {
    return intersectionKind;
  }

  /**
   * Returns a {@code List<String>} containing all of the input port IDs for
   * this {@code Intersection}.<p>
   *
   * Returns the port IDs in the order in which they should appear in XML. This
   * is typically alphabetical order, but is not always.
   */
  @Override
  public List<String> getInputIDs()
  {
    List<String> portsList = new ArrayList<String>(super.getInputIDs());
    Collections.sort(portsList);
    return Collections.unmodifiableList(portsList);
  }

  /**
   * Returns a {@code List<String>} containing all of the output port IDs for
   * this {@code Intersection}.<p>
   *
   * Returns the port IDs in the order in which they should appear in XML. This
   * is typically alphabetical order, but is not always.<p>
   *
   * In particular, the {@link BallSizeTest} subclass implements a different
   * order for output port IDs
   */
  @Override
  public List<String> getOutputIDs()
  {
    List<String> portsList = new ArrayList<String>(super.getOutputIDs());
    Collections.sort(portsList);
    return Collections.unmodifiableList(portsList);
  }

  /**
   * Sets the x coordinate that {@code this} is to appear at to {@code x}.
   *
   * @param x
   * Must be nonnegative
   */
  public void setX(double x)
  {
    if (x < 0)
      throw new IllegalArgumentException("x value of " + x + " illegal -- must be nonnegative");
    this.x = x;
  }

  /**
   * Returns the x coordinate that {@code this} is to appear at, or -1 if none
   * has been set.
   */
  public double getX()
  {
    return x;
  }

  /**
   * Sets the y coordinate that {@code this} is to appear at to {@code y}.
   *
   * @param y
   * Must be nonnegative
   */
  public void setY(double y)
  {
    if (y < 0)
      throw new IllegalArgumentException("y value of " + y + " illegal -- must be nonnegative");
    this.y = y;
  }

  /**
   * Returns the y coordinate that {@code this} is to appear at, or -1 if none
   * has been set.
   */
  public double getY()
  {
    return y;
  }

  /**
   * Returns {@code true} iff {@code this} is a {@link Subboard}.
   */
  public boolean isSubboard()
  {
    return false;
  }

  /**
   * Returns {@code this} as a {@link Subboard}<br/>
   * <br/>
   * Requires: {@link #isSubboard()}
   */
  public Subboard asSubboard()
  {
    // Is this the right exception to throw?
    throw new IllegalStateException(
        "asSubboard called on an Intersection not of Subboard kind");
  }

  /**
   * Returns {@code true} iff this is a {@link BallSizeTest}
   */
  public boolean isBallSizeTest()
  {
    return false;
  }

  /**
   * Returns {@code this} as a {@link BallSizeTest}<br/>
   * <br/>
   * Requires: {@link #isBallSizeTest()}
   */
  public BallSizeTest asBallSizeTest()
  {
    throw new IllegalStateException(
        "asBallSizeTest called on an Intersection not of BallSizeTest kind");
  }

  /**
   * Returns {@code UID}
   */
  public int getUID()
  {
    return UID;
  }

  @Override
  protected String shallowToString()
  {
    return getIntersectionKind().toString() + "#" + getUID();
  }

  /** Every intersection can be assigned to a board.
   * Null until it is assigned to a board.
   */
  private /*@LazyNonNull*/ Board board;

  /**
   * Sets the {@link Board} that {@code this} is in. Cannot be changed once
   * construction is finished.
   *
   * @see verigames.graph.Node#underConstruction()
   * @see verigames.graph.Node#finishConstruction()
   */
  public void setBoard(Board p) {
    if (!this.underConstruction())
      throw new IllegalStateException(
          "Mutation attempted on a constructed Intersection");
    board = p;
  }

  public /*@Nullable*/ Board getBoard() {
    return board;
  }

  /* These are overridden to facilitate testing. Overriding gives the tests
   * (which are in this package) access to these protected methods that would
   * otherwise be members of the superclass, and thus inaccessible. */
  @Override
  protected void setOutput(Chute output, String port)
  {
    super.setOutput(output, port);
  }

  @Override
  protected void setInput(Chute input, String port)
  {
    super.setInput(input, port);
  }

  @Override
  protected void finishConstruction()
  {
    super.finishConstruction();
  }
}
