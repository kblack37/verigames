import random.quals.*;

import java.security.SecureRandom;

public class SecureRandomTest {

	public static void main(String[] args) {
		java.util.Random r = new java.util.Random();
		java.util.Random r2 = new SecureRandom();
		SecureRandom r3 = new SecureRandom();

		@Random int test = 13;		// always error
		@Random int i = r.nextInt();    // error
		@Random int i2 = r2.nextInt();  // should we find the actual type?
		@Random int i3 = r3.nextInt();  // ok, declared type
	}
}
