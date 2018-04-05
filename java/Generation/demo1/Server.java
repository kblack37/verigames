// This example is from the book _Java in a Nutshell_ by David Flanagan.
// Written by David Flanagan.  Copyright (c) 1996 O'Reilly & Associates.
// You may study, use, modify, and distribute this example for any purpose.
// This example is provided WITHOUT WARRANTY either expressed or implied.

import java.net.*;
import java.io.*;
import java.awt.*;
import java.util.*;

@SuppressWarnings({"deprecation", "unchecked"})
public class Server extends Thread {
    public final static int DEFAULT_PORT = 6789;
    protected int port;
    protected ServerSocket listen_socket;
    protected ThreadGroup threadgroup;
    protected java.awt.List connection_list;
    protected Vector connections;
    protected Vulture vulture;
    
    // Exit with an error message, when an exception occurs.
    public static void fail(Exception e, String msg) {
        System.err.println(msg + ": " +  e);
        System.exit(1);
    }
    
    // Create a ServerSocket to listen for connections on;  start the thread.
    public Server(int port) {
        // Create our server thread with a name.
        super("Server");
        if (port == 0) port = DEFAULT_PORT;
        this.port = port;
        try { listen_socket = new ServerSocket(port); }
        catch (IOException e) { fail(e, "Exception creating server socket"); }
        // Create a threadgroup for our connections
        threadgroup = new ThreadGroup("Server Connections");

        // Create a window to display our connections in
        Frame f = new Frame("Server Status");
        connection_list = new java.awt.List();
        f.add("Center", connection_list);
        f.resize(400, 200);
        f.show();

        // Initialize a vector to store our connections in
        connections = new Vector();

        // Create a Vulture thread to wait for other threads to die.
        // It starts itself automatically.
        vulture = new Vulture(this);

        // Start the server listening for connections
        this.start();
    }
    
    // The body of the server thread.  Loop forever, listening for and
    // accepting connections from clients.  For each connection, 
    // create a Connection object to handle communication through the
    // new Socket.  When we create a new connection, add it to the
    // Vector of connections, and display it in the List.  Note that we
    // use synchronized to lock the Vector of connections.  The Vulture
    // class does the same, so the vulture won't be removing dead 
    // connections while we're adding fresh ones.
    public void run() {
        try {
            while(true) {
                Socket client_socket = listen_socket.accept();
                Connection c = new Connection(client_socket, threadgroup,
                                  3, vulture);
                // prevent simultaneous access.
                synchronized (connections) {
                    connections.addElement(c);
                    connection_list.addItem(c.toString());
                }
            }
        }
        catch (IOException e) {
            fail(e, "Exception while listening for connections");
        }
    }
    
    // Start the server up, listening on an optionally specified port
    public static void main(String[] args) {
        int port = 0;
        if (args.length == 1) {
            try { port = Integer.parseInt(args[0]); }
            catch (NumberFormatException e) { port = 0; }
        }
        new Server(port);
    }
}

// This class is the thread that handles all communication with a client
// It also notifies the Vulture when the connection is dropped.
class Connection extends Thread {
    static int connection_number = 0;
    protected Socket client;
    protected Vulture vulture;
    protected DataInputStream in;
    protected PrintStream out;

    // Initialize the streams and start the thread
    public Connection(Socket client_socket, ThreadGroup threadgroup,
              int priority, Vulture vulture) 
    {
        // Give the thread a group, a name, and a priority.
        super(threadgroup, "Connection-" + connection_number++);
        this.setPriority(priority);
        // Save our other arguments away
        client = client_socket;
        this.vulture = vulture;
        // Create the streams
        try { 
            in = new DataInputStream(client.getInputStream());
            out = new PrintStream(client.getOutputStream());
        }
        catch (IOException e) {
            try { client.close(); } catch (IOException e2) { ; }
            System.err.println("Exception while getting socket streams: " + e);
            return;
        }
        // And start the thread up
        this.start();
    }
    
    // Provide the service.
    // Read a line, reverse it, send it back.  
    @SuppressWarnings("deprecation")
    public void run() {
        String line;
        StringBuffer revline;
        int len;

        // Send a welcome message to the client
        out.println("Line Reversal Server version 1.0");
        out.println("A service of O'Reilly & Associates");

        try {
            for(;;) {
                // read in a line
                line = in.readLine();
                if (line == null) break;
                // reverse it
                len = line.length();
                revline = new StringBuffer(len);
                for(int i = len-1; i >= 0; i--) 
                    revline.insert(len-1-i, line.charAt(i));
                // and write out the reversed line
                out.println(revline);
            }
        }
        catch (IOException e) { ; }
        // When we're done, for whatever reason, be sure to close
        // the socket, and to notify the Vulture object.  Note that
        // we have to use synchronized first to lock the vulture
        // object before we can call notify() for it.
        finally {
            try { client.close(); } catch (IOException e2) { ; }
            synchronized (vulture) { vulture.notify(); }
        }
    }

    // This method returns the string representation of the Connection.
    // This is the string that will appear in the GUI List.
    public String toString() {
        return this.getName() + " connected to: " 
            + client.getInetAddress().getHostName()
            + ":" + client.getPort();
    }
}

// This class waits to be notified that a thread is dying (exiting)
// and then cleans up the list of threads and the graphical list.
class Vulture extends Thread {
    protected Server server;

    protected Vulture(Server s) {
        super(s.threadgroup, "Connection Vulture");
        server = s;
        this.start();
    }

    // This is the method that waits for notification of exiting threads
    // and cleans up the lists.  It is a synchronized method, so it
    // acquires a lock on the `this' object before running.  This is 
    // necessary so that it can call wait() on this.  Even if the 
    // the Connection objects never call notify(), this method wakes up
    // every five seconds and checks all the connections, just in case.
    // Note also that all access to the Vector of connections and to
    // the GUI List component are within a synchronized block as well.
    // This prevents the Server class from adding a new conenction while
    // we're removing an old one.
    @SuppressWarnings("deprecation")
    public synchronized void run() {
        for(;;) {
            try { this.wait(5000); } catch (InterruptedException e) { ; }
            // prevent simultaneous access
            synchronized(server.connections) {
                // loop through the connections
		for(int i = 0; i < server.connections.size(); i++) {
                    Connection c;
                    c = (Connection)server.connections.elementAt(i);
                    // if the connection thread isn't alive anymore, 
                    // remove it from the Vector and List.
                    if (!c.isAlive()) {
			server.connections.removeElementAt(i);
                        server.connection_list.delItem(i);
                        i--;
                    }
		}
            }
        }
    }
}
