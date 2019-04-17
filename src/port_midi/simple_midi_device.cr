require "./port_midi"
require "./input_stream"
require "./output_stream"

# A wrapper around an input/output pair of streams.
class SimpleMIDIDevice

  getter :input, :output

  # Opens streams on *input_device_num* and *output_device_num* and returns
  # a `SimpleMIDIDevice` initialized with the opened streams.
  def self.open(input_device_num, output_device_num)
    input = InputStream.open(input_device_num)
    output = OutputStream.open(output_device_num)
    new(input, output)
  end

  def initialize(@input : InputStream, @output : OutputStream)
  end

  # Closes both the input and output streams. Raises an exception on error.
  def close
    @input.close
    @output.close
  end

  # See `InputStream#read`.
  def read(buffer : Array(Event)) : Int32
    @input.read(buffer, buffer.size)
  end

  # See `InputStream#read`.
  def read(buffer : Pointer(Event), length : Int32) : Int32
    @input.read(buffer, length)
  end

  # See `InputStream#has_data?`.
  def has_data? : Bool
    @input.has_data?
  end

  # See `OutpuStream.write`.
  def write(buffer : Pointer(Event), length : Int32)
    @output.write(buffer, length)
  end

  # See `OutpuStream.write`.
  def write(buffer : Array(Event))
    @output.write(buffer)
  end

  # See `OutpuStream.write_short`.
  def write_short(msg : UInt32, when_tstamp : Int32 = 0)
    @output.write_short(when_tstamp, msg)
  end

  # See `OutpuStream.write_sysex`.
  def write_sysex(msg : UInt8*, when_tstamp : Int32 = 0)
    @output.write_sysex(when_tstamp, msg)
  end
end
