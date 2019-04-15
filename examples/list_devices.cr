require "../src/port_midi"

LibPortMIDI.initialize
PortMIDI.list_all_devices
LibPortMIDI.terminate
