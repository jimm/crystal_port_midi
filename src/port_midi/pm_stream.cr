require "./port_midi"

class PMStream
  getter :stream

  def initialize(@stream : LibPortMIDI::Stream)
  end

  def close
    err = LibPortMIDI.close_stream(@stream)
    if err != LibPortMIDI::PmError::NoError
      PortMIDI.raise_error(err, "error closing stream #{@stream}")
    end
  end

  def host_error?() : Int32
    LibPortMIDI.host_error?(@stream)
  end

  def synchronize
    err = LibPortMIDI.synchronize(@stream)
    if err != LibPortMIDI::PmError::NoError
      exception_raise(err, "error synchronizing stream #{@stream}")
    end
  end
end
