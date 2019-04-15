@[Link("portmidi")]

# These are the bindings to the PortMidi library. See the portmidi.h header
# file for the documenation of the PortMidi C library.
#
# See also class PortMIDI below.
lib LibPortMIDI
  @[Flags]
  enum Filter
    Sysex
    MTC                         # MIDI time code
    SongPosition
    SongSelect
    Unused1
    Unused2
    TuneRequest
    Unused3
    Clock
    Tick
    Play = ((1 << 0x0A) | (1 << 0x0C) | (1 << 0x0B))
    UndefinedRealtime = (1 << 0x0D)
    ActiveSensing
    Reset
    Note = ((1 << 0x19) | (1 << 0x18))
    PolyAftertouch = (1 << 0x1A)
    ControlChange
    ProgramChange
    ChannelAftertouch
    PitchBend

    # Returns a flag representing all realtime messages.
    def realtime
      ActiveSensing | Sysex | Clock | Play | UndefinedRealtime | Reset | Tick
    end

    # Returns a flag representing both channel and poly aftertouch.
    def aftertouch
      ChannelAftertouch | PolyAftertouch
    end

    # Returns a flag representing all System Common messages.
    def system_common
      MTC | SongPosition | SongSelect | TuneRequest
    end
  end

  # The error values returned by PortMidi.
  enum PmError : Int32
    NoError = 0
    NoData = 0    # A "no error" return that also indicates no data avail.
    GotData = 1,  # A "no error" return that also indicates data available
    HostError = -10000
    InvalidDeviceId,            # out of range or
                                # output device when input is requested or
                                # input device when output is requested or
                                # device is already opened
    InsufficientMemory,
    BufferTooSmall,
    BufferOverflow,
    BadPtr,                     # PortMidiStream parameter is NULL or
                                # stream is not opened or
                                # stream is output when input is required or
                                # stream is input when output is required
    BadData,                    # illegal midi data, e.g. missing EOX
    InternalError,
    BufferMaxSize               # buffer is already as large as it can be
  end

  type PmTimestamp = UInt32

  # The device information returned by PortMidi.
  struct DeviceInfo
    struct_version : Int32      # internal
    interf : UInt8 *            # underlying MIDI API
    name : UInt8 *              # device name
    input : Int32               # true iff input is available
    output : Int32              # true iff output is available
    opened : Int32              # used by generic MidiPort code
  end

  # A single MIDI event sent/received by PortMidi.
  struct Event
    message : UInt32
    timestamp : PmTimestamp
  end

  type Stream = Pointer(Void)

  fun initialize = Pm_Initialize() : PmError

  fun terminate = Pm_Terminate() : PmError

  fun host_error? = Pm_HasHostError(stream : Stream) : Int32

  fun get_error_text = Pm_GetErrorText(errnum : PmError) : UInt8*

  fun count_devices = Pm_CountDevices() : Int32

  fun get_default_input_device_id = Pm_GetDefaultInputDeviceID() : Int32

  fun get_default_output_device_id = Pm_GetDefaultOutputDeviceID() : Int32

  fun get_device_info = Pm_GetDeviceInfo(device_id : Int32) : DeviceInfo*

  fun open_input = Pm_OpenInput(stream : Stream*, input_device : Int32, input_driver_info : Int32*,
                                buffer_size : Int32, time_proc : Void* -> PmTimestamp,
                                time_info : Void* -> PmTimestamp) : PmError

  fun open_output = Pm_OpenOutput(stream : Stream*, output_device : Int32, output_driver_info : Int32*,
                                  buffer_size : Int32, time_proc : Void* -> PmTimestamp,
                                  time_info : Void* -> PmTimestamp,
                                  latency : Int32) : PmError

  fun set_filter = Pm_SetFilter(stream : Stream, filters_bitmask : UInt32) : PmError

  fun set_channel_mask = Pm_SetChannelMask(stream : Stream, bitmask : UInt32) : PmError

  fun abort_write = Pm_Abort(stream : Stream) : PmError

  fun close_stream = Pm_Close(stream : Stream) : PmError

  fun synchronize = Pm_Synchronize(stream : Stream) : PmError

  fun midi_read = Pm_Read(stream : Stream, buffer : Pointer(Event), length : Int32) : Int32

  fun poll = Pm_Poll(stream : Stream) : PmError

  fun midi_write = Pm_Write(stream : Stream, buffer : Event*, length : Int32) : PmError

  fun midi_write_short = Pm_WriteShort(stream : Stream, when_tstamp : Int32, msg : UInt32) : PmError

  fun midi_write_sysex = Pm_WriteSysEx(stream : Stream, when_tstamp : Int32, msg : UInt8*) : PmError
end

# Some functions useful when manipulating MIDI data and PortMidi messages.
module PortMIDI
  VERSION = "0.1.0"

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

  # This convenience function opens the PortMIDI streams for
  # *input_device_num* and *output_device_num* and returns them as a tuple.
  # Along the way, it checks for errors and prints error messages. If
  # *exit_on_error* is `true` (the default), calls `exit(1)` instead of
  # returning.
  def self.open_portmidi_streams(input_device_num, output_device_num, exit_on_error=true)
    err_happened = false
    input = uninitialized LibPortMIDI::Stream
    output = uninitialized LibPortMIDI::Stream
    err = LibPortMIDI.open_input(pointerof(input), input_device_num, nil, 1024, nil, nil)
    if err != LibPortMIDI::PmError::NoError
      err_happened = true
      STDERR.puts("error opening input port: #{err}")
    end
    err = LibPortMIDI.open_output(pointerof(output), output_device_num, nil, 1024, nil, nil, 0)
    if err != LibPortMIDI::PmError::NoError
      err_happened = true
      STDERR.puts("error opening output port: #{err}")
    end
    exit(1) if err_happened && exit_on_error

    {input, output}
  end
end
