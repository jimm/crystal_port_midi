require "../src/port_midi"

# A few helpful constant definitions.
SYSEX = 0xF0_u8
EOX = 0xF7_u8
KORG_MANUFACTURER_ID = 0x42_u8
KRONOS_DEVICE_ID = 0x68_u8
FUNC_CODE_CURR_OBJ_DUMP_REQ = 0x74_u8
OBJ_TYPE_SET_LIST_SLOT_NAME = 0x11_u8

# ================ helpers ================

# Reads an incoming sysex message. This function assumes that we're only
# recieving sysex. That is, we assume that we've already called
# `LibPortMIDI#set_filter` to filter out all other messages. Without that
# filter, we'd have to ignore all other incoming MIDI and terminate the
# sysex if any non-realtime status message was received.
def read_sysex(input_stream) : {LibPortMIDI::PmError, Array(UInt8)}
  buffer = uninitialized LibPortMIDI::Event[1024]
  sysex = UInt8[]

  while true
    while LibPortMIDI.poll(input_stream) == LibPortMIDI::PmError::NoData
      sleep(0.001)
    end
    len = LibPortMIDI.midi_read(input_stream, buffer, 1024)
    if len < 0
      err = LibPortMIDI::PmError.new(len)
      STDERR.puts "MIDI read error #{err}, ignoring message"
      return {err, [] of UInt8}
    end
    len.times do |i|
      bytes = PortMIDI.bytes(buffer[i])
      4.times do |j|
        sysex << bytes[j]
        return {LibPortMIDI::PmError::NoError, sysex} if bytes[j] == EOX
      end
    end
  end
end

# Converts *m_bytes* into a String.
def midi_to_string(m_bytes : Array(UInt8))
  i_bytes = midi_to_internal(m_bytes)
  # Convert '\r' to '\n' and ignore trailing NUL bytes.
  len_without_nuls = i_bytes.size
  i_bytes.size.times do |i|
    case i_bytes[i]
    when '\r'
      i_bytes[i] = '\n'.ord.to_u8
    when 0_u8
      len_without_nuls = i
      break
    end
  end
  String.new(Slice.new(i_bytes.to_unsafe, len_without_nuls))
end

# Converts Kronos 7-bit encoded *m_bytes* into 8-bit bytes.
def midi_to_internal(m_bytes : Array(UInt8))
  m_len = m_bytes.size
  m_offset = 0
  i_bytes = [] of UInt8

  while m_len > 0
    chunk_len = m_len.clamp(0, 8)
    (chunk_len-1).times do |i|
      high_bit_set = (m_bytes[m_offset] & (1 << i)) != 0
      i_bytes << m_bytes[m_offset+i+1] + (high_bit_set ? 0x80_u8 : 0_u8)
    end
    m_offset += chunk_len
    m_len -= chunk_len
  end
  i_bytes
end

# ================ main ================

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

# Filter out all incoming MIDI messages except sysex. This isn't normally
# necessary, but it makes our sysex-receiving code above much simpler.
filter = LibPortMIDI::Filter::All.value - LibPortMIDI::Filter::Sysex.value
LibPortMIDI.set_filter(input_stream, filter)

# Send a sysex message and receive a response. These particular sysex
# messages are for the Korg Kronos and won't work for anything else.

# Request the name of the current set list slot by sending a "current object
# dump request" with an object type of "slot name". This assumes that the
# Kronos' global channel is channel 1.
sysex = [SYSEX, KORG_MANUFACTURER_ID, 0x30_u8,
         KRONOS_DEVICE_ID,
         FUNC_CODE_CURR_OBJ_DUMP_REQ,
         OBJ_TYPE_SET_LIST_SLOT_NAME,
         EOX]
err = LibPortMIDI.midi_write_sysex(output_stream, 0, sysex)
if err != LibPortMIDI::PmError::NoError
  STDERR.puts("error sending sysex: #{err}")
  exit(1)
end

# Read the incoming sysex response. See the definition of `read_sysex` above.
err, sysex = read_sysex(input_stream)
if err != LibPortMIDI::PmError::NoError
  STDERR.puts("error reading sysex: #{err}")
  exit(1)
end

# Convert the encoded string in the response into a String and print it.
puts midi_to_string(sysex[7, sysex.size - 8])

LibPortMIDI.close_stream(input_stream)
LibPortMIDI.close_stream(output_stream)
LibPortMIDI.terminate
