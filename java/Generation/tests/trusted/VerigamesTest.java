import trusted.quals.*;

public class VerigamesTest {

    void bar(String s) {
        String f = "trusted";
        String g = "trusted";
        f = g;

        String h = f;
        h = s;
    }

}