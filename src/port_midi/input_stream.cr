require "./pm_stream"

# An input MIDI stream.
class InputStream < PMStream
  # Opens and returns a new `InputStream`. This convenience method provides
  # default for most of its arguments.
  def self.open(input_device_num : Int32,
                input_driver_info : Void*? = nil,
                buffer_size : Int32 = 1024,
                time_proc : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                time_info : Void*? = nil) : InputStream
    err = LibPortMIDI.open_input(out input, input_device_num, input_driver_info,
      buffer_size, time_proc, time_info)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error opening input device #{input_device_num}")
    end
    new(input)
  end

  # Returns `true` if polling indicates that data is ready to read.
  def has_data? : Bool
    LibPortMIDI.poll(@stream) != LibPortMIDI::PmError::NoData
  end

  # Polls for data, waiting *sleep_secs* between polls. *sleep_secs* may be
  # sub-second.
  def wait_for_data(sleep_secs = 0.001)
    while !has_data?
      sleep(sleep_secs)
    end
  end

  # Reads up to *length* `LibPortMIDI::Event` structs into *buffer*. Raises
  # an exception on error.
  def read(buffer : Pointer(LibPortMIDI::Event), length : Int32) : Int32
    len = LibPortMIDI.midi_read(@stream, buffer, length)
    if len < 0
      err = LibPortMIDI::PmError.new(len)
      PortMIDI.raise_error(err, "error reading input stream #{@stream}")
    end
    len
  end

  # Reads `LibPortMIDI::Event` structs into *buffer*, up to the length of
  # the buffer. Raises an exception on error.
  def read(buffer : Array(LibPortMIDI::Event)) : Int32
    read(buffer.to_unsafe, buffer.size)
  end

  # Sets the filter bitmask for this input stream. Raises an exception on
  # error.
  def set_filter(filters_bitmask : UInt32)
    err = LibPortMIDI.set_filter(@stream, filters_bitmask)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error setting filter for input stream #{@stream}")
    end
  end

  # Sets the channel maks for this input stream. Raises an exception on
  # error.
  def set_channel_mask(bitmask : UInt32)
    err = LibPortMIDI.set_channel_mask(@stream, bitmask)
    if err != LibPortMIDI::PmError::NoError
      raise PortMIDI.raise_error(err, "error setting channel mask for input stream #{@stream}")
    end
  end
end
