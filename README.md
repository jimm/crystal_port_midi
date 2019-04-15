# port_midi

`port_midi` is a wrapper around the cross-platform
[PortMidi](http://portmedia.sourceforge.net/portmidi/) MIDI I/O library.

The wrapper around PortMidi is in the lib `LibPortMIDI`.

The module `PortMIDI` contains a few helper functions that are useful when
converting between MIDI data and PortMidi messages. It also contains the
function `PortMIDI#list_all_devices` which prints out all of the input and
output devices available to PortMidi.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     port_midi:
       github: jimm/crystal_port_midi
   ```

2. Run `shards install`

## Usage

```crystal
require "port_midi"

LibPortMIDI::initialize
```

See the `examples` directory for a few sample applications that use
`port_midi`.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/jimm/port_midi/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jim Menard](https://github.com/jimm) - creator and maintainer
