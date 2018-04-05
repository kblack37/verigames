class LoopBasic {
    void foo(LoopBasic lb) {
        for (int i = 0; i < 5; i++) {
            lb.bar();
        }

        while (lb.proceed()) {
            lb.bar();
        }
    }

    void bar() {
        return;
    }

    boolean proceed() {
        return Math.random() < .5;
    }
}