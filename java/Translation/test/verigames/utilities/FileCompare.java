package verigames.utilities;

import java.io.*;
import java.util.*;

/**
 * A class that contains a single static method, {@link #compareFiles(File,
 * File)} that compares two files and returns a {@link #Result} object that
 * indicates the result of the comparison and provides extra information when
 * the two files are different.
 *
 * @author Nathaniel Mote
 */
public class FileCompare
{
  /**
   * Compares two files and returns the result in the form of a {@link #Result}
   * object.
   *
   * @throws FileNotFoundException
   * If either {@code first} or {@code second} is not found.
   */
  public static Result compareFiles(File first, File second) throws FileNotFoundException
  {
    Scanner one = new Scanner(first);
    Scanner two = new Scanner(second);
    
    int lineNumber = 1;
    while (one.hasNextLine() && two.hasNextLine())
    {
      String firstLine = one.nextLine();
      String secondLine = two.nextLine();
      
      if(!firstLine.equals(secondLine))
        return new Result(first, second, lineNumber, firstLine, secondLine);
      
      lineNumber++;
    }
    
    if (one.hasNextLine() || two.hasNextLine())
    {
      String firstLine;
      String secondLine;
      
      if (one.hasNextLine())
      {
        firstLine = one.nextLine();
        secondLine = "";
      }
      else
      {
        firstLine = "";
        secondLine = two.nextLine();
      }
      
      return new Result(first, second, lineNumber, firstLine, secondLine);
    }
    
    return new Result(first, second);
  }
  
  /**
   * A record type containing the results of a file comparison operation.
   *
   * If {@link #getResult()} returns {@code false}, then {@link
   * #getLineNumber()}, {@link #getFirstLine()}, and {@link #getSecondLine()}
   * will return the line number of the first difference between the two files,
   * along with the given lines in the first and second files, respectively.
   */
  public static class Result
  {
    private final File first;
    private final File second;
    
    private final boolean result;
    
    private final int lineNumber;
    private final String firstLine;
    private final String secondLine;
    
    /**
     * The constructor used when the two files are identical. Automatically
     * sets result to {@code true}, lineNumber to 0, and firstLine and
     * secondLine to "".
     */
    private Result(File first, File second)
    {
      this.result = true;
      
      this.first = first;
      this.second = second;
      
      this.lineNumber = 0;
      this.firstLine = "";
      this.secondLine = "";
    }
    
    /**
     * The constructor used when the two files are different. Automatically
     * sets result to {@code true}.
     */
    private Result(File first, File second, int lineNumber, String firstLine, String secondLine)
    {
      this.result = false;
      
      this.first = first;
      this.second = second;
      this.lineNumber = lineNumber;
      this.firstLine = firstLine;
      this.secondLine = secondLine;
    }
    
    public File getFirstFile()
    {
      return first;
    }
    
    public File getSecondFile()
    {
      return second;
    }
    
    public boolean getResult()
    {
      return result;
    }
    
    public int getLineNumber()
    {
      return lineNumber;
    }
    
    public String getFirstLine()
    {
      return firstLine;
    }
    
    public String getSecondLine()
    {
      return secondLine;
    }

    /**
     * If the comparison yielded no differences, returns a message stating this.
     * Otherwise, returns a message indicating where the difference occurred.
     */
    public String toString()
    {
      if (getResult())
        return "No differences found\n";
      else
        return "Difference at line " + getLineNumber() + ":\n" +
            "Expected: " + getFirstLine() + "\n"  +
            "But was : " + getSecondLine() + "\n" +
            "For files:\n" +
            "    expected = " + getFirstFile().getAbsolutePath() + "\n" +
            "    actual   = " + getSecondFile().getAbsolutePath()   + "\n";
    }
  }
}
