require "./spec_helper"
require "../src/output_stream"

describe OutputStream do
  it "throws an error given a bad output device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening output device -1") do
      OutputStream.open(-1)
    end
  end
end
