int main(string[] args) {
    if (args.length != 2) {
        print ("Usage: %s <path>\n", args[0]);
        return 1;
    }

    string path = args[1];

    var server = new UnixDomainSocketServer (path);
    var application = new Application (server);

    application.start ();

    return 0;
}
