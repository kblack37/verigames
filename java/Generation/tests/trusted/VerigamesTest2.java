import trusted.quals.*;

public class VerigamesTest2 {

    void bar(String s) {
        // TODO: demo when Cast is needed, e.g. make s @Untrusted
        isTrusted(s);
    }

    void isTrusted(@Trusted String s) {}
}