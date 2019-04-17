require "./spec_helper"
require "../src/input_stream"

describe InputStream do
  it "throws an error given a bad input device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening input device -1") do
      InputStream.open(-1)
    end
  end
end
