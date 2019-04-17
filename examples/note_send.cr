require "../src/port_midi"

PortMIDI.init
PortMIDI.list_all_devices

print "output device number: "
output_device_num = (gets() || "").to_i

output = OutputStream.open(output_device_num)

# Play a scale.
[64, 66, 68, 69, 71, 73, 75, 76].each do |note|
  output.write_short(PortMIDI.message(0x90, note, 127))
  sleep(0.25)
  output.write_short(PortMIDI.message(0x80, note, 0))
end

output.close()
PortMIDI.terminate
