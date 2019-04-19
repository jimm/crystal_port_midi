require "./spec_helper"

class TestInputStream < InputStream
  getter first_event : LibPortMIDI::Event
  getter num_events

  def initialize
    @stream = uninitialized LibPortMIDI::Stream
    @first_event = uninitialized LibPortMIDI::Event
    @num_events = -1
  end

  def read(buffer : Pointer(LibPortMIDI::Event), length : Int32) : Int32
    @first_event = buffer.value
    @num_events = length
  end
end

describe InputStream do
  it "converts array to pointer and length" do
    event = LibPortMIDI::Event.new(message: 0xdeadbeef)
    buffer = [event]
    istream = TestInputStream.new
    istream.read(buffer)

    istream.first_event.message.should eq(0xdeadbeef)
    istream.num_events.should eq(1)
  end

  it "throws an error given a bad input device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening input device -1") do
      InputStream.open(-1)
    end
  end
end
