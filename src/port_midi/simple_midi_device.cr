require "./port_midi"
require "./input_stream"
require "./output_stream"

class SimpleMIDIDevice

  getter :input, :output

  def self.open(input_device_num, output_device_num)
    input = InputStream.open(input_device_num)
    output = OutputStream.open(output_device_num)
    new(input, output)
  end

  def initialize(@input : InputStream, @output : OutputStream)
  end

  def close
    @input.close
    @output.close
  end

  def read(buffer : Array(Event)) : Int32
    @input.read(buffer, buffer.size)
  end

  def read(buffer : Pointer(Event), length : Int32) : Int32
    @input.read(buffer, length)
  end

  def has_data? : Bool
    @input.has_data?
  end

  def write(buffer : Pointer(Event), length : Int32)
    @output.write(buffer, length)
  end

  def write(buffer : Array(Event))
    @output.write(buffer)
  end

  def write_short(msg : UInt32, when_tstamp : Int32 = 0)
    @output.write_short(when_tstamp, msg)
  end

  def write_sysex(msg : UInt8*, when_tstamp : Int32 = 0)
    @output.write_sysex(when_tstamp, msg)
  end
end
