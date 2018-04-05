class Storage {
    Object data;

    Object get() {
        Object res;
        if (data!=null && (data.hashCode()%5 == 0)) {
            // This is valid data.
            res = data;
        } else {
            res = null;
        }
        return res;
    }

    void set(Object p) {
        data = p;
    }
}