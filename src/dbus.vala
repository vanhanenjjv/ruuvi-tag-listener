[DBus (name = "org.freedesktop.DBus.ObjectManager")]
public interface ObjectManager : GLib.Object {
    public signal void interfaces_added (
        ObjectPath path, 
        HashTable<string, HashTable<string, Variant>> interfaces
    );

    public signal void interfaces_removed (
        ObjectPath path,
        string[] interfaces
    );

    public abstract HashTable<
        ObjectPath, 
        HashTable<string, HashTable<string, Variant>>
    > get_managed_objects () throws GLib.Error;
}

[DBus (name = "org.bluez.Device1")]
public interface Device1 : GLib.Object {
    public abstract HashTable<uint16, Variant> manufacturer_data { owned get; }
}

[DBus (name = "org.freedesktop.DBus.Properties")]
public interface Properties : GLib.Object {
    public signal void properties_changed (
        string @interface, 
        HashTable<string, Variant> changed_properties, 
        string[] invalidated_properties
    );
}

[DBus (name = "org.bluez.Adapter1", timeout = 120000)]
public interface Adapter1 : GLib.Object {
    public abstract void start_discovery () throws GLib.Error;
}

public ObjectManager get_object_manager () throws GLib.IOError {
    return Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", "/");
}

public Adapter1 get_adapter1 () throws GLib.IOError {
    return Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", "/org/bluez/hci0");
}

public Properties get_bluetooth_device_properties (string path) throws GLib.IOError {
    return Bus.get_proxy_sync (BusType.SYSTEM, "org.bluez", path);
}
