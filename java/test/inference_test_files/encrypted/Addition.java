
import encrypted.quals.*;

class TestAddition {

    void test(String a, String b) {
        @Encrypted String t = a + b;
    }
}
