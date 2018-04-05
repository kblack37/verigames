package verigames.level;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An {@link Intersection} subclass that represents a
 * {@link Intersection.Kind#SUBBOARD SUBNETWORK}. Because {@code SUBNETWORK}s
 * represent more information than other {@code Intersection}s, they are
 * implemented separately.<br/>
 * <br/>
 * Specification Field: {@code subnetworkName}: {@code String}
 * // The name of the method to which {@code this} represents a call.<br/>
 *
 * @author Nathaniel Mote
 */

public class Subboard extends Intersection
{
  private final String subnetworkName;

  /**
   * Creates a new {@link Intersection} with {@link Intersection.Kind Kind}
   * {@link Intersection.Kind#SUBBOARD SUBNETWORK}.<br/>
   * <br/>
   * {@code this} represents a call to the method with name {@code methodName}.
   * @param methodName
   * The name of the method to which {@code this} refers.
   */
  protected Subboard(String methodName)
  {
    super(Kind.SUBBOARD);
    subnetworkName = methodName;
  }

  Subboard(int id, String methodName)
  {
    super(id, Kind.SUBBOARD);
    subnetworkName = methodName;
  }

    /**
   * Returns {@code true} iff {@code kind} is
   * {@link Intersection.Kind#SUBBOARD SUBNETWORK}, indicating that this
   * implementation supports only {@code SUBNETWORK}s<br/>
   *
   * @param kind
   */
  @Override protected boolean checkIntersectionKind(/*>>> @Raw Subboard this,*/ Kind kind)
  {
    // This implementation supports only the SUBNETWORK kind
    return kind == Kind.SUBBOARD;
  }

  /**
   * Returns {@code true} to indicate that {@code this} is a
   * {@link Intersection.Kind#SUBBOARD SUBNETWORK}.
   */
  @Override public boolean isSubboard()
  {
    return true;
  }

  /**
   * Returns {@code this}
   */
  @Override public Subboard asSubboard()
  {
    return this;
  }

  /**
   * Returns {@code subnetworkName}
   */
  // TODO change to Subboard -- this apparently missed the refactoring a while
  // ago
  public String getSubnetworkName()
  {
    return subnetworkName;
  }
}
