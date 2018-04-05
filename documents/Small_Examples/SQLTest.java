import java.util.*;
import java.awt.Point;
import java.sql.*;
import sqltrusted.quals.*;

public class SQLTest {

    public static void Main(String[] args){
        @SqlUntrusted String s1 = "hello";
	    @SqlTrusted String blah = "hi"; 
	    @SqlTrusted String foo = s1 + blah; // Should cause error
    }

    public static void method(Connection conn, @SqlUntrusted String s1) throws SQLException {
	    PreparedStatement pSafe = conn.prepareStatement("safe");
	    PreparedStatement pError = conn.prepareStatement(s1); // Should cause error and use jdk.astub file
    }

}
