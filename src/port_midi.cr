require "./lib_port_midi"
# see also the requires at the end of this file

module PortMIDI
  VERSION = "0.1.0"

  class HostError < Exception; end
  class InvalidDeviceId < Exception; end
  class InsufficientMemory < Exception; end
  class BufferTooSmall < Exception; end
  class BufferOverflow < Exception; end
  class BadPtr < Exception; end
  class BadData < Exception; end
  class InternalError < Exception; end
  class BufferMaxSize < Exception; end

  def self.exception_from_error(err : LibPortMIDI::PmError, msg : String)
    case err
    when LibPortMIDI::PmError::HostError
      raise HostError.new(msg)
    when LibPortMIDI::PmError::InvalidDeviceId
      raise InvalidDeviceId.new(msg)
    when LibPortMIDI::PmError::InsufficientMemory
      raise InsufficientMemory.new(msg)
    when LibPortMIDI::PmError::BufferTooSmall
      raise BufferTooSmall.new(msg)
    when LibPortMIDI::PmError::BufferOverflow
      raise BufferOverflow.new(msg)
    when LibPortMIDI::PmError::BadPtr
      raise BadPtr.new(msg)
    when LibPortMIDI::PmError::BadData
      raise BadData.new(msg)
    when LibPortMIDI::PmError::InternalError
      raise InternalError.new(msg)
    when LibPortMIDI::PmError::BufferMaxSize
      raise BufferMaxSize.new(msg)
    else
      raise Exception.new(msg)
    end
  end

  def self.init
    LibPortMIDI.initialize()
  end

  def self.terminate
    LibPortMIDI.terminate()
  end

  def self.get_error_text(errnum : PmError) : UInt8*
      LibPortMIDI.get_error_text(errnum)
  end

  def self.count_devices() : Int32
    LibPortMIDI.count_devices()
  end

  def self.get_default_input_device_id() : Int32
    LibPortMIDI.get_default_input_device_id()
  end

  def self.get_default_output_device_id() : Int32
    LibPortMIDI.get_default_output_device_id()
  end

  def self.get_device_info(device_id : Int32) : DeviceInfo
      LibPortMIDI.get_device_info(device_id).value
  end

  # Creates a PortMidi message from three MIDI bytes.
  def self.message(status, data1, data2) : UInt32
    ((((data2.to_u32) << 16) & 0xFF0000_u32) |
     (((data1.to_u32) << 8) & 0xFF00_u32) |
     ((status.to_u32) & 0xFF_u32))
  end

  # Extracts the status byte from a PortMidi *message*.
  def self.status(message : UInt32) : UInt8
    (message & 0xff).to_u8
  end

  # Extracts the first data byte from a PortMidi *message*.
  def self.data1(message : UInt32) : UInt8
    ((message >> 8) & 0xff).to_u8
  end

  # Extracts the second data byte from a PortMidi *message*.
  def self.data2(message : UInt32) : UInt8
    ((message >> 16) & 0xff).to_u8
  end

  # Returns an array of the four bytes contained in a PortMidi *event*.
  def self.bytes(event : LibPortMIDI::Event) : StaticArray(UInt8, 4)
    bytes(event.message)
  end

  # Returns an array of the four bytes contained in a PortMidi *message*.
  def self.bytes(message : UInt32) : StaticArray(UInt8, 4)
    buf = uninitialized UInt8[4]
    buf[0] = (message & 0xff).to_u8
    buf[1] = ((message >> 8) & 0xff).to_u8
    buf[2] = ((message >> 16) & 0xff).to_u8
    buf[3] = ((message >> 24) & 0xff).to_u8
    buf
  end

  # Lists all MIDI inputs and outputs, along with the port numbers that need
  # to be passed to `LibPortMIDI`.
  def self.list_all_devices
    num_devices = LibPortMIDI.count_devices
    inputs = {} of Int32 => LibPortMIDI::DeviceInfo
    outputs = {} of Int32 => LibPortMIDI::DeviceInfo
    (0...num_devices).each do |i|
      device = LibPortMIDI.get_device_info(i).value
      inputs[i] = device if device.input != 0
      outputs[i] = device if device.output != 0
    end
    list_devices("Inputs", inputs)
    list_devices("Outputs", outputs)
  end

  # Prints the list of all *devices* of the type described by *title*.
  private def self.list_devices(title : String,
                                devices : Hash(Int32, LibPortMIDI::DeviceInfo))
    puts title
    devices.each do |index, dev|
      puts "  #{index}: #{String.new(dev.name)}#{dev.opened == 1 ? " (open)" : ""}"
    end
  end
end

require "./input_stream"
require "./output_stream"
require "./simple_midi_device"
