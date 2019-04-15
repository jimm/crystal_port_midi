require "../src/port_midi"

LibPortMIDI.initialize
PortMIDI.list_all_devices

print "input device number: "
input_device_num = (gets() || "").to_i
print "output device number: "
output_device_num = (gets() || "").to_i

# This convenience function opens both an input and an output and checks for
# errors.
input_stream, output_stream =
  PortMIDI.open_portmidi_streams(input_device_num, output_device_num)

# send a note on, sleep for one second, then send a note off
LibPortMIDI.midi_write_short(input_stream, 0, PortMIDI.message(0x90, 64, 127))
sleep(1)
LibPortMIDI.midi_write_short(input_stream, 0, PortMIDI.message(0x80, 64, 0))

LibPortMIDI.close_stream(input_stream)
LibPortMIDI.close_stream(output_stream)
LibPortMIDI.terminate
