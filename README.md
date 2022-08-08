# RuuviTag Listener [![Build](https://github.com/vanhanenjjv/ruuvi-tag-listener/actions/workflows/build.yml/badge.svg)](https://github.com/vanhanenjjv/ruuvi-tag-listener/actions/workflows/build.yml)

A small program to listen for [RuuviTag](https://ruuvi.com) sensor data. It doesn't do anything fancy with the data and instead uses a [Unix domain socket](https://systemprogrammingatntu.github.io/mp2/unix_socket.html) to forward it to other programs to be processed further.

## Usage

The program takes one parameter which is the path where the socket is bound to.

```
./ruuvi-tag-listener <PATH>
```

To test that the program works you can use the [netcat (nc)](https://en.wikipedia.org/wiki/Netcat) utility to receive sensor data from the socket.

```
nc -U <PATH>
```

It should output lines of text that are not human readable.
