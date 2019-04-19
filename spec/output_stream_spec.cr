require "./spec_helper"

class TestOutputStream < OutputStream
  getter first_event : LibPortMIDI::Event
  getter num_events

  def initialize
    @stream = uninitialized LibPortMIDI::Stream
    @first_event = uninitialized LibPortMIDI::Event
    @num_events = -1
  end

  def write(buffer : Pointer(LibPortMIDI::Event), length : Int32) : Int32
    @first_event = buffer.value
    @num_events = length
  end
end

describe OutputStream do
  it "converts array to pointer and length" do
    event = LibPortMIDI::Event.new(message: 0xdeadbeef)
    buffer = [event]
    ostream = TestOutputStream.new
    ostream.write(buffer)

    ostream.first_event.message.should eq(0xdeadbeef)
    ostream.num_events.should eq(1)
  end

  it "throws an error given a bad output device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening output device -1") do
      OutputStream.open(-1)
    end
  end
end
