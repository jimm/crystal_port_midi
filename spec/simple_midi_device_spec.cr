require "./spec_helper"

describe SimpleMIDIDevice do
  it ".open raises an error given a bad device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening input device -1") do
      SimpleMIDIDevice.open(-1, -1)
    end
  end
end
