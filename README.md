# port_midi

`port_midi` is a wrapper around the cross-platform
[PortMidi](http://portmedia.sourceforge.net/portmidi/) MIDI I/O library.

The low-level wrapper around PortMidi is in the lib `LibPortMIDI`.

The module `PortMIDI` contains a few helper functions that are useful when
converting between MIDI data and PortMidi messages. It also contains the
function `PortMIDI#list_all_devices` which prints out all of the input and
output devices available to PortMidi.

At a higher level of abstraction, `InputStream` and `OutputStream` represent
the two kinds of streams that do reading and writing of MIDI data.

Finally, a `SimpleMIDIDevice` wraps one input stream and one output stream.

## Installation

1. Install the PortMidi library. If you are on MacOS and you use Homebrew,
   you can run `brew install portmidi`. Otherwise, download the PortMidi
   source from http://portmedia.sourceforge.net/portmidi/ and compile it.
2. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  port_midi:
    github: jimm/crystal_port_midi
```
3. Run `shards install`

## Usage

```crystal
require "port_midi"

PortMIDI.initialize
```

See the `examples` directory for a few sample applications that use
`port_midi` and the `InputStream`, `OutputStream`, and `SimpleMIDIDevice`
classes.

To build the examples, run `shards build`.

## Development

To run the tests, run `crystal spec`.

When running tests on Travis CI, we limit ourselves to tests that do not
return PortMidi errors. That is because the installation of libportmidi
available to Travis through `apt-get` is compiled with the `PM_CHECK_ERRORS`
flag enabled. When an error such as an invalid device ID happens, the flag
causes the PortMidi code to display a message, prompt the user to hit ENTER,
and exit immediately. I can work around the prompt by running `/usr/bin/yes
| crystal spec`, but I can't work around the call to `exit`.

## Documentation

To generate the docs, run `crystal docs`.

## Contributing

1. [Fork the repo](https://github.com/jimm/port_midi/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jim Menard](https://github.com/jimm) - creator and maintainer
