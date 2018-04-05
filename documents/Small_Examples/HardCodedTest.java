import hardcoded.quals.*;

public class HardCodedTest {

	public static void main(String[] args) {
		@SuppressWarnings("hardcoded")  // for demo purpose
		String hash = (@NotHardCoded String) "hashedpassword";
		method(hash); 			// ok
		method("monkey123");		// error
		method(hash + "monkey123"); 	// ok (concatenation with at least one non-hardcoded variable)
	}

	public static void method(@NotHardCoded String password) {
		
	}
}
