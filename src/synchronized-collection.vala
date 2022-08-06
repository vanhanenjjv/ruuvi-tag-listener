public class SynchronizedCollection<T> {
    private Mutex mutex = Mutex();
    private List<T> list = new List<T>();

    public void add (T item) {
        mutex.lock ();
        list.append (item);
        mutex.unlock ();
    }

    public void remove (T item) {
        mutex.lock ();
        list.remove (item);
        mutex.unlock ();
    }

    public uint length () {
        return list.length ();
    }

    public List<unowned T> items () {
        mutex.lock ();
        var copy = this.list.copy ();
        mutex.unlock ();
        return copy;
    }
}
