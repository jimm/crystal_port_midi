require "./port_midi"

# This abstract superclass represents a PortMidi I/O stream.
class PMStream
  getter :stream

  def initialize(@stream : LibPortMIDI::Stream)
  end

  # Closes the stream. Raises an exception on error.
  def close
    err = LibPortMIDI.close_stream(@stream)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error closing stream #{@stream}")
    end
  end

  # Returns `true` if the stream has a pending host error.
  #
  # The PortMidi docs note that normally you won't have to call this method.
  def host_error? : Bool
    LibPortMIDI.host_error?(@stream) != 0
  end

  # Synchronizes the stream. Raises an exception on error.
  def synchronize
    err = LibPortMIDI.synchronize(@stream)
    if err != LibPortMIDI::PmError::NoError
      exception_raise(err, "error synchronizing stream #{@stream}")
    end
  end
end
