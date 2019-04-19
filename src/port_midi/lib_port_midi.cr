@[Link("portmidi")]

# These are the C bindings to the PortMidi library. See PortMidi's
# portmidi.h header file for the documenation of the PortMidi C library.
lib LibPortMIDI
  @[Flags]
  enum Filter
    Sysex
    MTC # MIDI time code
    SongPosition
    SongSelect
    Unused1
    Unused2
    TuneRequest
    Unused3
    Clock
    Tick
    Play              = ((1 << 0x0A) | (1 << 0x0C) | (1 << 0x0B))
    UndefinedRealtime = (1 << 0x0D)
    ActiveSensing
    Reset
    Note              = ((1 << 0x19) | (1 << 0x18))
    PolyAftertouch    = (1 << 0x1A)
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
    NoError         =      0
    NoData          =      0   # A "no error" return that also indicates no data avail.
    GotData         =      1,  # A "no error" return that also indicates data available
HostError       = -10000
    InvalidDeviceId,  # out of range or
    # output device when input is requested or
    # input device when output is requested or
    # device is already opened
InsufficientMemory,
    BufferTooSmall,
    BufferOverflow,
    BadPtr,  # PortMidiStream parameter is NULL or
    # stream is not opened or
    # stream is output when input is required or
    # stream is input when output is required
BadData,  # illegal midi data, e.g. missing EOX
InternalError,
    BufferMaxSize # buffer is already as large as it can be
  end

  type PmTimestamp = UInt32

  # The device information returned by PortMidi.
  struct DeviceInfo
    struct_version : Int32 # internal
    interf : UInt8*        # underlying MIDI API
    name : UInt8*          # device name
    input : Int32          # true iff input is available
    output : Int32         # true iff output is available
    opened : Int32         # used by generic MidiPort code
  end

  # A single MIDI event sent/received by PortMidi.
  struct Event
    message : UInt32
    timestamp : PmTimestamp
  end

  type Stream = Pointer(Void)

  fun initialize = Pm_Initialize : PmError

  fun terminate = Pm_Terminate : PmError

  fun host_error? = Pm_HasHostError(stream : Stream) : Int32

  fun get_error_text = Pm_GetErrorText(errnum : PmError) : UInt8*

  fun count_devices = Pm_CountDevices : Int32

  fun get_default_input_device_id = Pm_GetDefaultInputDeviceID : Int32

  fun get_default_output_device_id = Pm_GetDefaultOutputDeviceID : Int32

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
