require "./lib_port_midi"

# A wrapper around a `LibPortMIDI::DeviceInfo` struct. Consider instances to
# be value objects because their instance variables do not change over time.
# For example, the value of `:opened?` will not change when the
# corresponding device is opened.
#
# To get a fresh instance call `PortMIDI#get_device_info`.
class DeviceInfo
  getter :version, :interface, :name, :is_input, :is_output, :is_opened

  def initialize(di : LibPortMIDI::DeviceInfo)
    @version = di.struct_version.as(Int32)
    @interface = String.new(di.interf)
    @name = String.new(di.name)
    @is_input = (di.input == 1).as(Bool)
    @is_output = (di.output == 1).as(Bool)
    @is_opened = (di.opened == 0).as(Bool)
  end

  def input?; @is_input; end
  def output?; @is_output; end
  def opened?; @is_opened; end
end
