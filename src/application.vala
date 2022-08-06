bool has_manufacturer_data (Variant properties) {
    return properties.lookup("ManufacturerData", "a{qv}");
}

bool has_ruuvi_tag_data (HashTable<string, Variant> properties) {
    var key = properties
        .get("ManufacturerData")
        .get_child_value(0)
        .get_child_value(0)
        .get_uint16();

    return key == 0x0499;
}

bool is_ruuvi_tag (HashTable<string, Variant> properties) {
    if (!has_manufacturer_data (properties)) return false;
    if (!has_ruuvi_tag_data (properties)) return false;
    return true;
}

public uint8[] get_ruuvi_tag_data (HashTable<string, Variant> properties) {
    return properties
        .get("ManufacturerData")
        .get_child_value(0)
        .get_child_value(1)
        .get_data_as_bytes()
        .get_data();
}

public class Application {
    private HashTable<string, Properties> properties = new HashTable<string, Properties>(str_hash, str_equal);

    private UnixDomainSocketServer server;

    public Application (UnixDomainSocketServer server) {
        this.server = server;
    }

    private void listen_for_device_properties_changed (ObjectPath device_path) throws GLib.Error {
        var properties = get_bluetooth_device_properties (device_path);
        properties.properties_changed.connect (on_properties_changed);
        this.properties.set (device_path, properties);
    }

    private void on_interfaces_added (ObjectPath path, HashTable<string, HashTable<string, Variant>> interfaces) {
        interfaces.foreach((name, properties) => {
            if (is_ruuvi_tag(properties)) {
                try {
                    listen_for_device_properties_changed (path);
                } catch (GLib.Error error) {
                    stderr.printf ("Failed to listen for device properties changed: %s\n", error.message);
                }
            }
        });
    }

    private void on_properties_changed (
        string @interface, 
        HashTable<string, Variant> changed_properties, 
        string[] invalidated_properties) {
        if (!is_ruuvi_tag(changed_properties)) return;
        var data = get_ruuvi_tag_data (changed_properties);
        this.server.broadcast (data);
    }

    public void start () {
        var loop = new MainLoop();

        ObjectManager object_manager;
        Adapter1 adapter1;

        try {
            this.server.start ();

            object_manager = get_object_manager();
            adapter1 = get_adapter1();
            
            object_manager
                .get_managed_objects ()
                .foreach ((path, interfaces) => interfaces.foreach ((name, properties) => {
                    if (is_ruuvi_tag (properties)) {
                        try {
                            listen_for_device_properties_changed (path);
                        } catch (GLib.Error error) {
                            stderr.printf ("Failed to listen for device properties changed: %s\n", error.message);
                        }
                    }
                }));

            object_manager.interfaces_added.connect (on_interfaces_added);

            adapter1.start_discovery();
        } catch (GLib.Error error) {
            stderr.printf ("Failed to start application: %s\n", error.message);
        }

        loop.run();
    }
}
