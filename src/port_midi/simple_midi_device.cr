require "./port_midi"
require "./input_stream"
require "./output_stream"

# A wrapper around an input/output pair of streams.
class SimpleMIDIDevice

  getter :input, :output
  delegate :read, :has_data?, :wait_for_data, :set_filter, :set_channel_mask,
           to: @input
  delegate :write, :write_short, :write_sysex, :abort_write, to: @output

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
end
