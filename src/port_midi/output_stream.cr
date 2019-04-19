require "./pm_stream"

# An output MIDI stream.
class OutputStream < PMStream
  # Opens and returns a new `OutputStream`. This convenience method provides
  # default for most of its arguments.
  def self.open(output_device_num : Int32, output_driver_info : Int32*? = nil,
                buffer_size : Int32 = 1024,
                time_proc : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                time_info : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                latency : Int32 = 0) : OutputStream
    err = LibPortMIDI.open_output(out output, output_device_num, output_driver_info,
      buffer_size, time_proc, time_info, latency)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error opening output device #{output_device_num}")
    end
    new(output)
  end

  # Writes the *length* `LibPortMIDI::Event` structs in *buffer*. Raises an
  # exception on error.
  def write(buffer : LibPortMIDI::Event*, length : Int32)
    err = LibPortMIDI.midi_write(@stream, buffer, length)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing to output stream #{@stream}")
    end
  end

  # Writes all of the `LibPortMIDI::Event` structs in *buffer*. Raises an
  # exception on error.
  def write(buffer : Array(LibPortMIDI::Event))
    write(buffer, buffer.size)
  end

  # Writes a single *msg* at time *when_tstamp* (now by default). Raises an
  # exception on error.
  def write_short(msg : UInt32, when_tstamp : Int32 = 0)
    err = LibPortMIDI.midi_write_short(@stream, when_tstamp, msg)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing a message to output stream #{@stream}")
    end
  end

  # Writes a sysex *msg* at time *when_tstamp* (now by default). Raises an
  # exception on error.
  def write_sysex(msg : UInt8*, when_tstamp : Int32 = 0)
    err = LibPortMIDI.midi_write_sysex(@stream, when_tstamp, msg)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error writing sysex to output stream #{@stream}")
    end
  end

  # Writes a sysex *msg* at time *when_tstamp* (now by default). Raises an
  # exception on error.
  def write_sysex(msg : Array(UInt8), when_tstamp : Int32 = 0)
    write_sysex(msg.as(UInt8*), when_tstamp)
  end

  # Terminates outgoing messages immediately. This stream should be closed
  # immediately after this call. Raises an exception on error.
  def abort_write
    err = LibPortMIDI.abort_write(@stream)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error aborting write to output stream #{@stream}")
    end
  end
end
