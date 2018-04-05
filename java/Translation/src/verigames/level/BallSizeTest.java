package verigames.level;

import java.util.*;

/*>>>
import checkers.nullness.quals.*;
*/

// TODO check if there is cleanup needed here after the deprecated int port
// removal

/**
 * An {@link Intersection} subclass that represents {@link
 * Intersection.Kind#BALL_SIZE_TEST BALL_SIZE_TEST} {@link Intersection.Kind
 * Kind}s of {@code Intersection}.<br/>
 * <br/>
 * The output chute in port "small" represents the "small ball" branch of this
 * test<br/>
 * <br/>
 * The output chute in port "large" represents the "big ball" branch of this
 * test<br/>
 *
 * @author Nathaniel Mote
 */

public class BallSizeTest extends Intersection
{
  /*
   * Representation Invariant (in addition to the superclass rep invariant):
   *
   * The output chute in port "small" is the "small ball" chute and must be
   * uneditable and narrow
   *
   * The output chute in port "large" is the "big ball" chute and must be
   * uneditable and wide
   */

  public static final String SMALL_PORT = "small";
  public static final String LARGE_PORT = "large";

  private static final boolean CHECK_REP_ENABLED =
      verigames.utilities.Misc.CHECK_REP_ENABLED;

  /**
   * Checks that the representation invariant holds
   */
  @Override
  protected void checkRep()
  {
    super.checkRep();

    if (!CHECK_REP_ENABLED)
      return;

    Chute nonNullChute = getNarrowChute();
    if (nonNullChute != null
        && (nonNullChute.isEditable() || !nonNullChute.isNarrow()))
      throw new RuntimeException(
          "BallSizeTest's NonNull chute does not have the proper settings");

    Chute nullChute = getWideChute();
    if (nullChute != null && (nullChute.isEditable() || nullChute.isNarrow()))
      throw new RuntimeException(
          "BallSizeTest's Null chute does not have the proper settings");

  }

  /**
   * Creates a new {@link Intersection} of {@link Intersection.Kind Kind} {@link
   * Intersection.Kind#BALL_SIZE_TEST BALL_SIZE_TEST}
   */
  protected BallSizeTest()
  {
    super(Kind.BALL_SIZE_TEST);
    checkRep();
  }

  BallSizeTest(int id)
  {
    super(id, Kind.BALL_SIZE_TEST);
    checkRep();
  }

  /**
   * Returns {@code true} iff {@code kind} is {@link
   * Intersection.Kind#BALL_SIZE_TEST BALL_SIZE_TEST}, indicating that this
   * implementation supports only {@code BALL_SIZE_TEST}.
   *
   * @param kind
   */
  @Override
  protected boolean checkIntersectionKind(/*>>> @Raw BallSizeTest this,*/ Kind kind)
  {
    // this implementation supports only BALL_SIZE_TEST
    return kind == Kind.BALL_SIZE_TEST;
  }

  /**
   * Returns {@code true} to indicate that {@code this} is a {@code
   * BallSizeTest}.
   */
  @Override
  public boolean isBallSizeTest()
  {
    return true;
  }

  /**
   * Returns {@code this}
   */
  @Override
  public BallSizeTest asBallSizeTest()
  {
    return this;
  }

  /**
   * Returns the {@link Chute} (or {@code null} if none exists) associated with
   * the null branch of this test. That is, in the game, after reaching this
   * {@link Intersection}, only "null balls" will roll down the returned
   * {@link Chute}.
   */
  public /*@Nullable*/ Chute getWideChute()
  {
    return getOutput(LARGE_PORT);
  }

  /**
   * Sets {@code chute} to the null branch<br/>
   * <br/>
   * Requires:<br/>
   * - {@link Chute#isEditable() !chute.isEditable()}<br/>
   * - {@link Chute#isNarrow() !chute.isNarrow()}<br/>
   * <br/>
   * Modifies: {@code this}<br/>
   * @param chute
   */
  protected void setWideChute(Chute chute)
  {
    if (chute.isEditable())
      throw new IllegalArgumentException(
          "Chute passed to setNullChute must not be editable");
    if (chute.isNarrow())
      throw new IllegalArgumentException(
          "Chute passed to setNullChute must not be narrow");
    super.setOutput(chute, LARGE_PORT);
    checkRep();
  }

  /**
   * Returns the {@link Chute} (or {@code null} if none exists) associated with
   * the not-null branch of this test. That is, in the game, after reaching
   * this {@link Intersection}, only "non-null balls" will roll down the
   * returned {@link Chute}.
   */
  public /*@Nullable*/ Chute getNarrowChute()
  {
    return getOutput(SMALL_PORT);
  }

  /**
   * Sets {@code chute} to the not-null branch<br/>
   * <br/>
   * Requires:<br/>
   * - {@link Chute#isEditable() !chute.isEditable()}<br/>
   * - {@link Chute#isNarrow() chute.isNarrow()}<br/>
   * <br/>
   * Modifies: {@code this}<br/>
   * @param chute
   */
  protected void setNarrowChute(Chute chute)
  {
    if (chute.isEditable())
      throw new IllegalArgumentException(
          "Chute passed to setNarrowChute must not be editable");
    if (!chute.isNarrow())
      throw new IllegalArgumentException(
          "Chute passed to setNarrowChute must be narrow");

    super.setOutput(chute, SMALL_PORT);
    checkRep();
  }

  /**
   * {@inheritDoc}
   *
   * @param port
   * The output port to which {@code output} will be attached. Must be "small"
   * or "large".<p>
   *
   * Deprecated support still exists for old port numbers, so "0" instead of
   * "small" and "1" instead of "large" can be used. However, support for this
   * is transitional and will be removed soon.
   *
   * @param output
   * The chute to attach.<br/>
   * Requires:<br/>
   * - {@link Chute#isEditable() !output.isEditable()}<br/>
   * - if {@code port} is "small": {@link Chute#isNarrow()
   *   output.isNarrow()}<br/>
   * - if {@code port} is "large": {@link Chute#isNarrow()
   *   !output.isNarrow()}<br/>
   */
  @Override
  protected void setOutput(Chute output, String port)
  {
    if (port.equals(SMALL_PORT))
      setNarrowChute(output);
    else if (port.equals(LARGE_PORT))
      setWideChute(output);
    else
      throw new IllegalArgumentException("port " + port
          + " illegal for BallSizeTest node");
  }

  @Override
  public List<String> getOutputIDs()
  {
    List<String> unorderedPortsList = super.getOutputIDs();
    List<String> portsList = new ArrayList<String>();

    // Check if the list of port IDs contains each possible port ID, then add
    // them in the proper order (the first output port is implicitly the small
    // one, the second the large).

    if (unorderedPortsList.contains(SMALL_PORT))
      portsList.add(SMALL_PORT);

    if (unorderedPortsList.contains(LARGE_PORT))
      portsList.add(LARGE_PORT);

    return Collections.unmodifiableList(portsList);
  }
}
