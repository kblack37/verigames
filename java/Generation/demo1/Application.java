class Application {
    void main() {
        Storage store = new Storage();
        store.set(new UserData("Demo Name", 44));

        Object ud = store.get();
        ud.toString();
    }
}
