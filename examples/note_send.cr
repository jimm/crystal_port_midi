require "../src/port_midi"

PortMIDI.init
PortMIDI.list_all_devices

print "output device number: "
output_device_num = (gets() || "").to_i

output = OutputStream.open(output_device_num)

# send a note on, sleep for one second, then send a note off
output.write_short(PortMIDI.message(0x90, 64, 127), 0)
sleep(1)
output.write_short(PortMIDI.message(0x80, 64, 0), 0)

output.close()
PortMIDI.terminate
