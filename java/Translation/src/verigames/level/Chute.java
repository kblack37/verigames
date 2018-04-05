package verigames.level;

import verigames.layout.GameCoordinate;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * A mutable chute segment for use in a {@link Board}. Once {@link #underConstruction()
 * this.underConstruction()} is false, {@code this} is immutable.<br/>
 * <br/>
 * Implements eternal equality because it is mutable, but must be used in
 * {@code Collection}s<br/>
 * <br/>
 * Specification Field: {@code pinch} : {@code boolean} // {@code true} iff
 * there is a pinch-point in this chute segment<br/>
 * {@code false} by default.<br/>
 * <br/>
 * Specification Field: {@code narrow} : {@code boolean} // {@code true} iff the
 * chute is currently narrow. Defaults to {@code true}<br/>
 * <br/>
 * Specification Field: {@code editable} : {@code boolean} // {@code true} iff
 * the player can edit the width of the chute<br/>
 * <br/>
 * Specification Field: Layout Coordinates : list of (x: real, y:real), where
 * the length of the list is 3n + 1, where n is a nonnegative integer. // The
 * coordinates for the B-spline defining this edge's curve.<br/>
 * <br/>
 * Specification Field: {@code UID} : integer // the unique identifier for this
 * chute<br/>
 * <br/>
 * Except in corner cases, {@code pinch} --> {@code narrow}. This is not,
 * however, enforced.<br/>
 *
 * @author Nathaniel Mote
 */

public class Chute extends verigames.graph.Edge<Intersection>
{
  private boolean pinch;

  private boolean narrow;
  private boolean editable;

  private boolean buzzsaw;

  /**
   * The variable ID for the variable represented by this chute.
   * -1 for chute's without corresponding variable.
   */
  private final int variableID;

  /**
   * A description for the chute, only used for debugging output.
   */
  private final String description;

  // should be instantiated as an immutable list
  // TODO enforce length in checkRep
  private /*@Nullable*/ List<GameCoordinate> layout;

  private final int UID;

  private static int nextUID = 1;

  /**
   * Constructor that creates a chute with a variableID equal to -1 and an
   * automatically generated, unique description.
   */
  // TODO: Should we force people to provide a description? I added this to make
  // the transition easier, but we might not want it.
  public Chute()
  {
    this(-1, null);
  }

  /**
   * Creates a new {@code Chute} object.
   *
   * @param varID
   * The variable identifier to use.
   *
   * @param description
   * The description of this chute. If null, a unique description will be
   * generated.
   */
  public Chute(int varID, /*@Nullable*/ String description)
  {
    this(nextUID++, varID, description);
  }

  /**
   * Dangerous package-only-level constructor that allows you to set the true
   * ID of this chute. Used when loading worlds where you want to preserve the
   * ID of the chutes.
   */
  Chute(int id, int varID, /*@Nullable*/ String description)
  {
    this.editable = true;

    this.narrow = true;
    this.pinch = false;

    this.buzzsaw = false;

    this.UID = id;

    this.variableID = varID;
    if (description != null)
    {
      this.description = description;
    }
    else
    {
      this.description = "chute" + UID;
    }

    this.checkRep();
  }


  /**
   * Returns {@code pinch}<br/>
   * <br/>
   * Defaults to {@code false}
   */
  public boolean isPinched()
  {
    return pinch;
  }

  /**
   * Sets {@code pinch} to the value of the parameter<br/>
   * <br/>
   * Requires: {@link #underConstruction() this.underConstruction()}<br/>
   * <br/>
   * Modifies: {@code this}
   *
   * @param pinched
   */
  public void setPinched(boolean pinched)
  {
    if (!underConstruction())
      throw new IllegalStateException("Mutation attempted on constructed Chute");
    this.pinch = pinched;
    checkRep();
  }

  /**
   * Returns {@code narrow}
   */
  public boolean isNarrow()
  {
    return narrow;
  }

  /**
   * Sets the specification field {@code narrow} to the value of the parameter
   * {@code narrow}<br/>
   * <br/>
   * Requires: {@link #underConstruction() this.underConstruction()} or {@link #isEditable() this.isEditable()}<br/>
   * <br/>
   * Modifies: {@code this}
   *
   * @param narrow
   */
  public void setNarrow(boolean narrow)
  {
    //TODO JB: REMOVE THE ALLOWANCE UNDER WEAK MODE
    if (!underConstruction() && !isEditable() && verigames.utilities.Misc.CHECK_REP_STRICT )
      throw new IllegalStateException("Cannot change the width of an immutable chute");
    this.narrow = narrow;
    checkRep();
  }

  /**
   * Returns {@code buzzsaw}
   */
  public boolean hasBuzzsaw()
  {
    return buzzsaw;
  }

  /**
   * Sets {@code buzzsaw}
   * <br/>
   * Modifies: {@code this}
   *
   * @param buzzsaw
   */
  public void setBuzzsaw(boolean buzzsaw)
  {
    this.buzzsaw = buzzsaw;
    checkRep();
  }

  /**
   * Returns {@code editable}
   */
  public boolean isEditable()
  {
    return editable;
  }

  /**
   * Sets the specification field {@code editable} to the value of the
   * parameter {@code editable}<br/>
   * <br/>
   * Requires: {@link #underConstruction() this.underConstruction()}<br/>
   * <br/>
   * Modifies: {@code this}
   *
   * @param editable
   */
  public void setEditable(boolean editable)
  {
    if (!underConstruction())
      throw new IllegalStateException("Mutation attempted on constructed Chute");

    this.editable = editable;
    checkRep();
  }

  public void setLayout(List<GameCoordinate> layout)
  {
    if (layout.size() < 4 || layout.size() % 3 != 1)
      throw new IllegalArgumentException("Number of points (" +
          layout.size() +
          ") illegal -- must be of the form 3n + 1 where n is a positive integer");

    this.layout = Collections.unmodifiableList(
        new ArrayList<GameCoordinate>(layout));
  }

  public /*@Nullable*/ List<GameCoordinate> getLayout()
  {
    return this.layout;
  }

  /**
   * Returns {@code UID}
   */
  public int getUID()
  {
    return UID;
  }

  /**
   * Returns the description of this {@code Chute}
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Returns the variable ID of this {@code Chute}
   */
  public int getVariableID()
  {
    return variableID;
  }

  /**
   * Returns a deep copy of {@code this}.
   * <p>
   * If this chute has {@code start} or {@code end} nodes, that information
   * will not be copied.
   * <p>
   * The choice not to override {@code Object.clone()} was deliberate. {@code
   * copy()} intentionally only copies *some* of the properties of a {@code
   * Chute}, and, notably, leaves out the UID. The UID is (and should be) a
   * final field, and if {@code clone()} were used, the UID would need to be
   * modified after object creation in order to maintain the property that no
   * two {@code Chute}s have the same UID.
   */
  // TODO explicitly document which information is and is not copied.
  public Chute copy()
  {
    return copy(variableID, description);
  }

  /**
   * Returns a deep copy of {@code this}, but with a different variable ID
   * and description.
   * @see #copy()
   * @param newVarID the new variable ID to use
   * @param newDescription the new description to use
   * @return a new Chute with the given variable ID and description
   */
  public Chute copy(int newVarID, String newDescription) {
      Chute copy = new Chute(newVarID, newDescription);
      copy.setNarrow(narrow);
      copy.setPinched(pinch);
      copy.setEditable(editable);
      copy.setBuzzsaw(buzzsaw);
      return copy;
  }

  @Override
  protected String shallowToString()
  {
    String propertyString = isNarrow() ? "Narrow" : "Wide";

    if (isPinched())
      propertyString += ", Pinched";

    return "Chute#" + getUID() + ", VarID#" + variableID + " [" + description + "] (" + propertyString + ")";
  }

  /* These are overridden to facilitate testing. Overriding gives the tests
   * (which are in this package) access to these protected methods that would
   * otherwise be members of the superclass, and thus inaccessible. */
  @Override
  protected void setEnd(Intersection n, String port)
  {
    super.setEnd(n, port);
  }

  @Override
  protected void setStart(Intersection n, String port)
  {
    super.setStart(n, port);
  }

  @Override
  protected void finishConstruction()
  {
    super.finishConstruction();
  }
}
