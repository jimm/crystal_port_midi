require "./pm_stream"

class OutputStream < PMStream
  def self.open(output_device_num : Int32, output_driver_info : Int32*? = nil,
                buffer_size : Int32 = 1024,
                time_proc : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                time_info : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                latency : Int32 = 0) : OutputStream
    output = uninitialized LibPortMIDI::Stream
    err = LibPortMIDI.open_output(pointerof(output),
                                  output_device_num, output_driver_info,
                                  buffer_size, time_proc, time_info, latency)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error opening output device #{output_device_num}")
    end
    new(output)
  end

  def write(buffer : Event*, length : Int32)
    err = LibPortMIDI.midi_write(@stream, buffer, length)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing to output stream #{@stream}")
    end
  end

  def write(buffer : Array(Event))
    write(buffer, buffer.size)
  end

  def write_short(msg : UInt32, when_tstamp : Int32 = 0)
    err = LibPortMIDI.midi_write_short(@stream, when_tstamp, msg)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing a message to output stream #{@stream}")
    end
  end

  def write_sysex(msg : UInt8*, when_tstamp : Int32 = 0)
    err = LibPortMIDI.midi_write_sysex(@stream, when_tstamp, msg)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing sysex to output stream #{@stream}")
    end
  end

  def write_sysex(msg : Array(UInt8), when_tstamp : Int32 = 0)
    write_sysex(msg.as(UInt8*), when_tstamp)
  end

  def abort_write
    err = LibPortMIDI.abort_write(@stream)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error aborting write to output stream #{@stream}")
    end
  end
end
