class Application1 {
    void main() {
        Scribble sc = new Scribble();
        sc.init();

        Storage store = new Storage();
        store.set(new UserData("Demo Name", 44));

        Server s = new Server(99);
        s.run();
        
        Object ud = store.get();
        ud.toString();
    }
}
