package verigames.utilities;

import java.io.PrintStream;

/*>>>
import checkers.nullness.quals.*;
*/

/**
 * Prints objects of type {@code E}. Subclasses must, minimally, provide an
 * implementation for {@link #printMiddle printMiddle}.<br/>
 * <br/>
 * Some subclasses may want to override {@link #printIntro printIntro} and/or
 * {@link #printOutro printOutro} -- the default implementation does nothing.<br/>
 * <br/>
 * Subclasses can override {@link #print print}, typically this will not be
 * necessary.
 *
 * @param <E>
 * The type of the object to be printed
 * @param <T>
 * The type of any extra data that may be necessary to print {@code E} objects.
 * Parameterize to Void if no data is needed.
 *
 * @author Nathaniel Mote
 */
public abstract class Printer<E, T extends /*@Nullable*/ Object>
{
  /**
   * Prints a textual representation of the given object to the given
   * PrintStream.<br/>
   * <br/>
   * By default, calls {@link #printIntro}, {@link #printMiddle}, then
   * {@link #printOutro}.
   *
   * @param toPrint
   * The object to print
   * @param out
   * The {@code PrintStream} to which {@code toPrint} will be printed.
   * @param data
   * Optional extra data to use while printing.
   */
  public void print(E toPrint, PrintStream out, T data)
  {
    printIntro(toPrint, out, data);
    printMiddle(toPrint, out, data);
    printOutro(toPrint, out, data);
  }

  /**
   * Prints the intro. By default, does nothing, but subclasses may override
   * it.
   * @param toPrint
   * The object to print
   * @param out
   * The {@code PrintStream} to which {@code toPrint} will be printed.
   * @param data
   * Optional extra data to use while printing.
   */
  protected void printIntro(E toPrint, PrintStream out, T data) { }

  /**
   * Prints the main part. Subclasses must provide an implementation for this
   * method.
   * @param toPrint
   * The object to print
   * @param out
   * The {@code PrintStream} to which {@code toPrint} will be printed.
   * @param data
   * Optional extra data to use while printing.
   */
  protected abstract void printMiddle(E toPrint, PrintStream out, T data);

  /**
   * Prints the outro. By default, does nothing, but subclasses may override
   * it.
   * @param toPrint
   * The object to print
   * @param out
   * The {@code PrintStream} to which {@code toPrint} will be printed.
   * @param data
   * Optional extra data to use while printing.
   */
  protected void printOutro(E toPrint, PrintStream out, T data) { }
}
