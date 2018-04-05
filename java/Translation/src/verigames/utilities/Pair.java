package verigames.utilities;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * An immutable record type representing a pair of arbitrary elements.
 * <p>
 * A pair is equal to another object if and only if the other object is also a
 * pair, and if the first elements are equal and the second elements are equal.
 */
public class Pair<A,B>
{
  private final A first;
  private final B second;

  /**
   * A static method for creating pairs that allows for less verbosity
   */
  public static <A,B> Pair<A,B> of(A first, B second)
  {
    return new Pair<A,B>(first, second);
  }

  public Pair(A first, B second)
  {
    this.first = first;
    this.second = second;
  }

  public A getFirst()
  {
    return first;
  }

  public B getSecond()
  {
    return second;
  }

  @Override
  public boolean equals(/*@Nullable*/ Object o)
  {
    if (o instanceof Pair)
    {
      Pair<?,?> other = (Pair<?,?>) o;
      return this.getFirst().equals(other.getFirst()) &&
          this.getSecond().equals(other.getSecond());
    }
    else
      return false;
  }

  @Override
  public int hashCode()
  {
    return first.hashCode() * 31 + second.hashCode() * 13;
  }
}
