public class UnixDomainSocketServer {
    private File file;
    private Socket socket;
    private Thread<void> thread;
    private SynchronizedCollection<Socket> clients;

    public UnixDomainSocketServer (string name) {
        this.file = File.new_for_path (name);
    }

    private void loop () {
        while (!this.socket.is_closed ()) {
            try {
                var client = this.socket.accept ();
                this.clients.add (client);
            } catch (GLib.Error error) {
                print ("Failed to accept client: %s", error.message);
            }
        }
    }

    public void start () throws GLib.Error {
        if (this.file.query_exists ()) this.file.delete ();
        this.clients = new SynchronizedCollection<Socket> ();
        var address = new UnixSocketAddress (this.file.get_path ());
        this.socket = new Socket (SocketFamily.UNIX, SocketType.STREAM, SocketProtocol.DEFAULT);
        this.socket.bind (address, true);
        this.socket.listen ();
        this.thread = new Thread<void> ("server", loop);
    }

    public void broadcast (uint8[] data) {
        foreach (var client in this.clients.items ()) {
            try {
                client.send (data);
            } catch (Error err) {
                this.clients.remove (client);
            }
        }
    }

    public void stop () throws GLib.Error {
        this.socket.close ();
        this.thread.join ();
    }
}
