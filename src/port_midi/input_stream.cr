require "./pm_stream"

class InputStream < PMStream
  def self.open(input_device_num : Int32, input_driver_info : Int32*? = nil,
                buffer_size : Int32 = 1024,
                time_proc : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                time_info : (Void* -> LibPortMIDI::PmTimestamp)? = nil) : InputStream
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

  def wait_for_data(sleep_secs = 0.001)
    while !has_data?
      sleep(sleep_secs)
    end
  end

  def read(buffer : Pointer(LibPortMIDI::Event), length : Int32) : Int32
    len = LibPortMIDI.midi_read(@stream, buffer, length)
    if len < 0
      err = LibPortMIDI::PmError.new(len)
      PortMIDI.raise_error(err, "error reading input stream #{@stream}")
    end
    len
  end

  def read(buffer : Array(LibPortMIDI::Event)) : Int32
    read(buffer.as(LibPortMIDI::Event*), buffer.size)
  end

  def set_filter(filters_bitmask : UInt32)
    err = LibPortMIDI.set_filter(@stream, filters_bitmask)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error setting filter for input stream #{@stream}")
    end
  end

  def set_channel_mask(bitmask : UInt32)
    err = LibPortMIDI.set_channel_mask(@stream, bitmask)
    if err != LibPortMIDI::PmError::NoError
      raise PortMIDI.raise_error(err, "error setting channel mask for input stream #{@stream}")
    end
  end
end
