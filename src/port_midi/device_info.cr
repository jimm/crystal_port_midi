require "./lib_port_midi"

# A wrapper around a `LibPortMIDI::DeviceInfo` struct. Consider instances to
# be snapshots, because their instance variables do not change over time. For
# example, the value of `#opened?` will not change when the corresponding
# device is opened.
#
# To get a fresh instance call `PortMIDI#get_device_info`.
class DeviceInfo
  getter :version, :interface, :name

  def initialize(di : LibPortMIDI::DeviceInfo)
    @version = di.struct_version.as(Int32)
    @interface = String.new(di.interf)
    @name = String.new(di.name)
    @is_input = (di.input == 1).as(Bool)
    @is_output = (di.output == 1).as(Bool)
    @is_opened = (di.opened == 0).as(Bool)
  end

  # Returns `true` if this is an input device.
  def input?; @is_input; end

  # Returns `true` if this is an output device.
  def output?; @is_output; end

  # Returns `true` if this device is opened. As noted in the class comment,
  # this is a snapshot: the value will not change when the device is opened
  # or closed.
  def opened?; @is_opened; end
end
