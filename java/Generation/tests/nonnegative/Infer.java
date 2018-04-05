import nonnegative.quals.*;

public class Infer {
    void m1(int n) {
        boolean[] arr = new boolean[10];

        System.out.println(arr[n]);
    }

    void m2() {
        int i = 20;
        m1(i);
    }
}
