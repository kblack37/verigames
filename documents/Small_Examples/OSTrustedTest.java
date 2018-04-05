import ostrusted.quals.*;

public class OSTrustedTest {

	public static void main(String[] args) {
		String s1 = "ls";
		String s2 = s1 + args[0];

        	java.lang.Runtime rt = java.lang.Runtime.getRuntime();
		
		try {
			rt.exec(s1); 		// ok
			rt.exec(s2); 		// error
			rt.exec(args[0]); 	// error
		} catch (java.io.IOException e) {
		}	
	}
}
