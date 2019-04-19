require "../src/port_midi"

# A few helpful constant definitions.
SYSEX                       = 0xF0_u8
EOX                         = 0xF7_u8
KORG_MANUFACTURER_ID        = 0x42_u8
KRONOS_DEVICE_ID            = 0x68_u8
FUNC_CODE_CURR_OBJ_DUMP_REQ = 0x74_u8
OBJ_TYPE_SET_LIST_SLOT_NAME = 0x11_u8

# ================ helpers ================

# Reads an incoming sysex message from *input_stream*. This function assumes
# that we're only receiving sysex. That is, we assume that we've already
# called `InputStream#set_filter` to filter out all other messages. Without
# that filter, we'd have to ignore all other incoming MIDI and terminate the
# sysex if any non-realtime status message was received.
def read_sysex(synth) : Array(UInt8)
  buffer = uninitialized LibPortMIDI::Event[1024]
  sysex = UInt8[]

  while true
    synth.wait_for_data
    len = synth.read(buffer.to_unsafe, 1024)
    if len < 0
      err = LibPortMIDI::PmError.new(len)
      PortMIDI.raise_error(err, "MIDI read error #{err}, ignoring message")
    end
    len.times do |i|
      bytes = PortMIDI.bytes(buffer[i])
      4.times do |j|
        sysex << bytes[j]
        return sysex if bytes[j] == EOX
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
    (chunk_len - 1).times do |i|
      high_bit_set = (m_bytes[m_offset] & (1 << i)) != 0
      i_bytes << m_bytes[m_offset + i + 1] + (high_bit_set ? 0x80_u8 : 0_u8)
    end
    m_offset += chunk_len
    m_len -= chunk_len
  end
  i_bytes
end

# ================ main ================

PortMIDI.init
PortMIDI.list_all_devices

print "input device number: "
input_device_num = (gets() || "").to_i
print "output device number: "
output_device_num = (gets() || "").to_i

synth = SimpleMIDIDevice.open(input_device_num, output_device_num)

# Filter out all incoming MIDI messages except sysex. This isn't normally
# necessary, but it makes our sysex-receiving code above much simpler.
filter = LibPortMIDI::Filter::All.value - LibPortMIDI::Filter::Sysex.value
synth.set_filter(filter.to_u32)

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
err = synth.write_sysex(sysex)

# Read the incoming sysex response. See the definition of `read_sysex` above.
sysex = read_sysex(synth)

# Convert the encoded string in the response into a String and print it.
puts midi_to_string(sysex[7, sysex.size - 8])

synth.close
LibPortMIDI.terminate
